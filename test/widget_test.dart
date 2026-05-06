import 'package:flutter_test/flutter_test.dart';
import 'package:get_device_info/helpers/api_result.dart';

void main() {
  group('ApiResult', () {
    test('Success holds data', () {
      const ApiResult<String> result = Success('ok');
      switch (result) {
        case Success(:final data):
          expect(data, 'ok');
        case Failure():
          fail('Expected Success');
      }
    });

    test('Failure holds message', () {
      const ApiResult<String> result = Failure('error');
      switch (result) {
        case Success():
          fail('Expected Failure');
        case Failure(:final message):
          expect(message, 'error');
      }
    });
  });
}
