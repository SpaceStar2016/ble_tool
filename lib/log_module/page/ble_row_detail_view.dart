import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';

import '../../app_base_page.dart';

class BleRowDetailView extends AppBaseStatefulPage {
  const BleRowDetailView({super.key});

  @override
  State<BleRowDetailView> createState() => _BleRowDetailViewState();
}

class _BleRowDetailViewState extends AppBaseStatefulPageState<BleRowDetailView> {
  @override
  String get pageTitle => '详情';

  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }

  @override
  Widget body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.construction_rounded,
              size: 48,
              color: AppTheme.warningColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          const Text(
            '功能开发中...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
