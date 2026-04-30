import 'package:dio/dio.dart';
import '../../../core/constants/api_keys.dart';

class OpenAIApi {
  final Dio _dio;

  OpenAIApi(this._dio);

  Future<String> chat(
    String userMessage,
    List<Map<String, String>> history,
  ) async {
    final messages = [
      {
        'role': 'system',
        'content':
            '''Kamu adalah asisten AI untuk peternak bebek bernama DuckBot. 
        Bantu petani dengan pertanyaan seputar: manajemen kandang, pakan, 
        produksi telur, kesehatan bebek, dan bisnis peternakan. 
        Jawab dalam Bahasa Indonesia yang ramah dan praktis.''',
      },
      ...history,
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      data: {
        'model': 'gpt-4o-mini',
        'messages': messages,
        'max_tokens': 500,
        'temperature': 0.7,
      },
      options: Options(headers: {'Authorization': 'Bearer ${ApiKeys.openAI}'}),
    );

    return response.data['choices'][0]['message']['content'];
  }

  Future<Map<String, dynamic>> predictProduksi(List<int> historicalData) async {
    final prompt =
        '''
    Berdasarkan data produksi telur bebek 30 hari terakhir: $historicalData
    Analisis pola dan berikan:
    1. Prediksi produksi 7 hari ke depan
    2. Rekomendasi pakan (kg/hari)
    3. Faktor yang mempengaruhi produksi
    Jawab dalam format JSON.
    ''';

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      data: {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a poultry analytics AI. Always respond in valid JSON.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
      },
      options: Options(headers: {'Authorization': 'Bearer ${ApiKeys.openAI}'}),
    );

    return response.data['choices'][0]['message']['content'];
  }
}
