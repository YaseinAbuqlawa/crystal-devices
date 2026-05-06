import "dart:convert";
import "dart:io";
import "package:file_picker/file_picker.dart";
import "package:get_device_info/helpers/api_result.dart";
import "package:get_device_info/helpers/string_extension.dart";
import "package:get_device_info/screens/pending_invoices_screen.dart";
import "package:intl/intl.dart";

const List<int> _standardStorageTiers = [16, 32, 64, 128, 256, 512, 1024];

/// Parses ideviceinfo key-value output (e.g. "Key: Value\n") into a map.
Map<String, String> _parseKeyValueOutput(String output) {
  final Map<String, String> data = {};
  for (final line in output.split("\n")) {
    if (line.contains(': ')) {
      final parts = line.split(': ');
      if (parts.length >= 2) {
        data[parts[0].trim()] = parts.sublist(1).join(': ').trim();
      }
    }
  }
  return data;
}

/// Snaps a raw GB value to the closest standard iOS storage tier.
int _nearestStorageTier(int rawGB) {
  int closest = _standardStorageTiers.first;
  int smallestDiff = (rawGB - closest).abs();
  for (final tier in _standardStorageTiers) {
    final diff = (rawGB - tier).abs();
    if (diff < smallestDiff) {
      smallestDiff = diff;
      closest = tier;
    }
  }
  return closest;
}

Future<ApiResult<DeviceClass>> readDeviceInfo() async {
  try {
    final deviceInfoResult = await Process.run('ideviceinfo', []);

    if (deviceInfoResult.exitCode != 0) {
      return Failure("ideviceinfo failed: ${deviceInfoResult.stderr}");
    }

    final fullInfo = deviceInfoResult.stdout.toString();

    Map<String, String> storageData = {};
    final deviceStorage = await Process.run('ideviceinfo', [
      '-q',
      'com.apple.disk_usage',
    ]);
    if (deviceStorage.exitCode == 0) {
      storageData = _parseKeyValueOutput(deviceStorage.stdout.toString());
    }

    return parseDeviceInfo(fullInfo, storageData);
  } catch (e) {
    return Failure("$e");
  }
}

ApiResult<DeviceClass> parseDeviceInfo(
  String fullInfo,
  Map<String, String> deviceStorage,
) {
  final deviceData = _parseKeyValueOutput(fullInfo);

  final productType = deviceData['ProductType'] ?? 'غير محدد';
  String deviceName = _iosDeviceNames[productType] ?? productType;
  final imei = deviceName.contains("iPad")
      ? (deviceData["SerialNumber"] ?? 'غير متاح')
      : (deviceData['InternationalMobileEquipmentIdentity'] ?? 'غير متاح');
  final activationState = deviceData['ActivationState'] ?? 'غير محدد';

  final originalStorageCapacity = deviceStorage['TotalDiskCapacity'];

  if (originalStorageCapacity == null) {
    return Failure("فشل في قراءة سعة التخزين");
  }

  // Decimal GB (10^9) — matches how manufacturers advertise storage capacity.
  final storageBytes = originalStorageCapacity.toDouble();
  final rawGB = (storageBytes / 1000000000).round();

  if (rawGB == 0) {
    return Failure("فشل في قراءة سعة التخزين");
  }

  final storageGB = _nearestStorageTier(rawGB);
  deviceName += ' ${storageGB}GB';

  return Success(
    DeviceClass(
      activationState: activationState,
      imeiNumber: imei,
      name: deviceName,
    ),
  );
}

Future<ApiResult<String>> saveInvoiceWithProductFiles(
  PendingInvoicesClass invoice, [
  String? basePath,
]) async {
  try {
    String targetPath;

    if (basePath == null) {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'اختر مجلد حفظ الفاتورة',
      );

      if (selectedDirectory == null) {
        return Failure("تم إلغاء العملية من قبل المستخدم");
      }
      targetPath = selectedDirectory;
    } else {
      targetPath = basePath;
    }

    final formattedDate = DateFormat(
      "d-MM-y hh.mm a",
    ).format(invoice.timeStamp.toDate());

    String folderName = '${invoice.customerName} $formattedDate';
    folderName = folderName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    final invoiceFolderPath = '$targetPath${Platform.pathSeparator}$folderName';
    final invoiceFolder = Directory(invoiceFolderPath);

    if (!await invoiceFolder.exists()) {
      await invoiceFolder.create(recursive: true);
    }

    for (final product in invoice.devicesList.toSet()) {
      final cleanProductName = product.name.replaceAll(
        RegExp(r'[<>:"/\\|?*]'),
        '_',
      );

      final fileName = '$cleanProductName.txt';
      final filePath = '$invoiceFolderPath${Platform.pathSeparator}$fileName';

      final productFile = File(filePath);
      final deviceSerials = <String>[];
      for (final device in invoice.devicesList.where(
        (device) => device.name == product.name,
      )) {
        deviceSerials.add("${device.imeiNumber}\n");
      }
      await productFile.writeAsString(
        deviceSerials.toString().replaceAll(RegExp(r'[\[\], \t]+'), ""),
        encoding: Encoding.getByName('utf-8')!,
      );
    }

    return Success(invoiceFolderPath);
  } catch (e) {
    return Failure("$e");
  }
}

