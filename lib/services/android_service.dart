import 'package:flutter/services.dart';
import 'package:neostation/services/logger_service.dart';

/// Mirrors native Android app categories used by the method channel scanner.
enum AndroidAppCategory {
  game('game'),
  system('system'),
  audio('audio'),
  video('video'),
  image('image'),
  social('social'),
  news('news'),
  maps('maps'),
  productivity('productivity'),
  other('other');

  final String value;
  const AndroidAppCategory(this.value);
}

class AndroidService {
  static const MethodChannel _channel = MethodChannel(
    'com.neogamelab.neostation/game',
  );

  static final _log = LoggerService.instance;

  static Future<List<Map<String, dynamic>>> getInstalledApps({
    List<AndroidAppCategory>? includeCategories,
    List<AndroidAppCategory>? excludeCategories,
  }) async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod(
        'getInstalledApps',
        {
          'includeCategories': includeCategories?.map((c) => c.value).toList(),
          'excludeCategories': excludeCategories?.map((c) => c.value).toList(),
        },
      );

      return apps.map((dynamic item) {
        final Map<Object?, Object?> map = item as Map<Object?, Object?>;
        return map.map((key, value) => MapEntry(key.toString(), value));
      }).toList();
    } on PlatformException catch (e) {
      _log.e("Failed to get installed apps: '${e.message}'.");
      return [];
    }
  }

  static Future<bool> launchPackage(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('launchPackage', {
        'packageName': packageName,
      });
      return result;
    } on PlatformException catch (e) {
      _log.e("Failed to launch package: '${e.message}'.");
      return false;
    }
  }

  static Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final Uint8List? iconData = await _channel.invokeMethod('getAppIcon', {
        'packageName': packageName,
      });
      return iconData;
    } on PlatformException catch (e) {
      _log.e("Failed to get app icon: '${e.message}'.");
      return null;
    }
  }

  static Future<bool> isPackageInstalled(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('isPackageInstalled', {
        'packageName': packageName,
      });
      return result;
    } on PlatformException catch (e) {
      _log.e("Failed to check if package is installed: '${e.message}'.");
      return false;
    }
  }
}
