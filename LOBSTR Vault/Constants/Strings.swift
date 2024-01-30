// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// The destination account cannot receive the balance of the source account and still satisfy its lumen buying liabilities.
  internal static let accountMergeDestFull = L10n.tr("Localizable", "account_merge_dest_full")
  /// The source account has trust lines/offers.
  internal static let accountMergeHasSubEntries = L10n.tr("Localizable", "account_merge_has_sub_entries")
  /// The source account has AUTH_IMMUTABLE flag set.
  internal static let accountMergeImmutableSet = L10n.tr("Localizable", "account_merge_immutable_set")
  /// Can't merge account that is a sponsor.
  internal static let accountMergeIsSponsor = L10n.tr("Localizable", "account_merge_is_sponsor")
  /// The operation is malformed because the source account cannot merge with itself. The destination must be a different account.
  internal static let accountMergeMalformed = L10n.tr("Localizable", "account_merge_malformed")
  /// The destination account does not exist.
  internal static let accountMergeNoAccount = L10n.tr("Localizable", "account_merge_no_account")
  /// Source's account sequence number is too high. It must be less than (ledgerSeq &lt;&lt; 32) = (ledgerSeq * 0x100000000).
  internal static let accountMergeSeqnumToFar = L10n.tr("Localizable", "account_merge_seqnum_to_far")
  /// The source account is trying to revoke the trustline of the trustor, but it cannot do so.
  internal static let allowTrustCantRevoke = L10n.tr("Localizable", "allow_trust_cant_revoke")
  /// Claimable balances can't be created on revocation of asset (or pool share) trustlines associated with a liquidity pool due to low reserves.
  internal static let allowTrustLowReserve = L10n.tr("Localizable", "allow_trust_low_reserve")
  /// The asset specified in type is invalid. In addition, this error happens when the native asset is specified.
  internal static let allowTrustMalformed = L10n.tr("Localizable", "allow_trust_malformed")
  /// The trustor does not have a trustline with the issuer performing this operation.
  internal static let allowTrustNoTrustLine = L10n.tr("Localizable", "allow_trust_no_trust_line")
  /// The source account attempted to allow a trustline for itself, which is not allowed because an account cannot create a trustline with itself.
  internal static let allowTrustSelfNotAllowed = L10n.tr("Localizable", "allow_trust_self_not_allowed")
  /// The source account (issuer performing this operation) does not require trust. In other words, it does not have the flag AUTH_REQUIRED_FLAG set.
  internal static let allowTrustTrustNotRequired = L10n.tr("Localizable", "allow_trust_trust_not_required")
  /// Copied
  internal static let animationCopy = L10n.tr("Localizable", "animation_copy")
  /// Please Wait
  internal static let animationWaiting = L10n.tr("Localizable", "animation_waiting")
  /// Source account is already sponsoring sponsoredID.
  internal static let beginSponsoringFutureReservesAlreadySponsored = L10n.tr("Localizable", "begin_sponsoring_future_reserves_already_sponsored")
  /// Source account is equal to sponsoredID.
  internal static let beginSponsoringFutureReservesMalformed = L10n.tr("Localizable", "begin_sponsoring_future_reserves_malformed")
  /// Either source account is currently being sponsored, or sponsoredID is sponsoring another account.
  internal static let beginSponsoringFutureReservesRecursive = L10n.tr("Localizable", "begin_sponsoring_future_reserves_recursive")
  /// The specified bumpTo sequence number is not a valid sequence number. It must be between 0 and INT64_MAX (9223372036854775807 or 0x7fffffffffffffff).
  internal static let bumpSequnceBadSeq = L10n.tr("Localizable", "bump_sequnce_bad_seq")
  /// Update
  internal static let buttonTextAppUpdate = L10n.tr("Localizable", "button_text_app_update")
  /// Skip
  internal static let buttonTextAppUpdateSkip = L10n.tr("Localizable", "button_text_app_update_skip")
  /// Cancel
  internal static let buttonTextCancel = L10n.tr("Localizable", "button_text_cancel")
  /// Change Account Nickname
  internal static let buttonTextChangeAccountNickname = L10n.tr("Localizable", "button_text_change_account_nickname")
  /// Clear Account Nickname
  internal static let buttonTextClearAccountNickname = L10n.tr("Localizable", "button_text_clear_account_nickname")
  /// Copy Public Key
  internal static let buttonTextCopy = L10n.tr("Localizable", "button_text_copy")
  /// Cancel
  internal static let buttonTextNicknameCancel = L10n.tr("Localizable", "button_text_nickname_cancel")
  /// Save
  internal static let buttonTextNicknameSave = L10n.tr("Localizable", "button_text_nickname_save")
  /// Open Network Explorer
  internal static let buttonTextOpenExplorer = L10n.tr("Localizable", "button_text_open_explorer")
  /// Set Account Nickname
  internal static let buttonTextSetAccountNickname = L10n.tr("Localizable", "button_text_set_account_nickname")
  /// Back
  internal static let buttonTitleBack = L10n.tr("Localizable", "button_title_back")
  /// Cancel
  internal static let buttonTitleCancel = L10n.tr("Localizable", "button_title_cancel")
  /// Clear
  internal static let buttonTitleClear = L10n.tr("Localizable", "button_title_clear")
  /// Close
  internal static let buttonTitleClose = L10n.tr("Localizable", "button_title_close")
  /// Confirm
  internal static let buttonTitleConfirm = L10n.tr("Localizable", "button_title_confirm")
  /// Copy Key
  internal static let buttonTitleCopyKey = L10n.tr("Localizable", "button_title_copy_key")
  /// Copy Signed XDR
  internal static let buttonTitleCopySignedXdr = L10n.tr("Localizable", "button_title_copy_signed_xdr")
  /// Copy Transaction XDR
  internal static let buttonTitleCopyXdr = L10n.tr("Localizable", "button_title_copy_xdr")
  /// Create Account
  internal static let buttonTitleCreateNewAccount = L10n.tr("Localizable", "button_title_create_new_account")
  /// Deny
  internal static let buttonTitleDeny = L10n.tr("Localizable", "button_title_deny")
  /// Done
  internal static let buttonTitleDone = L10n.tr("Localizable", "button_title_done")
  /// Enable
  internal static let buttonTitleEnable = L10n.tr("Localizable", "button_title_enable")
  /// Log Out
  internal static let buttonTitleLogout = L10n.tr("Localizable", "button_title_logout")
  /// Next
  internal static let buttonTitleNext = L10n.tr("Localizable", "button_title_next")
  /// OK
  internal static let buttonTitleOk = L10n.tr("Localizable", "button_title_ok")
  /// Open Help Center
  internal static let buttonTitleOpenHelpCenter = L10n.tr("Localizable", "button_title_open_help_center")
  /// Paste From Clipboard
  internal static let buttonTitlePasteFromClipboard = L10n.tr("Localizable", "button_title_paste_from_clipboard")
  /// Proceed
  internal static let buttonTitleProceed = L10n.tr("Localizable", "button_title_proceed")
  /// Re-Check
  internal static let buttonTitleReCheck = L10n.tr("Localizable", "button_title_re_check")
  /// Re-Check
  internal static let buttonTitleRecheck = L10n.tr("Localizable", "button_title_recheck")
  /// Remove All
  internal static let buttonTitleRemoveAll = L10n.tr("Localizable", "button_title_remove_all")
  /// Remove Invalid
  internal static let buttonTitleRemoveInvalid = L10n.tr("Localizable", "button_title_remove_invalid")
  /// Recover Account
  internal static let buttonTitleRestoreAccount = L10n.tr("Localizable", "button_title_restore_account")
  /// Show
  internal static let buttonTitleShow = L10n.tr("Localizable", "button_title_show")
  /// Signed Accounts
  internal static let buttonTitleSignedAccounts = L10n.tr("Localizable", "button_title_signed_accounts")
  /// I will do this later
  internal static let buttonTitleSkipForNow = L10n.tr("Localizable", "button_title_skip_for_now")
  /// Submit
  internal static let buttonTitleSubmit = L10n.tr("Localizable", "button_title_submit")
  /// Sync
  internal static let buttonTitleSync = L10n.tr("Localizable", "button_title_sync")
  /// By registering you agree to our Terms of Service and Privacy Policy.
  internal static let buttonTitleTerms = L10n.tr("Localizable", "button_title_terms")
  /// Turn On
  internal static let buttonTitleTurnOn = L10n.tr("Localizable", "button_title_turn_on")
  /// Enable Face ID
  internal static let buttonTitleTurnOnFaceid = L10n.tr("Localizable", "button_title_turn_on_faceid")
  /// Enable Touch ID
  internal static let buttonTitleTurnOnFingerprint = L10n.tr("Localizable", "button_title_turn_on_fingerprint")
  /// I Understand
  internal static let buttonTitleUnderstand = L10n.tr("Localizable", "button_title_understand")
  /// View Transaction Details
  internal static let buttonTitleViewTransactionDetails = L10n.tr("Localizable", "button_title_view_transaction_details")
  /// View Transactions List
  internal static let buttonTitleViewTransactionsList = L10n.tr("Localizable", "button_title_view_transactions_list")
  /// Yes
  internal static let buttonTitleYes = L10n.tr("Localizable", "button_title_yes")
  /// This action will cancel account creation. Shown recovery phrase will be deleted
  internal static let cancelAlertMnemonicMessage = L10n.tr("Localizable", "cancel_alert_mnemonic_message")
  /// Are you sure?
  internal static let cancelAlertMnemonicTitle = L10n.tr("Localizable", "cancel_alert_mnemonic_title")
  /// Asset trustline can't be removed. Stellar account provides liquidity into a pool that involves this asset.
  internal static let changeTrustCannotDelete = L10n.tr("Localizable", "change_trust_cannot_delete")
  /// The limit is not sufficient to hold the current balance of the trustline and still satisfy its buying liabilities.
  internal static let changeTrustInvalidLimit = L10n.tr("Localizable", "change_trust_invalid_limit")
  /// You don't have enough XLM available to perform this transaction.
  internal static let changeTrustLowReserve = L10n.tr("Localizable", "change_trust_low_reserve")
  /// The input to this operation is invalid.
  internal static let changeTrustMalformed = L10n.tr("Localizable", "change_trust_malformed")
  /// The issuer of the asset cannot be found.
  internal static let changeTrustNoIssuer = L10n.tr("Localizable", "change_trust_no_issuer")
  /// Asset trustline is deauthorized.
  internal static let changeTrustNotAuthMaintainLiabilities = L10n.tr("Localizable", "change_trust_not_auth_maintain_liabilities")
  /// The source account attempted to create a trustline for itself, which is not allowed.
  internal static let changeTrustSelfNotAllowed = L10n.tr("Localizable", "change_trust_self_not_allowed")
  /// The asset trustline is missing for the liquidity pool.
  internal static let changeTrustTrustLineMissing = L10n.tr("Localizable", "change_trust_trust_line_missing")
  /// There is no claimant that matches the source account, or the claimants predicate is not satisfied.
  internal static let claimClaimableBalanceCannotClaim = L10n.tr("Localizable", "claim_claimable_balance_cannot_claim")
  /// There is no existing ClaimableBalanceEntry that matches the input BalanceID.
  internal static let claimClaimableBalanceDoesNotExist = L10n.tr("Localizable", "claim_claimable_balance_does_not_exist")
  /// The account claiming the ClaimableBalanceEntry does not have sufficient limits to receive amount of the asset and still satisfy its buying liabilities.
  internal static let claimClaimableBalanceLineFull = L10n.tr("Localizable", "claim_claimable_balance_line_full")
  /// The source account does not trust the issuer of the asset it is trying to claim in the ClaimableBalanceEntry.
  internal static let claimClaimableBalanceNoTrust = L10n.tr("Localizable", "claim_claimable_balance_no_trust")
  /// The source account is not authorized to claim the asset in the ClaimableBalanceEntry.
  internal static let claimClaimableBalanceNotAuthorized = L10n.tr("Localizable", "claim_claimable_balance_not_authorized")
  /// There is no existing ClaimableBalanceEntry that matches the input BalanceID.
  internal static let clawbackClaimableBalanceDoesNotExist = L10n.tr("Localizable", "clawback_claimable_balance_does_not_exist")
  /// The CLAIMABLE_BALANCE_CLAWBACK_ENABLED_FLAG is not set for this trustline.
  internal static let clawbackClaimableBalanceNotClawbackEnabled = L10n.tr("Localizable", "clawback_claimable_balance_not_clawback_enabled")
  /// The source account is not the issuer of the asset in the claimable balance.
  internal static let clawbackClaimableBalanceNotIssuer = L10n.tr("Localizable", "clawback_claimable_balance_not_issuer")
  /// The input to the clawback is invalid.
  internal static let clawbackMalformed = L10n.tr("Localizable", "clawback_malformed")
  /// The From account does not trust the issuer of the asset.
  internal static let clawbackNoTrust = L10n.tr("Localizable", "clawback_no_trust")
  /// The trustline between From and the issuer account for this Asset does not have clawback enabled.
  internal static let clawbackNotClawbackEnabled = L10n.tr("Localizable", "clawback_not_clawback_enabled")
  /// The From account does not have a sufficient available balance of the asset (after accounting for selling liabilities).
  internal static let clawbackUnderfunded = L10n.tr("Localizable", "clawback_underfunded")
  /// The destination account already exists.
  internal static let createAccountAlreadyExist = L10n.tr("Localizable", "create_account_already_exist")
  /// This operation would create an account with fewer than the minimum number of XLM an account must hold.
  internal static let createAccountLowReserve = L10n.tr("Localizable", "create_account_low_reserve")
  /// The destination is invalid.
  internal static let createAccountMalformed = L10n.tr("Localizable", "create_account_malformed")
  /// The source account performing the command does not have enough funds to give destination the starting balance amount of XLM and still maintain its minimum XLM reserve plus satisfy its XLM selling liabilities.
  internal static let createAccountUnderfunded = L10n.tr("Localizable", "create_account_underfunded")
  /// The account creating this entry does not have enough XLM to satisfy the minimum XLM reserve increase caused by adding a ClaimableBalanceEntry. For every claimant in the list, the minimum amount of XLM this account must hold will increase by baseReserve.
  internal static let createClaimableBalanceLowReserve = L10n.tr("Localizable", "create_claimable_balance_low_reserve")
  /// The input to this operation is invalid.
  internal static let createClaimableBalanceMalformed = L10n.tr("Localizable", "create_claimable_balance_malformed")
  /// The source account does not trust the issuer of the asset it is trying to include in the ClaimableBalanceEntry.
  internal static let createClaimableBalanceNoTrust = L10n.tr("Localizable", "create_claimable_balance_no_trust")
  /// The source account is not authorized to transfer this asset.
  internal static let createClaimableBalanceNotAuthorized = L10n.tr("Localizable", "create_claimable_balance_not_authorized")
  /// The source account does not have enough funds to transfer amount of this asset to the ClaimableBalanceEntry.
  internal static let createClaimableBalanceUnderfunded = L10n.tr("Localizable", "create_claimable_balance_underfunded")
  /// Security delay
  internal static let dialogSecurityDelay = L10n.tr("Localizable", "dialog_security_delay")
  /// Source account is not sponsored.
  internal static let endSponsoringFutureReservesNotSponsored = L10n.tr("Localizable", "end_sponsoring_future_reserves_not_sponsored")
  /// error_biometric_not_available
  internal static let errorBiometricNotAvailable = L10n.tr("Localizable", "error_biometric_not_available")
  /// Biometric ID turned off in device settings
  internal static let errorBiometricNotAvailableMessage = L10n.tr("Localizable", "error_biometric_not_available_message")
  /// Not available
  internal static let errorBiometricNotAvailableTitle = L10n.tr("Localizable", "error_biometric_not_available_title")
  /// error_biometric_not_configured
  internal static let errorBiometricNotConfigured = L10n.tr("Localizable", "error_biometric_not_configured")
  /// Face ID/Touch ID may not be configured
  internal static let errorBiometricNotConfiguredMessage = L10n.tr("Localizable", "error_biometric_not_configured_message")
  /// Biometric disabled
  internal static let errorBiometricNotConfiguredTitle = L10n.tr("Localizable", "error_biometric_not_configured_title")
  /// error_biometric_not_verified_identity
  internal static let errorBiometricNotVerifiedIdentity = L10n.tr("Localizable", "error_biometric_not_verified_identity")
  /// There was a problem verifying your identity
  internal static let errorBiometricNotVerifiedIdentityMessage = L10n.tr("Localizable", "error_biometric_not_verified_identity_message")
  /// Biometric disabled
  internal static let errorBiometricNotVerifiedIdentityTitle = L10n.tr("Localizable", "error_biometric_not_verified_identity_title")
  /// error_biometric_pressed_cancel
  internal static let errorBiometricPressedCancel = L10n.tr("Localizable", "error_biometric_pressed_cancel")
  /// You pressed cancel
  internal static let errorBiometricPressedCancelMessage = L10n.tr("Localizable", "error_biometric_pressed_cancel_message")
  /// Biometric disabled
  internal static let errorBiometricPressedCancelTitle = L10n.tr("Localizable", "error_biometric_pressed_cancel_title")
  /// error_biometric_pressed_password
  internal static let errorBiometricPressedPassword = L10n.tr("Localizable", "error_biometric_pressed_password")
  /// You pressed password
  internal static let errorBiometricPressedPasswordMessage = L10n.tr("Localizable", "error_biometric_pressed_password_message")
  /// Biometric disabled
  internal static let errorBiometricPressedPasswordTitle = L10n.tr("Localizable", "error_biometric_pressed_password_title")
  /// Your account has reached the Stellar subentries limit at 1000. You can’t add more assets, signers or create more offers.
  internal static let errorTooManySubentriesMessage = L10n.tr("Localizable", "error_too_many_subentries_message")
  /// The transaction has already been confirmed or denied
  internal static let errorTransactionAlreadyConfirmedOrDeniedMessage = L10n.tr("Localizable", "error_transaction_already_confirmed_or_denied_message")
  /// error_unknown
  internal static let errorUnknown = L10n.tr("Localizable", "error_unknown")
  /// An unknown error has occured. If this issue persists, please contact support.
  internal static let errorUnknownMessage = L10n.tr("Localizable", "error_unknown_message")
  /// Unknown Error
  internal static let errorUnknownTitle = L10n.tr("Localizable", "error_unknown_title")
  /// Operation could not be completed. Code: %@
  internal static func genericErrorCode(_ p1: String) -> String {
    return L10n.tr("Localizable", "generic_error_code", p1)
  }
  /// horizon_error_bad_request
  internal static let horizonErrorBadRequest = L10n.tr("Localizable", "horizon_error_bad_request")
  /// There was an error processing this request. If this issue persists, please contact support.
  internal static let horizonErrorBadRequestMessage = L10n.tr("Localizable", "horizon_error_bad_request_message")
  /// Bad Request
  internal static let horizonErrorBadRequestTitle = L10n.tr("Localizable", "horizon_error_bad_request_title")
  /// horizon_error_before_history
  internal static let horizonErrorBeforeHistory = L10n.tr("Localizable", "horizon_error_before_history")
  /// Horizon is unable to provide the required information, it is outside of the recorded history range.
  internal static let horizonErrorBeforeHistoryMessage = L10n.tr("Localizable", "horizon_error_before_history_message")
  /// Account Error
  internal static let horizonErrorBeforeHistoryTitle = L10n.tr("Localizable", "horizon_error_before_history_title")
  /// horizon_error_forbidden
  internal static let horizonErrorForbidden = L10n.tr("Localizable", "horizon_error_forbidden")
  /// The requested resource is forbidden.
  internal static let horizonErrorForbiddenMessage = L10n.tr("Localizable", "horizon_error_forbidden_message")
  /// Forbidden
  internal static let horizonErrorForbiddenTitle = L10n.tr("Localizable", "horizon_error_forbidden_title")
  /// horizon_error_internal_server
  internal static let horizonErrorInternalServer = L10n.tr("Localizable", "horizon_error_internal_server")
  /// There was an internal server error. Please try again, or contact support for assistance.
  internal static let horizonErrorInternalServerMessage = L10n.tr("Localizable", "horizon_error_internal_server_message")
  /// Internal Server Error
  internal static let horizonErrorInternalServerTitle = L10n.tr("Localizable", "horizon_error_internal_server_title")
  /// horizon_error_invalid_response
  internal static let horizonErrorInvalidResponse = L10n.tr("Localizable", "horizon_error_invalid_response")
  /// The server returned an invalid and unprocessable response. Please contact support for assistance.
  internal static let horizonErrorInvalidResponseMessage = L10n.tr("Localizable", "horizon_error_invalid_response_message")
  /// Invalid Response
  internal static let horizonErrorInvalidResponseTitle = L10n.tr("Localizable", "horizon_error_invalid_response_title")
  /// horizon_error_not_acceptable
  internal static let horizonErrorNotAcceptable = L10n.tr("Localizable", "horizon_error_not_acceptable")
  /// The requested action is not acceptable.
  internal static let horizonErrorNotAcceptableMessage = L10n.tr("Localizable", "horizon_error_not_acceptable_message")
  /// Not Acceptable
  internal static let horizonErrorNotAcceptableTitle = L10n.tr("Localizable", "horizon_error_not_acceptable_title")
  /// horizon_error_not_found
  internal static let horizonErrorNotFound = L10n.tr("Localizable", "horizon_error_not_found")
  /// The requested information cannot be retrieved because it wasn't found.
  internal static let horizonErrorNotFoundMessage = L10n.tr("Localizable", "horizon_error_not_found_message")
  /// Not Found
  internal static let horizonErrorNotFoundTitle = L10n.tr("Localizable", "horizon_error_not_found_title")
  /// horizon_error_not_implemented
  internal static let horizonErrorNotImplemented = L10n.tr("Localizable", "horizon_error_not_implemented")
  /// This feature has not been implemented.
  internal static let horizonErrorNotImplementedMessage = L10n.tr("Localizable", "horizon_error_not_implemented_message")
  /// Not Implemented
  internal static let horizonErrorNotImplementedTitle = L10n.tr("Localizable", "horizon_error_not_implemented_title")
  /// horizon_error_rate_limit
  internal static let horizonErrorRateLimit = L10n.tr("Localizable", "horizon_error_rate_limit")
  /// Rate limit reached. Please try again in a few minutes.
  internal static let horizonErrorRateLimitMessage = L10n.tr("Localizable", "horizon_error_rate_limit_message")
  /// Rate Limit
  internal static let horizonErrorRateLimitTitle = L10n.tr("Localizable", "horizon_error_rate_limit_title")
  /// horizon_error_request_failed
  internal static let horizonErrorRequestFailed = L10n.tr("Localizable", "horizon_error_request_failed")
  /// Failed to submit the transaction due to the server overload or Stellar network outage. Please try again later.
  internal static let horizonErrorRequestFailedMessage = L10n.tr("Localizable", "horizon_error_request_failed_message")
  /// Request failed
  internal static let horizonErrorRequestFailedTitle = L10n.tr("Localizable", "horizon_error_request_failed_title")
  /// horizon_error_stale_history
  internal static let horizonErrorStaleHistory = L10n.tr("Localizable", "horizon_error_stale_history")
  /// Could not fetch account history from Horizon, the requested data is out of date.
  internal static let horizonErrorStaleHistoryMessage = L10n.tr("Localizable", "horizon_error_stale_history_message")
  /// Stale Data
  internal static let horizonErrorStaleHistoryTitle = L10n.tr("Localizable", "horizon_error_stale_history_title")
  /// horizon_error_stream
  internal static let horizonErrorStream = L10n.tr("Localizable", "horizon_error_stream")
  /// There was an error receiving Horizon stream data.
  internal static let horizonErrorStreamMessage = L10n.tr("Localizable", "horizon_error_stream_message")
  /// Steam Error
  internal static let horizonErrorStreamTitle = L10n.tr("Localizable", "horizon_error_stream_title")
  /// horizon_error_unauthorized
  internal static let horizonErrorUnauthorized = L10n.tr("Localizable", "horizon_error_unauthorized")
  /// The requested action is unauthorized for this account.
  internal static let horizonErrorUnauthorizedMessage = L10n.tr("Localizable", "horizon_error_unauthorized_message")
  /// Unauthorized
  internal static let horizonErrorUnauthorizedTitle = L10n.tr("Localizable", "horizon_error_unauthorized_title")
  /// Codes considered as 'failure' for the operation.
  internal static let inflationNotTime = L10n.tr("Localizable", "inflation_not_time")
  /// You are not connected to the Internet
  internal static let internetConnectionErrorDescription = L10n.tr("Localizable", "internet_connection_error_description")
  /// Network Error
  internal static let internetConnectionErrorTitle = L10n.tr("Localizable", "internet_connection_error_title")
  /// Operation was failed. Please, contact to support.
  internal static let invalidOperationMessage = L10n.tr("Localizable", "INVALID_OPERATION_MESSAGE")
  /// Invalid Operation
  internal static let invalidOperationTitle = L10n.tr("Localizable", "INVALID_OPERATION_TITLE")
  /// Transaction was failed. Please, contact to support.
  internal static let invalidTransactionMessage = L10n.tr("Localizable", "INVALID_TRANSACTION_MESSAGE")
  /// Invalid Transaction
  internal static let invalidTransactionTitle = L10n.tr("Localizable", "INVALID_TRANSACTION_TITLE")
  /// The deposit price is outside of the given bounds.
  internal static let liquidityPoolDepositBadPrice = L10n.tr("Localizable", "liquidity_pool_deposit_bad_price")
  /// The pool share trustline does not have a sufficient limit.
  internal static let liquidityPoolDepositLineFull = L10n.tr("Localizable", "liquidity_pool_deposit_line_full")
  /// One or more of the inputs to the operation was malformed.
  internal static let liquidityPoolDepositMalformed = L10n.tr("Localizable", "liquidity_pool_deposit_malformed")
  /// No trustline exists for one of the assets being deposited.
  internal static let liquidityPoolDepositNoTrust = L10n.tr("Localizable", "liquidity_pool_deposit_no_trust")
  /// The account does not have authorization for one of the assets.
  internal static let liquidityPoolDepositNotAuthorized = L10n.tr("Localizable", "liquidity_pool_deposit_not_authorized")
  /// The liquidity pool reserves are full.
  internal static let liquidityPoolDepositPoolFull = L10n.tr("Localizable", "liquidity_pool_deposit_pool_full")
  /// There is not enough balance of one of the assets to perform the deposit.
  internal static let liquidityPoolDepositUnderfunded = L10n.tr("Localizable", "liquidity_pool_deposit_underfunded")
  /// The withdrawal would exceed the trustline limit for one of the assets.
  internal static let liquidityPoolWithdrawLineFull = L10n.tr("Localizable", "liquidity_pool_withdraw_line_full")
  /// One or more of the inputs to the operation was malformed.
  internal static let liquidityPoolWithdrawMalformed = L10n.tr("Localizable", "liquidity_pool_withdraw_malformed")
  /// There is no trustline for one of the assets.
  internal static let liquidityPoolWithdrawNoTrust = L10n.tr("Localizable", "liquidity_pool_withdraw_no_trust")
  /// Unable to withdraw enough to satisfy the minimum price.
  internal static let liquidityPoolWithdrawUnderMinimum = L10n.tr("Localizable", "liquidity_pool_withdraw_under_minimum")
  /// Insufficient balance for the pool shares.
  internal static let liquidityPoolWithdrawUnderfunded = L10n.tr("Localizable", "liquidity_pool_withdraw_underfunded")
  /// You will not be able to recover your account or sign in without it.
  internal static let logoutAlertMessage = L10n.tr("Localizable", "logout_alert_message")
  /// Have you secured your recovery phrase?
  internal static let logoutAlertTitle = L10n.tr("Localizable", "logout_alert_title")
  /// Name not a valid string.
  internal static let manageDataInvalidName = L10n.tr("Localizable", "manage_data_invalid_name")
  /// This account does not have enough XLM to satisfy the minimum XLM reserve increase caused by adding a subentry and still satisfy its XLM selling liabilities. For every new DataEntry added to an account, the minimum reserve of XLM that account must hold increases.
  internal static let manageDataLowReserve = L10n.tr("Localizable", "manage_data_low_reserve")
  /// Trying to remove a Data Entry that isn't there. This will happen if Name is set (and Value isn't) but the Account doesn't have a DataEntry with that Name.
  internal static let manageDataNameNotFound = L10n.tr("Localizable", "manage_data_name_not_found")
  /// The network hasn't moved to this protocol change yet. This failure means the network doesn't support this feature yet.
  internal static let manageDataNotSupportedYet = L10n.tr("Localizable", "manage_data_not_supported_yet")
  /// The issuer of buying asset does not exist.
  internal static let manageOfferBuyNoIssuer = L10n.tr("Localizable", "manage_offer_buy_no_issuer")
  /// The account creating the offer does not have a trustline for the asset it is buying.
  internal static let manageOfferBuyNoTrust = L10n.tr("Localizable", "manage_offer_buy_no_trust")
  /// The account creating the offer is not authorized to buy this asset.
  internal static let manageOfferBuyNotAuthorized = L10n.tr("Localizable", "manage_offer_buy_not_authorized")
  /// The account has opposite offer of equal or lesser price active, so the account creating this offer would immediately cross itself.
  internal static let manageOfferCrossSelf = L10n.tr("Localizable", "manage_offer_cross_self")
  /// The account creating the offer only trusts the issuer of buying asset to a certain credit limit. If this offer succeeded, the account would exceed its trust limit with the issuer.
  internal static let manageOfferLineFull = L10n.tr("Localizable", "manage_offer_line_full")
  /// The account creating this offer does not have enough XLM. For every offer an account creates, the minimum amount of XLM that account must hold will increase.
  internal static let manageOfferLowReserve = L10n.tr("Localizable", "manage_offer_low_reserve")
  /// The input is incorrect and would result in an invalid offer.
  internal static let manageOfferMalformed = L10n.tr("Localizable", "manage_offer_malformed")
  /// The offer could not be found.
  internal static let manageOfferNotFound = L10n.tr("Localizable", "manage_offer_not_found")
  /// The issuer of selling asset does not exist.
  internal static let manageOfferSellNoIssuer = L10n.tr("Localizable", "manage_offer_sell_no_issuer")
  /// The account creating the offer does not have a trustline for the asset it is selling.
  internal static let manageOfferSellNoTrust = L10n.tr("Localizable", "manage_offer_sell_no_trust")
  /// The account creating the offer is not authorized to sell this asset.
  internal static let manageOfferSellNotAuthorized = L10n.tr("Localizable", "manage_offer_sell_not_authorized")
  /// The account does not have enough of selling asset to fund this offer.
  internal static let manageOfferUnderfunded = L10n.tr("Localizable", "manage_offer_underfunded")
  /// The transaction has already been confirmed or denied
  internal static let msgTransactionAlreadySignedOrDenied = L10n.tr("Localizable", "msg_transaction_already_signed_or_denied")
  /// Confirm New PIN
  internal static let navTitleChangePasscodeConfirmNew = L10n.tr("Localizable", "nav_title_change_passcode_confirm_new")
  /// Create New PIN
  internal static let navTitleChangePasscodeEnterNew = L10n.tr("Localizable", "nav_title_change_passcode_enter_new")
  /// Enter Old PIN
  internal static let navTitleChangePasscodeEnterOld = L10n.tr("Localizable", "nav_title_change_passcode_enter_old")
  /// Create PIN
  internal static let navTitleCreatePasscode = L10n.tr("Localizable", "nav_title_create_passcode")
  /// Licenses
  internal static let navTitleLicenses = L10n.tr("Localizable", "nav_title_licenses")
  /// Recovery Phrase
  internal static let navTitleMnemonicGeneration = L10n.tr("Localizable", "nav_title_mnemonic_generation")
  /// Verify Recovery Phrase
  internal static let navTitleMnemonicVerification = L10n.tr("Localizable", "nav_title_mnemonic_verification")
  /// Operation Details
  internal static let navTitleOperationDetails = L10n.tr("Localizable", "nav_title_operation_details")
  /// Confirm PIN
  internal static let navTitleReenterPasscode = L10n.tr("Localizable", "nav_title_reenter_passcode")
  /// Recover Account
  internal static let navTitleRestoreAccount = L10n.tr("Localizable", "nav_title_restore_account")
  /// Settings
  internal static let navTitleSettings = L10n.tr("Localizable", "nav_title_settings")
  /// Manage Account Nicknames
  internal static let navTitleSettingsManageNicknames = L10n.tr("Localizable", "nav_title_settings_manage_nicknames")
  /// Protected Accounts
  internal static let navTitleSettingsSignedAccounts = L10n.tr("Localizable", "nav_title_settings_signed_accounts")
  /// Transaction Details
  internal static let navTitleTransactionDetails = L10n.tr("Localizable", "nav_title_transaction_details")
  /// Transactions
  internal static let navTitleTransactions = L10n.tr("Localizable", "nav_title_transactions")
  /// Hold the Signer Card near the back of your device for a few seconds.
  internal static let nfcAlertDefault = L10n.tr("Localizable", "nfc_alert_default")
  /// Done
  internal static let nfcAlertDefaultDone = L10n.tr("Localizable", "nfc_alert_default_done")
  /// Transaction has been successfully signed
  internal static let nfcAlertSignCompleted = L10n.tr("Localizable", "nfc_alert_sign_completed")
  /// %@ left
  internal static func nfcSecondsLeft(_ p1: String) -> String {
    return L10n.tr("Localizable", "nfc_seconds_left", p1)
  }
  /// Session timeout. Please, try again
  internal static let nfcSessionTimeout = L10n.tr("Localizable", "nfc_session_timeout")
  /// It seems that NFC does not work properly on your iPhone
  internal static let nfcStuckError = L10n.tr("Localizable", "nfc_stuck_error")
  /// Unknown card state
  internal static let nfcUnknownCardState = L10n.tr("Localizable", "nfc_unknown_card_state")
  /// There are too few valid signatures, or the transaction was submitted to the wrong network.
  internal static let opBadAuth = L10n.tr("Localizable", "op_bad_auth")
  /// Operation did too much work.
  internal static let opExceedWorkLimit = L10n.tr("Localizable", "op_exceed_work_limit")
  /// The inner object result is valid and the operation was a success.
  internal static let opInner = L10n.tr("Localizable", "op_inner")
  /// Source account was not found.
  internal static let opNoAccount = L10n.tr("Localizable", "op_no_account")
  /// Operation not supported at this time.
  internal static let opNotSupported = L10n.tr("Localizable", "op_not_supported")
  /// Success.
  internal static let opSuccess = L10n.tr("Localizable", "op_success")
  /// Max number of subentries (1000) already reached.
  internal static let opToManySubentries = L10n.tr("Localizable", "op_to_many_subentries")
  /// Account is sponsoring too many entries.
  internal static let opTooManySponsoring = L10n.tr("Localizable", "op_too_many_sponsoring")
  /// Undefined.
  internal static let opUndefined = L10n.tr("Localizable", "op_undefined")
  /// 
  internal static let outOfOperationRangeMessage = L10n.tr("Localizable", "OUT_OF_OPERATION_RANGE_MESSAGE")
  /// 
  internal static let outOfOperationRangeTitle = L10n.tr("Localizable", "OUT_OF_OPERATION_RANGE_TITLE")
  /// The receiving account does not have sufficient limits to receive amount and still satisfy its buying liabilities.
  internal static let pathPaymentStrictLineFull = L10n.tr("Localizable", "path_payment_strict_line_full")
  /// The input to this path payment is invalid.
  internal static let pathPaymentStrictMalformed = L10n.tr("Localizable", "path_payment_strict_malformed")
  /// The receiving account does not exist.
  internal static let pathPaymentStrictNoDestination = L10n.tr("Localizable", "path_payment_strict_no_destination")
  /// The issuer of the asset does not exist.
  internal static let pathPaymentStrictNoIssuer = L10n.tr("Localizable", "path_payment_strict_no_issuer")
  /// The receiver does not trust the issuer of the asset being sent.
  internal static let pathPaymentStrictNoTrust = L10n.tr("Localizable", "path_payment_strict_no_trust")
  /// The receiving account is not authorized by the asset's issuer to hold the asset.
  internal static let pathPaymentStrictNotAuthorized = L10n.tr("Localizable", "path_payment_strict_not_authorized")
  /// Couldn't complete the transaction. The payment or asset swap would cross one of your own trading offers.
  internal static let pathPaymentStrictOfferCrossSelf = L10n.tr("Localizable", "path_payment_strict_offer_cross_self")
  /// The paths that could send destination amount of destination asset would exceed send max.
  internal static let pathPaymentStrictReceiveOverSendmax = L10n.tr("Localizable", "path_payment_strict_receive_over_sendmax")
  /// The paths that could send destination amount of destination asset would fall short of destination min.
  internal static let pathPaymentStrictSendUnderDestmin = L10n.tr("Localizable", "path_payment_strict_send_under_destmin")
  /// The source account does not trust the issuer of the asset it is trying to send.
  internal static let pathPaymentStrictSrcNoTrust = L10n.tr("Localizable", "path_payment_strict_src_no_trust")
  /// The source account is not authorized to send this payment.
  internal static let pathPaymentStrictSrcNotAuthorized = L10n.tr("Localizable", "path_payment_strict_src_not_authorized")
  /// There is no path of offers connecting the send asset and destination asset. Stellar only considers paths of length 5 or shorter.
  internal static let pathPaymentStrictTooFewOffers = L10n.tr("Localizable", "path_payment_strict_too_few_offers")
  /// The source account (sender) does not have enough funds to send amount and still satisfy its selling liabilities. Note that if sending XLM then the sender must additionally maintain its minimum XLM reserve.
  internal static let pathPaymentStrictUnderfunded = L10n.tr("Localizable", "path_payment_strict_underfunded")
  /// The destination account (receiver) does not have sufficient limits to receive amount and still satisfy its buying liabilities.
  internal static let paymentLineFull = L10n.tr("Localizable", "payment_line_full")
  /// The input to the payment is invalid.
  internal static let paymentMalformed = L10n.tr("Localizable", "payment_malformed")
  /// The receiving account does not exist.
  internal static let paymentNoDestination = L10n.tr("Localizable", "payment_no_destination")
  /// The issuer of the asset does not exist.
  internal static let paymentNoIssuer = L10n.tr("Localizable", "payment_no_issuer")
  /// The receiver does not trust the issuer of the asset being sent.
  internal static let paymentNoTrust = L10n.tr("Localizable", "payment_no_trust")
  /// The destination account is not authorized by the asset's issuer to hold the asset.
  internal static let paymentNotAuthorized = L10n.tr("Localizable", "payment_not_authorized")
  /// The source account does not trust the issuer of the asset it is trying to send.
  internal static let paymentSrcNoTrust = L10n.tr("Localizable", "payment_src_no_trust")
  /// The source account is not authorized to send this payment.
  internal static let paymentSrcNotAuthorized = L10n.tr("Localizable", "payment_src_not_authorized")
  /// The source account (sender) does not have enough funds to send amount and still satisfy its selling liabilities. Note that if sending XLM then the sender must additionally maintain its minimum XLM reserve.
  internal static let paymentUnderfunded = L10n.tr("Localizable", "payment_underfunded")
  /// Reading data: %@%%
  internal static func readingDataProgress(_ p1: String) -> String {
    return L10n.tr("Localizable", "reading_data_progress", p1)
  }
  /// The ledgerEntry for LedgerKey doesn't exist, the account ID on signer doesn't exist, or the Signer Key doesn't exist on account ID's account.
  internal static let revokeSponsorshipDoesNotExist = L10n.tr("Localizable", "revoke_sponsorship_does_not_exist")
  /// The sponsored account does not have enough XLM to satisfy the minimum balance increase caused by revoking sponsorship on a ledgerEntry/signer it owns, or the sponsor of the source account doesn't have enough XLM to satisfy the minimum balance increase caused by sponsoring a transferred ledgerEntry/signer.
  internal static let revokeSponsorshipLowReserve = L10n.tr("Localizable", "revoke_sponsorship_low_reserve")
  /// One or more of the inputs to the operation was malformed.
  internal static let revokeSponsorshipMalformed = L10n.tr("Localizable", "revoke_sponsorship_malformed")
  /// If the ledgerEntry/signer is sponsored, then the source account must be the sponsor. If the ledgerEntry/signer is not sponsored, the source account must be the owner. This error will be thrown otherwise.
  internal static let revokeSponsorshipNotSponsor = L10n.tr("Localizable", "revoke_sponsorship_not_sponsor")
  /// Sponsorship cannot be removed from this ledgerEntry. This error will happen if the user tries to remove the sponsorship from a ClaimableBalanceEntry.
  internal static let revokeSponsorshipOnlyTransferable = L10n.tr("Localizable", "revoke_sponsorship_only_transferable")
  /// Hold the Signer Card near the back of your device for a few seconds
  internal static let scanCardDescription = L10n.tr("Localizable", "scan_card_description")
  /// Taking screenshot of your Recovery Phrase increases security risks of your Vault account and protected wallet.
  internal static let screenshotWarningDescription = L10n.tr("Localizable", "screenshot_warning_description")
  /// Screenshot warning
  internal static let screenshotWarningTitle = L10n.tr("Localizable", "screenshot_warning_title")
  /// Auth revocable is required for clawback
  internal static let setOptionsAuthRevocableRequired = L10n.tr("Localizable", "set_options_auth_revocable_required")
  /// The flags set and/or cleared are invalid by themselves or in combination.
  internal static let setOptionsBadFlags = L10n.tr("Localizable", "set_options_bad_flags")
  /// Any additional signers added to the account cannot be the master key.
  internal static let setOptionsBadSigner = L10n.tr("Localizable", "set_options_bad_signer")
  /// This account can no longer change the option it wants to change.
  internal static let setOptionsCantChange = L10n.tr("Localizable", "set_options_cant_change")
  /// Home domain is malformed.
  internal static let setOptionsInvalidHomeDomain = L10n.tr("Localizable", "set_options_invalid_home_domain")
  /// The destination account set in the inflation field does not exist.
  internal static let setOptionsInvalidInflation = L10n.tr("Localizable", "set_options_invalid_inflation")
  /// This account does not have enough XLM to satisfy the minimum XLM reserve increase caused by adding a subentry and still satisfy its XLM selling liabilities. For every new signer added to an account, the minimum reserve of XLM that account must hold increases.
  internal static let setOptionsLowReserve = L10n.tr("Localizable", "set_options_low_reserve")
  /// The value for a key weight or threshold is invalid.
  internal static let setOptionsThresholdOutOfRange = L10n.tr("Localizable", "set_options_threshold_out_of_range")
  /// 20 is the maximum number of signers an account can have, and adding another signer would exceed that.
  internal static let setOptionsTooManySigners = L10n.tr("Localizable", "set_options_too_many_signers")
  /// The account is trying to set a flag that is unknown.
  internal static let setOptionsUnknownFlag = L10n.tr("Localizable", "set_options_unknown_flag")
  /// The issuer is trying to revoke the trustline authorization of Trustor, but it cannot do so because AUTH_REVOCABLE_FLAG is not set on the account.
  internal static let setTrustLineFlagsCantRevoke = L10n.tr("Localizable", "set_trust_line_flags_cant_revoke")
  /// If the final state of the trustline has both AUTHORIZED_FLAG (1) and AUTHORIZED_TO_MAINTAIN_LIABILITIES_FLAG (2) set, which are mutually exclusive.
  internal static let setTrustLineFlagsInvalidState = L10n.tr("Localizable", "set_trust_line_flags_invalid_state")
  /// Claimable balances can't be created on revocation of asset (or pool share) trustlines associated with a liquidity pool due to low reserves.
  internal static let setTrustLineFlagsLowReserve = L10n.tr("Localizable", "set_trust_line_flags_low_reserve")
  /// This can happen for a number of reasons: the asset specified by AssetCode and AssetIssuer is invalid; the asset issuer isn't the source account; the Trustor is the source account; the native asset is specified; or the flags being set/cleared conflict or are otherwise invalid.
  internal static let setTrustLineFlagsMalformed = L10n.tr("Localizable", "set_trust_line_flags_malformed")
  /// The Trustor does not have a trustline with the issuer performing this operation.
  internal static let setTrustLineFlagsNoTrustLine = L10n.tr("Localizable", "set_trust_line_flags_no_trust_line")
  /// Account Created
  internal static let textAccountCreated = L10n.tr("Localizable", "text_account_created")
  /// Account Merge
  internal static let textAccountMerge = L10n.tr("Localizable", "text_account_merge")
  /// Enter a public key and choose a short nickname
  internal static let textAddNicknameDescription = L10n.tr("Localizable", "text_add_nickname_description")
  /// Limited to 20 symbols
  internal static let textAddNicknameNicknameDescription = L10n.tr("Localizable", "text_add_nickname_nickname_description")
  /// Enter account nickname
  internal static let textAddNicknameNicknamePlaceholder = L10n.tr("Localizable", "text_add_nickname_nickname_placeholder")
  /// A sequence of 56 characters starting with the letter “G”
  internal static let textAddNicknamePublicKeyDescription = L10n.tr("Localizable", "text_add_nickname_public_key_description")
  /// Please enter a valid Stellar public key 
  internal static let textAddNicknamePublicKeyError = L10n.tr("Localizable", "text_add_nickname_public_key_error")
  /// Enter public key
  internal static let textAddNicknamePublicKeyPlaceholder = L10n.tr("Localizable", "text_add_nickname_public_key_placeholder")
  /// Set Nickname for Account
  internal static let textAddNicknameTitle = L10n.tr("Localizable", "text_add_nickname_title")
  /// To submit transaction enter its XDR below
  internal static let textAddTransactionDescription = L10n.tr("Localizable", "text_add_transaction_description")
  /// Transaction is invalid. Please try again.
  internal static let textAddTransactionError = L10n.tr("Localizable", "text_add_transaction_error")
  /// Enter transaction XDR
  internal static let textAddTransactionPlaceholder = L10n.tr("Localizable", "text_add_transaction_placeholder")
  /// Add Transaction XDR
  internal static let textAddTransactionTitle = L10n.tr("Localizable", "text_add_transaction_title")
  /// Allow Trust
  internal static let textAllowTrust = L10n.tr("Localizable", "text_allow_trust")
  /// Your app is outdated and is no longer supported. Update the app to continue using LOBSTR Vault.
  internal static let textAppUpdateMessageRequired = L10n.tr("Localizable", "text_app_update_message_required")
  /// Update LOBSTR Vault app to get the latest exciting features.
  internal static let textAppUpdateMessageWeak = L10n.tr("Localizable", "text_app_update_message_weak")
  /// Update the app
  internal static let textAppUpdateTitleRequired = L10n.tr("Localizable", "text_app_update_title_required")
  /// Update is available
  internal static let textAppUpdateTitleWeak = L10n.tr("Localizable", "text_app_update_title_weak")
  /// If you lose your Recovery Phrase, you may lose the control over your protected Stellar account and funds.
  internal static let textBackupAttention = L10n.tr("Localizable", "text_backup_attention")
  /// You will be shown a 12 word recovery phrase. It will allow you to recover access to your account in case your phone is lost or stolen.
  internal static let textBackupDescription = L10n.tr("Localizable", "text_backup_description")
  /// Backup Your Account
  internal static let textBackupTitle = L10n.tr("Localizable", "text_backup_title")
  /// Begin Sponsoring Future Reserves
  internal static let textBeginSponsoringFutureReserves = L10n.tr("Localizable", "text_begin_sponsoring_future_reserves")
  /// View Details
  internal static let textBtnErrorViewDetails = L10n.tr("Localizable", "text_btn_error_view_details")
  /// View on Network Explorer
  internal static let textBtnViewOnNetworkExplorer = L10n.tr("Localizable", "text_btn_view_on_network_explorer")
  /// Bump Sequence
  internal static let textBumpSequence = L10n.tr("Localizable", "text_bump_sequence")
  /// Buy Offer
  internal static let textBuyOffer = L10n.tr("Localizable", "text_buy_offer")
  /// Can’t be claimed
  internal static let textCantBeClaimed = L10n.tr("Localizable", "text_cant_be_claimed")
  /// Change Account Nickname
  internal static let textChangeNicknameTitle = L10n.tr("Localizable", "text_change_nickname_title")
  /// Confirm PIN
  internal static let textChangePasscodeConfirmNew = L10n.tr("Localizable", "text_change_passcode_confirm_new")
  /// Create PIN
  internal static let textChangePasscodeEnterNew = L10n.tr("Localizable", "text_change_passcode_enter_new")
  /// Enter PIN
  internal static let textChangePasscodeEnterOld = L10n.tr("Localizable", "text_change_passcode_enter_old")
  /// PINs do not match
  internal static let textChangePasscodeError = L10n.tr("Localizable", "text_change_passcode_error")
  /// You can not use old PIN
  internal static let textChangeTheSamePasscode = L10n.tr("Localizable", "text_change_the_same_passcode")
  /// Change Trust
  internal static let textChangeTrust = L10n.tr("Localizable", "text_change_trust")
  /// Claim After
  internal static let textClaimAfter = L10n.tr("Localizable", "text_claim_after")
  /// Claim Before
  internal static let textClaimBefore = L10n.tr("Localizable", "text_claim_before")
  /// Claim Between
  internal static let textClaimBetween = L10n.tr("Localizable", "text_claim_between")
  /// Claim Claimable Balance
  internal static let textClaimClaimableBalance = L10n.tr("Localizable", "text_claim_claimable_balance")
  /// Claim Conditions
  internal static let textClaimConditions = L10n.tr("Localizable", "text_claim_conditions")
  /// Claim now
  internal static let textClaimNow = L10n.tr("Localizable", "text_claim_now")
  /// Clawback
  internal static let textClawback = L10n.tr("Localizable", "text_clawback")
  /// Clawback Claimable Balance
  internal static let textClawbackClaimableBalance = L10n.tr("Localizable", "text_clawback_claimable_balance")
  /// What type of transactions do you want to remove?
  internal static let textClearTransactionsDescription = L10n.tr("Localizable", "text_clear_transactions_description")
  /// Remove transactions
  internal static let textClearTransactionsTitle = L10n.tr("Localizable", "text_clear_transactions_title")
  /// You will need to confirm recovery phrase on the next screen
  internal static let textConfirmDescription = L10n.tr("Localizable", "text_confirm_description")
  /// Want to confirm the transaction?
  internal static let textConfirmDialogDescription = L10n.tr("Localizable", "text_confirm_dialog_description")
  /// Want to confirm this transaction? Your transaction will be signed and submitted to the network.
  internal static let textConfirmDialogDescriptionNoOtherSignaturesRequired = L10n.tr("Localizable", "text_confirm_dialog_description_no_other_signatures_required")
  /// Want to confirm this transaction? Your transaction will be signed, and you will need confirmations from other signers to submit it to the network.
  internal static let textConfirmDialogDescriptionOtherSignaturesRequired = L10n.tr("Localizable", "text_confirm_dialog_description_other_signatures_required")
  /// Copied
  internal static let textCopiedKeySnack = L10n.tr("Localizable", "text_copied_key_snack")
  /// Write down these [number] words and keep them secure. Don’t email them or screenshot them.
  internal static let textCopyDescription = L10n.tr("Localizable", "text_copy_description")
  /// Create Claimable Balance
  internal static let textCreateClaimableBalance = L10n.tr("Localizable", "text_create_claimable_balance")
  /// Create Passive Offer
  internal static let textCreatePassiveOffer = L10n.tr("Localizable", "text_create_passive_offer")
  /// Transaction Declined
  internal static let textDeclinedTransaction = L10n.tr("Localizable", "text_declined_transaction")
  /// Want to deny the transaction?
  internal static let textDenyDialogDescription = L10n.tr("Localizable", "text_deny_dialog_description")
  /// Are you sure?
  internal static let textDenyDialogTitle = L10n.tr("Localizable", "text_deny_dialog_title")
  /// No account nicknames
  internal static let textEmptyStateManageNicknames = L10n.tr("Localizable", "text_empty_state_manage_nicknames")
  /// No protected accounts
  internal static let textEmptyStateSignedAccounts = L10n.tr("Localizable", "text_empty_state_signed_accounts")
  /// No transactions to sign
  internal static let textEmptyStateTransactions = L10n.tr("Localizable", "text_empty_state_transactions")
  /// End Sponsoring Future Reserves
  internal static let textEndSponsoringFutureReserves = L10n.tr("Localizable", "text_end_sponsoring_future_reserves")
  /// Extend Footprint TTL
  internal static let textExtendFootprintTtl = L10n.tr("Localizable", "text_extend_footprint_ttl")
  /// Nicknames saved in your iCloud storage will be downloaded and applied on this device. Note that your nicknames are also synced with iCloud every time you restart the app. Proceed with manual sync?
  internal static let textGetLatestNicknamesAlertDescription = L10n.tr("Localizable", "text_get_latest_nicknames_alert_description")
  /// Get latest nicknames
  internal static let textGetLatestNicknamesAlertTitle = L10n.tr("Localizable", "text_get_latest_nicknames_alert_title")
  /// Enable iCloud backup for account nicknames to keep your nicknames up to date across multiple Apple devices and quickly restore them in case you log out from your Vault account.
  internal static let textICloudSyncAdviceAlertDescription = L10n.tr("Localizable", "text_iCloud_sync_advice_alert_description")
  /// Enable iCloud backup?
  internal static let textICloudSyncAdviceAlertTitle = L10n.tr("Localizable", "text_iCloud_sync_advice_alert_title")
  /// You have account nicknames stored in your local storage on this device. Enabling the iCloud backup will delete your local nicknames and set nicknames stored in your iCloud backup. Do you want to proceed?
  internal static let textICloudSyncAlertDescription = L10n.tr("Localizable", "text_iCloud_sync_alert_description")
  /// Your on-device nicknames will be deleted
  internal static let textICloudSyncAlertTitle = L10n.tr("Localizable", "text_iCloud_sync_alert_title")
  /// Initial iCloud sync is currently in progress. It usually takes about 30 seconds. Please wait until it completes.
  internal static let textICloudSyncIsActiveAlertDescription = L10n.tr("Localizable", "text_iCloud_sync_is_active_alert_description")
  /// iCloud sync in progress
  internal static let textICloudSyncIsActiveAlertTitle = L10n.tr("Localizable", "text_iCloud_sync_is_active_alert_title")
  /// Enable the internet connection to sync nicknames with iCloud.
  internal static let textICloudSyncNoInternetConnectionAlertDescription = L10n.tr("Localizable", "text_iCloud_sync_no_internet_connection_alert_description")
  /// No internet connection
  internal static let textICloudSyncNoInternetConnectionAlertTitle = L10n.tr("Localizable", "text_iCloud_sync_no_internet_connection_alert_title")
  /// Inflation
  internal static let textInflation = L10n.tr("Localizable", "text_inflation")
  /// Invalid XDR
  internal static let textInvalidXdrError = L10n.tr("Localizable", "text_invalid_xdr_error")
  /// Invoke Host Function
  internal static let textInvokeHostFunction = L10n.tr("Localizable", "text_invoke_host_function")
  /// Liquidity Pool Deposit
  internal static let textLiquidityPoolDeposit = L10n.tr("Localizable", "text_liquidity_pool_deposit")
  /// Liquidity Pool Withdraw
  internal static let textLiquidityPoolWithdraw = L10n.tr("Localizable", "text_liquidity_pool_withdraw")
  /// Forgot PIN?
  internal static let textLogoutInfo = L10n.tr("Localizable", "text_logout_info")
  /// Manage Data
  internal static let textManageData = L10n.tr("Localizable", "text_manage_data")
  /// Recovery phrase can help you to recover access to your account and associated signer keys in case your phone is lost or stolen.
  internal static let textMnemonicDescription = L10n.tr("Localizable", "text_mnemonic_description")
  /// Tap the words in the correct order.
  internal static let textMnemonicVerificationDescription = L10n.tr("Localizable", "text_mnemonic_verification_description")
  /// Wrong order. Please try again.
  internal static let textMnemonicVerifivationIncorrectOrder = L10n.tr("Localizable", "text_mnemonic_verifivation_incorrect_order")
  /// Choose a short name for this account
  internal static let textNicknameDescription = L10n.tr("Localizable", "text_nickname_description")
  /// Limited to 20 symbols
  internal static let textNicknameTextViewDescrition = L10n.tr("Localizable", "text_nickname_text_view_descrition")
  /// Enter account nickname
  internal static let textNicknameTextViewPlaceholder = L10n.tr("Localizable", "text_nickname_text_view_placeholder")
  /// Not set
  internal static let textNotSet = L10n.tr("Localizable", "text_not_set")
  /// OPERATION DETAILS
  internal static let textOperationDetailsHeaderTitle = L10n.tr("Localizable", "text_operation_details_header_title")
  /// Account Created
  internal static let textOperationNameAccountCreated = L10n.tr("Localizable", "text_operation_name_account_created")
  /// Account Merge
  internal static let textOperationNameAccountMerge = L10n.tr("Localizable", "text_operation_name_account_merge")
  /// Allow Trust
  internal static let textOperationNameAllowTrust = L10n.tr("Localizable", "text_operation_name_allow_trust")
  /// Begin Sponsoring Future Reserves
  internal static let textOperationNameBeginSponsoringFutureReserves = L10n.tr("Localizable", "text_operation_name_begin_sponsoring_future_reserves")
  /// Bump Sequence
  internal static let textOperationNameBumpSequence = L10n.tr("Localizable", "text_operation_name_bump_sequence")
  /// Cancel Offer
  internal static let textOperationNameCancelOffer = L10n.tr("Localizable", "text_operation_name_cancel_offer")
  /// Challenge
  internal static let textOperationNameChallengeTitle = L10n.tr("Localizable", "text_operation_name_challenge_title")
  /// Change Trust
  internal static let textOperationNameChangeTrust = L10n.tr("Localizable", "text_operation_name_change_trust")
  /// Claim Claimable Balance
  internal static let textOperationNameClaimClaimableBalance = L10n.tr("Localizable", "text_operation_name_claim_claimable_balance")
  /// Clawback
  internal static let textOperationNameClawback = L10n.tr("Localizable", "text_operation_name_clawback")
  /// Clawback Claimable Balance
  internal static let textOperationNameClawbackClaimableBalance = L10n.tr("Localizable", "text_operation_name_clawback_claimable_balance")
  /// Create Account
  internal static let textOperationNameCreateAccount = L10n.tr("Localizable", "text_operation_name_create_account")
  /// Create Claimable Balance
  internal static let textOperationNameCreateClaimableBalance = L10n.tr("Localizable", "text_operation_name_create_claimable_balance")
  /// Create Passive Offer
  internal static let textOperationNameCreatePassiveSellOffer = L10n.tr("Localizable", "text_operation_name_create_passive_sell_offer")
  /// End Sponsoring Future Reserves
  internal static let textOperationNameEndSponsoringFutureReserves = L10n.tr("Localizable", "text_operation_name_end_sponsoring_future_reserves")
  /// Inflation
  internal static let textOperationNameInflation = L10n.tr("Localizable", "text_operation_name_inflation")
  /// Liquidity Pool Deposit
  internal static let textOperationNameLiquidityPoolDeposit = L10n.tr("Localizable", "text_operation_name_liquidity_pool_deposit")
  /// Liquidity Pool Withdraw
  internal static let textOperationNameLiquidityPoolWithdraw = L10n.tr("Localizable", "text_operation_name_liquidity_pool_withdraw")
  /// Buy Offer
  internal static let textOperationNameManageBuyOffer = L10n.tr("Localizable", "text_operation_name_manage_buy_offer")
  /// Manage Data
  internal static let textOperationNameManageData = L10n.tr("Localizable", "text_operation_name_manage_data")
  /// Path Payment Strict Receive
  internal static let textOperationNamePathPaymentStrictReceive = L10n.tr("Localizable", "text_operation_name_path_payment_strict_receive")
  /// Path Payment Strict Send
  internal static let textOperationNamePathPaymentStrictSend = L10n.tr("Localizable", "text_operation_name_path_payment_strict_send")
  /// Payment
  internal static let textOperationNamePayment = L10n.tr("Localizable", "text_operation_name_payment")
  /// Revoke Account Sponsorship
  internal static let textOperationNameRevokeAccountSponsorship = L10n.tr("Localizable", "text_operation_name_revoke_account_sponsorship")
  /// Revoke Claimable Balance Sponsorship
  internal static let textOperationNameRevokeClaimableBalanceSponsorship = L10n.tr("Localizable", "text_operation_name_revoke_claimable_balance_sponsorship")
  /// Revoke Data Sponsorship
  internal static let textOperationNameRevokeDataSponsorship = L10n.tr("Localizable", "text_operation_name_revoke_data_sponsorship")
  /// Revoke Offer Sponsorship
  internal static let textOperationNameRevokeOfferSponsorship = L10n.tr("Localizable", "text_operation_name_revoke_offer_sponsorship")
  /// Revoke Signer Sponsorship
  internal static let textOperationNameRevokeSignerSponsorship = L10n.tr("Localizable", "text_operation_name_revoke_signer_sponsorship")
  /// Revoke Sponsorship
  internal static let textOperationNameRevokeSponsorship = L10n.tr("Localizable", "text_operation_name_revoke_sponsorship")
  /// Revoke Trustline Sponsorship
  internal static let textOperationNameRevokeTrustlineSponsorship = L10n.tr("Localizable", "text_operation_name_revoke_trustline_sponsorship")
  /// Sell Offer
  internal static let textOperationNameSellOffer = L10n.tr("Localizable", "text_operation_name_sell_offer")
  /// Set Options
  internal static let textOperationNameSetOptions = L10n.tr("Localizable", "text_operation_name_set_options")
  /// Set Trustline Flags
  internal static let textOperationNameSetTrustlineFlags = L10n.tr("Localizable", "text_operation_name_set_trustline_flags")
  /// OPERATIONS
  internal static let textOperationsHeaderTitle = L10n.tr("Localizable", "text_operations_header_title")
  /// Change PIN
  internal static let textPasscodeSimpleChangeButton = L10n.tr("Localizable", "text_passcode_simple_change_button")
  /// Continue
  internal static let textPasscodeSimpleIgnoreButton = L10n.tr("Localizable", "text_passcode_simple_ignore_button")
  /// You are trying to set a very common PIN which can be easily guessed by someone. We recommend to set a new PIN.
  internal static let textPasscodeSimpleMessage = L10n.tr("Localizable", "text_passcode_simple_message")
  /// Warning
  internal static let textPasscodeSimpleTitle = L10n.tr("Localizable", "text_passcode_simple_title")
  /// Path Payment Strict Receive
  internal static let textPathPaymentStrictReceive = L10n.tr("Localizable", "text_path_payment_strict_receive")
  /// Path Payment Strict Send
  internal static let textPathPaymentStrictSend = L10n.tr("Localizable", "text_path_payment_strict_send")
  /// Payment
  internal static let textPayment = L10n.tr("Localizable", "text_payment")
  /// Protect your account
  internal static let textProtectYourWallet = L10n.tr("Localizable", "text_protect_your_wallet")
  /// Use Biometric login instead of your PIN to access your account.
  internal static let textProtectYourWalletDescription = L10n.tr("Localizable", "text_protect_your_wallet_description")
  /// This key will be set as a signer for your Stellar account. To protect your LOBSTR account, copy and paste the key to LOBSTR (Settings->Multisig->Enable).
  internal static let textPublicKeyDescription = L10n.tr("Localizable", "text_public_key_description")
  /// Your Vault Public Key
  internal static let textPublicKeyTitle = L10n.tr("Localizable", "text_public_key_title")
  /// LOBSTR Vault is not a signer for any Stellar account now. Press “Re-Check” button after adding Vault signer in your wallet.
  internal static let textRecheckInfo = L10n.tr("Localizable", "text_recheck_info")
  /// Restore Footprint
  internal static let textRestoreFootprint = L10n.tr("Localizable", "text_restore_footprint")
  /// Enter the 12 or 24 word recovery phrase you were given when you created your Vault account.
  internal static let textRestoreInfo = L10n.tr("Localizable", "text_restore_info")
  /// Mnemonic Code...
  internal static let textRestorePlaceholder = L10n.tr("Localizable", "text_restore_placeholder")
  /// Revoke Sponsorship
  internal static let textRevokeSponsorship = L10n.tr("Localizable", "text_revoke_sponsorship")
  /// Multiply your security
  internal static let textSecureYourLumens = L10n.tr("Localizable", "text_secure_your_lumens")
  /// Sell Offer
  internal static let textSellOffer = L10n.tr("Localizable", "text_sell_offer")
  /// Other pending transactions with the same sequence number may become invalid if you confirm this one.
  internal static let textSequenceNumberCountDialogDescription = L10n.tr("Localizable", "text_sequence_number_count_dialog_description")
  /// Confirm this transaction?
  internal static let textSequenceNumberCountDialogTitle = L10n.tr("Localizable", "text_sequence_number_count_dialog_title")
  /// Set Account Nickname
  internal static let textSetNicknameTitle = L10n.tr("Localizable", "text_set_nickname_title")
  /// Set Options
  internal static let textSetOptions = L10n.tr("Localizable", "text_set_options")
  /// Set Trustline Flags
  internal static let textSetTrustlineFlags = L10n.tr("Localizable", "text_set_trustline_flags")
  /// ACCOUNT
  internal static let textSettingsAccountSection = L10n.tr("Localizable", "text_settings_account_section")
  /// Change PIN
  internal static let textSettingsChangePinField = L10n.tr("Localizable", "text_settings_change_pin_field")
  /// All rights reserved
  internal static let textSettingsCopyright = L10n.tr("Localizable", "text_settings_copyright")
  /// Enter your PIN to view your Recovery Phrase
  internal static let textSettingsDisplayMnemonicTitle = L10n.tr("Localizable", "text_settings_display_mnemonic_title")
  /// PIN changed
  internal static let textSettingsDisplayPinChanged = L10n.tr("Localizable", "text_settings_display_pin_changed")
  /// Get Latest Nicknames
  internal static let textSettingsGetLatestNicknamesTitle = L10n.tr("Localizable", "text_settings_get_latest_nicknames_title")
  /// Help Center
  internal static let textSettingsHelpField = L10n.tr("Localizable", "text_settings_help_field")
  /// HELP
  internal static let textSettingsHelpSection = L10n.tr("Localizable", "text_settings_help_section")
  /// Backup Nicknames to iCloud
  internal static let textSettingsICloudSync = L10n.tr("Localizable", "text_settings_iCloud_sync")
  /// iCloud backup for account nicknames allow you to sync nicknames across multiple Apple devices where you use the Vault app. It will also help you quickly restore your nicknames in case you log out from your Vault account.
  internal static let textSettingsICloudSyncAbout = L10n.tr("Localizable", "text_settings_iCloud_sync_about")
  /// If you are using Vault app on multiple devices, you should first turn on the iCloud backup on the device where your nicknames are most up-to-date. They will be uploaded to iCloud and downloaded on other devices when you enable the backup there.
  internal static let textSettingsICloudSyncMultipleDevicesDescription = L10n.tr("Localizable", "text_settings_iCloud_sync_multiple_devices_description")
  /// Using this Vault account on multiple devices?
  internal static let textSettingsICloudSyncMultipleDevicesTitle = L10n.tr("Localizable", "text_settings_iCloud_sync_multiple_devices_title")
  /// BACKUP NICKNAMES TO ICLOUD
  internal static let textSettingsICloudSyncTitle = L10n.tr("Localizable", "text_settings_iCloud_sync_title")
  /// Log Out
  internal static let textSettingsLogoutfield = L10n.tr("Localizable", "text_settings_logoutfield")
  /// Manage Account Nicknames
  internal static let textSettingsManageNicknames = L10n.tr("Localizable", "text_settings_manage_nicknames")
  /// Recovery Phrase
  internal static let textSettingsMnemonicField = L10n.tr("Localizable", "text_settings_mnemonic_field")
  /// NICKNAMES
  internal static let textSettingsNicknamesSection = L10n.tr("Localizable", "text_settings_nicknames_section")
  /// Enable Push Notifications
  internal static let textSettingsNotificationsField = L10n.tr("Localizable", "text_settings_notifications_field")
  /// OTHER
  internal static let textSettingsOtherSection = L10n.tr("Localizable", "text_settings_other_section")
  /// Transaction Confirmations
  internal static let textSettingsPromtDecisionsField = L10n.tr("Localizable", "text_settings_promt_decisions_field")
  /// Vault Public key
  internal static let textSettingsPublicKeyField = L10n.tr("Localizable", "text_settings_public_key_field")
  /// Vault Signer Key
  internal static let textSettingsPublicKeyTitle = L10n.tr("Localizable", "text_settings_public_key_title")
  /// Rate Us
  internal static let textSettingsRateUsField = L10n.tr("Localizable", "text_settings_rate_us_field")
  /// SECURITY
  internal static let textSettingsSecuritySection = L10n.tr("Localizable", "text_settings_security_section")
  /// Signer for 5 accounts
  internal static let textSettingsSignerForField = L10n.tr("Localizable", "text_settings_signer_for_field")
  /// Protects [number] Account
  internal static let textSettingsSignersField = L10n.tr("Localizable", "text_settings_signers_field")
  /// Select whether you want to receive transaction requests that don’t contain any valid signatures from protected accounts or other signers. Choose ‘No’ to protect your signer account from spam transactions.
  internal static let textSettingsSpamProtectionAbout = L10n.tr("Localizable", "text_settings_spam_protection_about")
  /// Allow Unsigned Transactions
  internal static let textSettingsSpamProtectionField = L10n.tr("Localizable", "text_settings_spam_protection_field")
  /// ALLOW UNSIGNED TRANSACTIONS
  internal static let textSettingsSpamProtectionTitle = L10n.tr("Localizable", "text_settings_spam_protection_title")
  /// Fingerprint Login
  internal static let textSettingsTouchIdField = L10n.tr("Localizable", "text_settings_touch_id_field")
  /// Show additional confirmation alert before signing transaction requests to avoid mistakes.
  internal static let textSettingsTransactionsConfirmationsAbout = L10n.tr("Localizable", "text_settings_transactions_confirmations_about")
  /// CONFIRM TRANSACTIONS
  internal static let textSettingsTransactionsConfirmationsTitle = L10n.tr("Localizable", "text_settings_transactions_confirmations_title")
  /// Version
  internal static let textSettingsVersionField = L10n.tr("Localizable", "text_settings_version_field")
  /// Sign in to your iCloud account in device Settings to enable backup for nicknames. Launch Settings on the Home screen of your device, and sign in with your Apple ID. From there tap iCloud and turn iCloud Drive on. Grant access to iCloud for Vault app under Apps Using iCloud.
  internal static let textSignInToICloudAlertDescription = L10n.tr("Localizable", "text_sign_in_to_iCloud_alert_description")
  /// Sign In to iCloud
  internal static let textSignInToICloudAlertTitle = L10n.tr("Localizable", "text_sign_in_to_iCloud_alert_title")
  /// It looks like you’ve signed out from your Apple ID or disabled iCloud access for Vault app in device Settings. iCloud backup for nicknames has been disabled. Your nicknames will be stored locally on-device.
  internal static let textSignOutFromICloudAlertDescription = L10n.tr("Localizable", "text_sign_out_from_iCloud_alert_description")
  /// iCloud backup disabled
  internal static let textSignOutFromICloudAlertTitle = L10n.tr("Localizable", "text_sign_out_from_iCloud_alert_title")
  /// %@ signature required to submit this transaction to the network
  internal static func textSignatureRequiredMessage(_ p1: String) -> String {
    return L10n.tr("Localizable", "text_signature_required_message", p1)
  }
  /// %@ signatures required to submit this transaction to the network
  internal static func textSignaturesRequiredMessage(_ p1: String) -> String {
    return L10n.tr("Localizable", "text_signatures_required_message", p1)
  }
  /// Your Vault account is not a signer for any other Stellar accounts
  internal static let textSignerCheckInformation = L10n.tr("Localizable", "text_signer_check_information")
  /// Signer For
  internal static let textSignerFor = L10n.tr("Localizable", "text_signer_for")
  /// SIGNERS
  internal static let textSignersHeaderTitle = L10n.tr("Localizable", "text_signers_header_title")
  /// Transaction Failed
  internal static let textStatusFailureTitle = L10n.tr("Localizable", "text_status_failure_title")
  /// You have successfully signed this transaction. More signatures are required to submit this transaction to the network
  internal static let textStatusNeedMoreSignaturesDescription = L10n.tr("Localizable", "text_status_need_more_signatures_description")
  /// Signed XDR
  internal static let textStatusSignedXdrTitle = L10n.tr("Localizable", "text_status_signed_xdr_title")
  /// Transaction confirmed and submitted to the network
  internal static let textStatusSuccessDescription = L10n.tr("Localizable", "text_status_success_description")
  /// Success
  internal static let textStatusSuccessTitle = L10n.tr("Localizable", "text_status_success_title")
  /// Transaction can not be confirmed, its sequence number is invalid.
  internal static let textTransactionInvalidError = L10n.tr("Localizable", "text_transaction_invalid_error")
  /// Invalid
  internal static let textTransactionInvalidLabel = L10n.tr("Localizable", "text_transaction_invalid_label")
  /// Transactions to Sign
  internal static let textTransactionsToSign = L10n.tr("Localizable", "text_transactions_to_sign")
  /// You can do it later in Settings
  internal static let textTurnOnDescription = L10n.tr("Localizable", "text_turn_on_description")
  /// %@ operation failed
  internal static func textTvErrorShortDescription(_ p1: String) -> String {
    return L10n.tr("Localizable", "text_tv_error_short_description", p1)
  }
  /// %@ (operation %@) failed
  internal static func textTvErrorShortDescriptionWithNumber(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Localizable", "text_tv_error_short_description_with_number", p1, p2)
  }
  /// Unknown
  internal static let textUnknown = L10n.tr("Localizable", "text_unknown")
  /// Vault Signer Key
  internal static let textVaultPublicKey = L10n.tr("Localizable", "text_vault_publicKey")
  /// Operation Error
  internal static let titleErrorOperationDetails = L10n.tr("Localizable", "title_error_operation_details")
  /// Additional signatures are needed to authorize this transaction, please copy XDR and sign it.
  internal static let txBadAuth = L10n.tr("Localizable", "tx_bad_auth")
  /// Unused signatures attached to transaction.
  internal static let txBadAuthExtra = L10n.tr("Localizable", "tx_bad_auth_extra")
  /// minSeqAge or minSeqLedgerGap conditions not met.
  internal static let txBadMinSecAgeOrGap = L10n.tr("Localizable", "tx_bad_min_sec_age_or_gap")
  /// Sequence number does not match source account.
  internal static let txBadSeq = L10n.tr("Localizable", "tx_bad_seq")
  /// Sponsorship not confirmed.
  internal static let txBadSponsorship = L10n.tr("Localizable", "tx_bad_sponsorship")
  /// Fee bump inner transaction failed.
  internal static let txBumpInnerFailed = L10n.tr("Localizable", "tx_bump_inner_failed")
  /// Transaction was failed
  internal static let txCommonError = L10n.tr("Localizable", "tx_common_error")
  /// One of the operations failed.
  internal static let txFailed = L10n.tr("Localizable", "tx_failed")
  /// Fee bump inner transaction succeeded.
  internal static let txFeeBumpInnerSuccess = L10n.tr("Localizable", "tx_fee_bump_inner_success")
  /// The network transaction fee would bring your XLM balance below minimum reserve. Fund the account with extra XLM to complete the transaction.
  internal static let txInsufficientBalance = L10n.tr("Localizable", "tx_insufficient_balance")
  /// Fee is too small.
  internal static let txInsufficientFee = L10n.tr("Localizable", "tx_insufficient_fee")
  /// An unknown error occurred.
  internal static let txInternalError = L10n.tr("Localizable", "tx_internal_error")
  /// Precondition is invalid.
  internal static let txMalformed = L10n.tr("Localizable", "tx_malformed")
  /// No operation was specified.
  internal static let txMissingOperation = L10n.tr("Localizable", "tx_missing_operation")
  /// Source account not found.
  internal static let txNoAccount = L10n.tr("Localizable", "tx_no_account")
  /// Transaction type not supported.
  internal static let txNotSupported = L10n.tr("Localizable", "tx_not_supported")
  /// All operations succeeded.
  internal static let txSuccess = L10n.tr("Localizable", "tx_success")
  /// Ledger closeTime before minTime value in the transaction.
  internal static let txTooEarly = L10n.tr("Localizable", "tx_too_early")
  /// Ledger closeTime after maxTime value in the transaction.
  internal static let txTooLate = L10n.tr("Localizable", "tx_too_late")
  /// Undefined.
  internal static let txUndefined = L10n.tr("Localizable", "tx_undefined")
  /// Unknown card status
  internal static let unknownStatus = L10n.tr("Localizable", "unknownStatus")
  /// Writing data: %@%%
  internal static func writingDataProgress(_ p1: String) -> String {
    return L10n.tr("Localizable", "writing_data_progress", p1)
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
