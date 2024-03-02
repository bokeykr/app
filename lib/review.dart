import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'rvedit.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final int _selectedIndex = 0;
  SampleItem? selectedMenu;
  List<CReview> rec = [];
  String lastNo = "";
  bool bMore = false;
  bool bReady = false;
  late FocusNode myFocusNode;
  final TextEditingController _controller = TextEditingController();
  _onItemTapped(ndx) {
    if (ndx == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => widget));
    } else if (ndx == 1) {
      FocusScope.of(context).requestFocus(myFocusNode);
    } else if (ndx == 2) {
      //getRec("");
    }
  }

  getRec(no) async {
    const int bbsCnt = 10;

    var r = await http
        .post(getUrl(), body: {'mode': 'hmreview', 'no': no, 'cnt': '$bbsCnt'});
    try {
      List<CReview> cbbs = (json.decode(r.body) as List)
          .map((data) => CReview.fromJson(data))
          .toList();
      if (no == "") rec = [];
      rec.addAll(cbbs);
      lastNo = rec.last.no;
      bMore = cbbs.length == bbsCnt;
    } catch (e) {
      dPrint(e.toString());
    }
    dPrint(rec.toString());
    setState(() {
      bReady = true;
    });
  }

  @override
  void initState() {
    myFocusNode = FocusNode();
    super.initState();

    getRec("");
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    double sw = min(sz.width, 600.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('타로 후기'),
        actions: [
          TextButton(
              onPressed: () async {
                if (myid.isEmpty) return;
                var txt = _controller.text.trim();
                if (txt.isEmpty) return;
                var r = await http.post(getUrl(),
                    body: {"mode": "hmreview_post", 'id': myid, 'cont': txt});
                dPrint(r.body);
                if (r.statusCode == 200) {
                  _controller.clear();
                  getRec("");
                }
              },
              child: const Text("저장"))
        ],
      ),
      body: (!bReady)
          ? const Center(child: Text("Wait"))
          : Container(
              alignment: Alignment.topCenter,
              child: SizedBox(
                  width: sw,
                  child: CustomScrollView(slivers: [
                    SliverToBoxAdapter(
                        child: Card(
                            color: const Color(0xffedede9),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.album),
                                  title: myid.isEmpty
                                      ? const Text("후기 작성은 로그인 후 이용해주세요")
                                      : Text('ID: @$myid'),
                                  subtitle: myid.isEmpty
                                      ? Container()
                                      : const Text('건강한 리뷰 부탁드려요.'),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                        hintText: '타로 후기를 작성해주세요'),
                                    readOnly: myid.isEmpty,
                                    focusNode: myFocusNode,
                                    controller: _controller,
                                    maxLines: null,
                                    minLines: 2,
                                    maxLength: 512,
                                  ),
                                ),
                              ],
                            ))),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(((ctx, ndx) {
                        if (ndx == rec.length) {
                          return ElevatedButton.icon(
                              onPressed: () async {
                                bMore = false;
                                await getRec(lastNo);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("더보기"));
                        }
                        return Card(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: const Icon(Icons.album),
                              title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ID: ${rec[ndx].uid}'),
                                    MenuAnchor(
                                      builder: (BuildContext context,
                                          MenuController controller,
                                          Widget? child) {
                                        return IconButton(
                                          onPressed: () {
                                            if (myid != rec[ndx].uid) return;
                                            if (controller.isOpen) {
                                              controller.close();
                                            } else {
                                              controller.open();
                                            }
                                          },
                                          icon: const Icon(Icons.more_horiz),
                                        );
                                      },
                                      menuChildren: [
                                        MenuItemButton(
                                            onPressed: () async {
                                              var r = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          RVEditPage(
                                                              title:
                                                                  '후기 No.${rec[ndx].no} 수정',
                                                              cont:
                                                                  rec[ndx].cont,
                                                              no: rec[ndx]
                                                                  .no)));
                                              if (r == null) return;
                                              setState(() {
                                                rec[ndx].cont = r;
                                              });
                                            },
                                            child: const Text('수정')),
                                        MenuItemButton(
                                            onPressed: () async {
                                              var r = await http.post(getUrl(),
                                                  body: {
                                                    "mode": "hmreview_del",
                                                    'uid': myid,
                                                    'no': rec[ndx].no
                                                  });
                                              dPrint(r.body);
                                              if (r.statusCode == 200) {
                                                rec.removeAt(ndx);
                                                setState(() {});
                                              }
                                            },
                                            child: const Text('삭제')),
                                      ],
                                    ),
                                  ]),
                              subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('후기 No.${rec[ndx].no}'),
                                    Text(rec[ndx].dt,
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ]),
                            ),
                            if (rec[ndx].cont != "")
                              Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    rec[ndx].cont,
                                    textAlign: TextAlign.left,
                                  )),
                            /*
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
                                  child: const Text('좋아요'),
                                  onPressed: () {/* ... */},
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  child: const Text('힘내요'),
                                  onPressed: () {/* ... */},
                                ),
                                const SizedBox(width: 8),
                              ],
                            ), */
                          ],
                        ));
                      }), childCount: rec.length + (bMore ? 1 : 0)),
                    )
                  ]))),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: '새로 고침',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '후기 작성',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CReview {
  final String no, uid;
  String cont;
  final String dt;
  CReview(
      {required this.no,
      required this.uid,
      required this.dt,
      required this.cont});

  factory CReview.fromJson(Map<String, dynamic> json) {
    return CReview(
        no: json['no'] ?? "",
        uid: json['uid'] ?? "",
        dt: json['dt'] ?? "",
        cont: json['cont'] ?? "");
  }
}
