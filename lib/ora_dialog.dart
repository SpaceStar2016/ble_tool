import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OraDialog extends StatelessWidget {
  static TextStyle titleStyle = TextStyle(
      fontSize: 56 / 3,
      fontWeight: FontWeight.w500,
      color: Colors.black);
  static TextStyle messageStyle = TextStyle(
      fontSize: 44 / 3,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF383C47));

  static TextStyle leftButtonStyle = TextStyle(
      fontSize: 48 / 3,
      fontWeight: FontWeight.w500,
      color: Colors.black.withOpacity(0.5));

  static TextStyle rightButtonStyle = TextStyle(
      fontSize: 48 / 3,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF444957));

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
    this.attractiveColor = Colors.black,
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
        attractiveColor: attractiveColor ?? Colors.black,
        child: Flexible(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 210.h),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 84.w, bottom: 84.w, right: 72.w, left: 72.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.from([
                    title == null
                        ? null
                        : Padding(
                            padding: EdgeInsets.only(bottom: 20.w),
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
        attractiveColor: attractiveColor ?? Colors.black,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80.h, horizontal: 80.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List<Widget>.from([
              icon,
              message != null
                  ? SizedBox(
                      height: 40.w,
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
                      height: 40.w,
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
        attractiveColor: attractiveColor ?? Colors.black,
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle =
        TextStyle(fontSize: 44 / 3, color: const Color(0xFF8F8F8F));
    return Dialog(
      backgroundColor: backgroundColor ?? Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding:
          insetPadding ?? EdgeInsets.symmetric(horizontal: 88.w, vertical: 40),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(48.w))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.from([
          child,
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40.w),
                  bottomRight: Radius.circular(40.w)),
            ),
            child: Column(
              children: [
                Divider(
                  color: const Color(0xFF3D3D3D).withOpacity(0.08),
                  height: 2.h,
                ),
                Row(
                  children: List<Widget>.from([
                    leftButtonText == null
                        ? null
                        : Expanded(
                            child: SizedBox(
                              height: 138.h,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    fixedSize: Size.fromHeight(138.h),
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
                            width: 2.w,
                            height: 138.h,
                            color: const Color(0xFF3D3D3D).withOpacity(0.08),
                          ),
                    rightButtonText == null
                        ? null
                        : Expanded(
                            child: SizedBox(
                              height: 138.h,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    fixedSize: Size.fromHeight(138.h),
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

