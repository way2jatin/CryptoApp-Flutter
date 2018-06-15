import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChartsPage extends StatefulWidget{

  final String coinName;
  final String coinId;

  ChartsPage(this.coinName,this.coinId);

  @override
  State<StatefulWidget> createState() {
    return new ChartsState(coinName,coinId);
  }

}

class ChartsState extends State<ChartsPage>{

  var _isLoading = true;

  var graphData;
  int groupValue = 1;

  List<charts.Series> seriesList;
  String coinName;
  String coinId;

  ChartsState(this.coinName,this.coinId);

  _fetchData() async {
    var endTime = new DateTime.now();
    var startTime = endTime.subtract(new Duration(days: 1));
    final allUrl = "https://graphs2.coinmarketcap.com/currencies/"+coinId+"/";

    if(groupValue == 1){
      startTime = endTime.subtract(new Duration(days: 1));
    }
    else if(groupValue == 2){
      startTime = endTime.subtract(new Duration(days: 30));
    }
    else if(groupValue == 3){
      startTime = endTime.subtract(new Duration(days: 90));
    }
    else if(groupValue == 4){
      startTime = endTime.subtract(new Duration(days: 365));
    }

    final url = "https://graphs2.coinmarketcap.com/currencies/"+coinId+"/"+startTime.millisecondsSinceEpoch.toString()+"/"+endTime.millisecondsSinceEpoch.toString()+"/";

    var response;
    if(groupValue == 5){
      response = await http.get(allUrl);
    }
    else{
      response = await http.get(url);
    }

    if (response.statusCode == 200) {

      final map = json.decode(response.body);
      final videosJson = map["price_usd"];

      setState(() {
        _isLoading = false;
        this.graphData = videosJson;
        seriesList = _createData(graphData);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
          primarySwatch: Colors.orange),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(capitalize(coinName)),
          elevation: defaultTargetPlatform == TargetPlatform.iOS ? 0.0 : 5.0,
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.refresh),
              onPressed: () {
                print("Reloading...");
                setState(() {
                  _isLoading = true;
                });
                _fetchData();
              },
            )
          ],
        ),
        body: new Padding(padding: const EdgeInsets.only(left:10.0,bottom: 20.0,right: 16.0,top: 10.0),
          child: new Column(
            children: <Widget>[
              new Container(
                child: _isLoading ? new SizedBox( height: 250.0, child: new Center(child: new CircularProgressIndicator()))
                    : new SizedBox(
                  height: 250.0,
                  child: new charts.TimeSeriesChart(seriesList,
                    animate: false,
                    primaryMeasureAxis: new charts.NumericAxisSpec(
                        tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false,dataIsInWholeNumbers: false),
                        tickFormatterSpec: new charts.BasicNumericTickFormatterSpec(new NumberFormat.compactSimpleCurrency())
                    ),domainAxis: new charts.DateTimeAxisSpec(
                        tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                            month: new charts.TimeFormatterSpec(
                                format: 'MMM', transitionFormat: 'MMM'))),
                  ),
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: new Row(
                    children: <Widget>[
                      new Radio(
                          value: 1,
                          activeColor: Colors.orange,
                          groupValue: groupValue,
                          onChanged: (int e) => doSomething(e)
                      ),new Text("1D"),
                      new Radio(
                          value: 2,
                          activeColor: Colors.orange,
                          groupValue: groupValue,
                          onChanged: (int e) => doSomething(e))
                      ,new Text("1M"),
                      new Radio(
                          value: 3,
                          activeColor: Colors.orange,
                          groupValue: groupValue,
                          onChanged: (int e) => doSomething(e))
                      ,new Text("3M"),
                      new Radio(
                          value: 4,
                          activeColor: Colors.orange,
                          groupValue: groupValue,
                          onChanged: (int e) => doSomething(e))
                      ,new Text("1Y"),
                      new Radio(
                          value: 5,
                          activeColor: Colors.orange,
                          groupValue: groupValue,
                          onChanged: (int e) => doSomething(e))
                      ,new Text("ALL")
                    ],
                ),
              )
            ],
          ),

        ),),
    );
  }

  static List<charts.Series<LinearSales, DateTime>> _createData(var graphData) {

    var chartData = new List<LinearSales>();

    for(var data in graphData){
      chartData.add(new LinearSales(getFormattedDate(data[0]), data[1]));
    }

    return [
      new charts.Series<LinearSales, DateTime>(
        id: 'Chart',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: chartData,
      )
    ];
  }

  static DateTime getFormattedDate(data) {
    return new DateTime.fromMillisecondsSinceEpoch(data);
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  void doSomething(int e) {
    setState(() {
      if (e == 1){
        groupValue = 1;
      }
      else if(e == 2){
        groupValue = 2;
      }
      else if(e == 3){
        groupValue = 3;
      }
      else if (e == 4){
        groupValue = 4;
      }
      else if(e == 5){
        groupValue = 5;
      }
      _isLoading = true;
      _fetchData();
    });
  }

}

class LinearSales {
  final DateTime year;
  final num sales;

  LinearSales(this.year, this.sales);
}