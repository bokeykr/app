import 'package:flutter/foundation.dart';

const gameWidth = 820.0;
const gameHeight = 1600.0;
const uhome = 'https://honmall.net/web/';
//const uhome = 'http://192.168.0.7:8080/';
String myid = "";
getUrl() {
  return Uri.parse("https://honmall.net/q.php");
}

//final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

enum SampleItem { itemOne, itemTwo, itemThree }

idConvert(sns, id) {
  if (id == "") return "";
  return '$sns${int.parse("0x$id").toRadixString(36)}';
}

void dPrint(Object s) {
  if (kDebugMode) {
    print(s);
  }
}
