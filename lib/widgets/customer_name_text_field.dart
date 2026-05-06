import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_device_info/cubit/invoice_cubit.dart';
import 'package:get_device_info/helpers/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerNameTextField extends StatefulWidget {
  const CustomerNameTextField({super.key, required this.customerName});
  final String customerName;

  @override
  State<CustomerNameTextField> createState() => _CustomerNameTextFieldState();
}

class _CustomerNameTextFieldState extends State<CustomerNameTextField> {
  late final TextEditingController customerName;

  @override
  void initState() {
    super.initState();
    customerName = TextEditingController(text: widget.customerName);
  }

  @override
  void dispose() {
    customerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 50,
          width: 150,
          child: TextField(
            controller: customerName,
            textAlign: TextAlign.center,
            style: TextStyle(),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              focusColor: AppColors.primaryColor,
              fillColor: AppColors.primaryColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onChanged: (value) {
              context.read<InvoiceCubit>().changeCustomerNameValue(value);
            },
          ),
        ),
        SizedBox(width: 20),
        Text(
          "اسم العميل",
          style: GoogleFonts.inter(color: Colors.black, fontSize: 20),
        ),
      ],
    );
  }
}
