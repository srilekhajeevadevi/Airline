import 'dart:io';
import 'dart:convert';
import 'package:integration_test/integration_test_driver.dart' as driver;

Future<void> main() {
  final File logFile = File('test_results.json');
  if (logFile.existsSync()) {
    logFile.deleteSync();
  }

  return driver.integrationDriver(
    onScreenshot: (String name, List<int> imageBytes, [Map<String, dynamic>? args]) async {
      final File image = File('screenshots/$name.png');
      await image.create(recursive: true);
      await image.writeAsBytes(imageBytes);
      return true;
    },
    requestHandler: (String? requestJson) async {
      if (requestJson != null) {
        try {
          final Map<String, dynamic> request = jsonDecode(requestJson);
          if (request['action'] == 'log_result') {
            final Map<String, dynamic> testResult = request['result'];
            List<dynamic> currentResults = [];
            if (logFile.existsSync()) {
              final String content = logFile.readAsStringSync();
              if (content.isNotEmpty) {
                currentResults = jsonDecode(content);
              }
            }
            currentResults.add(testResult);
            logFile.writeAsStringSync(jsonEncode(currentResults), flush: true);
            return 'logged';
          }
        } catch (e) {
          return 'error: $e';
        }
      }
      return 'ignored';
    },
  );
}
