import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// list item
class PickerItem<T> {
  /// 展示的内容
  final Widget text;
  /// 最后选中的值
  final T value;
  /// 子项
  final List<PickerItem<T>> children;

  PickerItem({this.text, this.value, this.children});
}

/// 分隔符
class PickerDelimiter{
  final Widget child;
  final int column;
  PickerDelimiter({this.child, this.column});
}