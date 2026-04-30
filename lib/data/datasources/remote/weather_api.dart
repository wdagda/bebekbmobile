import 'package:dio/dio.dart';
import '../../../core/constants/api_keys.dart';

class WeatherApi {
  final Dio _dio;

  WeatherApi(this._dio);

  Future<Map<String, dynamic>> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': ApiKeys.openWeather,
          'units': 'metric',
          'lang': 'id',
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Gagal mengambil data cuaca: $e');
    }
  }
}
