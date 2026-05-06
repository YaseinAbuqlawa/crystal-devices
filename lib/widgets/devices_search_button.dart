import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/cubit/invoice_state.dart';
import 'package:get_device_info/helpers/api_result.dart';
import 'package:get_device_info/helpers/functions.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DevicesSearchButton extends StatefulWidget {
  const DevicesSearchButton({super.key});

  @override
  State<DevicesSearchButton> createState() => _DevicesSearchButtonState();
}

class _DevicesSearchButtonState extends State<DevicesSearchButton> {
  bool _scanning = false;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context.read<InvoiceCubit>().stream.listen((state) {
      if (!state.searching && _scanning) {
        _scanning = false;
      }
    });
  }

  @override
  void dispose() {
    _scanning = false;
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _scanLoop(InvoiceCubit cubit) async {
    while (_scanning) {
      final result = await readDeviceInfo();
      if (!_scanning) break;
      switch (result) {
        case Success(:final data):
          if (data.imeiNumber.isNotEmpty && data.imeiNumber != "غير متاح") {
            cubit.addToDevicesList(data, allowAudio: true);
          }
        case Failure():
          break;
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final InvoiceCubit cubit = BlocProvider.of<InvoiceCubit>(context);
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return TextButton(
          onPressed: () {
            if (!state.searching) {
              _scanning = true;
              cubit.changeSearchValue(true);
              _scanLoop(cubit);
            } else {
              _scanning = false;
              cubit.changeSearchValue(false);
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: state.searching
                ? const Color.fromARGB(255, 224, 15, 0)
                : AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
          child: Text(
            state.searching ? "ايقاف عملية البحث" : "ابدأ البحث عن الاجهزة",
            style: GoogleFonts.inter(color: Colors.white),
          ),
        );
      },
    );
  }
}
