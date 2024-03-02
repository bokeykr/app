import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'config.dart';
import 'lib_spread.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class ResPage extends StatefulWidget {
  //final List<int> arr;
  //final int mcnt, ncnt;
  //final int mode;
  final int no;

  const ResPage({
    super.key,
    required this.no,
  });

  @override
  State<ResPage> createState() => _ResPageState();
}

class _ResPageState extends State<ResPage> {
  late int mode, mcnt, ncnt;
  late var arr;
  late String title;
  late List<int> parr;
  List<int> carr = [];
  late var alen;
  late var blen;
  bool bReady = false;
  bool bError = false;
  checkIt(r) {
    dPrint(r['pmode']);
    mode = int.parse(r['pmode']);
    mcnt = int.parse(r['pm']);
    ncnt = int.parse(r['pn']);
    List<dynamic> data = r['pv'].split(',');
    parr = data.map((v) => int.parse(v)).toList();
    dPrint(parr);
    title = mode >= 1000 ? "스프레드" : (mode == 13 ? "무료 타로카드" : "유료 타로카드");
    if (mode == 13) {
      var narr = [2, 3, 0, 1, 4];
      for (int i = 0; i < narr.length; i++) {
        carr.add(parr[narr[i]]);
      }
    } else {
      carr = parr;
    }
    blen = mode % 1000;
    arr = bArr[blen];
    alen = arr[0];

    dPrint(carr);
    dPrint(bArr[mode % 1000]);

    setState(() {
      bReady = true;
    });
  }

  @override
  void initState() {
    super.initState();

    http.post(Uri.parse("https://honmall.net/q.php"),
        body: {'mode': 'hmres', 'no': '${widget.no}'}).then((r) {
      dPrint(r);
      if (r.statusCode == 200) {
        checkIt(jsonDecode(r.body));
      } else {
        setState(() {
          bError = true;
          bReady = true;
        });
      }
    });
  }

  Widget getCard2(int i, double sw, double sh, {double op = 1.0}) {
    return Stack(children: [
      Opacity(
          opacity: op,
          child: Image.asset('assets/images/mars/${carr[i] % 100}.jpg',
              width: sw * 0.9, height: sh * 0.9)),
      Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.black38, shape: BoxShape.circle),
          child: Text("${i + 1}",
              style: const TextStyle(fontSize: 14, color: Colors.yellow)))
    ]);
  }

  Widget getCard(int i, double sw, double sh) {
    if (mode == 1004) {
      if (i == 1) {
        return Transform.rotate(
            angle: pi / 2, child: getCard2(i, sw, sh, op: 0.9));
      }
    }
    if (carr[i] >= 100) {
      return Transform.rotate(angle: pi, child: getCard2(i, sw, sh));
    }
    return getCard2(i, sw, sh);
  }

  List<Widget> drawCards(double ww) {
    double sh = ww / 5;
    double sw = sh * 80 / 155;
    double sx = (ww - sw * alen[0]) / 2;
    double sy = (ww - sh * alen[1]) / 2;

    List<Widget> lst = [];
    for (int i = 1; i < arr.length; i++) {
      dPrint(carr[i - 1]);
      var a = Positioned(
          left: sx + arr[i][0] * sw + sw * 0.05,
          top: sy + arr[i][1] * sh + sh * 0.05,
          child: getCard(i - 1, sw, sh));

      lst.add(a);
      /*
      var b = Positioned(
          left: sx + arr[i][0] * sw,
          top: sy + arr[i][1] * sh,
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.black38, shape: BoxShape.circle),
              child: Text("$i",
                  style: const TextStyle(fontSize: 14, color: Colors.yellow))));
      lst.add(b);
      */
    }
    var c = const Positioned(
        bottom: 10, right: 10, child: Icon(Icons.zoom_out_map));
    lst.add(c);
    return lst;
  }

  String getName(int n) {
    int c = carr[n];
    int no = c % 100;
    bool rot = c >= 100;
    bool mn = no < 56;
    if (mn) {
      return "마이너 [${rot ? "역방향" : "정방향"}] ${mnArr1[no ~/ 14]} ${mnArr2[no % 14]}";
    }
    return "메이저 [${rot ? "역방향" : "정방향"}] ${mjArr[no - 56][0]} ${mjArr[no - 56][1]}. ${mjArr[no - 56][2]}";
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    double sw = min(sz.width, 600);
    if (!bReady) {
      return const Text("wait");
    }
    if (bError) {
      return const Text("Error");
    }
    return Scaffold(
        appBar: AppBar(title: Text(title), actions: [
          TextButton(
              onPressed: () {
                Share.share('https://honmall.net/res.php?no=${widget.no}',
                    subject: '혼몰 :: $title');
              },
              child: const Text("공유"))
        ]),
        body: SingleChildScrollView(
            child: Container(
                alignment: Alignment.topCenter,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: sw,
                        height: sw,
                        color: Colors.amber,
                        child: Stack(children: drawCards(sw)),
                      ),
                      SizedBox(
                          width: sw,
                          child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              primary: false,
                              padding: const EdgeInsets.all(8),
                              itemBuilder: (ctx, ndx) {
                                if (ndx == 0) {
                                  return Text(
                                    vlist[blen][ndx],
                                    style: const TextStyle(
                                        fontFamily: 'Gaegu', fontSize: 30),
                                    textAlign: TextAlign.center,
                                  );
                                }
                                if (ndx == 1) {
                                  return Text(
                                    vlist[blen][ndx],
                                    style: const TextStyle(
                                        fontFamily: 'Gaegu', fontSize: 18),
                                    textAlign: TextAlign.right,
                                  );
                                }
                                return InkWell(
                                    onTap: () {},
                                    child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "${ndx - 1}. ${vlist[blen][ndx]}\n${getName(ndx - 2)}"),
                                              Icon(Icons.arrow_right_alt,
                                                  color: Colors.primaries.first)
                                            ])));
                              },
                              separatorBuilder: (ctx, n) {
                                return const SizedBox(height: 8);
                              },
                              itemCount: vlist[blen].length))
                    ]))));
  }
}
