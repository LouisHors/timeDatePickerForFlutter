import 'dart:async';
import 'package:flutter/foundation.dart';
import 'PickerAdapter.dart';
import 'pickerItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as Dialog;
import 'package:flutter/cupertino.dart';


//MARK: 以下是回调
/// 选中回调
typedef PickerItemDidSelectedCallBack = void Function(
  Picker picker, int index, List<int> selecteds
);
/// 点击了确认按钮
typedef PickerDidConfirmCallBack = void Function(
  Picker picker, List<int> selecteds
);
/// 格式化数据回调
typedef PickerDidFormatValue<T> = String Function(T value);

/// 主体类
class Picker {
  // 默认字体大小
  static const double defaultTextSize = 20.0;

  /// 当前选中的选项的index
  List<int> selectedIdx = [];
  /// 适配器
  final PickerAdapter adapter;
  /// 根据数据插入的分隔符数组
  final List<PickerDelimiter> delimiter;
  /// 取消按钮回调
  final VoidCallback onCancel;
  /// 滚动选中回调
  final PickerItemDidSelectedCallBack onSelect;
  /// 确定按钮回调
  final PickerDidConfirmCallBack onConfirm;

  /// 当左边一列发生变化时，右边一列需要滚动到第一列
  final changeToFirst;

  /// 
  final List<int> columnFlex;
  
  /// UI相关
  final Widget title;
  final Widget cancel;
  final Widget confirm;
  final String cancelText;
  final String confirmText;
  
  final double height;
  final double itemHeight;
  
  final TextStyle textStyle, cancelStyle, confirmStyle, selectedStyle;
  final TextAlign textAlign;

  final double textScaleFactor;
  final EdgeInsetsGeometry columnPadding;
  final Color backgroundColor, headerColor, containerColor;

  /// 是否需要隐藏标题
  final bool shouldHideHeader;
  
  /// 滚动到底是否循环
  final bool looping;

  final Widget footer;

  final Decoration headerDecoration;

  Widget _widget;

  PickerWidgetState _state;

  Picker({
    this.adapter,
    this.delimiter,
    this.onCancel,
    this.onSelect,
    this.onConfirm,
    this.changeToFirst = false,
    this.columnFlex,
    this.title,
    this.cancel,
    this.confirm,
    this.cancelText,
    this.confirmText,
    this.height = 266.0,
    this.itemHeight = 28.0,
    this.textStyle,
    this.cancelStyle,
    this.confirmStyle,
    this.selectedStyle,
    this.textAlign = TextAlign.start,
    this.textScaleFactor,
    this.columnPadding,
    this.backgroundColor,
    this.headerColor,
    this.containerColor,
    this.shouldHideHeader = false,
    this.looping = false,
    this.footer,
    this.headerDecoration,
  }): assert(adapter != null);

  Widget get widget => _widget;
  PickerWidgetState get state => _state;
  int _maxLevel = 1;

  /// 用于制造Picker 
  Widget makePicker([ThemeData themeData, bool isModal = true]) {
    _maxLevel = adapter.maxLevel;
    adapter.picker = this;
    adapter.initSelects();
    _widget = _PickerWidget(picker: this, theme: themeData, isModal: isModal);
    return _widget;
  }

  /// 展示方法
  void show(ScaffoldState state, [ThemeData themeData]) {
    state.showBottomSheet((BuildContext context) {
      return makePicker(themeData);
    });
  }

  Future<T> showModal<T>(BuildContext context, [ThemeData themeData]) async {
    return await showModalBottomSheet<T>(
      context: context, 
      builder: (BuildContext context) {
        return makePicker(themeData, true);
      }
    );
  }

