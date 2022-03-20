import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:magnise_test_task/models/chart_datapoint.dart';

class CoinRepository {
  List<ChartDatapoint> chartDatapoints = [];

  String getFormattedDateString(String date) =>
      date.replaceRange(14, date.length, "00:00");

  Future<List<ChartDatapoint>> getHistoricalData() async {
    String apiKey = "?apikey=27F150D5-487F-45A8-9E27-2287B035871F";
    String baseUrl = "https://rest.coinapi.io/";
    String assetsList = "v1/exchangerate/BTC/USD/history";
    String now = DateTime.now().toIso8601String();
    String aDayAgo =
        DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    print(now);
    print(aDayAgo);
    String periodString =
        "&period_id=15MIN&time_start=${getFormattedDateString(aDayAgo)}&time_end=${getFormattedDateString(now)}";
    var response =
        await http.get(Uri.parse("$baseUrl$assetsList$apiKey$periodString"));
    final data = jsonDecode(response.body);

    for (var datapoint in data) {
      chartDatapoints.add(ChartDatapoint(
        DateTime.parse(datapoint["time_period_end"].toString())
            .subtract(const Duration(minutes: 30)),
        (datapoint["rate_high"] + datapoint["rate_low"]) / 2,
      ));
    }

    return chartDatapoints;
  }
}
