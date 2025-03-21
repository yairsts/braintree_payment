import Flutter
import Braintree
import Foundation
 
public class BraintreePaymentPlugin: NSObject, FlutterPlugin {
    
    private var venmoClient: BTVenmoClient?
    private var flutterResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "braintree_payment", binaryMessenger: registrar.messenger())
        let instance = BraintreePaymentPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        print("BraintreePaymentPlugin registered successfully")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Method called: \(call.method)")

        if call.method == VenmoConstants.VENMO_PAYMENT_METHOD_KEY {
                let args = call.arguments as? [String: Any] ?? [:]
                self.flutterResult = result
            print("Starting Venmo flow with args: \(args)")
            self.startVenmoFlow(args: args)
            } else {
                print("Method not implemented: \(call.method)")
                result(FlutterMethodNotImplemented)
            }
    }

    private func startVenmoFlow(args: [String: Any]) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("NO_VIEW_CONTROLLER: Could not find root view controller")
            flutterResult?(FlutterError(code: VenmoConstants.VENMO_ERROR_KEY, message: "Could not find root view controller", details: nil))
            return
        }

        // Use optional binding to safely extract the arguments
        let token = args[VenmoConstants.TOKEN_KEY] as! String
        let displayName = args[VenmoConstants.DISPLAY_NAME_KEY] as? String
        let amountString = args[VenmoConstants.AMOUNT_KEY] as? String
        
        print("Initializing Braintree API Client")
        let apiClient = BTAPIClient(authorization: token)
        self.venmoClient = BTVenmoClient(apiClient: apiClient!)

        let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
        venmoRequest.displayName = displayName
        venmoRequest.totalAmount = amountString
        venmoRequest.vault = true

        // Safely call the tokenize method
        print("Tokenizing Venmo payment... displayName: .\(venmoRequest.displayName), totalAmount: .\(venmoRequest.totalAmount)")
        self.venmoClient?.tokenize(venmoRequest) { (venmoAccount, error) in
            if let error = error {
                print("VENMO_ERROR: \(error.localizedDescription)")
                self.flutterResult?(FlutterError(code: VenmoConstants.VENMO_ERROR_KEY, message: error.localizedDescription, details: nil))
            } else if let venmoAccount = venmoAccount {
                print("VENMO_SUCCESS: Nonce received - \(venmoAccount.nonce)")
                self.flutterResult?(venmoAccount.nonce)
            } else {
                print("VENMO_CANCELED: Venmo payment was canceled")
                self.flutterResult?(FlutterError(code: VenmoConstants.VENMO_CANCELED_KEY, message: "Venmo payment was canceled", details: nil))
            }
        }
    }
}

public struct VenmoConstants {
    static let VENMO_PAYMENT_METHOD_KEY = "venmoPayment"
    
    // Request keys
    static let TOKEN_KEY = "token"
    static let AMOUNT_KEY = "amount"
    static let DISPLAY_NAME_KEY = "displayName"
 
    // Response keys
    static let VENMO_NONCE_KEY = "venmo_nonce"
    static let VENMO_CANCELED_KEY = "venmo_canceled"
    static let VENMO_ERROR_KEY = "venmo_error"
}
