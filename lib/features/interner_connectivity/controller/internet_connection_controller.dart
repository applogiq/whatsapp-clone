import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final internetConnectionProvider = Provider<InternetConnectionChecker>((ref) {
  return InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 10),
    checkInterval: const Duration(seconds: 10),
  );
});

final internetConnectionStatusProvider =
    StreamProvider<InternetConnectionStatus>((ref) {
  final internetConnectionChecker = ref.watch(internetConnectionProvider);
  return internetConnectionChecker.onStatusChange;
});
