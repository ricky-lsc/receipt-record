// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Receipt Record';

  @override
  String get navReceipts => 'Receipts';

  @override
  String get navSummary => 'Summary';

  @override
  String get navExport => 'Export';

  @override
  String get addReceiptTooltip => 'Take Photo / Add Receipt';

  @override
  String get toggleThemeTooltip => 'Toggle Theme';

  @override
  String get cloudAiSettingsTooltip => 'Cloud AI Settings (GLM)';

  @override
  String get chooseLanguageTooltip => 'Language Settings';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get followSystem => 'Follow System';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => 'Traditional Chinese (繁體中文)';

  @override
  String get simplifiedChinese => 'Simplified Chinese (简体中文)';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryDining => 'Dining & Cafes';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryHealthcare => 'Healthcare';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryOffice => 'Office Supplies';

  @override
  String get categoryOther => 'Other';

  @override
  String get paymentCreditCard => 'Credit Card';

  @override
  String get paymentDebitCard => 'Debit Card';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentDigitalWallet => 'Digital Wallet (Apple/Google Pay)';

  @override
  String get paymentBankTransfer => 'Bank Transfer';

  @override
  String get paymentOther => 'Other';

  @override
  String get receiptRecords => 'Receipt Records';

  @override
  String get sortAndFilter => 'Sort & Filter';

  @override
  String get searchPlaceholder => 'Search merchant, item, note...';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllReceiptsTitle => 'Clear All Receipts';

  @override
  String get clearAllReceiptsConfirm =>
      'Are you sure you want to delete all saved receipts?';

  @override
  String get clearAll => 'Clear All';

  @override
  String get deleteReceiptTitle => 'Delete Receipt';

  @override
  String get deleteReceiptConfirm =>
      'Are you sure you want to delete this receipt?';

  @override
  String get delete => 'Delete';

  @override
  String get noReceiptsFound => 'No receipts found';

  @override
  String get noReceiptsDesc =>
      'Tap the button below to add your first receipt.';

  @override
  String get noMatchingReceipts => 'No matching receipts';

  @override
  String get noMatchingReceiptsDesc =>
      'Try adjusting your search query or filter options.';

  @override
  String get sortDateDesc => 'Date: Newest First';

  @override
  String get sortDateAsc => 'Date: Oldest First';

  @override
  String get sortAmountDesc => 'Amount: High to Low';

  @override
  String get sortAmountAsc => 'Amount: Low to High';

  @override
  String get sortMerchantAsc => 'Merchant: A to Z';

  @override
  String get filterAll => 'All Time';

  @override
  String get filterThisMonth => 'This Month';

  @override
  String get filterLastMonth => 'Last Month';

  @override
  String get filterThisYear => 'This Year';

  @override
  String get receiptCountSuffix => 'receipts';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get recordReceipt => 'Record Receipt';

  @override
  String get editReceipt => 'Edit Receipt';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get takePhotoOrUpload => 'Take Photo or Upload Receipt';

  @override
  String get photoUploadSubtitle => 'Camera, gallery, or generate sample';

  @override
  String get totalAmount => 'TOTAL AMOUNT';

  @override
  String get merchantName => 'MERCHANT / STORE NAME';

  @override
  String get merchantPlaceholder => 'e.g. Trader Joe\'s, Target...';

  @override
  String get merchantRequired => 'Please enter a merchant name';

  @override
  String get date => 'DATE';

  @override
  String get category => 'CATEGORY';

  @override
  String get paymentMethod => 'PAYMENT METHOD';

  @override
  String get advancedDetails => 'Advanced Details & Line Items';

  @override
  String get lineItems => 'Line Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get quantity => 'Qty';

  @override
  String get unitPrice => 'Price';

  @override
  String get tax => 'Tax';

  @override
  String get tip => 'Tip';

  @override
  String get notes => 'Notes';

  @override
  String get notesPlaceholder => 'Add any notes or tags...';

  @override
  String get changePhoto => 'Change';

  @override
  String get aiExtract => 'AI Extract';

  @override
  String get scanOcr => 'Scan OCR';

  @override
  String get dataExtracted => 'Data Extracted';

  @override
  String get receiptAttached => 'Receipt Attached';

  @override
  String get scanningOnDevice => 'Scanning receipt on-device...';

  @override
  String get extractingWithAi => 'Extracting with GLM-5.3-Flash Cloud AI...';

  @override
  String get viewText => 'View Text';

  @override
  String get viewRaw => 'View Raw';

  @override
  String get cameraNotAvailable => 'Camera Not Available';

  @override
  String get cameraNotAvailableDesc =>
      'Camera is not available on this platform or simulator.\n\nWould you like to select a receipt photo from files instead?';

  @override
  String get chooseFromFiles => 'Choose from Files';

  @override
  String get configureCloudAiTitle => 'Configure Cloud AI';

  @override
  String get configureCloudAiDesc =>
      'GLM-5.3-Flash Cloud AI requires your API key for receipt extraction (BYOK).\n\nWould you like to enter your API key, or use on-device OCR instead?';

  @override
  String get useOnDeviceOcr => 'Use On-Device OCR';

  @override
  String get configureKey => 'Configure Key';

  @override
  String get noReceiptDataDetected =>
      'GLM AI did not detect clear receipt data. You can enter details manually or try On-Device OCR.';

  @override
  String get runOnDeviceOcr => 'Run On-Device OCR';

  @override
  String get close => 'Close';

  @override
  String get scannedText => 'Scanned Text';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get generateSamplePhoto => 'Generate Sample Photo';

  @override
  String get receiptDetails => 'Receipt Details';

  @override
  String get edit => 'Edit';

  @override
  String get items => 'Items';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get total => 'Total';

  @override
  String get cloudAiSettings => 'Cloud AI Settings';

  @override
  String get byokBadge => 'BYOK • GLM-5.3-Flash Vision';

  @override
  String get byokDescription =>
      'Bring Your Own Key (BYOK): Your API key is encrypted on your device (iOS Keychain / Android KeyStore) and only sent directly to Zhipu / BigModel API.';

  @override
  String get enableCloudAi => 'Enable Cloud AI Extraction';

  @override
  String get enableCloudAiSubtitle =>
      'Uses GLM-5.3-Flash to extract merchant, items, dates, and amounts';

  @override
  String get apiKeyLabel => 'Zhipu / BigModel API Key';

  @override
  String get apiKeyHint => 'Enter API Key (e.g. 82958f...voER...)';

  @override
  String get apiKeyHelpText =>
      'Get an API key from open.bigmodel.cn or z.ai platform.';

  @override
  String get modelAndEndpoint => 'Model & Endpoint Settings';

  @override
  String get modelName => 'Model Name';

  @override
  String get apiEndpoint => 'API Endpoint';

  @override
  String get testConnection => 'Test API Connection';

  @override
  String get testingConnection => 'Testing connection...';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get keyRemoved => 'API key removed from secure storage.';

  @override
  String get settingsSaved => 'Cloud AI settings saved successfully.';

  @override
  String get showKey => 'Show Key';

  @override
  String get hideKey => 'Hide Key';

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get expenseSummary => 'Expense Summary';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get totalReceipts => 'Total Receipts';

  @override
  String get topCategory => 'Top Category';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get spendingOverTime => 'Spending Over Time';

  @override
  String get monthlySpending => 'Monthly Spending';

  @override
  String get noExpenseData => 'No Expense Data Yet';

  @override
  String get noExpenseDataDesc =>
      'Record your receipts to see visual spending charts and expense analytics.';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get exportReceipts => 'Export Receipts';

  @override
  String get exportDescription =>
      'Export your receipts, line items, and expense records in CSV or JSON format.';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get csvFormat => 'CSV (Spreadsheet / Excel)';

  @override
  String get csvFormatDesc => 'Best for Excel, Numbers, and Google Sheets';

  @override
  String get jsonFormat => 'JSON (Data Interchange)';

  @override
  String get jsonFormatDesc =>
      'Complete data including line items and image links';

  @override
  String get dateRange => 'Date Range';

  @override
  String get allRecords => 'All Records';

  @override
  String get thisMonthRecords => 'This Month';

  @override
  String get lastMonthRecords => 'Last Month';

  @override
  String get thisYearRecords => 'This Year';

  @override
  String get exportAsFile => 'Export as File';

  @override
  String get shareRecords => 'Share Records';

  @override
  String get exportSuccess => 'Receipts exported successfully.';

  @override
  String get recentReceipts => 'Recent Receipts';

  @override
  String get viewAll => 'View All';

  @override
  String get splitBill => 'Split Bill';

  @override
  String get splitBillTitle => 'Split Receipt Bill';

  @override
  String get numberOfPeople => 'Number of People';

  @override
  String get personName => 'Person Name';

  @override
  String get participant => 'Participant';

  @override
  String get me => 'Me';

  @override
  String get equalSplit => 'Equal Split';

  @override
  String get customSplit => 'Custom Split';

  @override
  String get fineTuneAmounts => 'Fine-Tune Amounts';

  @override
  String get fineTuneSubtitle =>
      'Adjust individual shares if someone pays more or less';

  @override
  String get receiptTotal => 'Receipt Total';

  @override
  String get totalAllocated => 'Allocated';

  @override
  String get remainingBalance => 'Remaining';

  @override
  String get overAllocated => 'Over by';

  @override
  String get balanced => 'Balanced';

  @override
  String get distributeRemaining => 'Auto-Balance';

  @override
  String get copyBreakdown => 'Copy Breakdown';

  @override
  String get copiedToClipboard => 'Split breakdown copied to clipboard!';

  @override
  String get saveSplit => 'Save Split';

  @override
  String get splitSaved => 'Receipt split saved successfully.';

  @override
  String splitBadge(Object count) {
    return 'Split ($count)';
  }

  @override
  String get addPerson => 'Add Person';

  @override
  String get removePerson => 'Remove';

  @override
  String get clearSplit => 'Clear Split';

  @override
  String get clearSplitConfirm => 'Remove bill split for this receipt?';

  @override
  String get markPaid => 'Paid';

  @override
  String get markUnpaid => 'Unpaid';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterLast30Days => 'Last 30 Days';

  @override
  String get customRange => 'Custom Range';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get vsPreviousPeriod => 'vs previous period';

  @override
  String get spendingUp => 'more than previous';

  @override
  String get spendingDown => 'less than previous';

  @override
  String get spendingFlat => 'equal to previous';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get setBudget => 'Set Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get budgetSpent => 'Spent of';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetExceeded => 'Over Budget';

  @override
  String get daysRemaining => 'days left';

  @override
  String get dailyAllowance => 'daily budget';

  @override
  String get noBudgetSet => 'Set a monthly budget to track spending goals.';

  @override
  String get splitAndReimbursements => 'Split & Reimbursements';

  @override
  String get netPersonal => 'Net Personal Spend';

  @override
  String get grossTotal => 'Gross Total';

  @override
  String get unsettledFromFriends => 'Owed to You';

  @override
  String get settledReimbursements => 'Reimbursed';

  @override
  String get taxAndTipSummary => 'Tax & Tip Deductibles';

  @override
  String get totalTaxPaid => 'Total Tax Paid';

  @override
  String get totalTipPaid => 'Total Tips Paid';

  @override
  String get subtotalBeforeTax => 'Pre-Tax Subtotal';

  @override
  String get categoryDetails => 'Category Details';

  @override
  String get receiptsInCategory => 'receipts in this category';

  @override
  String get tapCategoryToInspect => 'Tap any category to view all receipts';

  @override
  String get storageSettings => 'Storage Location & Backup';

  @override
  String get storageMode => 'Storage Location';

  @override
  String get defaultStorage => 'Default App Storage';

  @override
  String get defaultStorageDesc => 'Internal application sandbox directory';

  @override
  String get customStorage => 'Custom Directory';

  @override
  String get customStorageDesc =>
      'Save receipt photos and live backups in your chosen folder';

  @override
  String get chooseFolder => 'Choose Folder';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get autoBackupTitle => 'Auto-Sync Live Backup';

  @override
  String get autoBackupSubtitle =>
      'Automatically maintains receipts.json and receipts.csv in this folder (sync with Dropbox, Nextcloud, or Obsidian)';

  @override
  String get migrateReceipts => 'Migrate Existing Receipts';

  @override
  String get migrateReceiptsDesc =>
      'Copy all current receipts and photos into this folder';

  @override
  String get folderNotSelected => 'No folder selected';

  @override
  String get currentPath => 'Current Path';

  @override
  String get importReceipts => 'Import & Restore';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get importDescription =>
      'Restore receipts from a JSON backup file or CSV spreadsheet.';

  @override
  String get selectBackupFile => 'Select Backup File';

  @override
  String get importPreview => 'Import Preview';

  @override
  String get importMode => 'Import Strategy';

  @override
  String get importMerge => 'Merge with Existing';

  @override
  String get importMergeDesc =>
      'Keep current receipts and add any new ones from file';

  @override
  String get importOverwrite => 'Overwrite All Records';

  @override
  String get importOverwriteDesc =>
      'Delete current receipts and restore exact file contents';

  @override
  String get confirmImport => 'Confirm Import';

  @override
  String get importSuccess => 'Receipts imported successfully.';

  @override
  String get importFailed => 'Import failed';

  @override
  String get noValidReceiptsFound => 'No valid receipts found in this file.';

  @override
  String get shareSummary => 'Share Summary';

  @override
  String get shareSummaryTitle => 'Share Expense Summary';

  @override
  String get summaryCopied => 'Summary copied to clipboard!';

  @override
  String get topCategoriesHeader => 'Top Categories';

  @override
  String get saveMarkdownReport => 'Save Report (.md)';

  @override
  String get shareViaReceiptRecord => 'Shared via Receipt Record';

  @override
  String get photoAttachedTip =>
      'Photo attached. Fill details by hand or tap AI Extract.';

  @override
  String get manualEntry => 'Manual Entry (No Photo)';

  @override
  String get manualEntrySubtitle => 'Type merchant and amount by hand';

  @override
  String get takePhotoSubtitle => 'Snap a photo of your paper receipt';

  @override
  String get chooseFromGallerySubtitle =>
      'Select an existing photo from device';
}
