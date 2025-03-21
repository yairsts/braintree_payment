import 'dart:convert';

import 'package:braintree_payment/braintree_payment.dart';
import 'package:braintree_payment/braintree_payment_constants.dart';
import 'package:braintree_payment/braintree_payment_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelBraintreePayment platform = MethodChannelBraintreePayment();
  const MethodChannel channel = MethodChannel('braintree_payment');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case BraintreePaymentConstants.venmoPaymentMethodKey:
            final result = VenmoAccountNonce(
              isDefault: true,
              nonce: "venmo nonce",
              username: "username",
            );
            return jsonEncode(result);
          case BraintreePaymentConstants.paypalPaymentMethodKey:
            final result = PaypalAccountNonce(
              isDefault: true,
              nonce: "paypal nonce",
              username: "username",
            );
            return jsonEncode(result);
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('venmoPayment', () async {
    final result = await platform.venmoPayment(
      VenmoRequest(
        token: "TOKEN",
        appLinkReturnUrl: "",
        deepLinkFallbackUrlScheme: "",
        displayName: "EXAMPLE",
        amount: "10.0",
      ),
    );
    expect(result?.nonce, "venmo nonce");
  });

  test('paypalPayment', () async {
    final result = await platform.paypalPayment(
      PaypalRequest(
        token: "TOKEN",
        appLinkReturnUrl: "",
        deepLinkFallbackUrlScheme: "",
        displayName: "EXAMPLE",
        amount: "10.0",
      ),
    );
    expect(result?.nonce, "paypal nonce");
  });
}
