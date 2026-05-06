import 'package:audioplayers/audioplayers.dart';
import 'package:get_device_info/cubit/invoice_state.dart';
import 'package:get_device_info/helpers/functions.dart';
import 'package:get_device_info/screens/pending_invoices_screen.dart';
import 'package:bloc/bloc.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  InvoiceCubit() : super(InvoiceState());

  void changeSearchValue(bool searching) {
    emit(state.copyWith(searching: searching));
  }

  void changeCustomerNameValue(String customerName) {
    emit(state.copyWith(customerName: customerName));
  }

  void addToDevicesList(DeviceClass deviceClass, {required bool allowAudio}) {
    bool noHaveBefore = state.devicesList
        .where((dev) => dev.imeiNumber == deviceClass.imeiNumber)
        .isEmpty;
    bool haveBeforeNotLast = false;
    if (noHaveBefore) {
      if (allowAudio) {
        _audioPlayer.play(AssetSource("got_it.MP3"));
      }

      emit(state.copyWith(devicesList: [...state.devicesList, deviceClass]));
    } else {
      haveBeforeNotLast =
          state.devicesList.last.imeiNumber != deviceClass.imeiNumber;
    }
    if (haveBeforeNotLast && allowAudio) {
      _audioPlayer.play(AssetSource("have_before.MP3"));
    }
  }

  void removeItemFromDevicesList(DeviceClass device) {
    final updatedList = List<DeviceClass>.from(state.devicesList)
      ..remove(device);

    emit(state.copyWith(devicesList: updatedList));
  }

  void clearDevicesList() {
    emit(
      state.copyWith(
        customerName: "",
        devicesList: [],
        searching: false,
        invoiceType: "شراء",
      ),
    );
  }

  void changeInvoiceType(String invoiceType) {
    emit(state.copyWith(invoiceType: invoiceType));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }

  void setPendingList(List<PendingInvoicesClass> pendingInvoicesList) {
    emit(state.copyWith(pendingInvoicesList: pendingInvoicesList));
  }
}
