import 'dart:convert';
import 'dart:math';
import 'package:app/scroll.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'dart:async';
import 'account.dart';
import 'bbs.dart';
import 'config.dart';
import 'deal.dart';
import 'lib_manse.dart';
import 'lib_spread.dart';
import 'login.dart';
import 'ready.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'review.dart';
import 'rview.dart';
import 'today.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WebViewPlatform.instance = WebWebViewPlatform();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '5aa7bf8bc8ca12022ac45f67ce9dd5bc',
    javaScriptAppKey: 'd9c883807ce91f7d2cdf2f9f0ba37b49',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: '혼몰',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '혼몰'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  doLogin() async {
    var prefs = await _prefs;
    String id = prefs.getString('id') ?? "";
    if (id == "") {
      var r = await http.post(getUrl(), body: {"mode": "signup"});
      dPrint(r.body);
      if (r.statusCode == 200) {
        id = r.body;
        await prefs.setString("id", id);
      }
    }
    dPrint('id: $id');
    setState(() {
      myid = id;
    });

    return id;
  }

  checkLogin(bForce) async {
    var prefs = await _prefs;
    var id = prefs.getString('id') ?? "";
    if (id.isNotEmpty) {
      var r = await http.post(getUrl(), body: {"mode": "signin", 'id': id});
      dPrint(r.body);
      if (r.statusCode == 200) {
        if (r.body.isEmpty) {
          myid = "";
        } else {
          var j = jsonDecode(r.body);
          myid = j['id'];
        }
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //String c =
    //final String base58Value = hexadecimalToBase58Converter('415a59758fb');
    // base58Value == '6xZA4Qt9vH7rePWeT5WLaVUZNjB6u6rGc'

    checkLogin(false);
    //doLogin();
/*
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
// #docregion CanAccessScopes
      // In mobile, being authenticated means being authorized...
      bool isAuthorized = account != null;
      // However, on web...
      if (kIsWeb && account != null) {
        isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      }
// #enddocregion CanAccessScopes

      setState(() {
        _currentUser = account;
        _isAuthorized = isAuthorized;
      });

      // Now that we know that the user can access the required scopes, the app
      // can call the REST API.
      if (isAuthorized) {
        unawaited(_handleGetContact(account!));
      }
    });

    // In the web, _googleSignIn.signInSilently() triggers the One Tap UX.
    //
    // It is recommended by Google Identity Services to render both the One Tap UX
    // and the Google Sign In button together to "reduce friction and improve
    // sign-in rates" ([docs](https://developers.google.com/identity/gsi/web/guides/display-button#html)).
    _googleSignIn.signInSilently();
    //_googleSignIn.signIn();
    */
  }

  deal(String title, int mode, int m, int n) async {
    //await Share.share("klshjdklfsdf");
    var r0 = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReadyPage(title: title)),
    );
    if (r0 == null) return;
    if (!mounted) return;
    var r1 = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(mj: true, cnt: m)),
    );
    if (r1 == null) return;
    dPrint("mj $r1");
    if (!mounted) return;
    if (n > 0) {
      var r2 = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GamePage(mj: false, cnt: n)),
      );
      dPrint("mn $r2");
      r1.addAll(r2);
    }
    if (r1 == null) return;
    if (!mounted) return;
    dPrint(r1.join(','));
    var rr = await http.post(Uri.parse('https://honmall.net/q.php'), body: {
      'mode': 'hmtarot',
      'pmode': '$mode',
      'pm': '$m',
      'pn': '$n',
      'pv': r1.join(',')
    });
    dPrint("${rr.body}, ${rr.statusCode}");
    if (rr.statusCode != 200) return;
    String no = rr.body;
    if (no == "-1") {
      dPrint("오류가 발생하였습니다.");
      return;
    }
    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RViewPage(title: title, no: no)));
    //var url = Uri.parse("https://honmall.net/rview.php?no=$no");
    //await launchUrl(url);

    /*
    if (mode == 2) {
      await launchUrl(Uri.parse("https://honmall.net/res.php?no=$no"));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ResPage(no: no)));
    }
    */
  }

  Future<List<BBS>> getNote() async {
    var r = await http
        .post(Uri.parse('https://honmall.net/q.php'), body: {'mode': 'note'});
    List<BBS> rbbs = (json.decode(r.body) as List)
        .map((data) => BBS.fromJson(data))
        .toList();
    //dPrint(rbbs);
    return rbbs;
  }

  Future<CHdb> getConfig() async {
    var r = await http.post(Uri.parse('https://honmall.net/q.php'),
        body: {'mode': 'hmconfig'});
    return jsonDecode(r.body);
  }

  final int _selectedIndex = 0;
  _onItemTapped(ndx) async {
    if (ndx == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => widget));
    } else if (ndx == 1) {
      await launchUrl(Uri.parse("http://pf.kakao.com/_Gaxexlj/chat"));
    } else if (ndx == 2) {
      if (myid.isEmpty) {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => const LoginPage()));
        if (mounted) {
          setState(() {});
        }
      } else {
        var r = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AccountPage()));
        if (r != null) {
          if (r == 0) {
            var prefs = await _prefs;
            await prefs.setString("id", "");
            myid = "";
          }
        }
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Future getIljin() async {
    var now = DateTime.now();
    var now2 = now.add(const Duration(minutes: 32));
    var tdt = DateFormat('yyyyMMdd').format(now2);
    //var hh = now2.hour / 2;
    var r = await http.post(Uri.parse('https://honmall.net/q.php'),
        body: {'mode': 'now', 'dt': '0', 'bd': tdt});
    //dPrint(r.body);
    return jsonDecode(r.body);
    //var rec = CHdb.fromJson(j, hh.toInt());
    //return rec;
  }

  setBoard(data, dt, sw) {
    //final String rt = data['conf']['rt'] ?? 1;
    //var img_rt = double.parse(rt);
    var rec = data['note'];
    var now = DateTime.now();
    var now2 = now.add(const Duration(minutes: 32));
    //var tdt = DateFormat('yyyyMMdd').format(now2);
    var hh = now2.hour / 2;
    var j = CHdb.fromJson(data['now'], hh.toInt());
    List<BBS> rbbs = (rec as List).map((data) => BBS.fromJson(data)).toList();
    //dPrint(rec);
    //return Text(img);
    var ldt = j.lunDate();
    return Column(children: [
      Container(
          alignment: Alignment.center,
          child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              width: sw,
              decoration: const BoxDecoration(
                  color: Color(0xffedede9),
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "현재시각(Seoul)",
                        //style: TextStyle(color: Colors.white),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("새로고침"),
                        onPressed: () {
                          setState(() {});
                        },
                      )
                    ]),
                Text("양력: $dt"),
                Column(children: [
                  Text(ldt),
                  Text(
                    "${msGan[j.tndx % 10]}${msGan[j.dndx % 10]}${msGan[j.mndx % 10]}${msGan[j.yndx % 10]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${msJi[j.tndx % 12]}${msJi[j.dndx % 12]}${msJi[j.mndx % 12]}${msJi[j.yndx % 12]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  color: const Color(0xffd6ccc2),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (c, n) {
                      if (n == rbbs.length) {
                        return const Text("... More");
                      }
                      return Row(children: [
                        Text(rbbs[n].subj),
                        Text(rbbs[n].dt,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                                color: Colors.grey))
                      ]);
                    },
                    separatorBuilder: (c, n) {
                      return const SizedBox(height: 4);
                    },
                    itemCount: rbbs.length + 1),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_right_alt,
                      color: Color(0xff343a40)),
                  label: const Text("혼몰 노트",
                      style: TextStyle(color: Color(0xff9a8c98))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BBSPage(grp: "0")));
                  },
                )
              ])))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    double sw = min(sz.width, 600.0);

    var dt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(centerTitle: true, title: const Text('혼몰')),
      body: SingleChildScrollView(
          child: Container(
              width: sz.width,
              color: Colors.pink[50],
              alignment: Alignment.center,
              child: Container(
                  color: Colors.white,
                  width: sw,
                  child: Column(children: [
                    FutureBuilder(
                        future: getIljin(),
                        builder: (ctx, shot) {
                          if (!shot.hasData) {
                            return const CircularProgressIndicator();
                          } else if (shot.hasError) {
                            return Text("error: ${shot.error}");
                          } else {
                            return setBoard(shot.data, dt, sw);
                          }
                        }),
                    InkWell(
                      child: Container(
                        width: sw,
                        height: sw,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/imgs/wiz.png'))),
                      ),
                      onTap: () {
                        launchUrl(Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.wizsome.tarot'));
                      },
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          width: sw,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: Column(children: [
                            const Text('오늘은 어떤일이 생길까요?\n오늘의 운세를 점쳐보세요.'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.arrow_right_alt,
                                      color: Color(0xff343a40)),
                                  label: const Text(
                                    "오늘의 타로",
                                    style: TextStyle(color: Color(0xff9a8c98)),
                                  ),
                                  onPressed: () async {
                                    //var r = await deal('오늘의 운세', 14, 1, 0);
                                    //dPrint("res: $r");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TodayPage()));
                                  },
                                ),
                              ],
                            )
                          ])),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          width: sw,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                              color: const Color(0xfff5ebe0),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: Column(children: [
                            const Text(
                                '소원이 있으신가요?\n타로는 언제나 님의 소원을 해결할 준비가 되어있습니다.'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.arrow_right_alt,
                                      color: Color(0xff343a40)),
                                  label: const Text(
                                    "무료 타로카드",
                                    style: TextStyle(color: Color(0xff9a8c98)),
                                  ),
                                  onPressed: () async {
                                    var r = await deal('무료 타로카드', 13, 2, 3);
                                    dPrint("res: $r");
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.arrow_right_alt,
                                      color: Color(0xff343a40)),
                                  label: const Text(
                                    "타로 후기",
                                    style: TextStyle(color: Color(0xff9a8c98)),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ReviewPage()));
                                  },
                                )
                              ],
                            )
                          ])),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(8),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          width: sw,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: Column(children: [
                            const Text(
                                '전문가의 상담이 필요하신가요?\n혼몰은 언제나 님의 편에서 준비가 되어있습니다.'),
                            TextButton.icon(
                              icon: const Icon(Icons.arrow_right_alt),
                              label: const Text("유료 타로 상담",
                                  style: TextStyle(color: Color(0xff9a8c98))),
                              onPressed: () async {
                                var r = await deal('유료 타로 상담', 2, 5, 5);
                                dPrint("res: $r");
                              },
                            )
                          ])),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(8),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          width: sw,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                              color: const Color(0xfff5ebe0),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: Column(children: [
                            const Text(
                                '사주가, 궁합이 궁굼하신가요?\n시시각각 변하는 운세 중에 당신은 지금 어디일까요?'),
                            TextButton.icon(
                              icon: const Icon(Icons.arrow_right_alt),
                              label: const Text("사주 상담",
                                  style: TextStyle(color: Color(0xff9a8c98))),
                              onPressed: () async {
                                await launchUrl(Uri.parse(
                                    "http://pf.kakao.com/_Gaxexlj/chat"));
                              },
                            )
                          ])),
                    ),
                    /*
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(8),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          width: sw,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                              color: const Color(0xfff5ebe0),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: Column(children: [
                            TextButton.icon(
                              icon: const Icon(Icons.arrow_right_alt),
                              label: const Text("만세력",
                                  style: TextStyle(color: Color(0xff9a8c98))),
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MSViewPage(no: -1)));
                              },
                            )
                          ])),
                    ),
                    */
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          width: sw,
                          child: const Text("직접 펼치고 해석하는 타로 스프레드")),
                    ),
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        width: sw,
                        child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (ctx, ndx) {
                              return InkWell(
                                child: Container(
                                    padding: const EdgeInsets.all(8),
                                    width: sw,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffedede9),
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                            color: const Color(0xffe3d5ca),
                                            padding: const EdgeInsets.all(8),
                                            child: Image.asset(
                                              'assets/spread/$ndx.png',
                                              width: 80,
                                              color: const Color(0xff9a8c98),
                                            )),
                                        const SizedBox(width: 24),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //Image.asset('spread/$ndx.png'),

                                            Text(vlist[ndx][0],
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const Divider(),
                                            Text(vlist[ndx][1]),
                                          ],
                                        ))
                                      ],
                                    )),
                                onTap: () async {
                                  var r = await deal('스프레드', 1000 + ndx,
                                      dlist[ndx][0], dlist[ndx][1]);
                                  dPrint("res: $r");
                                },
                              );
                            },
                            separatorBuilder: (ctx, ndx) {
                              return const SizedBox(height: 4);
                            },
                            itemCount: dlist.length)),
                  ])))),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: '새로고침',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '상담/고객센터',
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: myid.isEmpty ? '로그인' : '계정'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
