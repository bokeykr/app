import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class BBSPage extends StatefulWidget {
  final String grp;
  const BBSPage({super.key, required this.grp});

  @override
  State<BBSPage> createState() => _BBSPageState();
}

class _BBSPageState extends State<BBSPage> {
  late List<BBS> bbs;
  String lastNo = "";
  bool bReady = false;
  bool bMore = false;
  @override
  void initState() {
    super.initState();
    getBBS("");
  }

  getBBS(no) async {
    const int bbsCnt = 10;
    var r = await http.post(Uri.parse("https://honmall.net/q.php"),
        body: {'mode': 'hmbbs', 'no': no, 'grp': widget.grp, 'cnt': '$bbsCnt'});
    try {
      List<BBS> cbbs = (json.decode(r.body) as List)
          .map((data) => BBS.fromJson(data))
          .toList();
      if (no == "") bbs = [];
      bbs.addAll(cbbs);
      lastNo = bbs.last.no;
      bMore = cbbs.length == bbsCnt;
    } catch (e) {
      dPrint(e.toString());
    }
    dPrint(bbs.toString());
    setState(() {
      bReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    double sw = min(sz.width, 600.0);

    return Scaffold(
        appBar: AppBar(title: const Text("혼몰 Note")),
        body: (!bReady)
            ? const Center(child: CircularProgressIndicator())
            : Container(
                alignment: Alignment.topCenter,
                child: SizedBox(
                    width: sw,
                    child: RefreshIndicator(
                      color: Colors.white,
                      backgroundColor: Colors.blue,
                      strokeWidth: 4.0,
                      onRefresh: () async {
                        // Replace this delay with the code to be executed during refresh
                        // and return a Future when code finishes execution.
                        await getBBS("");
                        //setState(() {});

                        //return Future<void>.delayed(const Duration(seconds: 3));
                      },
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (ctx, ndx) {
                            if (ndx == bbs.length) {
                              return ElevatedButton(
                                  onPressed: () async {
                                    bMore = false;
                                    await getBBS(lastNo);
                                  },
                                  child: const Text("더보기"));
                            }
                            return Card(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.album),
                                  title: Text(bbs[ndx].subj),
                                  subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('노트 No.${bbs[ndx].no}'),
                                        Text(bbs[ndx].dt)
                                      ]),
                                ),
                                if (bbs[ndx].cont != "")
                                  Container(
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        bbs[ndx].cont,
                                        textAlign: TextAlign.left,
                                      )),
                                if (bbs[ndx].img != "")
                                  CachedNetworkImage(
                                    imageUrl: bbs[ndx].img,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: sw,
                                      height: sw,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                /*
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton(
                                      child: const Text('BUY TICKETS'),
                                      onPressed: () {/* ... */},
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      child: const Text('LISTEN'),
                                      onPressed: () {/* ... */},
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ), */
                              ],
                            ));
                          },
                          separatorBuilder: (ctx, ndx) {
                            return const SizedBox(height: 8);
                          },
                          itemCount: bbs.length + (bMore ? 1 : 0)),
                    ))));
  }
}

class BBS {
  final String no, img, subj, cont;
  final String dt;
  BBS(
      {required this.no,
      required this.dt,
      required this.img,
      required this.subj,
      required this.cont});

  factory BBS.fromJson(Map<String, dynamic> json) {
    return BBS(
        no: json['no'] ?? "",
        dt: json['dt'] ?? "",
        img: json['img'] ?? "",
        subj: json['subj'] ?? "",
        cont: json['cont'] ?? "");
  }
}
