import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class RVEditPage extends StatefulWidget {
  final String title;
  final String cont;
  final String no;
  const RVEditPage(
      {super.key, required this.title, required this.cont, required this.no});

  @override
  State<RVEditPage> createState() => _RVEditPageState();
}

class _RVEditPageState extends State<RVEditPage> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller.text = widget.cont;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          TextButton(
              onPressed: () async {
                String txt = _controller.text.trim();
                if (txt.isEmpty) return;
                if (txt == widget.cont) return;
                http.post(getUrl(), body: {
                  "mode": "hmreview_edit",
                  'uid': myid,
                  'no': widget.no,
                  'cont': txt
                }).then((value) {
                  dPrint(value.body);
                  if (value.statusCode == 200) {
                    Navigator.of(context).pop(txt);
                  }
                });
              },
              child: const Text('저장'))
        ]),
        body: Container(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            minLines: 2,
            maxLength: 512,
          ),
        ));
  }
}
