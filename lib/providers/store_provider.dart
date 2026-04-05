// lib/providers/store_provider.dart
//
// 多门店上下文骨架。当前版本始终返回 storeId = 1。
// 扩展步骤：
//   1. 登录后从服务端获取用户所属门店列表
//   2. 在"我的"页提供门店切换 UI
//   3. CustomerProvider.loadCustomers() 传入 currentStoreId 筛选

import 'package:flutter/foundation.dart';

class StoreProvider extends ChangeNotifier {
  int _currentStoreId = 1;

  int get currentStoreId => _currentStoreId;

  // TODO(扩展): 实现多店切换
  // void switchStore(int storeId) {
  //   _currentStoreId = storeId;
  //   notifyListeners();
  // }
}
