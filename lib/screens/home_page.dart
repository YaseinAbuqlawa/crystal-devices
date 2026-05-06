import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/helpers/context_extension.dart';
import 'package:get_device_info/screens/invoice_screen.dart';
import 'package:get_device_info/screens/pending_invoices_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 10,
        title: Text("الصفحة الرئيسية", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 50,
              width: context.screenWidth,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: () {
                  context.read<InvoiceCubit>().clearDevicesList();

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => InvoiceScreen(
                        isNewInvoice: true,
                        invoiceDocId: "",
                        customerName: '',
                      ),
                    ),
                  );
                },
                child: Text(
                  "فاتورة جديدة",
                  style: GoogleFonts.inter(fontSize: 25),
                ),
                style: TextButton.styleFrom(
                  alignment: AlignmentDirectional.centerEnd,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.primaryColor, width: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              width: context.screenWidth,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: () async {
                  final invoicesInJson = await FirebaseFirestore.instance
                      .collection("invoices")
                      .where("pending", isEqualTo: true)
                      .orderBy("timeStamp", descending: true)
                      .get();

                  final List<PendingInvoicesClass> invoicesList = invoicesInJson
                      .docs
                      .map((inv) => PendingInvoicesClass.fromJson(inv.data()))
                      .toList();

                  if (!context.mounted) return;
                  context.read<InvoiceCubit>().setPendingList(invoicesList);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PendingInvoicesScreen(
                        title: "الفواتير المعلقة",
                        isPending: true,
                      ),
                    ),
                  );
                },
                child: Text(
                  "الفواتير المعلقة",
                  style: GoogleFonts.inter(fontSize: 25),
                ),
                style: TextButton.styleFrom(
                  alignment: AlignmentDirectional.centerEnd,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.primaryColor, width: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Container(
              height: 50,
              width: context.screenWidth,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PendingInvoicesScreen(
                        title: "الفواتير المكتملة",
                        isPending: false,
                      ),
                    ),
                  );
                },
                child: Text(
                  "الفواتير المكتملة",
                  style: GoogleFonts.inter(fontSize: 25),
                ),
                style: TextButton.styleFrom(
                  alignment: AlignmentDirectional.centerEnd,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.primaryColor, width: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
