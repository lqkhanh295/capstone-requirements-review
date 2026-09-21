import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/models.dart';
import '../export/export_report_dialog.dart';

class ExportIntent extends Intent {
  const ExportIntent();
}

class GlobalKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final Document? currentDocument;

  const GlobalKeyboardShortcuts({
    super.key,
    required this.child,
    this.currentDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.keyE,
        ): const ExportIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.keyE,
        ): const ExportIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ExportIntent: CallbackAction<ExportIntent>(
            onInvoke: (ExportIntent intent) {
              if (currentDocument != null) {
                ExportReportDialog.show(context, currentDocument!);
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
