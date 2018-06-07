import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class ChartsPage extends StatefulWidget{

  String coinName;

  ChartsPage(this.coinName);

  @override
  State<StatefulWidget> createState() {
    return new ChartsState(coinName);
  }

}

class ChartsState extends State<ChartsPage>{

  var _isLoading = true;

  var graphData;

  List<charts.Series> seriesList;
  String coinName;

  ChartsState(this.coinName);

  _fetchData() async {
    print("Attempting to fetch data from network");

    var endTime = new DateTime.now();
    var startTime = endTime.subtract(new Duration(days: 365));

    final url = "https://graphs2.coinmarketcap.com/currencies/"+coinName+"/"+startTime.millisecondsSinceEpoch.toString()+"/"+endTime.millisecondsSinceEpoch.toString()+"/";
    final response = await http.get(url);

    if (response.statusCode == 200) {

      final map = json.decode(response.body);
      final videosJson = map["price_usd"];

      setState(() {
        _isLoading = false;
        this.graphData = videosJson;
        print(graphData);
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
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(coinName.toUpperCase()),
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
          body: new Center(
//              padding: const EdgeInsets.all(8.0),
              child: _isLoading ? new CircularProgressIndicator()
              : new charts.TimeSeriesChart(seriesList,
                  defaultRenderer: new charts.LineRendererConfig(includePoints: false)))
      ),
    );
  }

  static List<charts.Series<LinearSales, DateTime>> _createData(var graphData) {

    var chartData = new List<LinearSales>();

    for(var data in graphData){
      chartData.add(new LinearSales(getFormattedDate(data[0]), data[1]));
    }

    return [
      new charts.Series<LinearSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (LinearSales sales, _) => sales.year,
          measureFn: (LinearSales sales, _) => sales.sales,
          data: chartData,
      )
    ];
  }

  static DateTime getFormattedDate(data) {
    return new DateTime.fromMicrosecondsSinceEpoch(data);
  }

}

class LinearSales {
  final DateTime year;
  final num sales;

  LinearSales(this.year, this.sales);
}