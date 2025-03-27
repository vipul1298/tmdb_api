import 'package:connectivity_plus/connectivity_plus.dart';

class InternetConnectivity {
  InternetConnectivity._();
  static final instance = InternetConnectivity._();
  static Future<bool> checkInternetConnection() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
      return false;
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      // No available network types
      return false;
    }
    return false;
  }
}
