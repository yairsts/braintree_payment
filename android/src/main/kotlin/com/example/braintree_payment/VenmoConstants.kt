package com.example.braintree_payment

object VenmoConstants {
    const val VENMO_PAYMENT_METHOD_KEY = "venmoPayment"

    //Request keys
    const val TOKEN_KEY = "token"
    const val AMOUNT_KEY = "amount"
    const val DISPLAY_NAME_KEY = "displayName"
    const val APP_LINK_RETURN_URL = "appLinkReturnUrl"
    const val DEEP_LINK_FALLBACK_URL_SCHEME = "deepLinkFallbackUrlScheme"

    //Response keys
    const val VENMO_NONCE_KEY = "venmo_nonce"
    const val VENMO_CANCELED_KEY = "venmo_canceled"
    const val VENMO_ERROR_KEY = "venmo_error"
}