import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/cubit/invoice_state.dart';
import 'package:get_device_info/widgets/customer_name_text_field.dart';
import 'package:get_device_info/widgets/end_of_page.dart';
import 'package:get_device_info/widgets/invoice_type_drop_down.dart';
import 'package:get_device_info/widgets/submit_invoice_button.dart';
import 'package:get_device_info/widgets/devices_list_title.dart';
import 'package:get_device_info/widgets/devices_list_view.dart';
import 'package:get_device_info/widgets/default_divider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({
    super.key,
    required this.isNewInvoice,
    this.invoiceDocId = "",
    this.customerName = "",
    this.invoiceType = "شراء",
  });
  final String customerName;
  final String invoiceDocId;
  final String invoiceType;
  final bool isNewInvoice;

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 10,
            foregroundColor: Colors.white,
            title: Text(
              widget.isNewInvoice ? "فاتورة جديدة" : "تعديل الفاتورة",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SubmitInvoiceButton(
                            firestore: firestore,
                            saveAsDraft: false,
                            invoiceDocId: widget.invoiceDocId,
                            submitEdit: !widget.isNewInvoice,
                          ),

                          SizedBox(width: 10),

                          SubmitInvoiceButton(
                            firestore: firestore,
                            saveAsDraft: true,
                            invoiceDocId: widget.invoiceDocId,
                            submitEdit: !widget.isNewInvoice,
                          ),
                        ],
                      ),

                      Text(
                        "بيانات الفاتورة",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DefaultDivider(size: .25),
                        DefaultDivider(size: .25),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomerNameTextField(customerName: widget.customerName),
                      InvoiceTypeDropDown(),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      color: AppColors.primaryColor,
                      thickness: 1.7,
                    ),
                  ),

                  DevicesListTitle(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Divider(
                      color: AppColors.primaryColor,
                      thickness: 1.7,
                    ),
                  ),

                  DevicesListView(),

                  EndOfPage(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
