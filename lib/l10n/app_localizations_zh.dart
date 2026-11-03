// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '收据记账';

  @override
  String get navReceipts => '收据明细';

  @override
  String get navSummary => '支出统计';

  @override
  String get navExport => '导出数据';

  @override
  String get addReceiptTooltip => '拍照 / 记一笔';

  @override
  String get toggleThemeTooltip => '切换主题';

  @override
  String get cloudAiSettingsTooltip => '云端 AI 设置 (GLM)';

  @override
  String get chooseLanguageTooltip => '语言设置';

  @override
  String get language => '语言';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get languageUpdated => '语言已更新';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryGroceries => '日常买菜';

  @override
  String get categoryDining => '餐饮美食';

  @override
  String get categoryTransport => '交通出行';

  @override
  String get categoryShopping => '购物消费';

  @override
  String get categoryEntertainment => '休闲娱乐';

  @override
  String get categoryUtilities => '水电杂费';

  @override
  String get categoryHealthcare => '医疗健康';

  @override
  String get categoryTravel => '旅行出游';

  @override
  String get categoryOffice => '办公用品';

  @override
  String get categoryOther => '其他支出';

  @override
  String get paymentCreditCard => '信用卡';

  @override
  String get paymentDebitCard => '借记卡';

  @override
  String get paymentCash => '现金';

  @override
  String get paymentDigitalWallet => '移动支付 (微信/支付宝/Apple Pay)';

  @override
  String get paymentBankTransfer => '银行转账';

  @override
  String get paymentOther => '其他方式';

  @override
  String get receiptRecords => '收据记录';

  @override
  String get sortAndFilter => '排序与筛选';

  @override
  String get searchPlaceholder => '搜索商家、明细或备注...';

  @override
  String get clearAllData => '清空全部数据';

  @override
  String get clearAllReceiptsTitle => '清空所有收据';

  @override
  String get clearAllReceiptsConfirm => '确定要删除所有保存的收据记录吗？此操作无法撤销。';

  @override
  String get clearAll => '清空全部';

  @override
  String get deleteReceiptTitle => '删除收据';

  @override
  String get deleteReceiptConfirm => '确定要删除此条收据记录吗？';

  @override
  String get delete => '删除';

  @override
  String get noReceiptsFound => '暂无收据记录';

  @override
  String get noReceiptsDesc => '点击下方按钮记录您的第一张收据。';

  @override
  String get noMatchingReceipts => '未找到匹配收据';

  @override
  String get noMatchingReceiptsDesc => '尝试更改搜索关键词或调整筛选条件。';

  @override
  String get sortDateDesc => '日期：最新在前';

  @override
  String get sortDateAsc => '日期：最早在前';

  @override
  String get sortAmountDesc => '金额：从高到低';

  @override
  String get sortAmountAsc => '金额：从低到高';

  @override
  String get sortMerchantAsc => '商家：首字母 A-Z';

  @override
  String get filterAll => '全部时间';

  @override
  String get filterThisMonth => '本月';

  @override
  String get filterLastMonth => '上月';

  @override
  String get filterThisYear => '今年';

  @override
  String get receiptCountSuffix => '笔收据';

  @override
  String get totalSpent => '总支出';

  @override
  String get recordReceipt => '记一笔收据';

  @override
  String get editReceipt => '编辑收据';

  @override
  String get save => '保存';

  @override
  String get update => '更新';

  @override
  String get takePhotoOrUpload => '拍摄或上传收据照片';

  @override
  String get photoUploadSubtitle => '相机拍照、相册选择或生成样例';

  @override
  String get totalAmount => '消费总金额';

  @override
  String get merchantName => '商家 / 店铺名称';

  @override
  String get merchantPlaceholder => '如：山姆会员店、盒马、星巴克...';

  @override
  String get merchantRequired => '请输入商家名称';

  @override
  String get date => '消费日期';

  @override
  String get category => '支出分类';

  @override
  String get paymentMethod => '支付方式';

  @override
  String get advancedDetails => '详细明细与单品项';

  @override
  String get lineItems => '商品明细';

  @override
  String get addItem => '添加项目';

  @override
  String get itemName => '商品名称';

  @override
  String get quantity => '数量';

  @override
  String get unitPrice => '单价';

  @override
  String get tax => '税费';

  @override
  String get tip => '小费';

  @override
  String get notes => '备注';

  @override
  String get notesPlaceholder => '添加备注说明或标签...';

  @override
  String get changePhoto => '更换照片';

  @override
  String get aiExtract => 'AI 提取';

  @override
  String get scanOcr => '本地 OCR';

  @override
  String get dataExtracted => '已识别提取';

  @override
  String get receiptAttached => '已附收据图片';

  @override
  String get scanningOnDevice => '正在本地扫描识别...';

  @override
  String get extractingWithAi => '正在调用 GLM-5.3-Flash AI 提取...';

  @override
  String get viewText => '查看识别文本';

  @override
  String get viewRaw => '查看原始结果';

  @override
  String get cameraNotAvailable => '相机不可用';

  @override
  String get cameraNotAvailableDesc => '当前系统或模拟器不支持直接调用相机。\n\n是否从文件或相册中选择收据照片？';

  @override
  String get chooseFromFiles => '从文件中选择';

  @override
  String get configureCloudAiTitle => '配置云端 AI';

  @override
  String get configureCloudAiDesc =>
      'GLM-5.3-Flash 云端智能解析需要您提供 API Key (BYOK)。\n\n是否现在前往配置，或使用本地 OCR 识别？';

  @override
  String get useOnDeviceOcr => '使用本地 OCR';

  @override
  String get configureKey => '配置密钥';

  @override
  String get noReceiptDataDetected => 'AI 未能检测到明确的收据字段，您可以手动填写或尝试本地 OCR。';

  @override
  String get runOnDeviceOcr => '运行本地 OCR';

  @override
  String get close => '关闭';

  @override
  String get scannedText => '识别文本';

  @override
  String get takePhoto => '拍摄照片';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get generateSamplePhoto => '生成样例照片';

  @override
  String get receiptDetails => '收据详情';

  @override
  String get edit => '编辑';

  @override
  String get items => '商品明细';

  @override
  String get subtotal => '小计';

  @override
  String get total => '总计';

  @override
  String get cloudAiSettings => '云端 AI 设置';

  @override
  String get byokBadge => 'BYOK • GLM-5.3-Flash 视觉多模态';

  @override
  String get byokDescription =>
      '自带密钥 (BYOK)：您的 API 密钥使用设备安全硬件（iOS 钥匙串 / Android KeyStore）加密存储，仅在请求时直接与智谱 BigModel API 通信。';

  @override
  String get enableCloudAi => '启用云端 AI 识别';

  @override
  String get enableCloudAiSubtitle => '使用 GLM-5.3-Flash 智能提取商家、商品明细、日期和金额';

  @override
  String get apiKeyLabel => '智谱 / BigModel API 密钥';

  @override
  String get apiKeyHint => '输入 API Key (如 82958f...voER...)';

  @override
  String get apiKeyHelpText => '可从 open.bigmodel.cn 或 z.ai 开放平台获取密钥。';

  @override
  String get modelAndEndpoint => '模型与接口设置';

  @override
  String get modelName => '模型名称';

  @override
  String get apiEndpoint => '接口地址';

  @override
  String get testConnection => '测试 API 连接';

  @override
  String get testingConnection => '正在测试连接...';

  @override
  String get saveSettings => '保存设置';

  @override
  String get keyRemoved => '已从安全存储中移除 API 密钥。';

  @override
  String get settingsSaved => '云端 AI 设置已保存。';

  @override
  String get showKey => '显示密钥';

  @override
  String get hideKey => '隐藏密钥';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get expenseSummary => '支出统计';

  @override
  String get totalSpending => '累计支出';

  @override
  String get totalReceipts => '收据笔数';

  @override
  String get topCategory => '主要支出类别';

  @override
  String get dailyAverage => '日均支出';

  @override
  String get categoryBreakdown => '各类别占比';

  @override
  String get spendingOverTime => '支出趋势';

  @override
  String get monthlySpending => '月度支出';

  @override
  String get noExpenseData => '暂无统计数据';

  @override
  String get noExpenseDataDesc => '开始记录您的收据，即可查看支出图表与财务分析。';

  @override
  String get quickActions => '快捷操作';

  @override
  String get exportReceipts => '导出收据';

  @override
  String get exportDescription => '将您的收据、商品清单和支出记录导出为 CSV 或 JSON 格式。';

  @override
  String get exportFormat => '导出格式';

  @override
  String get csvFormat => 'CSV 表格 (Excel / Numbers)';

  @override
  String get csvFormatDesc => '适合在 Excel、Numbers 或在线表格中打开';

  @override
  String get jsonFormat => 'JSON 数据格式';

  @override
  String get jsonFormatDesc => '包含单品明细与图片链接的完整结构化数据';

  @override
  String get dateRange => '时间范围';

  @override
  String get allRecords => '全部记录';

  @override
  String get thisMonthRecords => '本月记录';

  @override
  String get lastMonthRecords => '上月记录';

  @override
  String get thisYearRecords => '今年记录';

  @override
  String get exportAsFile => '导出为文件';

  @override
  String get shareRecords => '分享发送';

  @override
  String get exportSuccess => '收据已成功导出。';

  @override
  String get recentReceipts => '近期收据';

  @override
  String get viewAll => '查看全部';

  @override
  String get splitBill => 'AA分摊';

  @override
  String get splitBillTitle => '收据分摊分账';

  @override
  String get numberOfPeople => '分摊人数';

  @override
  String get personName => '姓名';

  @override
  String get participant => '分摊人';

  @override
  String get me => '我';

  @override
  String get equalSplit => '平均分摊';

  @override
  String get customSplit => '自定微调';

  @override
  String get fineTuneAmounts => '调整各自金额';

  @override
  String get fineTuneSubtitle => '可根据消费情况微调各自分摊金额';

  @override
  String get receiptTotal => '收据总额';

  @override
  String get totalAllocated => '已分摊';

  @override
  String get remainingBalance => '待分配';

  @override
  String get overAllocated => '超出';

  @override
  String get balanced => '已平衡';

  @override
  String get distributeRemaining => '自动平账';

  @override
  String get copyBreakdown => '复制明细';

  @override
  String get copiedToClipboard => '分账明细已复制到剪贴板！';

  @override
  String get saveSplit => '保存分账';

  @override
  String get splitSaved => '收据分账已成功保存。';

  @override
  String splitBadge(Object count) {
    return '分摊 ($count人)';
  }

  @override
  String get addPerson => '增加分摊人';

  @override
  String get removePerson => '移除';

  @override
  String get clearSplit => '清除分账';

  @override
  String get clearSplitConfirm => '确定要清除本收据的分账记录吗？';

  @override
  String get markPaid => '已付';

  @override
  String get markUnpaid => '未付';

  @override
  String get filterThisWeek => '本周';

  @override
  String get filterLast30Days => '近30天';

  @override
  String get customRange => '自定义范围';

  @override
  String get selectDateRange => '选择日期范围';

  @override
  String get vsPreviousPeriod => '较上周期';

  @override
  String get spendingUp => '较上期增加';

  @override
  String get spendingDown => '较上期减少';

  @override
  String get spendingFlat => '与上期持平';

  @override
  String get monthlyBudget => '月度预算';

  @override
  String get setBudget => '设置预算';

  @override
  String get editBudget => '编辑预算';

  @override
  String get budgetAmount => '预算金额';

  @override
  String get budgetSpent => '已使用 / 预算';

  @override
  String get budgetRemaining => '剩余额度';

  @override
  String get budgetExceeded => '超出预算';

  @override
  String get daysRemaining => '剩余天数';

  @override
  String get dailyAllowance => '建议日均可用';

  @override
  String get noBudgetSet => '设定月度预算以管理消费目标与控制开支。';

  @override
  String get splitAndReimbursements => '分摊与待收款项';

  @override
  String get netPersonal => '个人实际支出';

  @override
  String get grossTotal => '账面总额';

  @override
  String get unsettledFromFriends => '待收款项';

  @override
  String get settledReimbursements => '已收回款项';

  @override
  String get taxAndTipSummary => '税费与小费统计';

  @override
  String get totalTaxPaid => '累计税费支出';

  @override
  String get totalTipPaid => '累计小费支出';

  @override
  String get subtotalBeforeTax => '税前总小计';

  @override
  String get categoryDetails => '类别支出明细';

  @override
  String get receiptsInCategory => '该类别共包含收据';

  @override
  String get tapCategoryToInspect => '点击分类可查看收据明细';

  @override
  String get storageSettings => '存储位置与数据备份';

  @override
  String get storageMode => '存储位置';

  @override
  String get defaultStorage => '默认应用存储目录';

  @override
  String get defaultStorageDesc => '保存在应用内置安全沙盒中';

  @override
  String get customStorage => '自定义外部文件夹';

  @override
  String get customStorageDesc => '直接在您指定的文件夹中存储收据照片与自动备份';

  @override
  String get chooseFolder => '选择文件夹';

  @override
  String get resetToDefault => '恢复默认存储';

  @override
  String get autoBackupTitle => '实时同步数据备份';

  @override
  String get autoBackupSubtitle =>
      '在此文件夹中自动保持最新的 receipts.json 与 receipts.csv（方便与云盘或笔记同步）';

  @override
  String get migrateReceipts => '迁移现有收据数据';

  @override
  String get migrateReceiptsDesc => '将目前的所有收据照片与备份数据拷贝至新目录';

  @override
  String get folderNotSelected => '未选择文件夹';

  @override
  String get currentPath => '当前存储路径';

  @override
  String get importReceipts => '导入与恢复';

  @override
  String get importBackup => '导入备份文件';

  @override
  String get importDescription => '从 JSON 备份文件或 CSV 表格恢复收据数据。';

  @override
  String get selectBackupFile => '选择备份文件';

  @override
  String get importPreview => '导入预览';

  @override
  String get importMode => '导入处理方式';

  @override
  String get importMerge => '合并保留现有记录';

  @override
  String get importMergeDesc => '保留现有收据，并追加合并文件中的记录';

  @override
  String get importOverwrite => '覆盖清空并导入';

  @override
  String get importOverwriteDesc => '清空现有收据并完全恢复文件中的记录';

  @override
  String get confirmImport => '确认导入';

  @override
  String get importSuccess => '收据已成功导入。';

  @override
  String get importFailed => '导入失败';

  @override
  String get noValidReceiptsFound => '该文件中未找到有效的收据记录。';

  @override
  String get shareSummary => '分享统计';

  @override
  String get shareSummaryTitle => '分享支出统计报告';

  @override
  String get summaryCopied => '支出统计已复制到剪贴板！';

  @override
  String get topCategoriesHeader => '主要支出类别';

  @override
  String get saveMarkdownReport => '保存为报告 (.md)';

  @override
  String get shareViaReceiptRecord => '由收据记账生成';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => '收据记账';

  @override
  String get navReceipts => '收据明细';

  @override
  String get navSummary => '支出统计';

  @override
  String get navExport => '导出数据';

  @override
  String get addReceiptTooltip => '拍照 / 记一笔';

  @override
  String get toggleThemeTooltip => '切换主题';

  @override
  String get cloudAiSettingsTooltip => '云端 AI 设置 (GLM)';

  @override
  String get chooseLanguageTooltip => '语言设置';

  @override
  String get language => '语言';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get languageUpdated => '语言已更新';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryGroceries => '日常买菜';

  @override
  String get categoryDining => '餐饮美食';

  @override
  String get categoryTransport => '交通出行';

  @override
  String get categoryShopping => '购物消费';

  @override
  String get categoryEntertainment => '休闲娱乐';

  @override
  String get categoryUtilities => '水电杂费';

  @override
  String get categoryHealthcare => '医疗健康';

  @override
  String get categoryTravel => '旅行出游';

  @override
  String get categoryOffice => '办公用品';

  @override
  String get categoryOther => '其他支出';

  @override
  String get paymentCreditCard => '信用卡';

  @override
  String get paymentDebitCard => '借记卡';

  @override
  String get paymentCash => '现金';

  @override
  String get paymentDigitalWallet => '移动支付 (微信/支付宝/Apple Pay)';

  @override
  String get paymentBankTransfer => '银行转账';

  @override
  String get paymentOther => '其他方式';

  @override
  String get receiptRecords => '收据记录';

  @override
  String get sortAndFilter => '排序与筛选';

  @override
  String get searchPlaceholder => '搜索商家、明细或备注...';

  @override
  String get clearAllData => '清空全部数据';

  @override
  String get clearAllReceiptsTitle => '清空所有收据';

  @override
  String get clearAllReceiptsConfirm => '确定要删除所有保存的收据记录吗？此操作无法撤销。';

  @override
  String get clearAll => '清空全部';

  @override
  String get deleteReceiptTitle => '删除收据';

  @override
  String get deleteReceiptConfirm => '确定要删除此条收据记录吗？';

  @override
  String get delete => '删除';

  @override
  String get noReceiptsFound => '暂无收据记录';

  @override
  String get noReceiptsDesc => '点击下方按钮记录您的第一张收据。';

  @override
  String get noMatchingReceipts => '未找到匹配收据';

  @override
  String get noMatchingReceiptsDesc => '尝试更改搜索关键词或调整筛选条件。';

  @override
  String get sortDateDesc => '日期：最新在前';

  @override
  String get sortDateAsc => '日期：最早在前';

  @override
  String get sortAmountDesc => '金额：从高到低';

  @override
  String get sortAmountAsc => '金额：从低到高';

  @override
  String get sortMerchantAsc => '商家：首字母 A-Z';

  @override
  String get filterAll => '全部时间';

  @override
  String get filterThisMonth => '本月';

  @override
  String get filterLastMonth => '上月';

  @override
  String get filterThisYear => '今年';

  @override
  String get receiptCountSuffix => '笔收据';

  @override
  String get totalSpent => '总支出';

  @override
  String get recordReceipt => '记一笔收据';

  @override
  String get editReceipt => '编辑收据';

  @override
  String get save => '保存';

  @override
  String get update => '更新';

  @override
  String get takePhotoOrUpload => '拍摄或上传收据照片';

  @override
  String get photoUploadSubtitle => '相机拍照、相册选择或生成样例';

  @override
  String get totalAmount => '消费总金额';

  @override
  String get merchantName => '商家 / 店铺名称';

  @override
  String get merchantPlaceholder => '如：山姆会员店、盒马、星巴克...';

  @override
  String get merchantRequired => '请输入商家名称';

  @override
  String get date => '消费日期';

  @override
  String get category => '支出分类';

  @override
  String get paymentMethod => '支付方式';

  @override
  String get advancedDetails => '详细明细与单品项';

  @override
  String get lineItems => '商品明细';

  @override
  String get addItem => '添加项目';

  @override
  String get itemName => '商品名称';

  @override
  String get quantity => '数量';

  @override
  String get unitPrice => '单价';

  @override
  String get tax => '税费';

  @override
  String get tip => '小费';

  @override
  String get notes => '备注';

  @override
  String get notesPlaceholder => '添加备注说明或标签...';

  @override
  String get changePhoto => '更换照片';

  @override
  String get aiExtract => 'AI 提取';

  @override
  String get scanOcr => '本地 OCR';

  @override
  String get dataExtracted => '已识别提取';

  @override
  String get receiptAttached => '已附收据图片';

  @override
  String get scanningOnDevice => '正在本地扫描识别...';

  @override
  String get extractingWithAi => '正在调用 GLM-5.3-Flash AI 提取...';

  @override
  String get viewText => '查看识别文本';

  @override
  String get viewRaw => '查看原始结果';

  @override
  String get cameraNotAvailable => '相机不可用';

  @override
  String get cameraNotAvailableDesc => '当前系统或模拟器不支持直接调用相机。\n\n是否从文件或相册中选择收据照片？';

  @override
  String get chooseFromFiles => '从文件中选择';

  @override
  String get configureCloudAiTitle => '配置云端 AI';

  @override
  String get configureCloudAiDesc =>
      'GLM-5.3-Flash 云端智能解析需要您提供 API Key (BYOK)。\n\n是否现在前往配置，或使用本地 OCR 识别？';

  @override
  String get useOnDeviceOcr => '使用本地 OCR';

  @override
  String get configureKey => '配置密钥';

  @override
  String get noReceiptDataDetected => 'AI 未能检测到明确的收据字段，您可以手动填写或尝试本地 OCR。';

  @override
  String get runOnDeviceOcr => '运行本地 OCR';

  @override
  String get close => '关闭';

  @override
  String get scannedText => '识别文本';

  @override
  String get takePhoto => '拍摄照片';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get generateSamplePhoto => '生成样例照片';

  @override
  String get receiptDetails => '收据详情';

  @override
  String get edit => '编辑';

  @override
  String get items => '商品明细';

  @override
  String get subtotal => '小计';

  @override
  String get total => '总计';

  @override
  String get cloudAiSettings => '云端 AI 设置';

  @override
  String get byokBadge => 'BYOK • GLM-5.3-Flash 视觉多模态';

  @override
  String get byokDescription =>
      '自带密钥 (BYOK)：您的 API 密钥使用设备安全硬件（iOS 钥匙串 / Android KeyStore）加密存储，仅在请求时直接与智谱 BigModel API 通信。';

  @override
  String get enableCloudAi => '启用云端 AI 识别';

  @override
  String get enableCloudAiSubtitle => '使用 GLM-5.3-Flash 智能提取商家、商品明细、日期和金额';

  @override
  String get apiKeyLabel => '智谱 / BigModel API 密钥';

  @override
  String get apiKeyHint => '输入 API Key (如 82958f...voER...)';

  @override
  String get apiKeyHelpText => '可从 open.bigmodel.cn 或 z.ai 开放平台获取密钥。';

  @override
  String get modelAndEndpoint => '模型与接口设置';

  @override
  String get modelName => '模型名称';

  @override
  String get apiEndpoint => '接口地址';

  @override
  String get testConnection => '测试 API 连接';

  @override
  String get testingConnection => '正在测试连接...';

  @override
  String get saveSettings => '保存设置';

  @override
  String get keyRemoved => '已从安全存储中移除 API 密钥。';

  @override
  String get settingsSaved => '云端 AI 设置已保存。';

  @override
  String get showKey => '显示密钥';

  @override
  String get hideKey => '隐藏密钥';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get expenseSummary => '支出统计';

  @override
  String get totalSpending => '累计支出';

  @override
  String get totalReceipts => '收据笔数';

  @override
  String get topCategory => '主要支出类别';

  @override
  String get dailyAverage => '日均支出';

  @override
  String get categoryBreakdown => '各类别占比';

  @override
  String get spendingOverTime => '支出趋势';

  @override
  String get monthlySpending => '月度支出';

  @override
  String get noExpenseData => '暂无统计数据';

  @override
  String get noExpenseDataDesc => '开始记录您的收据，即可查看支出图表与财务分析。';

  @override
  String get quickActions => '快捷操作';

  @override
  String get exportReceipts => '导出收据';

  @override
  String get exportDescription => '将您的收据、商品清单和支出记录导出为 CSV 或 JSON 格式。';

  @override
  String get exportFormat => '导出格式';

  @override
  String get csvFormat => 'CSV 表格 (Excel / Numbers)';

  @override
  String get csvFormatDesc => '适合在 Excel、Numbers 或在线表格中打开';

  @override
  String get jsonFormat => 'JSON 数据格式';

  @override
  String get jsonFormatDesc => '包含单品明细与图片链接的完整结构化数据';

  @override
  String get dateRange => '时间范围';

  @override
  String get allRecords => '全部记录';

  @override
  String get thisMonthRecords => '本月记录';

  @override
  String get lastMonthRecords => '上月记录';

  @override
  String get thisYearRecords => '今年记录';

  @override
  String get exportAsFile => '导出为文件';

  @override
  String get shareRecords => '分享发送';

  @override
  String get exportSuccess => '收据已成功导出。';

  @override
  String get recentReceipts => '近期收据';

  @override
  String get viewAll => '查看全部';

  @override
  String get splitBill => 'AA分摊';

  @override
  String get splitBillTitle => '收据分摊分账';

  @override
  String get numberOfPeople => '分摊人数';

  @override
  String get personName => '姓名';

  @override
  String get participant => '分摊人';

  @override
  String get me => '我';

  @override
  String get equalSplit => '平均分摊';

  @override
  String get customSplit => '自定微调';

  @override
  String get fineTuneAmounts => '调整各自金额';

  @override
  String get fineTuneSubtitle => '可根据消费情况微调各自分摊金额';

  @override
  String get receiptTotal => '收据总额';

  @override
  String get totalAllocated => '已分摊';

  @override
  String get remainingBalance => '待分配';

  @override
  String get overAllocated => '超出';

  @override
  String get balanced => '已平衡';

  @override
  String get distributeRemaining => '自动平账';

  @override
  String get copyBreakdown => '复制明细';

  @override
  String get copiedToClipboard => '分账明细已复制到剪贴板！';

  @override
  String get saveSplit => '保存分账';

  @override
  String get splitSaved => '收据分账已成功保存。';

  @override
  String splitBadge(Object count) {
    return '分摊 ($count人)';
  }

  @override
  String get addPerson => '增加分摊人';

  @override
  String get removePerson => '移除';

  @override
  String get clearSplit => '清除分账';

  @override
  String get clearSplitConfirm => '确定要清除本收据的分账记录吗？';

  @override
  String get markPaid => '已付';

  @override
  String get markUnpaid => '未付';

  @override
  String get filterThisWeek => '本周';

  @override
  String get filterLast30Days => '近30天';

  @override
  String get customRange => '自定义范围';

  @override
  String get selectDateRange => '选择日期范围';

  @override
  String get vsPreviousPeriod => '较上周期';

  @override
  String get spendingUp => '较上期增加';

  @override
  String get spendingDown => '较上期减少';

  @override
  String get spendingFlat => '与上期持平';

  @override
  String get monthlyBudget => '月度预算';

  @override
  String get setBudget => '设置预算';

  @override
  String get editBudget => '编辑预算';

  @override
  String get budgetAmount => '预算金额';

  @override
  String get budgetSpent => '已使用 / 预算';

  @override
  String get budgetRemaining => '剩余额度';

  @override
  String get budgetExceeded => '超出预算';

  @override
  String get daysRemaining => '剩余天数';

  @override
  String get dailyAllowance => '建议日均可用';

  @override
  String get noBudgetSet => '设定月度预算以管理消费目标与控制开支。';

  @override
  String get splitAndReimbursements => '分摊与待收款项';

  @override
  String get netPersonal => '个人实际支出';

  @override
  String get grossTotal => '账面总额';

  @override
  String get unsettledFromFriends => '待收款项';

  @override
  String get settledReimbursements => '已收回款项';

  @override
  String get taxAndTipSummary => '税费与小费统计';

  @override
  String get totalTaxPaid => '累计税费支出';

  @override
  String get totalTipPaid => '累计小费支出';

  @override
  String get subtotalBeforeTax => '税前总小计';

  @override
  String get categoryDetails => '类别支出明细';

  @override
  String get receiptsInCategory => '该类别共包含收据';

  @override
  String get tapCategoryToInspect => '点击分类可查看收据明细';

  @override
  String get storageSettings => '存储位置与数据备份';

  @override
  String get storageMode => '存储位置';

  @override
  String get defaultStorage => '默认应用存储目录';

  @override
  String get defaultStorageDesc => '保存在应用内置安全沙盒中';

  @override
  String get customStorage => '自定义外部文件夹';

  @override
  String get customStorageDesc => '直接在您指定的文件夹中存储收据照片与自动备份';

  @override
  String get chooseFolder => '选择文件夹';

  @override
  String get resetToDefault => '恢复默认存储';

  @override
  String get autoBackupTitle => '实时同步数据备份';

  @override
  String get autoBackupSubtitle =>
      '在此文件夹中自动保持最新的 receipts.json 与 receipts.csv（方便与云盘或笔记同步）';

  @override
  String get migrateReceipts => '迁移现有收据数据';

  @override
  String get migrateReceiptsDesc => '将目前的所有收据照片与备份数据拷贝至新目录';

  @override
  String get folderNotSelected => '未选择文件夹';

  @override
  String get currentPath => '当前存储路径';

  @override
  String get importReceipts => '导入与恢复';

  @override
  String get importBackup => '导入备份文件';

  @override
  String get importDescription => '从 JSON 备份文件或 CSV 表格恢复收据数据。';

  @override
  String get selectBackupFile => '选择备份文件';

  @override
  String get importPreview => '导入预览';

  @override
  String get importMode => '导入处理方式';

  @override
  String get importMerge => '合并保留现有记录';

  @override
  String get importMergeDesc => '保留现有收据，并追加合并文件中的记录';

  @override
  String get importOverwrite => '覆盖清空并导入';

  @override
  String get importOverwriteDesc => '清空现有收据并完全恢复文件中的记录';

  @override
  String get confirmImport => '确认导入';

  @override
  String get importSuccess => '收据已成功导入。';

  @override
  String get importFailed => '导入失败';

  @override
  String get noValidReceiptsFound => '该文件中未找到有效的收据记录。';

  @override
  String get shareSummary => '分享统计';

  @override
  String get shareSummaryTitle => '分享支出统计报告';

  @override
  String get summaryCopied => '支出统计已复制到剪贴板！';

  @override
  String get topCategoriesHeader => '主要支出类别';

  @override
  String get saveMarkdownReport => '保存为报告 (.md)';

  @override
  String get shareViaReceiptRecord => '由收据记账生成';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '收據記帳';

  @override
  String get navReceipts => '收據明細';

  @override
  String get navSummary => '支出統計';

  @override
  String get navExport => '匯出資料';

  @override
  String get addReceiptTooltip => '拍照 / 記一筆';

  @override
  String get toggleThemeTooltip => '切換外觀主題';

  @override
  String get cloudAiSettingsTooltip => '雲端 AI 設定 (GLM)';

  @override
  String get chooseLanguageTooltip => '語言設定';

  @override
  String get language => '語言';

  @override
  String get chooseLanguage => '選擇語言';

  @override
  String get followSystem => '跟隨系統';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確定';

  @override
  String get languageUpdated => '語言已更新';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryGroceries => '日常採買';

  @override
  String get categoryDining => '餐飲美食';

  @override
  String get categoryTransport => '交通出行';

  @override
  String get categoryShopping => '購物消費';

  @override
  String get categoryEntertainment => '休閒娛樂';

  @override
  String get categoryUtilities => '水電雜費';

  @override
  String get categoryHealthcare => '醫療健康';

  @override
  String get categoryTravel => '旅行出遊';

  @override
  String get categoryOffice => '辦公用品';

  @override
  String get categoryOther => '其他支出';

  @override
  String get paymentCreditCard => '信用卡';

  @override
  String get paymentDebitCard => '簽帳金融卡';

  @override
  String get paymentCash => '現金';

  @override
  String get paymentDigitalWallet => '行動支付 (Apple Pay / Google Pay / Line Pay)';

  @override
  String get paymentBankTransfer => '銀行轉帳';

  @override
  String get paymentOther => '其他方式';

  @override
  String get receiptRecords => '收據記錄';

  @override
  String get sortAndFilter => '排序與篩選';

  @override
  String get searchPlaceholder => '搜尋店家、明細或備註...';

  @override
  String get clearAllData => '清空全部資料';

  @override
  String get clearAllReceiptsTitle => '清空所有收據';

  @override
  String get clearAllReceiptsConfirm => '確定要刪除所有已儲存的收據記錄嗎？此操作無法復原。';

  @override
  String get clearAll => '清空全部';

  @override
  String get deleteReceiptTitle => '刪除收據';

  @override
  String get deleteReceiptConfirm => '確定要刪除此筆收據記錄嗎？';

  @override
  String get delete => '刪除';

  @override
  String get noReceiptsFound => '尚無收據記錄';

  @override
  String get noReceiptsDesc => '點擊下方按鈕記錄您的第一張收據。';

  @override
  String get noMatchingReceipts => '查無符合條件的收據';

  @override
  String get noMatchingReceiptsDesc => '請嘗試調整搜尋關鍵字或變更篩選條件。';

  @override
  String get sortDateDesc => '日期：最新在前';

  @override
  String get sortDateAsc => '日期：最舊在前';

  @override
  String get sortAmountDesc => '金額：由高至低';

  @override
  String get sortAmountAsc => '金額：由低至高';

  @override
  String get sortMerchantAsc => '店家：名稱 A-Z';

  @override
  String get filterAll => '全部時間';

  @override
  String get filterThisMonth => '本月';

  @override
  String get filterLastMonth => '上月';

  @override
  String get filterThisYear => '今年';

  @override
  String get receiptCountSuffix => '筆收據';

  @override
  String get totalSpent => '總支出';

  @override
  String get recordReceipt => '記錄收據';

  @override
  String get editReceipt => '編輯收據';

  @override
  String get save => '儲存';

  @override
  String get update => '更新';

  @override
  String get takePhotoOrUpload => '拍攝或上傳收據照片';

  @override
  String get photoUploadSubtitle => '相機拍照、相簿選取或產生範本';

  @override
  String get totalAmount => '消費總金額';

  @override
  String get merchantName => '店家 / 商家名稱';

  @override
  String get merchantPlaceholder => '例如：Costco、全聯、星巴克...';

  @override
  String get merchantRequired => '請輸入店家名稱';

  @override
  String get date => '消費日期';

  @override
  String get category => '支出分類';

  @override
  String get paymentMethod => '付款方式';

  @override
  String get advancedDetails => '詳細明細與單品項';

  @override
  String get lineItems => '品項明細';

  @override
  String get addItem => '新增品項';

  @override
  String get itemName => '品項名稱';

  @override
  String get quantity => '數量';

  @override
  String get unitPrice => '單價';

  @override
  String get tax => '稅金';

  @override
  String get tip => '服務費 / 小費';

  @override
  String get notes => '備註';

  @override
  String get notesPlaceholder => '新增備註說明或標籤...';

  @override
  String get changePhoto => '更換照片';

  @override
  String get aiExtract => 'AI 辨識';

  @override
  String get scanOcr => '本機 OCR';

  @override
  String get dataExtracted => '已辨識提取';

  @override
  String get receiptAttached => '已附加收據照片';

  @override
  String get scanningOnDevice => '正在本機掃描辨識...';

  @override
  String get extractingWithAi => '正在呼叫 GLM-5.3-Flash AI 辨識...';

  @override
  String get viewText => '檢視辨識文字';

  @override
  String get viewRaw => '檢視原始資料';

  @override
  String get cameraNotAvailable => '相機無法使用';

  @override
  String get cameraNotAvailableDesc => '目前裝置或模擬器不支援直接啟用相機。\n\n是否從檔案或相簿中選取收據照片？';

  @override
  String get chooseFromFiles => '從檔案中選取';

  @override
  String get configureCloudAiTitle => '設定雲端 AI';

  @override
  String get configureCloudAiDesc =>
      'GLM-5.3-Flash 雲端智慧辨識需要您提供 API Key (BYOK)。\n\n是否現在前往設定，或使用本機 OCR 辨識？';

  @override
  String get useOnDeviceOcr => '使用本機 OCR';

  @override
  String get configureKey => '設定金鑰';

  @override
  String get noReceiptDataDetected => 'AI 未能辨識出明確的收據欄位，您可以手動填寫或嘗試本機 OCR。';

  @override
  String get runOnDeviceOcr => '執行本機 OCR';

  @override
  String get close => '關閉';

  @override
  String get scannedText => '辨識文字';

  @override
  String get takePhoto => '拍攝相片';

  @override
  String get chooseFromGallery => '從相簿選取';

  @override
  String get generateSamplePhoto => '產生範例相片';

  @override
  String get receiptDetails => '收據詳情';

  @override
  String get edit => '編輯';

  @override
  String get items => '品項明細';

  @override
  String get subtotal => '小計';

  @override
  String get total => '總計';

  @override
  String get cloudAiSettings => '雲端 AI 設定';

  @override
  String get byokBadge => 'BYOK • GLM-5.3-Flash 視覺多模態';

  @override
  String get byokDescription =>
      '自備金鑰 (BYOK)：您的 API 金鑰使用裝置安全硬體（iOS 鑰匙圈 / Android KeyStore）加密儲存，僅在發送辨識請求時直接傳輸至智譜 BigModel API。';

  @override
  String get enableCloudAi => '啟用雲端 AI 辨識';

  @override
  String get enableCloudAiSubtitle => '使用 GLM-5.3-Flash 智慧提取店家、品項明細、日期與消費金額';

  @override
  String get apiKeyLabel => '智譜 / BigModel API 金鑰';

  @override
  String get apiKeyHint => '輸入 API Key (如 82958f...voER...)';

  @override
  String get apiKeyHelpText => '可至 open.bigmodel.cn 或 z.ai 開放平台取得金鑰。';

  @override
  String get modelAndEndpoint => '模型與端點設定';

  @override
  String get modelName => '模型名稱';

  @override
  String get apiEndpoint => 'API 端點';

  @override
  String get testConnection => '測試 API 連線';

  @override
  String get testingConnection => '正在測試連線...';

  @override
  String get saveSettings => '儲存設定';

  @override
  String get keyRemoved => '已自安全儲存區中清除 API 金鑰。';

  @override
  String get settingsSaved => '雲端 AI 設定已儲存。';

  @override
  String get showKey => '顯示金鑰';

  @override
  String get hideKey => '隱藏金鑰';

  @override
  String get pasteFromClipboard => '自剪貼簿貼上';

  @override
  String get expenseSummary => '支出統計';

  @override
  String get totalSpending => '累積支出';

  @override
  String get totalReceipts => '收據筆數';

  @override
  String get topCategory => '主要支出類別';

  @override
  String get dailyAverage => '每日平均';

  @override
  String get categoryBreakdown => '各類別佔比';

  @override
  String get spendingOverTime => '支出趨勢';

  @override
  String get monthlySpending => '月份支出';

  @override
  String get noExpenseData => '尚無統計資料';

  @override
  String get noExpenseDataDesc => '開始記錄您的收據，即可查看支出圖表與財務分析。';

  @override
  String get quickActions => '快速操作';

  @override
  String get exportReceipts => '匯出收據';

  @override
  String get exportDescription => '將您的收據、商品清單與支出記錄匯出為 CSV 或 JSON 格式。';

  @override
  String get exportFormat => '匯出格式';

  @override
  String get csvFormat => 'CSV 試算表 (Excel / Numbers)';

  @override
  String get csvFormatDesc => '適合在 Excel、Numbers 或 Google 試算表中開啟';

  @override
  String get jsonFormat => 'JSON 資料格式';

  @override
  String get jsonFormatDesc => '包含單品明細與相片連結的完整結構化資料';

  @override
  String get dateRange => '時間範圍';

  @override
  String get allRecords => '全部記錄';

  @override
  String get thisMonthRecords => '本月記錄';

  @override
  String get lastMonthRecords => '上月記錄';

  @override
  String get thisYearRecords => '今年記錄';

  @override
  String get exportAsFile => '匯出至檔案';

  @override
  String get shareRecords => '分享傳送';

  @override
  String get exportSuccess => '收據已成功匯出。';

  @override
  String get recentReceipts => '近期收據';

  @override
  String get viewAll => '查看全部';

  @override
  String get splitBill => '分帳分攤';

  @override
  String get splitBillTitle => '收據分帳分攤';

  @override
  String get numberOfPeople => '分攤人數';

  @override
  String get personName => '姓名';

  @override
  String get participant => '分攤者';

  @override
  String get me => '我';

  @override
  String get equalSplit => '平均分攤';

  @override
  String get customSplit => '自訂微調';

  @override
  String get fineTuneAmounts => '調整各自金額';

  @override
  String get fineTuneSubtitle => '可依照個別消費微調各自分攤金額';

  @override
  String get receiptTotal => '收據總額';

  @override
  String get totalAllocated => '已分攤';

  @override
  String get remainingBalance => '待分配';

  @override
  String get overAllocated => '超出';

  @override
  String get balanced => '已平衡';

  @override
  String get distributeRemaining => '自動平帳';

  @override
  String get copyBreakdown => '複製明細';

  @override
  String get copiedToClipboard => '分帳明細已複製到剪貼簿！';

  @override
  String get saveSplit => '儲存分帳';

  @override
  String get splitSaved => '收據分帳已成功儲存。';

  @override
  String splitBadge(Object count) {
    return '分帳 ($count人)';
  }

  @override
  String get addPerson => '新增分攤者';

  @override
  String get removePerson => '移除';

  @override
  String get clearSplit => '清除分帳';

  @override
  String get clearSplitConfirm => '確定要清除此收據的分帳記錄嗎？';

  @override
  String get markPaid => '已付';

  @override
  String get markUnpaid => '未付';

  @override
  String get filterThisWeek => '本週';

  @override
  String get filterLast30Days => '近30天';

  @override
  String get customRange => '自訂範圍';

  @override
  String get selectDateRange => '選擇日期範圍';

  @override
  String get vsPreviousPeriod => '較上週期';

  @override
  String get spendingUp => '較上期增加';

  @override
  String get spendingDown => '較上期減少';

  @override
  String get spendingFlat => '與上期持平';

  @override
  String get monthlyBudget => '月度預算';

  @override
  String get setBudget => '設定預算';

  @override
  String get editBudget => '編輯預算';

  @override
  String get budgetAmount => '預算金額';

  @override
  String get budgetSpent => '已使用 / 預算';

  @override
  String get budgetRemaining => '剩餘額度';

  @override
  String get budgetExceeded => '超出預算';

  @override
  String get daysRemaining => '剩餘天數';

  @override
  String get dailyAllowance => '建議每日可用';

  @override
  String get noBudgetSet => '設定月度預算以管理消費目標與控制開支。';

  @override
  String get splitAndReimbursements => '分攤與待收款項';

  @override
  String get netPersonal => '個人實際支出';

  @override
  String get grossTotal => '帳面總額';

  @override
  String get unsettledFromFriends => '待收款項';

  @override
  String get settledReimbursements => '已收回款項';

  @override
  String get taxAndTipSummary => '稅金與服務費統計';

  @override
  String get totalTaxPaid => '累計稅金支出';

  @override
  String get totalTipPaid => '累計服務費支出';

  @override
  String get subtotalBeforeTax => '稅前總小計';

  @override
  String get categoryDetails => '類別支出明細';

  @override
  String get receiptsInCategory => '此類別共包含收據';

  @override
  String get tapCategoryToInspect => '點擊類別可檢視收據明細';

  @override
  String get storageSettings => '儲存位置與資料備份';

  @override
  String get storageMode => '儲存位置';

  @override
  String get defaultStorage => '預設應用程式儲存目錄';

  @override
  String get defaultStorageDesc => '儲存在應用程式內建安全沙盒中';

  @override
  String get customStorage => '自訂外部資料夾';

  @override
  String get customStorageDesc => '直接在您指定的資料夾中儲存收據相片與自動備份';

  @override
  String get chooseFolder => '選擇資料夾';

  @override
  String get resetToDefault => '恢復預設儲存';

  @override
  String get autoBackupTitle => '即時同步資料備份';

  @override
  String get autoBackupSubtitle =>
      '在此資料夾中自動保持最新的 receipts.json 與 receipts.csv（方便與雲端硬碟或筆記同步）';

  @override
  String get migrateReceipts => '遷移現有收據資料';

  @override
  String get migrateReceiptsDesc => '將目前的所有收據相片與備份資料拷貝至新目錄';

  @override
  String get folderNotSelected => '未選擇資料夾';

  @override
  String get currentPath => '目前儲存路徑';

  @override
  String get importReceipts => '匯入與復原';

  @override
  String get importBackup => '匯入備份檔案';

  @override
  String get importDescription => '從 JSON 備份檔案或 CSV 試算表復原收據資料。';

  @override
  String get selectBackupFile => '選擇備份檔案';

  @override
  String get importPreview => '匯入預覽';

  @override
  String get importMode => '匯入處理方式';

  @override
  String get importMerge => '合併保留現有記錄';

  @override
  String get importMergeDesc => '保留現有收據，並追加合併檔案中的記錄';

  @override
  String get importOverwrite => '覆蓋清空並匯入';

  @override
  String get importOverwriteDesc => '清空現有收據並完全復原檔案中的記錄';

  @override
  String get confirmImport => '確認匯入';

  @override
  String get importSuccess => '收據已成功匯入。';

  @override
  String get importFailed => '匯入失敗';

  @override
  String get noValidReceiptsFound => '此檔案中未找到有效的收據記錄。';

  @override
  String get shareSummary => '分享統計';

  @override
  String get shareSummaryTitle => '分享支出統計報告';

  @override
  String get summaryCopied => '支出統計已複製到剪貼簿！';

  @override
  String get topCategoriesHeader => '主要支出類別';

  @override
  String get saveMarkdownReport => '儲存為報告 (.md)';

  @override
  String get shareViaReceiptRecord => '由收據記帳產生';
}
