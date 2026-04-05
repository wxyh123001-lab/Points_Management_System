import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              AppConfig.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // TODO: 后续在此添加更多功能条目
            // 例如：门店切换、账号设置、操作日志等
          ],
        ),
      ),
    );
  }
}
