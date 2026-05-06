import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/cubit/invoice_state.dart';
import 'package:get_device_info/helpers/context_extension.dart';
import 'package:get_device_info/helpers/functions.dart';
import 'package:google_fonts/google_fonts.dart';

class DevicesListView extends StatefulWidget {
  const DevicesListView({super.key});

  @override
  State<DevicesListView> createState() => _DevicesListViewState();
}

class _DevicesListViewState extends State<DevicesListView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return Expanded(
          flex: 10,
          child: ListView.builder(
            itemCount: state.devicesList.isEmpty ? 1 : state.devicesList.length,
            itemBuilder: (context, index) {
              late final DeviceClass device;
              if (state.devicesList.isNotEmpty) {
                device = state.devicesList[index];
              }
              return state.devicesList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Align(
                        alignment: AlignmentGeometry.center,
                        child: Text(
                          "يرجى اضافة الاجهزة للاستمرار",
                          style: GoogleFonts.inter(fontSize: 25),
                        ),
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      width: context.screenWidth,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(50, 59, 59, 59),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: AlignmentGeometry.centerLeft,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: context.screenWidth * .2,
                                child: Text(
                                  device.imeiNumber,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(),
                                ),
                              ),
                              SizedBox(
                                width: context.screenWidth * .2,
                                child: Text(
                                  device.activationState,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(),
                                ),
                              ),
                              SizedBox(
                                width: context.screenWidth * .2,
                                child: Text(
                                  device.name,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              context
                                  .read<InvoiceCubit>()
                                  .removeItemFromDevicesList(device);
                            },
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                          ),
                        ],
                      ),
                    );
            },
          ),
        );
      },
    );
  }
}
