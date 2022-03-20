import 'dart:convert';
import 'dart:core';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:magnise_test_task/components/chart.dart';
import 'package:magnise_test_task/models/chart_datapoint.dart';
import 'package:magnise_test_task/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chart_bloc/chart_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BTC Price Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'BTC Price Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  final CoinRepository coinRepository = CoinRepository()..getHistoricalData();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CoinRepository _coinRepository;
  late WebSocketChannel channel;

  @override
  void initState() {
    _coinRepository = CoinRepository()..getHistoricalData();
    channel = IOWebSocketChannel.connect("wss://ws-sandbox.coinapi.io/v1/");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChartBloc(_coinRepository)..add(GetChartData()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Container(
                    height: 30,
                    child: const Center(child: Text("BTC/USD")),
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                    onPressed: () => channel.sink.add(jsonEncode({
                          "type": "hello",
                          "apikey": "94113111-5F64-4DAE-9614-B56E87D91B9F",
                          "heartbeat": true,
                          "subscribe_data_type": ["exrate"],
                          "subscribe_filter_asset_id": ["BTC/USD"]
                        })),
                    child: const Text("Subscribe"))
              ]),
              const SizedBox(height: 15),
              const Text("Market data:"),
              const SizedBox(height: 15),
              Container(
                  height: 66,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: StreamBuilder(
                      stream: channel.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var exrateStream = Map<String, dynamic>.from(
                              json.decode(snapshot.data.toString()));
                          return Row(
                            children: [
                              Column(
                                children: [
                                  const Text("Symbol:"),
                                  Text(
                                      "${exrateStream["asset_id_base"]}/${exrateStream["asset_id_quote"]}"),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Price:"),
                                  SizedBox(
                                      child: Text(exrateStream["rate"]
                                          .toStringAsFixed(3)),
                                      width: 80),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Time:"),
                                  Text(DateFormat("MMM d, HH:MM").format(
                                      DateTime.parse(
                                          exrateStream["time"].toString()))),
                                ],
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                          );
                        }
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 66,
                          child: const Center(
                            child:
                                Text("Press Subscribe to get real time data"),
                          ),
                        );
                      },
                    ),
                  )),
              const SizedBox(height: 22),
              const Text("Charting data (past 24 hours):"),
              const SizedBox(height: 22),
              const Chart(),
            ],
          ),
        ),
      ),
    );
  }
}