  void showDialog(BuildContext context) {
    Dialog.showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Widget> actions = [];

        if (cancel == null) {
          String _cancelText = cancelText;
          if (_cancelText != null && _cancelText != "") {
            actions.add(FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onCancel != null) onCancel();
                },
                child: cancelStyle == null ? Text(_cancelText) : DefaultTextStyle(style: cancelStyle, child: Text(_cancelText)),
              )
            );
          }
        }else {
          actions.add(cancel);
        }

        if (confirm == null) {
          String _confirmText = confirmText;
          if (_confirmText != null && _confirmText != "") {
            actions.add(FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onConfirm != null) onConfirm(this, selectedIdx);
                },
                child: confirmStyle == null ? Text(_confirmText) : DefaultTextStyle(style: confirmStyle, child: Text(_confirmText)),
              )
            );
          }
        }else {
          actions.add(confirm);
        }

        return AlertDialog(
          title: title,
          actions: actions,
          content: makePicker(),
        );
      }
    );
  }

  // 两个按钮对应的点击方法
  void doCancel(BuildContext context) {
    if (onCancel != null) onCancel();
    Navigator.of(context).pop();
    _widget = null;
  }

  void doConfirm(BuildContext context) {
    if (onConfirm != null) onConfirm(this, selectedIdx);
    Navigator.of(context).pop();
    _widget = null;
  }

  List getSelectedValues() {
    return adapter.getSelectedValues();
  }
}

class _PickerWidget<T> extends StatefulWidget {

  final Picker picker;
  final ThemeData theme;
  final bool isModal;
  _PickerWidget({Key key, @required this.picker, @required this.theme, this.isModal}): super(key: key);

  @override
  PickerWidgetState createState() =>
    PickerWidgetState<T>(picker: this.picker, themeData: this.theme);
  
}

class PickerWidgetState<T> extends State<_PickerWidget> {

  final Picker picker;
  final ThemeData themeData;
  PickerWidgetState({Key key, @required this.picker, @required this.themeData});

  ThemeData theme;
  final List<FixedExtentScrollController> scrollController = [];

  bool _changing = false;
  final Map<int, int> lastData = {};

