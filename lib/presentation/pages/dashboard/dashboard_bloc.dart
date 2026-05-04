import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/dao/kandang_dao.dart';
import '../../../data/database/dao/produksi_dao.dart';
import '../../../data/database/dao/pakan_dao.dart';
import '../../../data/database/dao/produk_dao.dart';
import '../../../data/datasources/remote/weather_api.dart';
import '../../../core/network/dio_client.dart';

// ── Events
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends DashboardEvent {
  final int userId;
  final double lat;
  final double lon;
  LoadDashboardEvent({
    required this.userId,
    required this.lat,
    required this.lon,
  });
  @override
  List<Object?> get props => [userId];
}

// ── States
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

class DashboardLoaded extends DashboardState {
  final int totalKandang;
  final int totalBebek;
  final int produksiHariIni;
  final int stokMentah;
  final int stokAsin;
  final int stokKerupuk;
  final int pakanHampirHabis;
  final WeatherData? cuaca;
  final List<Map<String, dynamic>> chart7Hari;

  DashboardLoaded({
    required this.totalKandang,
    required this.totalBebek,
    required this.produksiHariIni,
    required this.stokMentah,
    required this.stokAsin,
    required this.stokKerupuk,
    required this.pakanHampirHabis,
    this.cuaca,
    required this.chart7Hari,
  });

  @override
  List<Object?> get props => [
    totalKandang,
    totalBebek,
    produksiHariIni,
    stokMentah,
    stokAsin,
    stokKerupuk,
    pakanHampirHabis,
  ];
}

// ── BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final _kandangDao = KandangDao();
  final _produksiDao = ProduksiDao();
  final _pakanDao = PakanDao();
  final _produkDao = ProdukDao();
  final _weatherApi = WeatherApi(DioClient.instance);

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDashboardEvent e,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final kandangList = await _kandangDao.getAll(e.userId);
      final totalKandang = kandangList.length;
      final totalBebek = kandangList.fold<int>(
        0,
        (sum, k) => sum + (k['total_bebek'] as int? ?? 0),
      );
      final produksiHariIni = await _produksiDao.getTotalToday(e.userId);
      final stokMap = await _produkDao.getStokSummary(e.userId);
      final lowPakan = await _pakanDao.getLowStock(e.userId);
      final chart7Hari = await _produksiDao.getChart7Days(e.userId);

      WeatherData? cuaca;
      try {
        cuaca = await _weatherApi.getCurrentWeather(lat: e.lat, lon: e.lon);
      } catch (_) {} // Cuaca opsional, tidak crash kalau gagal

      emit(
        DashboardLoaded(
          totalKandang: totalKandang,
          totalBebek: totalBebek,
          produksiHariIni: produksiHariIni,
          stokMentah: stokMap['MENTAH'] ?? 0,
          stokAsin: stokMap['ASIN'] ?? 0,
          stokKerupuk: stokMap['KERUPUK'] ?? 0,
          pakanHampirHabis: lowPakan.length,
          cuaca: cuaca,
          chart7Hari: chart7Hari,
        ),
      );
    } catch (err) {
      emit(DashboardError('Gagal memuat dashboard: $err'));
    }
  }
}
