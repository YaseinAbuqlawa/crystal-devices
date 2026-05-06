import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_device_info/helpers/functions.dart';
import 'package:get_device_info/screens/pending_invoices_screen.dart';
part 'invoice_state.freezed.dart';

@freezed
abstract class InvoiceState with _$InvoiceState {
  const factory InvoiceState({
    @Default([]) List<DeviceClass> devicesList,
    @Default([]) List<PendingInvoicesClass> pendingInvoicesList,
    @Default("شراء") String invoiceType,
    @Default(false) bool searching,
    @Default("") String customerName,
  }) = _initial;
}
