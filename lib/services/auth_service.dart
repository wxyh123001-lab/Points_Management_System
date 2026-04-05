// lib/services/auth_service.dart
//
// 登录功能扩展骨架。当前版本不启用。
// 接入步骤：
//   1. 在 AppConfig 中添加 authEndpoint
//   2. 实现 login(username, password) → 返回 token
//   3. 将 token 存入 flutter_secure_storage
//   4. SqlhubService 的 _headers 改为读取 token
//   5. 在 main.dart 中挂载 AuthProvider，跳转登录页

class AuthService {
  // ignore: unused_field
  String? _token;

  bool get isLoggedIn => _token != null;

  // TODO(扩展): 实现登录
  // Future<void> login(String username, String password) async { ... }

  // TODO(扩展): 实现登出
  // Future<void> logout() async { ... }
}
