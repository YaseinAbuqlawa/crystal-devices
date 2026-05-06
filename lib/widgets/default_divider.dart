import 'package:flutter/material.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:get_device_info/helpers/context_extension.dart';

class DefaultDivider extends StatelessWidget {
  final double size;
  const DefaultDivider({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.screenWidth * size,
      child: Divider(color: AppColors.primaryColor, thickness: 1.7),
    );
  }
}
