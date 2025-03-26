import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;

  const DeleteConfirmationDialog({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate("delete_title")),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                context,
              ).translate("delete_confirmation_question"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Cancel action
          child: Text(AppLocalizations.of(context).translate("delete_cancel")),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(context, true); // Confirm action
          },
          child: Text(AppLocalizations.of(context).translate("delete_confirm")),
        ),
      ],
    );
  }
}
