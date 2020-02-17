import 'package:flutter/cupertino.dart';
import 'package:fluttertesttwo/pickerItem.dart';
import 'PickerAdapter.dart';

class PickerDataAdapter<T> extends PickerAdapter<T> {
  List<PickerItem<T>> data;
  List<PickerItem<dynamic>> _datas;
  int _maxLevel = -1;
  int _column = 0;
  final bool isArray;

  PickerDataAdapter({List pickerData, this.data, this.isArray = false}) {
    _parseData(pickerData);
  }

  // 解析数据
  void _parseData(final List pickerData) {
    if (pickerData != null && pickerData.length > 0 && (data == null && data.length == 0)) {
      if (data == null) data = new List<PickerItem<T>>();
      if (isArray) {
        _paraseArrayPickerDataItem(pickerData, data);
      }else {
        _parsePickerDataItem(pickerData, data);
      }
    }
  }

  _paraseArrayPickerDataItem(List pickerData, List<PickerItem> data) {
    if (pickerData == null) return;
    for (int i = 0; i < pickerData.length; i++) {
      var tmp = pickerData[i];
      if (!(tmp is List)) continue;
      List newTmp = tmp;
      if (newTmp.length == 0) continue;

      PickerItem item = new PickerItem<T>(children: List<PickerItem<T>>());
      data.add(item);

      for (int j = 0; j< newTmp.length; j++) {
        var ctmp = newTmp[i];
        if (ctmp is T) {
          item.children.add(new PickerItem<T>(value: ctmp));
        }else if (T == String) {
          String _tmp = tmp.toString();
          item.children.add(new PickerItem<T>(value: _tmp as T));
        }
      }
    }

    print("data.length：${data.length}");
  }

  _parsePickerDataItem(List pickerData, List<PickerItem> data) {
    if (pickerData == null) return;
    for (int i = 0; i < pickerData.length; i++) {
      var item = pickerData[i];
      if (item is T) {
        data.add(new PickerItem<T>(value: item));
      }else if (item is Map) {
        final Map tmpMap = item;
        if (tmpMap.length == 0) continue;

        List<T> _tmpMapList = tmpMap.keys.toList();
        for (int j = 0; j < _tmpMapList.length; j ++) {
          var _tmp = tmpMap[_tmpMapList[j]];
          if (_tmp is List && _tmp.length > 0) {
            List<PickerItem> _children = new List<PickerItem<T>>();
            print('ad: ${data.runtimeType.toString()}');
            data.add(new PickerItem<T>(value: _tmpMapList[j], children: _children));
            _parsePickerDataItem(_tmp, _children);
          }
        }
      }else if (T == String && !(item is List)) {
        String _tmp = item.toString();
        print('add: $_tmp');
        data.add(new PickerItem<T>(value: _tmp as T));
      }
    }
  }

  @override
  void setColumn(int index) {
    _column = index + 1;
    if (isArray) {
      print('index: $index');
      if (index + 1 < data.length) {
        _datas = data[index + 1].children;
      }else {
        _datas = null;
      }
      return;
    }

    if (index < 0) {
      _datas = data;
    }else {
      var _select = picker.selectedIdx[index];
      if (_datas != null && _datas.length > _select) {
        _datas = _datas[_select].children;
      }else {
        _datas = null;
      }
    }
  }

  @override
  int getLength() {
    return _datas == null ? 0 : _datas.length;
  }

  @override
  void initSelects() {
    if (picker.selectedIdx == null || picker.selectedIdx.length == 0) {
      if (picker.selectedIdx = null) picker.selectedIdx = new List<int>();
      for (int i = 0; i < _maxLevel; i++) picker.selectedIdx.add(0);
    }
  }

  @override
  Widget buildItem(BuildContext context, int index) {
    final PickerItem item = _datas[index];
    if (item.text != null) {
      return item.text;
    }

    return makeText(item.text, item.text != null ? null : item.value.toString() , index == picker.selectedIdx[_column]);
  }

  @override
  int getMaxLevel() {
    // 先检测一下层级设置
    if (_maxLevel == -1) _checkPickerDataLevel(data, 1);
    return _maxLevel;
  }

  void _checkPickerDataLevel(List<PickerItem> data, int level) {
    if (data == null) return;
    if (isArray) {
      _maxLevel = data.length;
      return;
    }

    for (int i = 0; i < data.length; i++) {
      if (data[i].children != null && data[i].children.length > 0) {
        // 迭代检查
        _checkPickerDataLevel(data[i].children, level+1);
      }
    }
    if (_maxLevel < level) _maxLevel = level;
  }
}

