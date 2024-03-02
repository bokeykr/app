import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:google_sign_in/google_sign_in.dart';

const List<String> scopes = <String>[
//  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  clientId:
      "103981431252-g3hf75v2o8t905e60172f7n7p97dgq86.apps.googleusercontent.com",
  scopes: scopes,
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool bLoging = false;
  GoogleSignInAccount? _currentUser;
  /*
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    //_contactText = 'Loading contact info...';
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      //_contactText = 'People API gave a ${response.statusCode} response. Check logs for details.';

      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    if (namedContact != null) {
      //_contactText = 'I see you know $namedContact!';
    } else {
      //_contactText = 'No contacts to display.';
    }
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }
*/
  /*
  Future<void> _handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);

    _isAuthorized = isAuthorized;
    if (isAuthorized) {
      unawaited(_handleGetContact(_currentUser!));
    }
  }
  */
  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  doKLogin() async {
    var m = await UserApi.instance.me();
    var id = '${m.id}';
    String email = "";
    String nick = "";
    if (m.kakaoAccount != null) {
      var k = m.kakaoAccount!;
      email = k.email ?? "";
      if (k.profile != null) {
        nick = k.profile!.nickname ?? "";
      }
    }
    doLogin('k', id, email, nick);
  }

  doLogin(sns, id, email, nick) async {
    var r = await http.post(getUrl(), body: {
      "mode": "signup",
      'sns': '$sns$id',
      'email': email,
      'nick': nick
    });
    if (r.statusCode == 200 && mounted) {
      var j = jsonDecode(r.body);
      myid = j['id'];
      var prefs = await _prefs;
      await prefs.setString('id', myid);
      if (mounted) {
        Navigator.of(context).pop(0);
      }
    }
  }

  doGLogin() async {
    if (_currentUser == null) {
      return;
    }

    var id = _currentUser!.id;
    var email = _currentUser!.email;
    var nick = _currentUser!.displayName;
    await doLogin('g', id, email, nick);
  }

  doKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        await doKLogin();
        dPrint('카카오톡으로 로그인 성공');
      } catch (error) {
        dPrint('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          await doKLogin();
          dPrint('카카오계정으로 로그인 성공');
        } catch (error) {
          dPrint('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        await doKLogin();
        dPrint('카카오계정으로 로그인 성공');
      } catch (error) {
        dPrint('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  doGoogle() async {
    // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
    //
    // It is recommended by Google Identity Services to render both the One Tap UX
    // and the Google Sign In button together to "reduce friction and improve
    // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
    await _handleSignOut();
    //await _googleSignIn.signIn();
    //await _googleSignIn.signInSilently();
    GoogleSignInAccount? googleSignInAccount = kIsWeb
        ? await _googleSignIn.signInSilently()
        : await _googleSignIn.signIn();

    if (kIsWeb && googleSignInAccount == null) {
      googleSignInAccount = await _googleSignIn.signIn();
    }
  }

  @override
  void initState() {
    super.initState();
    /*
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      bool isAuthorized = account != null;
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }
      _currentUser = account;
      _isAuthorized = isAuthorized;
      dPrint(account.toString());

      if (isAuthorized) {
        unawaited(_handleGetContact(account!));
      }
      await doGLogin();
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    double sw = min(sz.width, 600.0);

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
          child: (bLoging)
              ? const CircularProgressIndicator()
              : Container(
                  width: sw,
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    TextButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffedede9),
                        ),
                        onPressed: () async {
                          await doKakao();
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'assets/imgs/kakao.png',
                                    width: 64,
                                  )),
                              const SizedBox(width: 16),
                              const Text(
                                "카카오 계정으로 로그인",
                                style: TextStyle(color: Colors.black),
                              ),
                            ])), /*
                const SizedBox(height: 8),
                TextButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffedede9),
                    ),
                    onPressed: () async {
                      doGoogle();
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              child: Image.asset(
                                'assets/imgs/google.png',
                                width: 64,
                              )),
                          const SizedBox(width: 16),
                          const Text(
                            "구글 계정으로 로그인",
                            style: TextStyle(color: Colors.black),
                          )
                        ])) */
                  ]))),
    );
  }
}
