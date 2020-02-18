import 'package:flutter/material.dart';
import 'package:fluttertesttwo/PickerDateTimeDataAdapter.dart';
import 'Picker.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() => new MyAppState();
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final double listSpec = 4.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String stateText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("时间选择器",),
        automaticallyImplyLeading: false,
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        alignment: Alignment.topCenter,
        child: ListView(
          children: <Widget>[
            (stateText != null) ? Text(stateText) : Container(),
            RaisedButton(
              child: Text("选择日期"),
              onPressed: () {
                showDatePicker(context);
              },
            ),
            SizedBox(height: listSpec,),
            RaisedButton(
              onPressed: () {
                showTimePicker(context);
              },
              child: Text("选择时间"),
            ),
            SizedBox(height: listSpec,),
            RaisedButton(
              child: Text("时间日期一起"),
              onPressed: () {
                showDateTimePicker(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showDatePicker(BuildContext context) {
    Picker(
      shouldHideHeader: false,
      adapter: new PickerDateTimeDataAdapter(
        customColumnType: [0, 1, 2],
        yearSuffix: "年",
        monthSuffix: "月",
        daySuffix: "日"
      ),
      title: Text("请选择日期"),
      selectedStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List value) {
        print((picker.adapter as PickerDateTimeDataAdapter).value);
      },
    ).showModal(this.context);
  }

  void showTimePicker(BuildContext context) {
    new Picker(
      shouldHideHeader: true,
      adapter: new PickerDateTimeDataAdapter(
        customColumnType: [3, 4],
      ),
      title: Text("请选择时间"),
      selectedStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List value) {
        print((picker.adapter as PickerDateTimeDataAdapter).value);
      }
    ).showModal(this.context);
  }

  void showDateTimePicker(BuildContext context) {
    new Picker(
      shouldHideHeader: true,
      adapter: PickerDateTimeDataAdapter(
        customColumnType: [0, 1, 2, 3, 4],
        yearSuffix: "年",
        monthSuffix: "月",
        daySuffix: "日",
      ),
      title: Text("请选择时间日期"),
      selectedStyle: TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List value) {
        print((picker.adapter as PickerDateTimeDataAdapter).value);
      },
    ).showModal(this.context);
  }
}
