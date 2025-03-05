import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roqqu_task/data/data_source.dart';
import 'package:roqqu_task/domain/repository/binance_repo.dart';

final binanceDataSourceProvider = Provider<BinanceDataSource>((ref) {
  final dataSource = BinanceDataSource();

  ref.onDispose(() {
    dataSource.dispose();
  });

  return dataSource;
});

//-------> Repository Provider
final binanceRepositoryProvider = Provider<BinanceRepository>((ref) {
  final dataSource = ref.watch(binanceDataSourceProvider);
  return BinanceRepositoryImpl(dataSource: dataSource);
});
