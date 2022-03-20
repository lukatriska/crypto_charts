import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:magnise_test_task/models/chart_datapoint.dart';
import 'package:magnise_test_task/services.dart';
import 'package:meta/meta.dart';

part 'chart_event.dart';

part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  final CoinRepository _coinRepository;


  ChartBloc(this._coinRepository) : super(ChartInitial()) {
    on<GetChartData>((event, emit) async {

      emit(ChartDataLoaded(await _coinRepository.getHistoricalData()));
    });
  }
}
