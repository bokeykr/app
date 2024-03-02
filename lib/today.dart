import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  var cardsk = ['금전운', '연애운', '사업운', '학업운'];
  var cards = [
    '새로움이 찾아온다.|좋음',
    '방심은 금물|주의',
    '편안하고 순조로운 날이다.|좋음',
    '실망주의! 눈앞의 결과에 연연하지 마라.|주의',
    '앞으로 나아가기보다 지난일을 정리하기 좋은 날|보통',
    '이불킥 주의! 남의 눈에 띄지않게 행동하라.|주의',
    '기회는 이때, 원하는 일에 도전하라|좋음',
    '힘으로 흥한자 힘으로 망하리라.|매우 나쁨',
    '원하는 대로, 바라는 대로|매우 좋음',
    '지나치면 부족함만 못하다.|주의',
    '작은일에 연연하지 마라.|보통',
    '뿌린대로 거두리라.|좋음',
    '행운이 가득하리라.|매우 좋음',
    '엄청난 기회가 온다.|매우 좋음'
  ];
  late int c, k, n;
  late List<String> p;
  bool bReady = false;
  @override
  void initState() {
    super.initState();
    c = Random().nextInt(56);
    k = c ~/ 14;
    n = c % 14;
    p = cards[n].split('|');

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        bReady = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    double sw = min(sz.width, 600.0);
    return Scaffold(
        appBar: AppBar(title: const Text('오늘의 타로')),
        body: (!bReady)
            ? Container(
                alignment: Alignment.center,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: sw / 4,
                          height: sw / 4,
                          child: const LoadingIndicator(
                            indicatorType: Indicator.orbit,
                            strokeWidth: 4.0,
                          )),
                      const Text("오늘의 타로를 선택중입니다.")
                    ]))
            : Container(
                alignment: Alignment.topCenter,
                child: Container(
                    width: sw,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/imgs/today.jpg'),
                          fit: BoxFit.cover),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: 80),
                      Image.asset('assets/images/mars/$c.jpg')
                          .animate(delay: 100.ms)
                          .fade(duration: 500.ms),
                      const SizedBox(height: 8),
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            p[0],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )).animate(delay: 500.ms).fade(duration: 1000.ms),
                      const SizedBox(height: 8),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "${cardsk[k]} ${p[1]}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          )).animate(delay: 1000.ms).fade(duration: 1000.ms),
                    ]))));
  }
}
