part of 'chart_bloc.dart';

@immutable
abstract class ChartState {}

class ChartInitial extends ChartState {}

class ChartDataLoaded extends ChartState {
  final List<ChartDatapoint> chartData;

  ChartDataLoaded(this.chartData);
}