import 'package:flutter/material.dart';
import 'package:get_device_info/helpers/context_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class DevicesListTitle extends StatelessWidget {
  const DevicesListTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ColumnName(name: "رقم الـIMEI"),
        ColumnName(name: "حالة الجهاز"),
        ColumnName(name: "اسم الجهاز"),
      ],
    );
  }
}

class ColumnName extends StatelessWidget {
  final String name;
  const ColumnName({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.screenWidth * .2,
      child: Text(
        name,
        style: GoogleFonts.inter(),
        textAlign: TextAlign.center,
      ),
    );
  }
}
