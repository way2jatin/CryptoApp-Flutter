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

  List<charts.Series> seriesList;
  String coinName;
  String coinId;

  ChartsState(this.coinName,this.coinId);

  _fetchData() async {
    var endTime = new DateTime.now();
    var startTime = endTime.subtract(new Duration(hours: 24));

    final url = "https://graphs2.coinmarketcap.com/currencies/"+coinId+"/"+startTime.millisecondsSinceEpoch.toString()+"/"+endTime.millisecondsSinceEpoch.toString()+"/";
    final response = await http.get(url);

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
        body: new Padding(padding: const EdgeInsets.only(left:16.0,bottom: 20.0,right: 16.0,top: 10.0),
            child: new Center(
              child: _isLoading ? new CircularProgressIndicator()
                  : new charts.TimeSeriesChart(seriesList,
                primaryMeasureAxis: new charts.NumericAxisSpec(
                    tickProviderSpec: new charts.BasicNumericTickProviderSpec(zeroBound: false,dataIsInWholeNumbers: false),
                    tickFormatterSpec: new charts.BasicNumericTickFormatterSpec(new NumberFormat.compactSimpleCurrency())
                ),domainAxis: new charts.DateTimeAxisSpec(
                    tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
                        month: new charts.TimeFormatterSpec(
                            format: 'MMM', transitionFormat: 'MMM'))),
              ) ,
            )
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

}

class LinearSales {
  final DateTime year;
  final num sales;

  LinearSales(this.year, this.sales);
}