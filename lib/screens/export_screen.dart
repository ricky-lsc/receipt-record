import 'package:flutter/material.dart';
import '../widgets/export_receipts_dialog.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ExportReceiptsDialog(),
      ),
    );
  }
}
