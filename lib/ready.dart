import 'package:flutter/material.dart';

class ReadyPage extends StatefulWidget {
  final String title;
  const ReadyPage({super.key, required this.title});

  @override
  State<ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends State<ReadyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            "원하는 내용에 집중하세요.\n\n원하는 상황이 뚜렸해지면\n\n아래의 시작버튼을 누르세요.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffedede9),
              ),
              onPressed: () {
                Navigator.of(context).pop(1);
              },
              child: const Text("시작", style: TextStyle(color: Colors.black)))
        ])));
  }
}
