import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OraDialog extends StatelessWidget {
  static TextStyle titleStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );
  
  static TextStyle messageStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppTheme.textSecondary,
  );

  static TextStyle leftButtonStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppTheme.textSecondary,
  );

  static TextStyle rightButtonStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppTheme.primaryColor,
  );

  final String? leftButtonText;
  final VoidCallback? leftButtonOnPressed;
  final String? rightButtonText;
  final VoidCallback? rightButtonOnPressed;
  final Color? backgroundColor;
  final EdgeInsets? insetPadding;
  final Color attractiveColor;
  final Widget child;

  const OraDialog({
    super.key,
    this.leftButtonText,
    this.leftButtonOnPressed,
    this.rightButtonText,
    this.rightButtonOnPressed,
    this.insetPadding,
    this.attractiveColor = AppTheme.primaryColor,
    this.backgroundColor,
    required this.child,
  });

  factory OraDialog.simpleText(
    String message, {
    String? title,
    String? leftButtonText,
    VoidCallback? leftButtonOnPressed,
    String? rightButtonText,
    VoidCallback? rightButtonOnPressed,
    Color? attractiveColor,
  }) =>
      OraDialog(
        leftButtonText: leftButtonText,
        leftButtonOnPressed: leftButtonOnPressed,
        rightButtonText: rightButtonText,
        rightButtonOnPressed: rightButtonOnPressed,
        attractiveColor: attractiveColor ?? AppTheme.primaryColor,
        child: Flexible(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 70.h),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 28.w, bottom: 28.w, right: 24.w, left: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.from([
                    title == null
                        ? null
                        : Padding(
                            padding: EdgeInsets.only(bottom: 12.w),
                            child: Text(
                              title ?? '',
                              textAlign: TextAlign.center,
                              style: titleStyle,
                            ),
                          ),
                    Text(message,
                        textAlign: TextAlign.center, style: messageStyle),
                  ].where((e) => e != null)),
                ),
              ),
            ),
          ),
        ),
      );

  factory OraDialog.simpleIcon(
    Widget icon, {
    String? message,
    String? leftButtonText,
    VoidCallback? leftButtonOnPressed,
    String? rightButtonText,
    VoidCallback? rightButtonOnPressed,
    Color? attractiveColor,
  }) =>
      OraDialog(
        leftButtonText: leftButtonText,
        leftButtonOnPressed: leftButtonOnPressed,
        rightButtonText: rightButtonText,
        rightButtonOnPressed: rightButtonOnPressed,
        attractiveColor: attractiveColor ?? AppTheme.primaryColor,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 26.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List<Widget>.from([
              icon,
              message != null
                  ? SizedBox(
                      height: 14.w,
                    )
                  : null,
              message != null
                  ? Text(
                      message,
                      style: messageStyle,
                      maxLines: 5,
                      textAlign: TextAlign.center,
                    )
                  : null,
              message != null
                  ? SizedBox(
                      height: 14.w,
                    )
                  : null,
            ].where((e) => e != null)),
          ),
        ),
      );

  factory OraDialog.contentChild(
    Widget child, {
    String? leftButtonText,
    VoidCallback? leftButtonOnPressed,
    String? rightButtonText,
    VoidCallback? rightButtonOnPressed,
    Color? attractiveColor,
  }) =>
      OraDialog(
        leftButtonText: leftButtonText,
        leftButtonOnPressed: leftButtonOnPressed,
        rightButtonText: rightButtonText,
        rightButtonOnPressed: rightButtonOnPressed,
        attractiveColor: attractiveColor ?? AppTheme.primaryColor,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? AppTheme.cardBackground,
      surfaceTintColor: Colors.transparent,
      insetPadding:
          insetPadding ?? EdgeInsets.symmetric(horizontal: 30.w, vertical: 40),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLarge))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.from([
          child,
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusLarge),
                  bottomRight: Radius.circular(AppTheme.radiusLarge)),
            ),
            child: Column(
              children: [
                Divider(
                  color: AppTheme.dividerColor,
                  height: 1.h,
                ),
                Row(
                  children: List<Widget>.from([
                    leftButtonText == null
                        ? null
                        : Expanded(
                            child: SizedBox(
                              height: 50.h,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    fixedSize: Size.fromHeight(50.h),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => leftButtonOnPressed?.call(),
                                  child: Text(leftButtonText ?? '',
                                      textAlign: TextAlign.center,
                                      style: leftButtonStyle)),
                            ),
                          ),
                    leftButtonText == null
                        ? null
                        : Container(
                            width: 1.w,
                            height: 50.h,
                            color: AppTheme.dividerColor,
                          ),
                    rightButtonText == null
                        ? null
                        : Expanded(
                            child: SizedBox(
                              height: 50.h,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    fixedSize: Size.fromHeight(50.h),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => rightButtonOnPressed?.call(),
                                  child: Text(rightButtonText ?? '',
                                      textAlign: TextAlign.center,
                                      style: rightButtonStyle.copyWith(color: attractiveColor))),
                            ),
                          ),
                  ].where((e) => e != null)),
                ),
              ],
            ),
          )
        ].where((e) => e != null)),
      ),
    );
  }
}
