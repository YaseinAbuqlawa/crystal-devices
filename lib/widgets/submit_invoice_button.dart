import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/cubit/invoice_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class SubmitInvoiceButton extends StatelessWidget {
  final FirebaseFirestore firestore;
  final String invoiceDocId;
  final bool saveAsDraft;
  final bool submitEdit;

  const SubmitInvoiceButton({
    super.key,
    required this.firestore,
    required this.submitEdit,
    required this.saveAsDraft,
    required this.invoiceDocId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return TextButton(
          onPressed: () async {
            if (state.devicesList.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color.fromARGB(255, 173, 0, 0),
                  content: Text("يرجى اضافة الاجهزة قبل تأكيد الفاتورة"),
                ),
              );
            } else if (state.customerName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color.fromARGB(255, 173, 0, 0),
                  content: Text("يرجى كتابة اسم العميل قبل تأكيد الفاتورة"),
                ),
              );
            } else {
              try {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("جاري ارسال البيانات"),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: const CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  ),
                );

                if (submitEdit) {
                  await firestore
                      .collection("invoices")
                      .doc(invoiceDocId)
                      .update({
                        "invoiceType": state.invoiceType,
                        "pending": saveAsDraft,
                        "lastUpdate": Timestamp.now(),
                        "customerName": state.customerName,
                        "invoiceDevices": state.devicesList
                            .map(
                              (device) => {
                                "deviceName": device.name,
                                "imei": device.imeiNumber,
                                "activationState": device.activationState,
                              },
                            )
                            .toList(),
                      });
                } else {
                  final invoiceDoc = firestore.collection("invoices").doc();

                  await invoiceDoc.set({
                    "invoiceType": state.invoiceType,
                    "pending": saveAsDraft,
                    "invoiceDoc": invoiceDoc.id,
                    "timeStamp": Timestamp.now(),
                    "customerName": state.customerName,
                    "invoiceDevices": state.devicesList
                        .map(
                          (device) => {
                            "deviceName": device.name,
                            "imei": device.imeiNumber,
                            "activationState": device.activationState,
                          },
                        )
                        .toList(),
                  });
                }
                if (!context.mounted) return;
                context.read<InvoiceCubit>().clearDevicesList();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color.fromARGB(255, 0, 173, 6),
                    content: Text("تم ارسال الاجهزة بنجاح"),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color.fromARGB(255, 173, 0, 0),
                    content: Text("فشل ارسال الاجهزة $e"),
                  ),
                );
              }
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: saveAsDraft
                ? Colors.white
                : AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
          child: Text(
            saveAsDraft ? "حفظ كـ مسودة" : "تاكيد الفاتورة",
            style: GoogleFonts.inter(
              color: saveAsDraft ? AppColors.primaryColor : Colors.white,
            ),
          ),
        );
      },
    );
  }
}
