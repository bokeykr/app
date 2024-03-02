import 'dart:async';
import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

import 'config.dart';

class MyGame extends FlameGame with HasGameRef {
  BuildContext context;
  final bool mj;
  final int clen;
  MyGame({required this.context, required this.mj, required this.clen});
  List<int> carr = [];
  final style = TextStyle(color: BasicPalette.white.color);
  //final regular = TextPaint(style: style);
  late TextComponent textComponent;
  void doUpdate() {
    int cnt = clen - carr.length;
    textComponent.text = cnt == 0
        ? ''
        : (cnt == clen)
            ? '${mj ? '메이저 카드 중' : '마이너 카드 중'}\n${clen - carr.length} 장을 선택하세요'
            : '${mj ? '메이저 카드 중' : '마이너 카드 중'}\n${clen - carr.length} 장을 더 선택하세요';
  }

  TextStyle fntStyle = const TextStyle(fontSize: 20, color: Color(0xffe8eddf));

  @override
  Color backgroundColor() => const Color(0xff2d3142);
  @override
  Future<void> onLoad() async {
    super.onLoad();
    //add(AirplaneGameBg());
    {
      //var w = gameRef.size.x;
      var h = gameRef.size.y;
      var rows = mj ? 6 : 9;
      //var cols = mj ? 6 : 8;
      var sh = h / rows;
      //var sw = sh * 80.0 / 155.0;
      textComponent = TextComponent(
        text: '${mj ? '메이저 카드 중' : '마이너 카드 중'}\n${clen - carr.length} 장을 선택하세요',
        textRenderer: TextPaint(
          style: fntStyle,
        ),
        anchor: Anchor.center,
        position: Vector2(gameRef.size.x / 2, sh),
      );
      add(textComponent);
    }

    int cnt = mj ? 22 : 56;
    int cols = mj ? 6 : 8;

    List<int> arr = [];
    for (int i = 0; i < cnt; i++) {
      int n = Random().nextBool() ? 100 : 0;
      arr.add(i + (mj ? 56 : 0) + n);
    }
    arr.shuffle();
    dPrint(arr.toString());
    //var w = gameRef.size.x;
    //var h = gameRef.size.y;
    //var rows = mj ? 6 : 9;
    //var cols = mj ? 6 : 8;
    //var sh = h / rows;
    //var sw = sh * 80.0 / 155.0;
    //sprite = await gameRef.loadSprite('mars/deck.jpg');
    //var size = Vector2(sw * .9, sh * .9);
    //var sx = (w - sw * cols) / 2;

    for (int i = 0; i < cnt; i++) {
      int x = i % cols;
      int y = i ~/ cols;
      if (mj) {
        if (i >= 18) x = x + 1;
      }
      var c = Card(base: this, mj: mj, no: arr[i], tx: x * 1.0, ty: y * 1.0);

      add(c);

      /*
        c
          ..add(
            SizeEffect.to(
              Vector2(sw * .9, sh * .9),
              EffectController(
                duration: 0.2,
                infinite: false,
                curve: Curves.linear,
              ),
            ),
          ),
      );
      */
    }
  }

  /*
  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    dPrint('call tap down');
  }
  */
}

class AirplaneGameBg extends SpriteComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await gameRef.loadSprite('mars/0.jpg');
    size = Vector2(gameRef.size.x, gameRef.size.y);
  }
}

class Card extends SpriteComponent with HasGameRef, TapCallbacks {
  final int no;
  final bool mj;
  final double tx, ty;
  final MyGame base;
  late double sw, sh;
  late Vector2 sz;
  late ColorEffect cfx;
  bool bOpen = false;
  bool bReady = false;
  Card(
      {required this.base,
      required this.mj,
      required this.no,
      required this.tx,
      required this.ty});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    var w = gameRef.size.x;
    var h = gameRef.size.y;
    var rows = mj ? 6 : 9;
    var cols = mj ? 6 : 8;
    sh = h / rows;
    sw = sh * 80.0 / 155.0;
    opacity = 0.0;
    sprite = await gameRef.loadSprite('mars/deck.jpg');

    sz = Vector2(sw * .9, sh * .9);
    size = sz;
    var sx = (w - sw * cols) / 2;
    position = Vector2(sx + tx * sw, (ty + 1.5) * sh);
    Color cardColor = const Color.fromRGBO(183, 139, 225, 1);
    cfx = ColorEffect(
        cardColor,
        EffectController(
          duration: 0.2,
          infinite: false,
          curve: Curves.linear,
        ));
    add(cfx);
    add(OpacityEffect.to(
        1,
        EffectController(
          startDelay: Random().nextDouble() * 1.0,
          duration: 0.2,
          infinite: false,
          curve: Curves.linear,
        ), onComplete: () {
      bReady = true;
    }));
  }

  @override
  void onTapUp(TapUpEvent event) async {
    super.onTapUp(event);
    if (!bReady) return;
    if (bOpen) return;
    if (base.carr.length >= base.clen) return;
    bOpen = true;
    base.carr.add(no);
    add(OpacityEffect.to(
        0,
        EffectController(
          duration: 0.2,
          infinite: false,
          curve: Curves.linear,
        ), onComplete: () async {
      sprite = await gameRef.loadSprite('mars/${no % 100}.jpg');
      add(ColorEffect(
          Colors.transparent,
          opacityFrom: 1,
          opacityTo: 0,
          EffectController(
            duration: 0.2,
            infinite: false,
            curve: Curves.linear,
          )));
      if (no >= 100) {
        anchor = Anchor.bottomRight;
        angle = pi;
      }
      add(OpacityEffect.to(
          1,
          EffectController(
            duration: 0.2,
            infinite: false,
            curve: Curves.linear,
          ), onComplete: () {
        dPrint("tab $no");
        base.doUpdate();
        if (base.carr.length >= base.clen) {
          //Future.delayed(Duration(seconds: 1), () {
          dPrint('game over');
          flutterDialog();
          //Navigator.of(base.context).pop(base.carr);
          //});
        }
      }));
    }));
  }

  flutterDialog() async {
    await showDialog(
        context: base.context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            /*
            title: Column(
              children: <Widget>[
                new Text("Dialog Title"),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Dialog Content",
                ),
              ],
            ),
            */
            actions: <Widget>[
              ElevatedButton(
                child: const Text("다음 단계로 이동"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });

    Navigator.of(base.context).pop(base.carr);
  }
}
