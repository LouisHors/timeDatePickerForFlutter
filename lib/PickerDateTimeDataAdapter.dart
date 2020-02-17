
import 'package:flutter/cupertino.dart';
import 'package:fluttertesttwo/Picker.dart';
import 'package:fluttertesttwo/PickerAdapter.dart';

class PickerDateTimeType {
  static const int kMDY = 0; // m, d, y
  static const int kHM = 1; // hh, mm
  static const int kHMS = 2; // hh, mm, ss
  static const int kHM_AP = 3; // hh, mm, ap(AM/PM)
  static const int kMDYHM = 4; // m, d, y, hh, mm
  static const int kMDYHM_AP = 5; // m, d, y, hh, mm, AM/PM
  static const int kMDYHMS = 6; // m, d, y, hh, mm, ss

  static const int kYMD = 7; // y, m, d
  static const int kYMDHM = 8; // y, m, d, hh, mm
  static const int kYMDHMS = 9; // y, m, d, hh, mm, ss
  static const int kYMD_AP_HM = 10; // y, m, d, ap, hh, mm

  static const int kYM = 11; // y, m
  static const int kDMY = 12; // d, m, y
}

class PickerDateTimeDataAdapter extends PickerAdapter<DateTime> {
  /// 类型
  final int type;
  final bool isNumberMonth;
  final List<String> months;
  final List<String> strAMPM;
  final int yearBegin, yearEnd;
  final DateTime minValue, maxValue;
  final int minuteInterval;
  final String yearSuffix, monthSuffix, daySuffix;
  final bool twoDigitYear;
  final List<int> customColumnType;

  static const List<String> MonthsList_EN = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  static const List<String> MonthsList_CN = const [
    "一月",
    "二月",
    "三月",
    "四月",
    "五月",
    "六月",
    "七月",
    "八月",
    "九月",
    "十月",
    "十一月",
    "十二月"
  ];

  static const List<String> MonthsList_Num = const [
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12"
  ];

  static const List<String> MonthsList_EN_L = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  PickerDateTimeDataAdapter({
    Picker picker,
    this.type = 0,
    this.isNumberMonth = true,
    this.months = MonthsList_Num,
    this.strAMPM,
    this.yearBegin = 1900,
    this.yearEnd = 2100,
    this.value,
    this.minValue,
    this.maxValue,
    this.yearSuffix,
    this.monthSuffix,
    this.daySuffix,
    this.minuteInterval,
    this.customColumnType,
    this.twoDigitYear = false
  }) : assert (minuteInterval == null || (minuteInterval >= 1 && minuteInterval <= 30 && (60 % minuteInterval == 0))) {
    super.picker = picker;
    _yearBegin = yearBegin;
    if (minValue != null && minValue.year > _yearBegin) {
      _yearBegin = minValue.year;
    }
  }

  int _column = 0;
  int _columnAP = -1;
  int _yearBegin = 0;

  DateTime value;

  // 不同类型的数据长度
  static const List<List<int>> lengths = const [
    [0, 12, 31],
    [24, 60],
    [24, 60, 60],
    [12, 60, 2],
    [12, 31, 0, 24, 60],
    [12, 31, 0, 12, 60, 2],
    [12, 31, 0, 24, 60, 60],
    [0, 12, 31],
    [0, 12, 31, 24, 60],
    [0, 12, 31, 24, 60, 60],
    [0, 12, 31, 2, 12, 60],
    [0, 12],
    [31, 12, 0],
  ];
  static const Map<int, int> columnTypeLength = {
    0: 0,
    1: 12,
    2: 31,
    3: 24,
    4: 60,
    5: 60,
    6: 2,
    7: 12
  };

  /// year 0, month 1, day 2, hour 3, minute 4, sec 5, am/pm 6, hour-ap: 7
  static const List<List<int>> columnType = const [
    [1, 2, 0],
    [3, 4],
    [3, 4, 5],
    [7, 4, 6],
    [1, 2, 0, 3, 4],
    [1, 2, 0, 7, 4, 6],
    [1, 2, 0, 3, 4, 5],
    [0, 1, 2],
    [0, 1, 2, 3, 4],
    [0, 1, 2, 3, 4, 5],
    [0, 1, 2, 6, 7, 4],
    [0, 1],
    [2, 1, 0],
  ];

  static const List<int> leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

  // 获取当前列的类型
  int getCurrentColumnType(int index) {
    if (customColumnType != null) {
      return customColumnType[index];
    }
    List<int> items = columnType[type];
    if (index >= items.length) return -1;
    return items[index];
  }

  @override
  int getMaxLevel() {
    return customColumnType == null ? lengths[type].length : customColumnType.length;
  }

  @override
  void setColumn(int index) {
    _column = index + 1;
    if (_column < 0) _column = 0;
  }

  @override
  void initSelects() {
    if (value == null) value = DateTime.now();
    _columnAP = _getColumnAPIndex();
    int _maxLevel = getMaxLevel();
    if (picker.selectedIdx == null) picker.selectedIdx = new List<int>();
    for (int i = 0; i < _maxLevel; i++) picker.selectedIdx.add(0);
  }

  int _getColumnAPIndex() {
    List<int> items = customColumnType ?? columnType[type];
    for (int i = 0; i < items.length; i++) {
      if (items[i] == 6) return i;
    }
    return -1;
  }

