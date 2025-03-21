import 'dart:async';

import 'package:braintree_payment/braintree_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _venmoResponse = '';
  bool isLoading = false;
  final BraintreePayment braintreePayment = BraintreePayment();
  Future<void> venmoPayment() async {
    try {
      setState(() {
        isLoading = true;
      });
      final brainTreeToken = dotenv.env['BRAINTREE_TOKEN'] ?? '';
      final packageInfo = await PackageInfo.fromPlatform();

      final res = await braintreePayment.venmoPayment(
        VenmoRequest(
          token: brainTreeToken,
          amount: "10",
          displayName: "WhoPayForIt??",
          appLinkReturnUrl: packageInfo.packageName,
          deepLinkFallbackUrlScheme: packageInfo.packageName,
        ),
      );
      _venmoResponse = res.toString();
    } catch (e) {
      _venmoResponse = e.toString();
    }

    debugPrint("BraintreePaymentPlugin, $_venmoResponse");

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(onPressed: venmoPayment, child: Text("Venmo")),
              if (isLoading) CircularProgressIndicator(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Text('_venmoResponse: $_venmoResponse')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
