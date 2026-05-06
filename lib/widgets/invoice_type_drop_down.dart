import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/cubit/invoice_state.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceTypeDropDown extends StatefulWidget {
  const InvoiceTypeDropDown({super.key});

  @override
  State<InvoiceTypeDropDown> createState() => _InvoiceTypeDropDownState();
}

class _InvoiceTypeDropDownState extends State<InvoiceTypeDropDown> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(width: .5),
                borderRadius: BorderRadius.circular(5),
              ),
              width: 120,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownButton(
                  value: state.invoiceType,
                  items: [
                    DropdownMenuItem(value: "شراء", child: Text("شراء")),
                    DropdownMenuItem(value: "بيع", child: Text("بيع")),
                    DropdownMenuItem(
                      value: "استبدال راجع",
                      child: Text("استبدال راجع"),
                    ),
                    DropdownMenuItem(
                      value: "استبدال خارج",
                      child: Text("استبدال خارج"),
                    ),
                    DropdownMenuItem(value: "مرتجع", child: Text("مرتجع")),
                  ],
                  icon: Container(),
                  menuWidth: 150,
                  focusColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  enableFeedback: false,
                  style: GoogleFonts.inter(color: Colors.black, fontSize: 20),
                  underline: Container(),
                  isExpanded: true,
                  onChanged: (val) {
                    context.read<InvoiceCubit>().changeInvoiceType(val!);
                  },
                ),
              ),
            ),
            SizedBox(width: 20),
            Text(
              "نوع الفاتورة",
              style: GoogleFonts.inter(color: Colors.black, fontSize: 20),
            ),
          ],
        );
      },
    );
  }
}
