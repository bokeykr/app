import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'mygame.dart';

class GamePage extends StatefulWidget {
  final bool mj;
  final int cnt;
  const GamePage({super.key, required this.mj, required this.cnt});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343a40),
      body: Container(
        color: Colors.white,
        child: GameWidget(
          game: MyGame(
              context: context,
              mj: widget.mj,
              clen: widget.cnt), // 이부분에 게임 인스턴스를 넣어준다.
        ),
      ),
    );
  }
}