  @override
  Widget buildItem(BuildContext context, int index) {
    String _text = "";
    int colType = getCurrentColumnType(_column);
    switch (colType) {
      case 0: // 年， 分几几年和全称两种情况
        if (twoDigitYear != null && twoDigitYear) {
          _text = "${_yearBegin + index}";
          _text = "${_text.substring(_text.length - (_text.length - 2), _text.length)}${_checkStr(yearSuffix)}";
        }else {
          _text = "${_yearBegin + index}${_checkStr(yearSuffix)}";
        }
        break;
      case 1: // 月
        if (isNumberMonth) {
          _text = "${index + 1}${_checkStr(monthSuffix)}";
        }else {
          if (months != null) {
            _text = "${months[index]}";
          }else {
            _text = "${MonthsList_Num[index]}";
          }
        }
        break;
      case 2: // 日
        _text = "${index + 1}${_checkStr(daySuffix)}";
        break;
      case 3:
      case 5:
        _text = "${intToTwoDigitStr(index)}"; // 小时，秒
        break;
      case 4:
        if (minuteInterval == null || minuteInterval < 2) {
          _text = "${intToTwoDigitStr(index)}"; // 时间间隔为1的时候（为设置
        }else {
          _text = "${intToTwoDigitStr(index * minuteInterval)}";
        }
        break;
      case 6:
        List _ampm = strAMPM;
        if (_ampm == null) _ampm = const ['AM', 'PM'];
        _text = "${_ampm[index]}";
        break;
      case 7:
        _text = "${intToTwoDigitStr(index + 1)}";
        break;
    }
    return makeText(null, _text, picker.selectedIdx[_column]==index);
  }

  // 整数转换成2位数的字符串
  String intToTwoDigitStr(int tmp) {
    if (tmp < 10) return "0$tmp";
    return "$tmp";
  }

  String _checkStr(String str) {
    return str == null ? "" : str;
  }

  @override
  String getText() {
    return value.toString();
  }

  @override
  int getColumnFlex(int column) {
    if (picker.columnFlex != null && column < picker.columnFlex.length) {
      return picker.columnFlex[column];
    }
    if (getCurrentColumnType(column) == 0) {
      return 3;
    }
    return 2;
  }

  @override
  void doShow() {
    if (_yearBegin == 0) {
      getLength();
    }
    for (int i = 0; i < getMaxLevel(); i++) {
      int colType = getCurrentColumnType(i);
      switch (colType) {
        case 0:
          picker.selectedIdx[i] = value.year - _yearBegin;
          break;
        case 1:
          picker.selectedIdx[i] = value.month - 1;
          break;
        case 2:
          picker.selectedIdx[i] = value.day - 1;
          break;
        case 3:
          picker.selectedIdx[i] = value.hour;
          break;
        case 4:
          picker.selectedIdx[i] = (minuteInterval == null || minuteInterval < 2) ? value.minute : value.minute ~/ minuteInterval;
          break;
        case 5:
          picker.selectedIdx[i] = value.second;
          break;
        case 6:
          picker.selectedIdx[i] = (value.hour > 12 || value.hour == 0) ? 1 : 0;
          break;
        case 7:
          picker.selectedIdx[i] = value.hour == 0 ? 11 : (value.hour > 12) ? value.hour - 12 - 1 : value.hour - 1;
          break;
      }
    }
  }
  
  @override
  void doSelect(int column, int index) {
    int year, month, day, h, m, s;
    year = value.year;
    month = value.month;
    day = value.day;
    h = value.hour;
    m = value.minute;
    s = value.second;

    if (type != 2 && type != 6) s = 0;
    int colType = getCurrentColumnType(index);
    switch (colType) {
      case 0:
        year = _yearBegin + index;
        break;
      case 1:
        month = index + 1;
        break;
      case 2:
        day = index + 1;
        break;
      case 3:
        h = index;
        break;
      case 4:
        m = (minuteInterval == null || minuteInterval < 2) ? index : index * minuteInterval;
        break;
      case 5:
        s = index;
        break;
      case 6:
        if (picker.selectedIdx[_columnAP] == 0) {
          if (h == 0) h = 12;
          if (h > 12) h = h -12;
        }else {
          if (h < 12) h = h + 12;
          if (h == 12) h = 0;
        }
        break;
      case 7:
        h = index + 1;
        if (_columnAP >= 0 && picker.selectedIdx[_columnAP] == 1) h = h + 12;
        if (h > 23) h = 0;
        break;
    }

    int tmpDay = _calculateDateCount(year, month);
    if (day > tmpDay) day = tmpDay;
    value = new DateTime(year, month, day, h, m, s);
    
    if (minValue != null && (value.millisecondsSinceEpoch < minValue.millisecondsSinceEpoch)) {
      value = minValue;
      dataDidChangeNotification();
    }else if (maxValue != null && (value.millisecondsSinceEpoch > maxValue.millisecondsSinceEpoch)) {
      value = maxValue;
      dataDidChangeNotification();
    }
  } 

  @override
  int getLength() {
    int tmpLen = customColumnType == null ? lengths[type][_column] : columnTypeLength[customColumnType[_column]];
    if (tmpLen == 0) {
      int tmpYear = yearEnd;
      if (maxValue != null) {
        tmpYear = maxValue.year;
      }
      return tmpYear - _yearBegin + 1;
    }
    if (tmpLen == 31) {
      return _calculateDateCount(value.year, value.month);
    }
    if (minuteInterval != null && minuteInterval > 1) {
      int _type = getCurrentColumnType(_column);
      if (_type == 4) {
        return tmpLen ~/ minuteInterval;
      }
    }
    return tmpLen;
  }

  // 根据给定的年月返回月份天数
  int _calculateDateCount(int year, int month) {
    // 31天的
    if (leapYearMonths.contains(month)) {
      return 31;
    }else if (month == 2) {
      if (isLeapYear(year)) {
        return 29;
      }
      return 28;
    }
    return 30;
  }

  bool isLeapYear(int year) {
    return ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0);
  }

  
}