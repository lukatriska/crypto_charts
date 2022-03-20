import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magnise_test_task/chart_bloc/chart_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatelessWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<ChartBloc, ChartState>(
      builder: (context, state) {
        if (state is ChartInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ChartDataLoaded) {
          return SfCartesianChart(
            primaryXAxis: NumericAxis(
              title: AxisTitle(text: "HH:MM"),
              axisLabelFormatter: (AxisLabelRenderDetails args) {
                late String text;
                int minute =
                    DateTime.fromMillisecondsSinceEpoch(args.value.toInt())
                        .minute;
                int hour =
                    DateTime.fromMillisecondsSinceEpoch(args.value.toInt())
                        .hour;
                String minuteText =
                    minute >= 10 ? minute.toString() : "0$minute";
                text =
                    "${hour >= 10 ? hour : "0$hour"}:${minute >= 10 ? minute : "0$minute"}";
                return ChartAxisLabel(text, args.textStyle);
              },
            ),
            series: <ChartSeries>[
              LineSeries(
                dataSource: state.chartData,
                xValueMapper: (dynamic datapoints, _) =>
                    datapoints.time.millisecondsSinceEpoch,
                yValueMapper: (dynamic datapoints, _) {
                  return datapoints.price;
                },
              )
            ],
          );
        }
        return const Center();
      },
    );
}
