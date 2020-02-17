import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Picker.dart';

/// 选择数据适配器
abstract class PickerAdapter<T> {
  Picker picker;

  // 计算对应数据
  int getLength();
  int getMaxLevel();

  // 条目数据适配
  void setColumn(int index);
  // 初始化选中数据
  void initSelects();

  Widget buildItem(BuildContext context, int index);

  // 返回的是条目上的内容Widget
  Widget makeText(Widget child, String text, bool isSelected) {
    return new Container(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: picker.textStyle ?? new TextStyle(color: Colors.black87, fontSize: Picker.defaultTextSize),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: picker.textAlign, 
        child: child ?? new Text(text, textScaleFactor: picker.textScaleFactor, style: (isSelected ? picker.selectedStyle : null))
      ),
    );
  }

    Widget makeTextEx(Widget child, String text, Widget postfix, Widget suffix, bool isSel) {
    List<Widget> items = [];
    if (postfix != null)
      items.add(postfix);
    items.add(child ?? new Text(text, style: (isSel ? picker.selectedStyle : null)));
    if (suffix != null)
      items.add(suffix);

    var _txtColor = Colors.black87;
    var _txtSize = Picker.defaultTextSize;
    if (isSel && picker.selectedStyle != null) {
      if (picker.selectedStyle.color != null)
        _txtColor = picker.selectedStyle.color;
      if (picker.selectedStyle.fontSize != null)
        _txtSize = picker.selectedStyle.fontSize;
    }

    return new Container(
        alignment: Alignment.center,
        child: DefaultTextStyle(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: picker.textAlign,
            style: picker.textStyle ??
                new TextStyle(
                    color: _txtColor, fontSize: _txtSize),
            child: Wrap(
              children: items,
            )
        )
    );
  }

  String getText() {
    return getSelectedValues().toString();
  }
  
  List<T> getSelectedValues() {
    return [];
  }

  void doShow() {}
  void doSelect(int column, int index) {}

  int getColumnFlex(int column) {
    if (picker.columnFlex != null && column < picker.columnFlex.length) {
      return picker.columnFlex[column];
    }
    return 1;
  }

  bool getIsLinkage() {
    return true;
  }

  int get maxLevel => getMaxLevel();

  int get length => getLength();

  String get text => getText();

  bool get isLinkage => getIsLinkage();

  @override
  String toString() {
    return getText();
  }

  /// 数据改变的同志
  void dataDidChangeNotification() {
    if (picker != null && picker.state != null) {
      picker.adapter.doShow();
      picker.adapter.initSelects();
      for (int j = 0; j < picker.selectedIdx.length; j++) {
        // 滚动
        picker.state.scrollController[j].jumpToItem(picker.selectedIdx[j]);
      }
    }
  }
}