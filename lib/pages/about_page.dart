import 'package:flutter/material.dart';
import '../config/constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text(AppConstants.appName),
            subtitle: Text('到达即提醒 · P0 版本'),
          ),
          Divider(),
          ListTile(
            title: Text('当前能力'),
            subtitle: Text('地址库 / 半径设定 / 频率设定 / 进出围栏判定 / 普通通知'),
          ),
          ListTile(
            title: Text('尚未包含'),
            subtitle: Text('AI 提醒、语音播报、云同步、用户体系'),
          ),
        ],
      ),
    );
  }
}
