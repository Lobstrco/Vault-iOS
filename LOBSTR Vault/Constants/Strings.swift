// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Copied
  internal static let animationCopy = L10n.tr("Localizable", "animation_copy")
  /// Please Wait
  internal static let animationWaiting = L10n.tr("Localizable", "animation_waiting")
  /// Back
  internal static let buttonTitleBack = L10n.tr("Localizable", "button_title_back")
  /// Cancel
  internal static let buttonTitleCancel = L10n.tr("Localizable", "button_title_cancel")
  /// Confirm
  internal static let buttonTitleConfirm = L10n.tr("Localizable", "button_title_confirm")
  /// Copy Key
  internal static let buttonTitleCopyKey = L10n.tr("Localizable", "button_title_copy_key")
  /// Create Account
  internal static let buttonTitleCreateNewAccount = L10n.tr("Localizable", "button_title_create_new_account")
  /// Deny
  internal static let buttonTitleDeny = L10n.tr("Localizable", "button_title_deny")
  /// Done
  internal static let buttonTitleDone = L10n.tr("Localizable", "button_title_done")
  /// Log Out
  internal static let buttonTitleLogout = L10n.tr("Localizable", "button_title_logout")
  /// Next
  internal static let buttonTitleNext = L10n.tr("Localizable", "button_title_next")
  /// OK
  internal static let buttonTitleOk = L10n.tr("Localizable", "button_title_ok")
  /// Re-Check
  internal static let buttonTitleReCheck = L10n.tr("Localizable", "button_title_re_check")
  /// Re-Check
  internal static let buttonTitleRecheck = L10n.tr("Localizable", "button_title_recheck")
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
  /// View Transactions List
  internal static let buttonTitleViewTransactionsList = L10n.tr("Localizable", "button_title_view_transactions_list")
  /// This action will cancel account creation. Shown recovery phrase will be deleted
  internal static let cancelAlertMnemonicMessage = L10n.tr("Localizable", "cancel_alert_mnemonic_message")
  /// Are you sure?
  internal static let cancelAlertMnemonicTitle = L10n.tr("Localizable", "cancel_alert_mnemonic_title")
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
  /// error_unknown
  internal static let errorUnknown = L10n.tr("Localizable", "error_unknown")
  /// An unknown error has occured. If this issue persists, please contact support.
  internal static let errorUnknownMessage = L10n.tr("Localizable", "error_unknown_message")
  /// Unknown Error
  internal static let errorUnknownTitle = L10n.tr("Localizable", "error_unknown_title")
  /// \nIn order to change the PIN of your LOBSTR Vault account, perform the following steps:\n\n1. Select the 'Settings' screen in the main navigation\n2. Select the 'Change PIN' option in the 'Security' section\n3. Enter your current PIN\n4. Enter your new desired PIN\n5. Confirm your new desired PIN\n\n\nIf you can't remember your PIN or your biometric authentication does not match, you will need to go through the recovery process in order to access your account.\n\nThere is currently no ability to request a PIN reset in LOBSTR Vault app.\n\nBefore you log out from your LOBSTR Vault account, make sure you have secured your Recovery Phrase. You will not be able to recover your account or sign in without your Recovery Phrase - your account will be lost.\n\nRefer to the 'How To' section for instructions on the account recovery process.\n
  internal static let helpChapter10Description = L10n.tr("Localizable", "help_chapter10_description")
  /// 10. Change or Reset my PIN
  internal static let helpChapter10Title = L10n.tr("Localizable", "help_chapter10_title")
  /// \nTransactions in the Stellar Network are made up of a list of operations but mostly include only one operation.\n\nLOBSTR Vault allows signing transactions with one or many operations.\n\nYou can view the details of each transaction and the operations to be executed at the 'Transaction Details' screen.\n\n\nList of Stellar Network Operation Types:\n\n1. Create Account\nCreates a new account in Stellar network.\n\n2. Payment\nSends a simple payment between two accounts in Stellar network.\n\n3. Path Payment\nSends a path payment between two accounts in the Stellar network.\n\n4. Manage Offer\nCreates, updates or deletes an offer in the Stellar network.\n\n5. Create Passive Offer\nCreates an offer that won’t consume a counter offer that exactly matches this offer.\n\n6. Set Options\nSets account options (inflation destination, adding signers, etc.)\n\n7. Change Trust\nCreates, updates or deletes a trust line.\n\n8. Allow Trust\nUpdates the “authorized” flag of an existing trust line this is called by the issuer of the related asset.\n\n8. Account Merge\nDeletes account and transfers remaining balance to the destination account.\n\n9. Inflation\nRuns inflation.\n\n10. Manage Data\nSet, modify or delete a Data Entry (name/value pair) for an account.\n\n11. Bump Sequence\nBumps forward the sequence number of an account.\n
  internal static let helpChapter11Description = L10n.tr("Localizable", "help_chapter11_description")
  /// 11. Which transactions can I sign?
  internal static let helpChapter11Title = L10n.tr("Localizable", "help_chapter11_title")
  /// \nIf the main Stellar account has multiple signers, you may see a message that more signatures are needed for the transaction to occur at the 'Success' screen.\n\nIn most cases, this means that other signers for the main account should provide their signatures by 'Confirming' the transaction.\n\nSuch transaction will not occur on the Stellar Network until it is signed by all signers including the main account.\n\nIf you are using the combination of LOBSTR Wallet and LOBSTR Vault apps, all signers will be notified of the transaction 'sign' requests automatically.\n\n\nIn case you need more signatures, the 'Success' screen will also display a Transaction XDR.\n\nYou may treat this string as the desired transaction signed using the secret key of your LOBSTR Vault account.\n\nYou can copy a Transaction XDR and provide it to other signers if there are issues with transaction not appearing in LOBSTR Vault automatically.\n
  internal static let helpChapter12Description = L10n.tr("Localizable", "help_chapter12_description")
  /// 12. Transaction requires more signatures
  internal static let helpChapter12Title = L10n.tr("Localizable", "help_chapter12_title")
  /// \nEach transaction on the Stellar Network has a sequence number. Transactions follow a strict ordering rule when it comes to processing of transactions for each account.\n\nFor a transaction to be valid, the sequence number must be strictly 1 greater than the sequence number stored in the source account entry when the transaction is applied.\n\nIn the multisig setup using LOBSTR Vault and LOBSTR wallet, the source account is the Stellar account used in LOBSTR wallet.\n\n\nFor accounts with multisig setup, there is a probability of multiple unsigned transactions existing with the same sequence number, waiting to be signed and submitted to the Stellar Network.\n\nSuch transactions do not exist on the Stellar Network until all signatures are provided.\n\nOnly one of those transactions can ultimately occur on the Stellar Network with the given sequence number.\n\nOnce one of those transactions is accepted and applied to the ledger, other transactions will be rendered invalid and will not be accepted by the Stellar Network.\n\nAn attempt to sign a transaction with an outdated sequence number in LOBSTR Vault will fail with the 'Sequence number does not match source account' message.\n\nYou will need to remove such transactions from your transaction list manually by choosing the 'Deny' option at the 'Transaction Details' screen\n\n\nAn attempt to sign a transaction will also fail for the same reason if the sequence number is greater than the sequence number stored in the source account entry by 2 or more.\n\nIn this case, a transaction will be considered valid once the sequence number stored in the source account entry reaches the required value.\n
  internal static let helpChapter13Description = L10n.tr("Localizable", "help_chapter13_description")
  /// 13. Invalid sequence number
  internal static let helpChapter13Title = L10n.tr("Localizable", "help_chapter13_title")
  /// \nAll transactions on the Stellar Network are stored in a decentralized ledger and are final, non-reversible and non-editable.\n\nIf you successfully 'Confirmed' a transaction in LOBSTR Vault and no additional signatures are required, the transaction is final and can not be reversed.\n\nLOBSTR is not able to refund/revert a transaction, so please ensure that all the details are correct before signing.\n\nIf you successfully 'Confirmed' a transaction in LOBSTR Vault and additional signatures are required, it will be up to other transaction signers to 'Confirm' or 'Deny' the transaction.\n\nThe transaction will not be published on the Stellar Network until it contains the required signatures from all signers.\n\nIf you successfully 'Denied' a transaction in LOBSTR Vault, the transaction is rendered no longer valid and you will need to create a new transaction.\n
  internal static let helpChapter14Description = L10n.tr("Localizable", "help_chapter14_description")
  /// 14. I accidentally confirmed a transaction
  internal static let helpChapter14Title = L10n.tr("Localizable", "help_chapter14_title")
  /// \nDeveloped by the creators of LOBSTR wallet - your favorite app for storing Lumens, LOBSTR Vault is the transaction signer app for your mobile device with the local key storage.\n\nLOBSTR Vault uses multisignature technology of the Stellar Network and allows you to create a local signer account and verify transactions from multiple accounts on the Stellar Network.\n\nYour secret key is fully encrypted, securely stored in the local storage and never touches our servers.\n\nThe app uses the secret key to sign transactions on-device - you make the final decision to 'Confirm' or 'Deny' the transaction.\n\nQuick and easy to use, LOBSTR Vault is an open source app that fully integrates with LOBSTR wallet and takes the security of your Stellar account to the next level.\n\nYou can find the 'Multisig' option under the 'Settings' tab in LOBSTR wallet.\n\nWith LOBSTR wallet integration, there is no need to import Transaction XDRs. Your pending outgoing transactions will appear in the signing LOBSTR Vault account in a matter of seconds.\n\nLOBSTR Vault supports push notifications to help you to stay up-to-date with your transaction 'sign' requests.\n\nA custom 6-digit PIN and your biometric authentication help keeping your signer account safe.\n
  internal static let helpChapter1Description = L10n.tr("Localizable", "help_chapter1_description")
  /// 1. Welcome to LOBSTR Vault
  internal static let helpChapter1Title = L10n.tr("Localizable", "help_chapter1_title")
  /// \nStellar Network uses signatures as authorization. Transactions always need authorization from at least one public key in order to be considered valid.\n\nTypically transactions only involve operations on a single account. For example, if account A wanted to send lumens to account B, only account A needs to authorize the transaction.\n\nTransaction signatures are created by cryptographically signing the transaction object contents with a secret key.\n\nA transaction with an attached signature is considered to have authorization from that public key or Stellar account.\n\nIn two cases, a transaction may need more than one signature:\n\n- If the transaction has operations that affect more than one account, it will need authorization from every account in question.\n- A transaction will also need additional signatures if the account associated with the transaction has multiple singers. That is where the multisignature comes in.\n\n\nMultisignature (or “multisig”) concept presumes that account requires two or more secret key signatures before allowing a transaction to occur on the account.\n\nFor example, two people want to have a joint account so that any transactions made from that account first requires both parties to agree and sign them before it can be submitted.\n\nThis increases the security of account, as long as the two or more secret keys are stored separately.\n\n\nTransactions on the Stellar Network are made up of a list of operations but mostly include only one operation.\n\nEach operation falls under a specific threshold category: low, medium, or high. Each threshold defines the combined amount of signature weight an operation needs in order to succeed.\n\nEach account can set its own threshold values. By default, all thresholds levels are set to 0, and the master key is set to weight 1.\n\nFor the sake of simplicity of use and additional security, at the time of multisig setup, LOBSTR currently sets identical values for all threshold categories and increases them evenly with the addition of new signers.\n\nBe careful and use caution when changing your accounts thresholds in other services as this may lead to a permanent block of your account and a loss of your funds!\n\n\nFor all Stellar wallets, the private key that corresponds to its public key is called the master key.\n\nEach master key can be assigned a weight also referred to as the signature weight of that account.\n\nEach signer account also has its own signature weight.\n\nIn the multisig setup using LOBSTR Vault and LOBSTR wallet, signature weights of signer keys are the same as the weight of the master key of the primary account.\n\n\nFor the multisig-enabled account, all operations like payments, adding trustlines, updating weights and others will require two or more signatures - one from your account and one or more additional signatures from your signers.\n\nThat is where you will need LOBSTR Vault app.\n
  internal static let helpChapter2Description = L10n.tr("Localizable", "help_chapter2_description")
  /// 2. Intro to Multisignature concept
  internal static let helpChapter2Title = L10n.tr("Localizable", "help_chapter2_title")
  /// \nA Recovery Phrase, 12 Words Backup, Seed Phrase or the seed represent the same thing and have many more names in the cryptocurrency ecosystem which may be misleading.\n\nLOBSTR Vault uses the term 'Recovery Phrase'.\n\nRecovery Phrase is a list of 12 or 24 words that represent the single secret piece of data that is used to generate both the public and private key of your account.\n\nYou are the only one who has access to your Recovery Phrase.\n\nYou will need these words to restore access to your LOBSTR Vault account in case your phone is lost or stolen.\n\nYour 12 or 24-word Recovery Phrase is stored in an encrypted manner on the device you install LOBSTR Vault on.\n\nWe do not store your Recovery Phrase on our servers, nor do we have any access to it.\n\n\nThe order of the words in the Recovery Phase is very important!\n\nMake sure to write down the Recovery Phrase in the correct order without any spelling mistakes:\n\n- Start from the word in the top left corner and follow the line to the last word\n- Transition down to the next line and start with the first word on the left\n- Continue until every word is written down\n\nWrite down these 12 words on a piece of paper or print them using a secure printer.\n\nA smart move is to create multiple copies of your Recovery Phase and store it in multiple locations to prevent an inadvertent loss.\n\n\nYou will not be able to access your account without this phrase. Entering the phrase incorrectly will result in you not being able to access your account!\n\nA loss of your Recovery Phrase may also result in your main account not being able to function properly as you will not be able to sign outgoing transactions!\n\nAnybody else who discovers the phrase can access your signer account, so it must be kept safe like your other valuables. It must not be stored in any electronic or digital form.\n\nDo not email or screenshot the Recovery Phrase.\n
  internal static let helpChapter3Description = L10n.tr("Localizable", "help_chapter3_description")
  /// 3. What is a Recovery Phrase?
  internal static let helpChapter3Title = L10n.tr("Localizable", "help_chapter3_title")
  /// \nEvery Stellar account has a public key and a secret seed (Recovery Phrase).\n\nThe public key is always safe to share — other people need it to identify your account and verify that you authorized a transaction.\n\nYou will also need your Vault public key to set up the multisig solution in LOBSTR wallet.\n\nIf you are currently setting up or recovering your LOBSTR Vault account, you can find your public key at the 'Your Vault Public Key' screen.\n\nUse the 'Copy Key' button to transfer your key. The QR-code contains your Vault public key as well - you can scan it using your LOBSTR wallet app on another device.\n\nIf you are already inside your LOBSTR Vault account, you can find your Vault public key at the 'Home' screen or in the 'Account' section of the 'Settings' screen.\n\n\nIf you try to find your account using a network explorer like StellarExpert, you may receive a message that your account does not exist on Stellar ledger.\n\nDo not worry, your account is safe. It is stored locally in LOBSTR Vault app. The account does not need to actually exist on the Stellar Network to act as a signer for your main account.\n\nIf you want to use your LOBSTR Vault account as a wallet, you would need to create and fund this account at first.\n
  internal static let helpChapter4Description = L10n.tr("Localizable", "help_chapter4_description")
  /// 4. Where can I find my public key?
  internal static let helpChapter4Title = L10n.tr("Localizable", "help_chapter4_title")
  /// \nThe Recovery Phrase is the single secret piece of data that is used to generate both the public and private key for your account.\n\nLOBSTR Vault uses the Recovery Phrase instead of the private key for your convenience.\n\nYour private key is still stored locally and used to encrypt data and sign transactions.\n\nLOBSTR Vault is not a wallet app and does not expose the private key for security reasons.\n\nIf you need the private key of your LOBSTR Vault account, you would need to derive it from your 12-word Recovery Phrase using third party tools.\n
  internal static let helpChapter5Description = L10n.tr("Localizable", "help_chapter5_description")
  /// 5. Where is my private key?
  internal static let helpChapter5Title = L10n.tr("Localizable", "help_chapter5_title")
  /// \nXDR, also known as External Data Representation, is a binary serialization data format used extensively in the Stellar Network.\n\nThe ledger, transactions, results, history, and other data on the Stellar Network are encoded using XDR.\n\nTransactions are the basic unit of change in the Stellar Network and are essentially a grouping of operations.\n\nTransaсtions can include one or more operations.\n\n\nIf you have a multisig solution configured on your account, your service or wallet may provide you with Transaction Envelope XDR string.\n\nYou may treat this string as the desired transaction signed using the secret key of your account. You will need one or more additional signatures for this transaction to occur.\n\nThis string should be provided to the owner of signing account and imported to the signing service, like LOBSTR Vault.\n\nThe good news is that LOBSTR Vault saves you time and manages this process automatically - you won't need to add the Transaction XDR manually.\n\nIf you use a combination of LOBSTR wallet and LOBSTR Vault apps, your pending outgoing transaction will appear in the signing LOBSTR Vault account in a matter of seconds.\n\nThe owner of the signer account will be alerted via a push notification on the signing device.\n
  internal static let helpChapter6Description = L10n.tr("Localizable", "help_chapter6_description")
  /// 6. What is a Transaction XDR?
  internal static let helpChapter6Title = L10n.tr("Localizable", "help_chapter6_title")
  /// \nIn order to recover your LOBSTR Vault account, you should have your Recovery Phrase you've written down when you created your account.\n\nOur company does not have access to your Recovery Phrase.\n\nIt is securely stored in the local storage of your phone until you log out from your LOBSTR Vault account or remove the app.\n\nIf you ever lose your phone, remove LOBSTR Vault app accidentally or can't access your account for any reason, you can restore the account using the 12-word Recovery Phrase.\n\n\nFollow the steps below to recover your LOBSTR Vault account:\n\n1. Install LOBSTR Vault app on your iOS or Android device and open it.\n2. Choose the Recover Account option.\n3. Enter the 12-word Recovery Phrase you've written down when you created your account.\n- The word order is very important. Enter the Recovery Phrase in the correct order without any spelling mistakes.\n4. If the Recovery Phrase is entered correctly, the 'Next' button should become active.\n5. Set up your custom 6-digit PIN.\n6. Enable biometric authentication, if required.\n\nIf your account is a signer for another Stellar Account and you followed the steps correctly, the recovery process should now be complete.\n\nIf your account is not a signer for another Stellar Account, you will be transitioned to the 'Your Vault Public Key' screen.\n\nTo access your LOBSTR Vault account, you will need to set up a multisig solution on your main account at first.\n\n\nYou can use the Recover Account option to access the account (signer) created in another signer service, for example, StellarGuard.\n\nSuch service should provide the BIP-039 generated 12 or 24-word Recovery Phrase.\n\nYou should configure the multisig solution at the LOBSTR side for the system to function properly.\n
  internal static let helpChapter7Description = L10n.tr("Localizable", "help_chapter7_description")
  /// 7. Recover my LOBSTR Vault account
  internal static let helpChapter7Title = L10n.tr("Localizable", "help_chapter7_title")
  /// \nThis section will guide you through the multisig setup process where you are using a single device with both LOBSTR wallet and LOBSTR Vault apps installed.\n\nBefore you start:\n\n- Install LOBSTR wallet app on your device and login into your account.\n- Make sure you have a Stellar account linked to your LOBSTR account in the app.\n- Make sure your Stellar account activation credit provided by LOBSTR is paid off.\n- Your Stellar account should have a sufficient balance to enable a multisig solution - each additional signer increases the base reserve by 0.5 XLM.\n- Install LOBSTR Vault app on your device.\n\n\nTo enable the multisig solution for your Stellar account in LOBSTR wallet using a new signer account from LOBSTR Vault app, follow the steps below:\n\n1. In LOBSTR Vault, select 'Create Account' option.\n2. Carefully read the description and tap the 'I Understand' button.\n3. At the 'Recovery Phrase' screen, write down the presented Recovery Phrase and tap 'Next' button.\n4. Verify your Recovery Phrase by tapping the words in the correct order and tap 'Next' button.\n5. Create your custom 6 digit PIN.\n6. Confirm your custom 6 digit PIN.\n7. If enabled on your device, protect your account by enabling biometric authentication.\n8. You will be transitioned to the screen with the Vault public key and the QR code.\n9. In LOBSTR wallet app, open the 'Settings' screen and select the 'Multisig' option.\n10. Tap 'Enable Multisig' button.\n11. LOBSTR wallet should detect LOBSTR Vault account automatically and prompt to use it.\n12. Tap 'Yes, Use This Device' button.\n13. At this step, you will need to confirm that you want to add a new signer to your Stellar account. Carefully read the description and tap the 'Continue' button.\n14. If the 'Multisig enabled' screen is displayed, the singer account should be successfully added to your Stellar account.\n15. To complete the setup at LOBSTR Vault side, open the app and tap the 'Next' button at the screen with your Vault public key.\n16. If required, tap the 'Re-Check' button at the next screen.\n17. You will be transitioned to the 'Home' screen of LOBSTR Vault app.\n\nIf you followed the steps correctly, your LOBSTR Stellar account should be protected by LOBSTR Vault signer account.\n
  internal static let helpChapter8Description = L10n.tr("Localizable", "help_chapter8_description")
  /// 8. Add a signer in LOBSTR app
  internal static let helpChapter8Title = L10n.tr("Localizable", "help_chapter8_title")
  /// \nIf you have multisig enabled for your Stellar account and try to make a transaction, you may be provided with a Transaction XDR by your wallet or signer service.\n\nIt is likely that you need additional signatures for this transaction to occur on your account.\n\nIf you are using the combination of LOBSTR Wallet and LOBSTR Vault apps, transaction 'sign' requests should appear automatically in LOBSTR Vault in most cases - there is no need to import Transaction XDRs.\n\nIf you are using other service and need to add and sign a Transaction XDR in LOBSTR Vault app, follow the steps below:\n\n1. Select the 'Transactions' screen in the main navigation.\n2. Tap the '+' floating button.\n3. Paste your Transaction XDR into the input field of 'Add Transaction XDR' form.\n4. Tap the 'Submit' button.\n\nIf the 'Success' screen is displayed - your transaction should be successfully signed.\n\nYou may be provided with another Transaction XDR if you need more signatures on this transaction.\n\n\nIf the 'Add Transaction XDR' form displays errors or the 'Submit' button is disabled:\n\n- Make sure you've copied the Transaction XDR correctly - there should be no spaces before and after the XDR string.\n- Make sure you are using the correct XDR - a transaction is considered invalid if it includes signatures that aren't needed to authorize the transaction.\n
  internal static let helpChapter9Description = L10n.tr("Localizable", "help_chapter9_description")
  /// 9. Add a Transaction XDR manually
  internal static let helpChapter9Title = L10n.tr("Localizable", "help_chapter9_title")
  /// GET STARTED
  internal static let helpFirstSectionTitle = L10n.tr("Localizable", "help_first_section_title")
  /// HOW TO
  internal static let helpSecondSectionTitle = L10n.tr("Localizable", "help_second_section_title")
  /// SIGNING TRANSACTIONS
  internal static let helpThirdSectionTitle = L10n.tr("Localizable", "help_third_section_title")
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
  /// Your network connection appears to be offline. Please connect to a Wifi or cellular network to complete this operation.
  internal static let horizonErrorRequestFailedMessage = L10n.tr("Localizable", "horizon_error_request_failed_message")
  /// No Network Connection
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
  /// You will not be able to recover your account or sign in without it.
  internal static let logoutAlertMessage = L10n.tr("Localizable", "logout_alert_message")
  /// Have you secured your recovery phrase?
  internal static let logoutAlertTitle = L10n.tr("Localizable", "logout_alert_title")
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
  /// Signed Accounts
  internal static let navTitleSettingsSignedAccounts = L10n.tr("Localizable", "nav_title_settings_signed_accounts")
  /// Transaction Details
  internal static let navTitleTransactionDetails = L10n.tr("Localizable", "nav_title_transaction_details")
  /// Transactions
  internal static let navTitleTransactions = L10n.tr("Localizable", "nav_title_transactions")
  /// 
  internal static let outOfOperationRangeMessage = L10n.tr("Localizable", "OUT_OF_OPERATION_RANGE_MESSAGE")
  /// 
  internal static let outOfOperationRangeTitle = L10n.tr("Localizable", "OUT_OF_OPERATION_RANGE_TITLE")
  /// To submit transaction enter its XDR below
  internal static let textAddTransactionDescription = L10n.tr("Localizable", "text_add_transaction_description")
  /// Transaction is invalid. Please try again.
  internal static let textAddTransactionError = L10n.tr("Localizable", "text_add_transaction_error")
  /// Transaction XDR
  internal static let textAddTransactionPlaceholder = L10n.tr("Localizable", "text_add_transaction_placeholder")
  /// Add Transaction XDR
  internal static let textAddTransactionTitle = L10n.tr("Localizable", "text_add_transaction_title")
  /// You will be shown a 12 word recovery phrase. It will allow you to recover access to your account in case your phone is lost or stolen.
  internal static let textBackupDescription = L10n.tr("Localizable", "text_backup_description")
  /// Backup Your Account
  internal static let textBackupTitle = L10n.tr("Localizable", "text_backup_title")
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
  /// You will need to confirm recovery phrase on the next screen
  internal static let textConfirmDescription = L10n.tr("Localizable", "text_confirm_description")
  /// Copied
  internal static let textCopiedKeySnack = L10n.tr("Localizable", "text_copied_key_snack")
  /// Write down these [number] words and keep them secure. Don’t email them or screenshot them.
  internal static let textCopyDescription = L10n.tr("Localizable", "text_copy_description")
  /// Transaction Declined
  internal static let textDeclinedTransaction = L10n.tr("Localizable", "text_declined_transaction")
  /// Want to deny the operation?
  internal static let textDenyDialogDescription = L10n.tr("Localizable", "text_deny_dialog_description")
  /// Are you sure?
  internal static let textDenyDialogTitle = L10n.tr("Localizable", "text_deny_dialog_title")
  /// Signed accounts not found
  internal static let textEmptyStateSignedAccounts = L10n.tr("Localizable", "text_empty_state_signed_accounts")
  /// Transactions not found
  internal static let textEmptyStateTransactions = L10n.tr("Localizable", "text_empty_state_transactions")
  /// Forgot PIN?
  internal static let textLogoutInfo = L10n.tr("Localizable", "text_logout_info")
  /// Recovery phrase can help you to recover access to your account in case your phone is lost or stolen.
  internal static let textMnemonicDescription = L10n.tr("Localizable", "text_mnemonic_description")
  /// Tap the words in the correct order.
  internal static let textMnemonicVerificationDescription = L10n.tr("Localizable", "text_mnemonic_verification_description")
  /// Wrong order. Please try again.
  internal static let textMnemonicVerifivationIncorrectOrder = L10n.tr("Localizable", "text_mnemonic_verifivation_incorrect_order")
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
  /// Enter the 12 or 24 word recovery phrase you were given when you created your Vault account.
  internal static let textRestoreInfo = L10n.tr("Localizable", "text_restore_info")
  /// Mnemonic Code...
  internal static let textRestorePlaceholder = L10n.tr("Localizable", "text_restore_placeholder")
  /// Multiply your security
  internal static let textSecureYourLumens = L10n.tr("Localizable", "text_secure_your_lumens")
  /// OTHER
  internal static let textSettingsAboutSection = L10n.tr("Localizable", "text_settings_about_section")
  /// ACCOUNT
  internal static let textSettingsAccountSection = L10n.tr("Localizable", "text_settings_account_section")
  /// Change PIN
  internal static let textSettingsChangePinField = L10n.tr("Localizable", "text_settings_change_pin_field")
  /// ©2019. All rights reserved
  internal static let textSettingsCopyright = L10n.tr("Localizable", "text_settings_copyright")
  /// Enter your PIN to view your Recovery Phrase
  internal static let textSettingsDisplayMnemonicTitle = L10n.tr("Localizable", "text_settings_display_mnemonic_title")
  /// PIN changed
  internal static let textSettingsDisplayPinChanged = L10n.tr("Localizable", "text_settings_display_pin_changed")
  /// Help
  internal static let textSettingsHelpField = L10n.tr("Localizable", "text_settings_help_field")
  /// Log Out
  internal static let textSettingsLogoutfield = L10n.tr("Localizable", "text_settings_logoutfield")
  /// Recovery Phrase
  internal static let textSettingsMnemonicField = L10n.tr("Localizable", "text_settings_mnemonic_field")
  /// Notifications
  internal static let textSettingsNotificationsField = L10n.tr("Localizable", "text_settings_notifications_field")
  /// Vault Public key
  internal static let textSettingsPublicKeyField = L10n.tr("Localizable", "text_settings_public_key_field")
  /// Vault Public Key
  internal static let textSettingsPublicKeyTitle = L10n.tr("Localizable", "text_settings_public_key_title")
  /// SECURITY
  internal static let textSettingsSecuritySection = L10n.tr("Localizable", "text_settings_security_section")
  /// Signer for 5 accounts
  internal static let textSettingsSignerForField = L10n.tr("Localizable", "text_settings_signer_for_field")
  /// Signer for [number] account
  internal static let textSettingsSignersField = L10n.tr("Localizable", "text_settings_signers_field")
  /// Fingerprint Login
  internal static let textSettingsTouchIdField = L10n.tr("Localizable", "text_settings_touch_id_field")
  /// Version
  internal static let textSettingsVersionField = L10n.tr("Localizable", "text_settings_version_field")
  /// Your Vault account is not a signer for any other Stellar accounts
  internal static let textSignerCheckInformation = L10n.tr("Localizable", "text_signer_check_information")
  /// Signer For
  internal static let textSignerFor = L10n.tr("Localizable", "text_signer_for")
  /// You need more signatures to submit the operation
  internal static let textStatusDescription = L10n.tr("Localizable", "text_status_description")
  /// Transaction Failed
  internal static let textStatusFailureTitle = L10n.tr("Localizable", "text_status_failure_title")
  /// Signed XDR
  internal static let textStatusSignedXdrTitle = L10n.tr("Localizable", "text_status_signed_xdr_title")
  /// Success
  internal static let textStatusSuccessTitle = L10n.tr("Localizable", "text_status_success_title")
  /// Transaction can not be confirmed, it’s sequence number is invalid.
  internal static let textTransactionInvalidError = L10n.tr("Localizable", "text_transaction_invalid_error")
  /// Invalid
  internal static let textTransactionInvalidLabel = L10n.tr("Localizable", "text_transaction_invalid_label")
  /// Transactions to Sign
  internal static let textTransactionsToSign = L10n.tr("Localizable", "text_transactions_to_sign")
  /// You can do it later in Settings
  internal static let textTurnOnDescription = L10n.tr("Localizable", "text_turn_on_description")
  /// Vault Public Key
  internal static let textVaultPublicKey = L10n.tr("Localizable", "text_vault_publicKey")
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
