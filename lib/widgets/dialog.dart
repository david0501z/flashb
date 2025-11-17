import 'dart:math';

import 'package:fl_clash/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommonDialog extends ConsumerWidget {
  final String title;
  final Widget? child;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final bool overrideScroll;
  final Color? backgroundColor;

  const CommonDialog({
    super.key,
    required this.title,
    this.actions,
    this.child,
    this.padding,
    this.overrideScroll = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(viewSizeProvider);
    
    // 如果viewSize还是初始的Size.zero，则使用当前context的MediaQuery
    final effectiveSize = size == Size.zero 
        ? MediaQuery.of(context).size 
        : size;
        
    return AlertDialog(
      title: Text(title),
      actions: actions,
      contentPadding: padding,
      backgroundColor: backgroundColor,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: min(
            max(effectiveSize.height - 40, 0),
            500,
          ),
          maxWidth: 300,
        ),
        width: max(effectiveSize.width - 40, 0),
        child: !overrideScroll
            ? SingleChildScrollView(
                child: child,
              )
            : child,
      ),
    );
  }
}

class CommonModal extends ConsumerWidget {
  final Widget? child;

  const CommonModal({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(viewSizeProvider);
    
    // 如果viewSize还是初始的Size.zero，则使用当前context的MediaQuery
    final effectiveSize = size == Size.zero 
        ? MediaQuery.of(context).size 
        : size;
        
    return Center(
      child: Container(
        width: effectiveSize.width * 0.85,
        height: effectiveSize.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
