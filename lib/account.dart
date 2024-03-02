import 'dart:math';

import 'package:flutter/material.dart';

import 'config.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    var sz = MediaQuery.of(context).size;
    double sw = min(sz.width, 600.0);

    return Scaffold(
      appBar: AppBar(title: const Text('계정')),
      body: Container(
          alignment: Alignment.topCenter,
          child: Container(
              width: sw,
              padding: const EdgeInsets.all(8),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text("ID"),
                    const SizedBox(width: 8),
                    Text(myid,
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ]),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(0);
                      },
                      child: const Text("로그아웃"))
                ],
              ))),
    );
  }
}