  @override
  void initState() {
    super.initState();
    
    theme = themeData;
    picker._state = this;
    picker.adapter.doShow();

    if (scrollController.length == 0) {
      for (int i = 0; i < picker._maxLevel; i++) {
        scrollController.add(FixedExtentScrollController(initialItem: picker.selectedIdx[i]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var v = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        (picker.shouldHideHeader) ? SizedBox() : Container(
          child:  Row(
            children: setupHeaderViews(),
          ),
          decoration: picker.headerDecoration ?? BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.dividerColor, width: 0.5),
              bottom: BorderSide(color: theme.dividerColor, width: 0.5),
            ),
            color: picker.headerColor == null
              ? theme.bottomAppBarColor
              : picker.headerColor,
          ),
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: setupUI(),
          ), 
        ),
        picker.footer ?? SizedBox(width: 0.0, height: 0.0,),
      ],
    );

    if (widget.isModal == null || widget.isModal == false) {
      return v;
    }
    return GestureDetector(
      onTap: () {},
      child: v,
    );
  }

  List<Widget> setupHeaderViews() {
    if (theme == null) theme = Theme.of(context);
    List<Widget> items = [];
    // 取消按钮
    if (picker.cancel != null) {
      items.add(DefaultTextStyle(style: picker.cancelStyle ?? TextStyle(color: theme.accentColor, fontSize: Picker.defaultTextSize), child: picker.cancel));
    }else {
      String tmpCancelText = picker.cancelText ?? "取消";
      if (tmpCancelText != null || tmpCancelText != "") {
        FlatButton cancelBtn = FlatButton(
          onPressed: () {
              picker.doCancel(context);
          }, 
          child: Text(
              tmpCancelText,
              overflow: TextOverflow.ellipsis,
              style: picker.cancelStyle ?? TextStyle(color: theme.accentColor, fontSize: Picker.defaultTextSize),
          )
        );
        items.add(cancelBtn);
      }
    }

    Expanded title = Expanded(
        child: Container(
          alignment: Alignment.center,
          child: picker.title == null 
          ? picker.title 
          : DefaultTextStyle(
              style: TextStyle(
                  fontSize: Picker.defaultTextSize, color: theme.textTheme.title.color
                ), 
              child: picker.title
            ),
        )
    );
    // 标题
    items.add(title);

    // 确定按钮
    if (picker.confirm != null) {
      items.add(
        DefaultTextStyle(
          style: picker.confirmStyle ?? TextStyle(color: theme.accentColor, fontSize: Picker.defaultTextSize), 
          child: picker.confirm
        )
      );
    }else {
      String tmpConfirmText = picker.confirmText ?? "确认";
      if (tmpConfirmText != null || tmpConfirmText != "") {
        FlatButton confirm = FlatButton(
          onPressed: () {
            picker.doConfirm(context);
          }, 
          child: Text(
            tmpConfirmText,
            overflow: TextOverflow.ellipsis,
            style: picker.confirmStyle ?? TextStyle(color: theme.accentColor, fontSize: Picker.defaultTextSize),
          )
        );
        items.add(confirm);
      }
    }
    return items;
  }

  List<Widget> setupUI() {
    print("setupUI");
    if (theme == null) theme = Theme.of(context);

    List<Widget> items = [];

    PickerAdapter adapter = picker.adapter;
    if (adapter != null) adapter.setColumn(-1);

    if (adapter != null && adapter.length > 0) {
      for (int i = 0; i < picker._maxLevel; i++) {
        final int tmpLength = adapter.length;

        Widget tmpView = new Expanded(
          flex: adapter.getColumnFlex(i),
          child: Container(
            padding: picker.columnPadding,
            height: picker.height,
            decoration: BoxDecoration(
              color: picker.containerColor == null 
              ? theme.dialogBackgroundColor
              : picker.containerColor,
            ),
            child: CupertinoPicker(
              backgroundColor: picker.backgroundColor,
              scrollController: scrollController[i],
              itemExtent: picker.itemHeight,
              looping: picker.looping,
              onSelectedItemChanged: (int index) {
                print("正在选择");
                setState(() {
                  picker.selectedIdx[i] = index;
                  updateScrollController(i);
                  adapter.doSelect(i, index);
                  if (picker.changeToFirst) {
                    for (int j = i + 1; j < picker.selectedIdx.length; j++) {
                      picker.selectedIdx[j] = 0;
                      scrollController[j].jumpTo(0.0);
                    }
                  }
                  if (picker.onSelect != null) {
                    picker.onSelect(picker, i, picker.selectedIdx);
                  }
                });
              },
              children: List<Widget>.generate(tmpLength, (int index) {
                return adapter.buildItem(context, index);
              }),
            ),
          )
        );

        items.add(tmpView);
        if (!picker.changeToFirst && (picker.selectedIdx[i] >= tmpLength)) {
          Timer(Duration(milliseconds: 100), () {
            print("计时器正在运作");
            scrollController[i].jumpToItem(tmpLength - 1);
          });
        }

        adapter.setColumn(i);
      }
    }

    if (picker.delimiter != null) {
      for (int i = 0; i < picker.delimiter.length; i++) {
        var tmpDelimiter = picker.delimiter[i];
        if (tmpDelimiter.child == null) continue;
        var item = Container(child: tmpDelimiter.child, height: picker.height);
        if (tmpDelimiter.column < 0) {
          items.insert(0, item);
        }else if (tmpDelimiter.column >= items.length) {
          items.add(item);
        }else {
          items.insert(tmpDelimiter.column, item);
        }
      }
    }

    return items;
  }

  void updateScrollController(int i) {
    if (_changing || !picker.adapter.isLinkage) return;
    _changing = true;
    for (int j = 0; j < picker.selectedIdx.length; j++) {
      if (j != i) {
        if (scrollController[j].position.maxScrollExtent == null) {
          continue;
        }
        scrollController[j].position.notifyListeners();
      }
    }
    _changing = false;
  }
  
}