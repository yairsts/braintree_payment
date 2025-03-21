import 'package:braintree_payment/braintree_payment.dart';
import 'package:braintree_payment/braintree_payment_method_channel.dart';
import 'package:braintree_payment/braintree_payment_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBraintreePaymentPlatform
    with MockPlatformInterfaceMixin
    implements BraintreePaymentPlatform {
  @override
  Future<VenmoAccountNonce?> venmoPayment(VenmoRequest request) async {
    return VenmoAccountNonce(
      isDefault: true,
      nonce: "venmo nonce",
      username: "username",
    );
  }

  @override
  Future<PaypalAccountNonce?> paypalPayment(PaypalRequest request) async {
    return PaypalAccountNonce(
      isDefault: true,
      nonce: "paypal nonce",
      username: "username",
    );
  }
}

void main() {
  final BraintreePaymentPlatform initialPlatform =
      BraintreePaymentPlatform.instance;

  test('$MethodChannelBraintreePayment is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBraintreePayment>());
  });

  test('venmoPayment', () async {
    BraintreePayment braintreePaymentPlugin = BraintreePayment();
    MockBraintreePaymentPlatform fakePlatform = MockBraintreePaymentPlatform();
    BraintreePaymentPlatform.instance = fakePlatform;
    final result = await braintreePaymentPlugin.venmoPayment(
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
    BraintreePayment braintreePaymentPlugin = BraintreePayment();
    MockBraintreePaymentPlatform fakePlatform = MockBraintreePaymentPlatform();
    BraintreePaymentPlatform.instance = fakePlatform;
    final result = await braintreePaymentPlugin.paypalPayment(
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
