import 'package:triva/src/configs/flavors.dart';
import 'package:triva/src/logs/log_console.dart';
import 'package:triva/src/utils/navigation/app_router.dart';
// ignore: depend_on_referenced_packages
import "package:get_it/get_it.dart";

import 'package:logger/logger.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show
        AndroidOptions,
        FlutterSecureStorage,
        IOSOptions,
        KeychainAccessibility;

GetIt getIt = GetIt.I;

Future setupGetIt({bool testing = false}) async {
  Logger logger = Logger(
    filter: ProductionFilter(),
    printer: SimplePrinter(colors: false),
    output: LogConsole.wrap(),
  );
  getIt.registerSingleton<Logger>(logger);
  getIt.registerSingleton(AppRouter());
  getIt.registerSingleton(FlutterSecureStorage(
    iOptions: IOSOptions(
      groupId: F.appGroupName,
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  ));
}
