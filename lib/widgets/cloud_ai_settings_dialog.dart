import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/glm_receipt_service.dart';

class CloudAiSettingsDialog extends StatefulWidget {
  const CloudAiSettingsDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const CloudAiSettingsDialog(),
    );
  }

  @override
  State<CloudAiSettingsDialog> createState() => _CloudAiSettingsDialogState();
}

class _CloudAiSettingsDialogState extends State<CloudAiSettingsDialog> {
  final _keyController = TextEditingController();
  final _endpointController = TextEditingController();
  final _modelController = TextEditingController();

  bool _obscureKey = true;
  bool _isLoading = true;
  bool _isTesting = false;
  GlmTestResult? _testResult;

  final List<String> _commonModels = [
    'glm-5.3-flash',
    'glm-5.3-flashx',
    'glm-4v-flash',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _endpointController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final service = GlmReceiptService.instance;
    final key = await service.getApiKey();
    final endpoint = await service.getEndpoint();
    final model = await service.getModelName();

    if (!mounted) return;
    setState(() {
      _keyController.text = key ?? '';
      _endpointController.text = endpoint;
      _modelController.text = model;
      _isLoading = false;
    });
  }

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context);
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _testResult = GlmTestResult(
          success: false,
          message: l10n.apiKeyHint,
        );
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await GlmReceiptService.instance.testConnection(
      apiKeyOverride: key,
      endpointOverride: _endpointController.text.trim(),
      modelOverride: _modelController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testResult = result;
    });
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context);
    final service = GlmReceiptService.instance;
    await service.saveApiKey(_keyController.text.trim());
    if (_endpointController.text.trim().isNotEmpty) {
      await service.setEndpoint(_endpointController.text.trim());
    }
    if (_modelController.text.trim().isNotEmpty) {
      await service.setModelName(_modelController.text.trim());
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsSaved),
        backgroundColor: const Color(0xFF0F766E),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      setState(() {
        _keyController.text = data.text!.trim();
        _testResult = null;
      });
    }
  }

  Future<void> _clearKey() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _keyController.clear();
      _testResult = null;
    });
    await GlmReceiptService.instance.clearApiKey();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.keyRemoved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF0F766E),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cloudAiSettings,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n.byokBadge,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l10n.close,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Privacy & Security Callout
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock_outline, size: 18, color: Color(0xFF0F766E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.byokDescription,
                              style: const TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // API Key Field
                    Text(
                      l10n.apiKeyLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _keyController,
                      obscureText: _obscureKey,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        hintText: l10n.apiKeyHint,
                        prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off, size: 20),
                              tooltip: _obscureKey ? l10n.showKey : l10n.hideKey,
                              onPressed: () => setState(() => _obscureKey = !_obscureKey),
                            ),
                            IconButton(
                              icon: const Icon(Icons.content_paste, size: 20),
                              tooltip: l10n.pasteFromClipboard,
                              onPressed: _pasteFromClipboard,
                            ),
                            if (_keyController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                tooltip: l10n.close,
                                onPressed: _clearKey,
                              ),
                          ],
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (_) {
                        if (_testResult != null) {
                          setState(() => _testResult = null);
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.apiKeyHelpText,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Advanced Settings Expansion
                    Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(bottom: 12),
                        leading: const Icon(Icons.tune, size: 20),
                        title: Text(
                          l10n.modelAndEndpoint,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        children: [
                          // Model Name
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _modelController,
                                  decoration: InputDecoration(
                                    labelText: l10n.modelName,
                                    hintText: 'glm-5.3-flash',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                tooltip: l10n.modelName,
                                icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                                onSelected: (val) {
                                  setState(() => _modelController.text = val);
                                },
                                itemBuilder: (_) => _commonModels.map((m) {
                                  return PopupMenuItem<String>(
                                    value: m,
                                    child: Text(m),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Endpoint
                          TextField(
                            controller: _endpointController,
                            decoration: InputDecoration(
                              labelText: l10n.apiEndpoint,
                              hintText: GlmReceiptService.defaultEndpoint,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              suffixIcon: PopupMenuButton<String>(
                                tooltip: l10n.apiEndpoint,
                                icon: const Icon(Icons.public),
                                onSelected: (val) {
                                  setState(() => _endpointController.text = val);
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: GlmReceiptService.defaultEndpoint,
                                    child: Text('BigModel China (open.bigmodel.cn)'),
                                  ),
                                  const PopupMenuItem(
                                    value: GlmReceiptService.internationalEndpoint,
                                    child: Text('Z.ai International (api.z.ai)'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Test Result Display
                    if (_testResult != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _testResult!.success
                              ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                              : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _testResult!.success ? Icons.check_circle : Icons.error_outline,
                              color: _testResult!.success ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _testResult!.message,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _testResult!.success
                                      ? (isDark ? Colors.green[100] : const Color(0xFF065F46))
                                      : (isDark ? Colors.red[100] : const Color(0xFF991B1B)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Test Connection Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check, size: 18),
                      label: Text(_isTesting ? l10n.testingConnection : l10n.testConnection),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(l10n.saveSettings),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
