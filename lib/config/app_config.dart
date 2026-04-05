// lib/config/app_config.dart
// 所有 API key 和 endpoint 集中管理。
// 接入 OCR 服务时，将 YOUR_* 替换为实际值。

class AppConfig {
  // OCR API 配置（用户提供）
  static const String ocrEndpoint = 'YOUR_OCR_ENDPOINT';
  static const String ocrApiKey = 'YOUR_OCR_API_KEY';

  // 多店扩展（当前单店，默认 store_id = 1）
  static const int defaultStoreId = 1;

  // 我的页展示名称
  static const String displayName = 'Demo Store';
}
