library lib_manse;

var msGanji = [
  "甲子", //경오
  "乙丑", //신미
  "丙寅", //임신
  "丁卯", //계유,
  "戊辰", // 갑술
  "己巳", // 을해
  "庚午", // 병자
  "辛未", // 정축
  "壬申", // 무인
  "癸酉", // 기묘
  "甲戌", // 경진
  "乙亥", // 신사
  "丙子", // 임오
  "丁丑", // 계미
  "戊寅", // 갑신
  "己卯", // 을유
  "庚辰", // 병술
  "辛巳", // 정해
  "壬午", // 무자
  "癸未", //
  "甲申",
  "乙酉",
  "丙戌",
  "丁亥",
  "戊子",
  "己丑",
  "庚寅",
  "辛卯",
  "壬辰",
  "癸巳",
  "甲午",
  "乙未",
  "丙申",
  "丁酉",
  "戊戌",
  "己亥",
  "庚子",
  "辛丑",
  "壬寅",
  "癸卯",
  "甲辰",
  "乙巳",
  "丙午",
  "丁未",
  "戊申",
  "己酉",
  "庚戌",
  "辛亥",
  "壬子",
  "癸丑",
  "甲寅",
  "乙卯",
  "丙辰",
  "丁巳",
  "戊午",
  "己未",
  "庚申",
  "辛酉",
  "壬戌",
  "癸亥"
];
var msTerms = [
  '소한',
  '대한',
  '입춘',
  '우수',
  '경칩',
  '춘분',
  '청명',
  '곡우',
  '입하',
  '소만',
  '망종',
  '하지',
  '소서',
  '대서',
  '입추',
  '처서',
  '백로',
  '추분',
  '한로',
  '상강',
  '입동',
  '소설',
  '대설',
  '동지'
];

var msGan = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"];
var msJi = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"];
var msGanH = ["갑", "을", "병", "정", "무", "기", "경", "신", "임", "계"];
var msGanV = ["이", "이", "이", "이", "가", "가", "이", "이", "이", "가"];
var msJiH = ["자", "축", "인", "묘", "진", "사", "오", "미", "신", "유", "술", "해"];

class CHdb {
  String sol, lun, jul, lday;
  int dt, yndx, mndx, dndx, tndx;
  bool leap;
  String jul1, jul2, jul3;
  DateTime jdt1, jdt2, jdt3;
  CHdb(
      {required this.sol,
      required this.lun,
      required this.dt,
      required this.leap,
      required this.lday,
      required this.yndx,
      required this.mndx,
      required this.dndx,
      required this.tndx,
      required this.jul,
      required this.jul1,
      required this.jul2,
      required this.jul3,
      required this.jdt1,
      required this.jdt2,
      required this.jdt3});
  factory CHdb.fromJson(Map<String, dynamic> json, int hh) {
    String sol = json['sol'] ?? '';
    String lun = json['lun'];
    String jul = json['jul'];
    int yndx = int.parse(json['yy']);
    int mndx = int.parse(json['mm']);
    int dndx = int.parse(json['dd']);
    int tndx = dndx * 12 + hh;
    int dt = 0;
    //String dday = 'sol';
    String jul1 = jul.substring(0, 12);
    String jul2 = jul.substring(14, 26);
    String jul3 = jul.substring(28, 40);
    DateTime jdt1 = DateTime.parse(jul1.substring(0, 8));
    DateTime jdt2 = DateTime.parse(jul2.substring(0, 8));
    DateTime jdt3 = DateTime.parse(jul3.substring(0, 8));
    bool leap = lun.startsWith('2');
    String lunDt = lun.substring(1);
    return CHdb(
        sol: sol,
        lun: lun,
        jul: jul,
        dt: dt,
        leap: leap,
        lday: lunDt,
        jul1: jul1,
        jul2: jul2,
        jul3: jul3,
        jdt1: jdt1,
        jdt2: jdt2,
        jdt3: jdt3,
        yndx: yndx,
        mndx: mndx,
        dndx: dndx,
        tndx: tndx);
  }
  String lunDate() {
    return '음력: ${leap ? '윤달' : '평달'} ${lday.substring(0, 4)}-${lday.substring(4, 6)}-${lday.substring(6, 8)}';
  }
}