const Map<String, String> _iosDeviceNames = {
  "iPhone1,1": "iPhone (Original)",
  "iPhone1,2": "iPhone 3G",
  "iPhone2,1": "iPhone 3GS",
  "iPhone3,1": "iPhone 4 (GSM)",
  "iPhone3,2": "iPhone 4 (Rev A)",
  "iPhone3,3": "iPhone 4 (CDMA)",
  "iPhone4,1": "iPhone 4S",
  "iPhone5,1": "iPhone 5 (GSM)",
  "iPhone5,2": "iPhone 5 (GSM+CDMA)",
  "iPhone5,3": "iPhone 5C (GSM)",
  "iPhone5,4": "iPhone 5C (Global)",
  "iPhone6,1": "iPhone 5S (GSM)",
  "iPhone6,2": "iPhone 5S (Global)",
  "iPhone7,1": "iPhone 6 Plus",
  "iPhone7,2": "iPhone 6",
  "iPhone8,1": "iPhone 6s",
  "iPhone8,2": "iPhone 6s Plus",
  "iPhone8,4": "iPhone SE (1st Gen)",
  "iPhone9,1": "iPhone 7",
  "iPhone9,2": "iPhone 7 Plus",
  "iPhone9,3": "iPhone 7",
  "iPhone9,4": "iPhone 7 Plus",
  "iPhone10,1": "iPhone 8",
  "iPhone10,2": "iPhone 8 Plus",
  "iPhone10,3": "iPhone X (Global)",
  "iPhone10,4": "iPhone 8",
  "iPhone10,5": "iPhone 8 Plus",
  "iPhone10,6": "iPhone X (GSM)",
  "iPhone11,2": "iPhone XS",
  "iPhone11,4": "iPhone XS Max",
  "iPhone11,6": "iPhone XS Max (Global)",
  "iPhone11,8": "iPhone XR",
  "iPhone12,1": "iPhone 11",
  "iPhone12,3": "iPhone 11 Pro",
  "iPhone12,5": "iPhone 11 Pro Max",
  "iPhone12,8": "iPhone SE (2nd Gen)",
  "iPhone13,1": "iPhone 12 Mini",
  "iPhone13,2": "iPhone 12",
  "iPhone13,3": "iPhone 12 Pro",
  "iPhone13,4": "iPhone 12 Pro Max",
  "iPhone14,2": "iPhone 13 Pro",
  "iPhone14,3": "iPhone 13 Pro Max",
  "iPhone14,4": "iPhone 13 Mini",
  "iPhone14,5": "iPhone 13",
  "iPhone14,6": "iPhone SE (3rd Gen)",
  "iPhone14,7": "iPhone 14",
  "iPhone14,8": "iPhone 14 Plus",
  "iPhone15,2": "iPhone 14 Pro",
  "iPhone15,3": "iPhone 14 Pro Max",
  "iPhone15,4": "iPhone 15",
  "iPhone15,5": "iPhone 15 Plus",
  "iPhone16,1": "iPhone 15 Pro",
  "iPhone16,2": "iPhone 15 Pro Max",
  "iPhone17,1": "iPhone 16 Pro",
  "iPhone17,2": "iPhone 16 Pro Max",
  "iPhone17,3": "iPhone 16",
  "iPhone17,4": "iPhone 16 Plus",
  "iPhone17,5": "iPhone 16e",
  "iPhone18,1": "iPhone 17 Pro",
  "iPhone18,2": "iPhone 17 Pro Max",
  "iPhone18,3": "iPhone 17",
  "iPhone18,4": "iPhone Air",
  'iPad1,1': 'iPad (1st Gen)',
  'iPad1,2': 'iPad 3G',
  'iPad2,1': 'iPad (2nd Gen)',
  'iPad2,2': 'iPad (2nd Gen, GSM)',
  'iPad2,3': 'iPad (2nd Gen, CDMA)',
  'iPad2,4': 'iPad (2nd Gen, Rev)',
  'iPad3,1': 'iPad (3rd Gen, WiFi)',
  'iPad3,2': 'iPad (3rd Gen, CDMA)',
  'iPad3,3': 'iPad (3rd Gen, GSM)',
  'iPad2,5': 'iPad mini (1st Gen)',
  'iPad2,6': 'iPad mini (LTE)',
  'iPad2,7': 'iPad mini (CDMA+LTE)',
  'iPad3,4': 'iPad (4th Gen, WiFi)',
  'iPad3,5': 'iPad (4th Gen, GSM+Cellular)',
  'iPad3,6': 'iPad (4th Gen, Global)',
  'iPad4,1': 'iPad Air (1st Gen, WiFi)',
  'iPad4,2': 'iPad Air (1st Gen, Cellular)',
  'iPad4,3': 'iPad Air (1st Gen, China)',
  'iPad4,4': 'iPad mini Retina (WiFi)',
  'iPad4,5': 'iPad mini Retina (Cellular)',
  'iPad4,6': 'iPad mini Retina (China)',
  'iPad4,7': 'iPad mini 3 (WiFi)',
  'iPad4,8': 'iPad mini 3 (Cellular)',
  'iPad4,9': 'iPad mini 3 (China)',
  'iPad5,1': 'iPad mini 4 (WiFi)',
  'iPad5,2': 'iPad mini 4 (WiFi+Cellular)',
  'iPad5,3': 'iPad Air 2 (WiFi)',
  'iPad5,4': 'iPad Air 2 (Cellular)',
  'iPad6,3': 'iPad Pro 9.7" (WiFi)',
  'iPad6,4': 'iPad Pro 9.7" (WiFi+LTE)',
  'iPad6,7': 'iPad Pro 12.9" (WiFi)',
  'iPad6,8': 'iPad Pro 12.9" (WiFi+LTE)',
  'iPad6,11': 'iPad (5th Gen, WiFi)',
  'iPad6,12': 'iPad (5th Gen, WiFi+Cellular)',
  'iPad7,1': 'iPad Pro 12.9" (2nd Gen, WiFi)',
  'iPad7,2': 'iPad Pro 12.9" (2nd Gen, WiFi+Cellular)',
  'iPad7,3': 'iPad Pro 10.5" (WiFi)',
  'iPad7,4': 'iPad Pro 10.5" (WiFi+Cellular)',
  'iPad7,5': 'iPad (6th Gen, WiFi)',
  'iPad7,6': 'iPad (6th Gen, WiFi+Cellular)',
  'iPad7,11': 'iPad (7th Gen, WiFi)',
  'iPad7,12': 'iPad (7th Gen, WiFi+Cellular)',
  'iPad8,1': 'iPad Pro 11" (1st Gen, WiFi)',
  'iPad8,2': 'iPad Pro 11" (1st Gen, WiFi+Cellular)',
  'iPad8,3': 'iPad Pro 11" (1st Gen, WiFi)',
  'iPad8,4': 'iPad Pro 11" (1st Gen, WiFi+Cellular)',
  'iPad8,5': 'iPad Pro 12.9" (3rd Gen, WiFi)',
  'iPad8,6': 'iPad Pro 12.9" (3rd Gen, WiFi+Cellular)',
  'iPad8,7': 'iPad Pro 12.9" (3rd Gen, WiFi)',
  'iPad8,8': 'iPad Pro 12.9" (3rd Gen, WiFi+Cellular)',
  'iPad8,9': 'iPad Pro 11" (2nd Gen, WiFi)',
  'iPad8,10': 'iPad Pro 11" (2nd Gen, WiFi+Cellular)',
  'iPad8,11': 'iPad Pro 12.9" (4th Gen, WiFi)',
  'iPad8,12': 'iPad Pro 12.9" (4th Gen, WiFi+Cellular)',
  'iPad11,1': 'iPad mini (5th Gen, WiFi)',
  'iPad11,2': 'iPad mini (5th Gen, WiFi+Cellular)',
  'iPad11,3': 'iPad Air (3rd Gen, WiFi)',
  'iPad11,4': 'iPad Air (3rd Gen, WiFi+Cellular)',
  'iPad11,6': 'iPad (8th Gen, WiFi)',
  'iPad11,7': 'iPad (8th Gen, WiFi+Cellular)',
  'iPad12,1': 'iPad (9th Gen, WiFi)',
  'iPad12,2': 'iPad (9th Gen, WiFi+Cellular)',
  'iPad13,1': 'iPad Air (4th Gen, WiFi)',
  'iPad13,2': 'iPad Air (4th Gen, WiFi+Cellular)',
  'iPad13,4': 'iPad Pro 11" (3rd Gen, WiFi)',
  'iPad13,5': 'iPad Pro 11" (3rd Gen, WiFi+Cellular)',
  'iPad13,6': 'iPad Pro 11" (3rd Gen, WiFi)',
  'iPad13,7': 'iPad Pro 11" (3rd Gen, WiFi+Cellular)',
  'iPad13,8': 'iPad Pro 12.9" (5th Gen, WiFi)',
  'iPad13,9': 'iPad Pro 12.9" (5th Gen, WiFi+Cellular)',
  'iPad13,10': 'iPad Pro 12.9" (5th Gen, WiFi)',
  'iPad13,11': 'iPad Pro 12.9" (5th Gen, WiFi+Cellular)',
  'iPad14,1': 'iPad mini (6th Gen, WiFi)',
  'iPad14,2': 'iPad mini (6th Gen, WiFi+Cellular)',
};

class DeviceClass {
  String name;
  String imeiNumber;
  String activationState;

  DeviceClass({
    required this.activationState,
    required this.imeiNumber,
    required this.name,
  });

  factory DeviceClass.fromJson(Map<String, dynamic> data) {
    return DeviceClass(
      activationState: data["activationState"],
      imeiNumber: data["imei"],
      name: data["deviceName"],
    );
  }
}
