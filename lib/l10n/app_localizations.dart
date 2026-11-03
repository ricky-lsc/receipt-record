import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt Record'**
  String get appTitle;

  /// No description provided for @navReceipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get navReceipts;

  /// No description provided for @navSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get navSummary;

  /// No description provided for @navExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get navExport;

  /// No description provided for @addReceiptTooltip.
  ///
  /// In en, this message translates to:
  /// **'Take Photo / Add Receipt'**
  String get addReceiptTooltip;

  /// No description provided for @toggleThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleThemeTooltip;

  /// No description provided for @cloudAiSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI Settings (GLM)'**
  String get cloudAiSettingsTooltip;

  /// No description provided for @chooseLanguageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get chooseLanguageTooltip;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @traditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese (繁體中文)'**
  String get traditionalChinese;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese (简体中文)'**
  String get simplifiedChinese;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryDining.
  ///
  /// In en, this message translates to:
  /// **'Dining & Cafes'**
  String get categoryDining;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get categoryHealthcare;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryOffice.
  ///
  /// In en, this message translates to:
  /// **'Office Supplies'**
  String get categoryOffice;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @paymentCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get paymentCreditCard;

  /// No description provided for @paymentDebitCard.
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get paymentDebitCard;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentDigitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Digital Wallet (Apple/Google Pay)'**
  String get paymentDigitalWallet;

  /// No description provided for @paymentBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get paymentBankTransfer;

  /// No description provided for @paymentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get paymentOther;

  /// No description provided for @receiptRecords.
  ///
  /// In en, this message translates to:
  /// **'Receipt Records'**
  String get receiptRecords;

  /// No description provided for @sortAndFilter.
  ///
  /// In en, this message translates to:
  /// **'Sort & Filter'**
  String get sortAndFilter;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search merchant, item, note...'**
  String get searchPlaceholder;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllReceiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Receipts'**
  String get clearAllReceiptsTitle;

  /// No description provided for @clearAllReceiptsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all saved receipts?'**
  String get clearAllReceiptsConfirm;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @deleteReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Receipt'**
  String get deleteReceiptTitle;

  /// No description provided for @deleteReceiptConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this receipt?'**
  String get deleteReceiptConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noReceiptsFound.
  ///
  /// In en, this message translates to:
  /// **'No receipts found'**
  String get noReceiptsFound;

  /// No description provided for @noReceiptsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to add your first receipt.'**
  String get noReceiptsDesc;

  /// No description provided for @noMatchingReceipts.
  ///
  /// In en, this message translates to:
  /// **'No matching receipts'**
  String get noMatchingReceipts;

  /// No description provided for @noMatchingReceiptsDesc.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search query or filter options.'**
  String get noMatchingReceiptsDesc;

  /// No description provided for @sortDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Date: Newest First'**
  String get sortDateDesc;

  /// No description provided for @sortDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Date: Oldest First'**
  String get sortDateAsc;

  /// No description provided for @sortAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount: High to Low'**
  String get sortAmountDesc;

  /// No description provided for @sortAmountAsc.
  ///
  /// In en, this message translates to:
  /// **'Amount: Low to High'**
  String get sortAmountAsc;

  /// No description provided for @sortMerchantAsc.
  ///
  /// In en, this message translates to:
  /// **'Merchant: A to Z'**
  String get sortMerchantAsc;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAll;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get filterThisMonth;

  /// No description provided for @filterLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get filterLastMonth;

  /// No description provided for @filterThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get filterThisYear;

  /// No description provided for @receiptCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'receipts'**
  String get receiptCountSuffix;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @recordReceipt.
  ///
  /// In en, this message translates to:
  /// **'Record Receipt'**
  String get recordReceipt;

  /// No description provided for @editReceipt.
  ///
  /// In en, this message translates to:
  /// **'Edit Receipt'**
  String get editReceipt;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @takePhotoOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Take Photo or Upload Receipt'**
  String get takePhotoOrUpload;

  /// No description provided for @photoUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Camera, gallery, or generate sample'**
  String get photoUploadSubtitle;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AMOUNT'**
  String get totalAmount;

  /// No description provided for @merchantName.
  ///
  /// In en, this message translates to:
  /// **'MERCHANT / STORE NAME'**
  String get merchantName;

  /// No description provided for @merchantPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Trader Joe\'s, Target...'**
  String get merchantPlaceholder;

  /// No description provided for @merchantRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a merchant name'**
  String get merchantRequired;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get date;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get paymentMethod;

  /// No description provided for @advancedDetails.
  ///
  /// In en, this message translates to:
  /// **'Advanced Details & Line Items'**
  String get advancedDetails;

  /// No description provided for @lineItems.
  ///
  /// In en, this message translates to:
  /// **'Line Items'**
  String get lineItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get quantity;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get unitPrice;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add any notes or tags...'**
  String get notesPlaceholder;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changePhoto;

  /// No description provided for @aiExtract.
  ///
  /// In en, this message translates to:
  /// **'AI Extract'**
  String get aiExtract;

  /// No description provided for @scanOcr.
  ///
  /// In en, this message translates to:
  /// **'Scan OCR'**
  String get scanOcr;

  /// No description provided for @dataExtracted.
  ///
  /// In en, this message translates to:
  /// **'Data Extracted'**
  String get dataExtracted;

  /// No description provided for @receiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Receipt Attached'**
  String get receiptAttached;

  /// No description provided for @scanningOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Scanning receipt on-device...'**
  String get scanningOnDevice;

  /// No description provided for @extractingWithAi.
  ///
  /// In en, this message translates to:
  /// **'Extracting with GLM-5.3-Flash Cloud AI...'**
  String get extractingWithAi;

  /// No description provided for @viewText.
  ///
  /// In en, this message translates to:
  /// **'View Text'**
  String get viewText;

  /// No description provided for @viewRaw.
  ///
  /// In en, this message translates to:
  /// **'View Raw'**
  String get viewRaw;

  /// No description provided for @cameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera Not Available'**
  String get cameraNotAvailable;

  /// No description provided for @cameraNotAvailableDesc.
  ///
  /// In en, this message translates to:
  /// **'Camera is not available on this platform or simulator.\n\nWould you like to select a receipt photo from files instead?'**
  String get cameraNotAvailableDesc;

  /// No description provided for @chooseFromFiles.
  ///
  /// In en, this message translates to:
  /// **'Choose from Files'**
  String get chooseFromFiles;

  /// No description provided for @configureCloudAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Configure Cloud AI'**
  String get configureCloudAiTitle;

  /// No description provided for @configureCloudAiDesc.
  ///
  /// In en, this message translates to:
  /// **'GLM-5.3-Flash Cloud AI requires your API key for receipt extraction (BYOK).\n\nWould you like to enter your API key, or use on-device OCR instead?'**
  String get configureCloudAiDesc;

  /// No description provided for @useOnDeviceOcr.
  ///
  /// In en, this message translates to:
  /// **'Use On-Device OCR'**
  String get useOnDeviceOcr;

  /// No description provided for @configureKey.
  ///
  /// In en, this message translates to:
  /// **'Configure Key'**
  String get configureKey;

  /// No description provided for @noReceiptDataDetected.
  ///
  /// In en, this message translates to:
  /// **'GLM AI did not detect clear receipt data. You can enter details manually or try On-Device OCR.'**
  String get noReceiptDataDetected;

  /// No description provided for @runOnDeviceOcr.
  ///
  /// In en, this message translates to:
  /// **'Run On-Device OCR'**
  String get runOnDeviceOcr;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @scannedText.
  ///
  /// In en, this message translates to:
  /// **'Scanned Text'**
  String get scannedText;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @generateSamplePhoto.
  ///
  /// In en, this message translates to:
  /// **'Generate Sample Photo'**
  String get generateSamplePhoto;

  /// No description provided for @receiptDetails.
  ///
  /// In en, this message translates to:
  /// **'Receipt Details'**
  String get receiptDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @cloudAiSettings.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI Settings'**
  String get cloudAiSettings;

  /// No description provided for @byokBadge.
  ///
  /// In en, this message translates to:
  /// **'BYOK • GLM-5.3-Flash Vision'**
  String get byokBadge;

  /// No description provided for @byokDescription.
  ///
  /// In en, this message translates to:
  /// **'Bring Your Own Key (BYOK): Your API key is encrypted on your device (iOS Keychain / Android KeyStore) and only sent directly to Zhipu / BigModel API.'**
  String get byokDescription;

  /// No description provided for @enableCloudAi.
  ///
  /// In en, this message translates to:
  /// **'Enable Cloud AI Extraction'**
  String get enableCloudAi;

  /// No description provided for @enableCloudAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses GLM-5.3-Flash to extract merchant, items, dates, and amounts'**
  String get enableCloudAiSubtitle;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Zhipu / BigModel API Key'**
  String get apiKeyLabel;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter API Key (e.g. 82958f...voER...)'**
  String get apiKeyHint;

  /// No description provided for @apiKeyHelpText.
  ///
  /// In en, this message translates to:
  /// **'Get an API key from open.bigmodel.cn or z.ai platform.'**
  String get apiKeyHelpText;

  /// No description provided for @modelAndEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Model & Endpoint Settings'**
  String get modelAndEndpoint;

  /// No description provided for @modelName.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelName;

  /// No description provided for @apiEndpoint.
  ///
  /// In en, this message translates to:
  /// **'API Endpoint'**
  String get apiEndpoint;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test API Connection'**
  String get testConnection;

  /// No description provided for @testingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing connection...'**
  String get testingConnection;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @keyRemoved.
  ///
  /// In en, this message translates to:
  /// **'API key removed from secure storage.'**
  String get keyRemoved;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI settings saved successfully.'**
  String get settingsSaved;

  /// No description provided for @showKey.
  ///
  /// In en, this message translates to:
  /// **'Show Key'**
  String get showKey;

  /// No description provided for @hideKey.
  ///
  /// In en, this message translates to:
  /// **'Hide Key'**
  String get hideKey;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @expenseSummary.
  ///
  /// In en, this message translates to:
  /// **'Expense Summary'**
  String get expenseSummary;

  /// No description provided for @totalSpending.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get totalSpending;

  /// No description provided for @totalReceipts.
  ///
  /// In en, this message translates to:
  /// **'Total Receipts'**
  String get totalReceipts;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get topCategory;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdown;

  /// No description provided for @spendingOverTime.
  ///
  /// In en, this message translates to:
  /// **'Spending Over Time'**
  String get spendingOverTime;

  /// No description provided for @monthlySpending.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending'**
  String get monthlySpending;

  /// No description provided for @noExpenseData.
  ///
  /// In en, this message translates to:
  /// **'No Expense Data Yet'**
  String get noExpenseData;

  /// No description provided for @noExpenseDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Record your receipts to see visual spending charts and expense analytics.'**
  String get noExpenseDataDesc;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @exportReceipts.
  ///
  /// In en, this message translates to:
  /// **'Export Receipts'**
  String get exportReceipts;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your receipts, line items, and expense records in CSV or JSON format.'**
  String get exportDescription;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @csvFormat.
  ///
  /// In en, this message translates to:
  /// **'CSV (Spreadsheet / Excel)'**
  String get csvFormat;

  /// No description provided for @csvFormatDesc.
  ///
  /// In en, this message translates to:
  /// **'Best for Excel, Numbers, and Google Sheets'**
  String get csvFormatDesc;

  /// No description provided for @jsonFormat.
  ///
  /// In en, this message translates to:
  /// **'JSON (Data Interchange)'**
  String get jsonFormat;

  /// No description provided for @jsonFormatDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete data including line items and image links'**
  String get jsonFormatDesc;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @allRecords.
  ///
  /// In en, this message translates to:
  /// **'All Records'**
  String get allRecords;

  /// No description provided for @thisMonthRecords.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonthRecords;

  /// No description provided for @lastMonthRecords.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonthRecords;

  /// No description provided for @thisYearRecords.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYearRecords;

  /// No description provided for @exportAsFile.
  ///
  /// In en, this message translates to:
  /// **'Export as File'**
  String get exportAsFile;

  /// No description provided for @shareRecords.
  ///
  /// In en, this message translates to:
  /// **'Share Records'**
  String get shareRecords;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipts exported successfully.'**
  String get exportSuccess;

  /// No description provided for @recentReceipts.
  ///
  /// In en, this message translates to:
  /// **'Recent Receipts'**
  String get recentReceipts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
