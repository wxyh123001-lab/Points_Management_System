# 积分管理 — 服装门店会员积分系统

线下服装门店专用的移动端会员积分管理工具，支持 Android、iOS 及 Web 平台。

---

## 功能

### 录入页
- 手动填写会员信息：姓名、衣服型号、积分（必填），性别、生日、手机号（选填）
- 📷 拍照/图库识别：拍摄会员卡或手写单据，OCR 自动识别并预填表单
- OCR 识别结果高亮显示，低置信度字段显示警告提示

### 查询页
- 按积分范围筛选（全部 / ≥500 / ≥800 / ≥1000 / 自定义区间）
- 按生日月份筛选
- 积分里程碑徽章：
  - 铜牌：≥ 500 分
  - 银牌：≥ 800 分
  - 金牌：≥ 1000 分
- 点击会员进入详情页，支持在线编辑

### 我的页
- 显示门店名称，预留后续扩展条目

---

## 技术栈

| 技术 | 说明 |
|------|------|
| Flutter 3.27.4 | 跨平台 UI 框架 |
| sqflite | 本地 SQLite 数据库（Android / iOS） |
| sqflite_common_ffi_web | Web 平台 SQLite 支持 |
| Provider | 状态管理 |
| image_picker | 相机 / 图库调用 |
| http | OCR API 网络请求 |
| intl | 日期格式化 |

---

## 项目结构

```
lib/
├── config/
│   └── app_config.dart          # OCR API 配置（填入密钥）
├── models/
│   └── customer.dart            # 会员数据模型 + 积分等级判断
├── services/
│   ├── database_service.dart    # 本地 SQLite 增删改查
│   ├── ocr_service.dart         # OCR 图片识别
│   └── auth_service.dart        # 登录骨架（预留多店扩展）
├── providers/
│   ├── customer_provider.dart   # 会员列表全局状态
│   └── store_provider.dart      # 门店上下文（预留）
├── screens/
│   ├── entry/entry_screen.dart  # 录入页
│   ├── query/query_screen.dart  # 查询页
│   ├── query/detail_screen.dart # 详情/编辑页
│   └── profile/profile_screen.dart # 我的页
└── widgets/
    ├── milestone_badge.dart     # 积分里程碑徽章组件
    └── customer_list_tile.dart  # 会员列表行组件
```

---

## 快速开始

### 环境要求
- Flutter 3.27.4+
- Android SDK（Android 运行）/ Xcode（iOS 运行，需 Mac）

### 安装依赖

```bash
flutter pub get
```

### Web 运行（开发调试）

```bash
# 初始化 Web SQLite 支持（仅首次需要）
dart run sqflite_common_ffi_web:setup

flutter run -d chrome
```

### Android 运行

```bash
flutter run -d <device-id>
```

---

## 配置 OCR 服务

编辑 `lib/config/app_config.dart`，填入 OCR 服务地址和密钥：

```dart
static const String ocrEndpoint = 'https://your-ocr-api.com/recognize';
static const String ocrApiKey = 'your-api-key';
```

---

## 数据存储

数据保存在设备本地 SQLite，离线可用，无需网络即可录入和查询（OCR 识别需要网络）。

| 平台 | 存储位置 |
|------|---------|
| Android | `/data/data/<package>/databases/clothing_points.db` |
| iOS | App 沙盒 Documents 目录 |
| Web | 浏览器 IndexedDB |

---

## 扩展计划

- [ ] 多店管理（`store_provider.dart` 已预留接口）
- [ ] 账号登录（`auth_service.dart` 已预留接口）
- [ ] 云端数据同步
- [ ] 积分消费记录明细
- [ ] 数据导出（Excel / CSV）
