import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/cubit/invoice_state.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:get_device_info/helpers/context_extension.dart';
import 'package:get_device_info/widgets/default_divider.dart';
import 'package:get_device_info/widgets/devices_search_button.dart';
import 'package:google_fonts/google_fonts.dart';

class EndOfPage extends StatelessWidget {
  const EndOfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: AlignmentGeometry.centerRight,
                child: DefaultDivider(size: .25),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DevicesSearchButton(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        state.devicesList.length.toString(),
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              List<String> devicesSet = [];
                              state.devicesList.forEach((device) {
                                if (!devicesSet.contains(device.name)) {
                                  devicesSet.add(device.name);
                                }
                              });

                              return AlertDialog(
                                title: Align(
                                  alignment: AlignmentGeometry.centerRight,
                                  child: Text("عدد اجهزة كل نوع"),
                                ),
                                content: SizedBox(
                                  height: context.screenHeight * .2,
                                  width: context.screenWidth * .2,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: devicesSet.length,
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                final device = state.devicesList
                                                    .where(
                                                      (dev) =>
                                                          dev.name ==
                                                          devicesSet[index],
                                                    )
                                                    .length
                                                    .toString();
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(device),
                                                    Text(devicesSet[index]),
                                                  ],
                                                );
                                              },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          "اجمالي عدد الاجهزة => ",
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.inter(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: AppColors.primaryColor, thickness: 1.7),
            ],
          ),
        );
      },
    );
  }
}
