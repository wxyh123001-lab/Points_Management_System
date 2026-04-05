import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// OCR 识别结果，每个字段含置信度
class OcrField {
  final String key;
  final String value;
  final double confidence;

  OcrField({
    required this.key,
    required this.value,
    required this.confidence,
  });

  factory OcrField.fromJson(Map<String, dynamic> json) {
    return OcrField(
      key: json['key'] as String,
      value: json['value'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class OcrService {
  /// 识别图片，返回字段识别结果列表
  /// 如果 confidence < 0.7，UI 层应显示感叹号提示用户核对
  Future<List<OcrField>> recognizeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse(AppConfig.ocrEndpoint);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConfig.ocrApiKey}',
      },
      body: jsonEncode({
        'image': base64Image,
        // 告知 OCR API 需要识别的字段（字段名按实际 API 文档调整）
        'fields': ['name', 'phone', 'birthday', 'clothing_size', 'points'],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OCR failed: ${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    // 按实际 API 响应格式调整这里的解析路径
    final List<dynamic> fields = body['fields'] as List<dynamic>;
    return fields
        .map((e) => OcrField.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
