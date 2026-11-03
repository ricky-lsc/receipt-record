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

  /// No description provided for @splitBill.
  ///
  /// In en, this message translates to:
  /// **'Split Bill'**
  String get splitBill;

  /// No description provided for @splitBillTitle.
  ///
  /// In en, this message translates to:
  /// **'Split Receipt Bill'**
  String get splitBillTitle;

  /// No description provided for @numberOfPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of People'**
  String get numberOfPeople;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get personName;

  /// No description provided for @participant.
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get participant;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @equalSplit.
  ///
  /// In en, this message translates to:
  /// **'Equal Split'**
  String get equalSplit;

  /// No description provided for @customSplit.
  ///
  /// In en, this message translates to:
  /// **'Custom Split'**
  String get customSplit;

  /// No description provided for @fineTuneAmounts.
  ///
  /// In en, this message translates to:
  /// **'Fine-Tune Amounts'**
  String get fineTuneAmounts;

  /// No description provided for @fineTuneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust individual shares if someone pays more or less'**
  String get fineTuneSubtitle;

  /// No description provided for @receiptTotal.
  ///
  /// In en, this message translates to:
  /// **'Receipt Total'**
  String get receiptTotal;

  /// No description provided for @totalAllocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get totalAllocated;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingBalance;

  /// No description provided for @overAllocated.
  ///
  /// In en, this message translates to:
  /// **'Over by'**
  String get overAllocated;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @distributeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Auto-Balance'**
  String get distributeRemaining;

  /// No description provided for @copyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Copy Breakdown'**
  String get copyBreakdown;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Split breakdown copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @saveSplit.
  ///
  /// In en, this message translates to:
  /// **'Save Split'**
  String get saveSplit;

  /// No description provided for @splitSaved.
  ///
  /// In en, this message translates to:
  /// **'Receipt split saved successfully.'**
  String get splitSaved;

  /// No description provided for @splitBadge.
  ///
  /// In en, this message translates to:
  /// **'Split ({count})'**
  String splitBadge(Object count);

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add Person'**
  String get addPerson;

  /// No description provided for @removePerson.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePerson;

  /// No description provided for @clearSplit.
  ///
  /// In en, this message translates to:
  /// **'Clear Split'**
  String get clearSplit;

  /// No description provided for @clearSplitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove bill split for this receipt?'**
  String get clearSplitConfirm;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get markPaid;

  /// No description provided for @markUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get markUnpaid;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get filterThisWeek;

  /// No description provided for @filterLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get filterLast30Days;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @vsPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'vs previous period'**
  String get vsPreviousPeriod;

  /// No description provided for @spendingUp.
  ///
  /// In en, this message translates to:
  /// **'more than previous'**
  String get spendingUp;

  /// No description provided for @spendingDown.
  ///
  /// In en, this message translates to:
  /// **'less than previous'**
  String get spendingDown;

  /// No description provided for @spendingFlat.
  ///
  /// In en, this message translates to:
  /// **'equal to previous'**
  String get spendingFlat;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget Amount'**
  String get budgetAmount;

  /// No description provided for @budgetSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent of'**
  String get budgetSpent;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get budgetRemaining;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get budgetExceeded;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysRemaining;

  /// No description provided for @dailyAllowance.
  ///
  /// In en, this message translates to:
  /// **'daily budget'**
  String get dailyAllowance;

  /// No description provided for @noBudgetSet.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget to track spending goals.'**
  String get noBudgetSet;

  /// No description provided for @splitAndReimbursements.
  ///
  /// In en, this message translates to:
  /// **'Split & Reimbursements'**
  String get splitAndReimbursements;

  /// No description provided for @netPersonal.
  ///
  /// In en, this message translates to:
  /// **'Net Personal Spend'**
  String get netPersonal;

  /// No description provided for @grossTotal.
  ///
  /// In en, this message translates to:
  /// **'Gross Total'**
  String get grossTotal;

  /// No description provided for @unsettledFromFriends.
  ///
  /// In en, this message translates to:
  /// **'Owed to You'**
  String get unsettledFromFriends;

  /// No description provided for @settledReimbursements.
  ///
  /// In en, this message translates to:
  /// **'Reimbursed'**
  String get settledReimbursements;

  /// No description provided for @taxAndTipSummary.
  ///
  /// In en, this message translates to:
  /// **'Tax & Tip Deductibles'**
  String get taxAndTipSummary;

  /// No description provided for @totalTaxPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Tax Paid'**
  String get totalTaxPaid;

  /// No description provided for @totalTipPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Tips Paid'**
  String get totalTipPaid;

  /// No description provided for @subtotalBeforeTax.
  ///
  /// In en, this message translates to:
  /// **'Pre-Tax Subtotal'**
  String get subtotalBeforeTax;

  /// No description provided for @categoryDetails.
  ///
  /// In en, this message translates to:
  /// **'Category Details'**
  String get categoryDetails;

  /// No description provided for @receiptsInCategory.
  ///
  /// In en, this message translates to:
  /// **'receipts in this category'**
  String get receiptsInCategory;

  /// No description provided for @tapCategoryToInspect.
  ///
  /// In en, this message translates to:
  /// **'Tap any category to view all receipts'**
  String get tapCategoryToInspect;

  /// No description provided for @storageSettings.
  ///
  /// In en, this message translates to:
  /// **'Storage Location & Backup'**
  String get storageSettings;

  /// No description provided for @storageMode.
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageMode;

  /// No description provided for @defaultStorage.
  ///
  /// In en, this message translates to:
  /// **'Default App Storage'**
  String get defaultStorage;

  /// No description provided for @defaultStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Internal application sandbox directory'**
  String get defaultStorageDesc;

  /// No description provided for @customStorage.
  ///
  /// In en, this message translates to:
  /// **'Custom Directory'**
  String get customStorage;

  /// No description provided for @customStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Save receipt photos and live backups in your chosen folder'**
  String get customStorageDesc;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose Folder'**
  String get chooseFolder;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @autoBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Sync Live Backup'**
  String get autoBackupTitle;

  /// No description provided for @autoBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically maintains receipts.json and receipts.csv in this folder (sync with Dropbox, Nextcloud, or Obsidian)'**
  String get autoBackupSubtitle;

  /// No description provided for @migrateReceipts.
  ///
  /// In en, this message translates to:
  /// **'Migrate Existing Receipts'**
  String get migrateReceipts;

  /// No description provided for @migrateReceiptsDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy all current receipts and photos into this folder'**
  String get migrateReceiptsDesc;

  /// No description provided for @folderNotSelected.
  ///
  /// In en, this message translates to:
  /// **'No folder selected'**
  String get folderNotSelected;

  /// No description provided for @currentPath.
  ///
  /// In en, this message translates to:
  /// **'Current Path'**
  String get currentPath;

  /// No description provided for @importReceipts.
  ///
  /// In en, this message translates to:
  /// **'Import & Restore'**
  String get importReceipts;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore receipts from a JSON backup file or CSV spreadsheet.'**
  String get importDescription;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get selectBackupFile;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Import Preview'**
  String get importPreview;

  /// No description provided for @importMode.
  ///
  /// In en, this message translates to:
  /// **'Import Strategy'**
  String get importMode;

  /// No description provided for @importMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge with Existing'**
  String get importMerge;

  /// No description provided for @importMergeDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep current receipts and add any new ones from file'**
  String get importMergeDesc;

  /// No description provided for @importOverwrite.
  ///
  /// In en, this message translates to:
  /// **'Overwrite All Records'**
  String get importOverwrite;

  /// No description provided for @importOverwriteDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete current receipts and restore exact file contents'**
  String get importOverwriteDesc;

  /// No description provided for @confirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get confirmImport;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipts imported successfully.'**
  String get importSuccess;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @noValidReceiptsFound.
  ///
  /// In en, this message translates to:
  /// **'No valid receipts found in this file.'**
  String get noValidReceiptsFound;

  /// No description provided for @shareSummary.
  ///
  /// In en, this message translates to:
  /// **'Share Summary'**
  String get shareSummary;

  /// No description provided for @shareSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Expense Summary'**
  String get shareSummaryTitle;

  /// No description provided for @summaryCopied.
  ///
  /// In en, this message translates to:
  /// **'Summary copied to clipboard!'**
  String get summaryCopied;

  /// No description provided for @topCategoriesHeader.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategoriesHeader;

  /// No description provided for @saveMarkdownReport.
  ///
  /// In en, this message translates to:
  /// **'Save Report (.md)'**
  String get saveMarkdownReport;

  /// No description provided for @shareViaReceiptRecord.
  ///
  /// In en, this message translates to:
  /// **'Shared via Receipt Record'**
  String get shareViaReceiptRecord;

  /// No description provided for @photoAttachedTip.
  ///
  /// In en, this message translates to:
  /// **'Photo attached. Fill details by hand or tap AI Extract.'**
  String get photoAttachedTip;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry (No Photo)'**
  String get manualEntry;

  /// No description provided for @manualEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type merchant and amount by hand'**
  String get manualEntrySubtitle;

  /// No description provided for @takePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo of your paper receipt'**
  String get takePhotoSubtitle;

  /// No description provided for @chooseFromGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an existing photo from device'**
  String get chooseFromGallerySubtitle;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @settingsHub.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsHub;

  /// No description provided for @analyticsAndReports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get analyticsAndReports;

  /// No description provided for @themeAppearance.
  ///
  /// In en, this message translates to:
  /// **'Theme & Appearance'**
  String get themeAppearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;
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
