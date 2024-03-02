import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'config.dart';
import 'deal.dart';
import 'res.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
    return MaterialApp(
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
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  deal(String title, int mode, int m, int n) async {
    var r1 = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamePage(mj: true, cnt: m)),
    );
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
    int no = int.parse(rr.body);
    if (no == -1) {
      dPrint("오류가 발생하였습니다.");
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ResPage(no: no)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            "조언을 얻고자 하는 내용에 집중하세요.\n\n마음이 안정되면\n\n아래의 시작버튼을 누르세요.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: () async {
                await deal('유료 타로카드', 2, 5, 5);
              },
              child: const Text("시작"))
        ])));
  }
}
