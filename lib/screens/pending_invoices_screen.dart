import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/helpers/api_result.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:get_device_info/helpers/context_extension.dart';
import 'package:get_device_info/helpers/functions.dart';
import 'package:get_device_info/screens/invoice_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PendingInvoicesScreen extends StatefulWidget {
  const PendingInvoicesScreen({
    super.key,
    required this.title,
    required this.isPending,
  });
  final String title;
  final bool isPending;

  @override
  State<PendingInvoicesScreen> createState() => _PendingInvoicesScreenState();
}

class _PendingInvoicesScreenState extends State<PendingInvoicesScreen> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InvoiceCubit>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        elevation: 10,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("invoices")
            .where("pending", isEqualTo: widget.isPending)
            .orderBy("timeStamp", descending: true)
            .snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            final invoicesInJson = asyncSnapshot.data!.docs;

            final List<PendingInvoicesClass> invoicesList = invoicesInJson
                .map((inv) => PendingInvoicesClass.fromJson(inv.data()))
                .toList();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<InvoiceCubit>().setPendingList(invoicesList);
            });
            if (invoicesList.isEmpty) {
              return Center(child: Text("لا توجد فواتير"));
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: invoicesList.length,
                      itemBuilder: (context, index) {
                        final invoice = invoicesList[index];
                        final invoiceDate = invoice.timeStamp.toDate();

                        return Container(
                          height: 50,
                          width: context.screenWidth,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextButton(
                            onLongPress: () async {
                              final result = await saveInvoiceWithProductFiles(
                                invoice,
                              );
                              if (!context.mounted) return;
                              switch (result) {
                                case Success(:final data):
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        0,
                                        173,
                                        6,
                                      ),
                                      content: Text(
                                        "تم حفظ الفاتورة في: $data",
                                      ),
                                    ),
                                  );
                                case Failure(:final message):
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        173,
                                        0,
                                        0,
                                      ),
                                      content: Text(message),
                                    ),
                                  );
                              }
                            },
                            onPressed: () async {
                              context.read<InvoiceCubit>().clearDevicesList();

                              for (final dev in invoice.devicesList) {
                                cubit.addToDevicesList(dev, allowAudio: false);
                              }

                              cubit.changeCustomerNameValue(
                                invoice.customerName,
                              );

                              cubit.changeInvoiceType(invoice.invoiceType);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => InvoiceScreen(
                                    isNewInvoice: false,
                                    invoiceDocId: invoice.invoiceDocId,
                                    customerName: invoice.customerName,
                                    invoiceType: invoice.invoiceType,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              alignment: AlignmentDirectional.centerEnd,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: AppColors.primaryColor,
                                  width: .5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat(
                                    "d-M-y h:mm a",
                                  ).format(invoiceDate),
                                  style: GoogleFonts.inter(fontSize: 25),
                                ),
                                Text(
                                  invoice.customerName,
                                  style: GoogleFonts.inter(fontSize: 25),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class PendingInvoicesClass {
  List<DeviceClass> devicesList;
  String customerName;
  String invoiceDocId;
  Timestamp timeStamp;
  String invoiceType;

  PendingInvoicesClass({
    required this.customerName,
    required this.invoiceDocId,
    required this.devicesList,
    required this.invoiceType,
    required this.timeStamp,
  });

  factory PendingInvoicesClass.fromJson(Map<String, dynamic> data) {
    return PendingInvoicesClass(
      customerName: data["customerName"],
      timeStamp: data['timeStamp'],
      invoiceDocId: data["invoiceDoc"],
      invoiceType: data["invoiceType"],
      devicesList: (data["invoiceDevices"] as List)
          .map((element) => DeviceClass.fromJson(element))
          .toList(),
    );
  }
}
