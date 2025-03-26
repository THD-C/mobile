import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/repositories/wallet_repository.dart';

class AddWalletMoneyDialog extends StatefulWidget {
  Wallet wallet;

  AddWalletMoneyDialog({super.key, required this.wallet});

  @override
  State<AddWalletMoneyDialog> createState() => _AddWalletMoneyDialogState();
}

class _AddWalletMoneyDialogState extends State<AddWalletMoneyDialog> {
  late final TextEditingController nominalController = TextEditingController(
    text: '1',
  );

  @override
  void dispose() {
    nominalController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    try {
      final walletMoney = {
        'id': widget.wallet.id,
        'currency': widget.wallet.currency,
        'value': nominalController.text,
      };
      await WalletRepository.update(walletMoney);

      // Zamknij dialog z sygnałem sukcesu
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      Logger().e(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate("wallet_add_money_error"),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context).translate("wallet_add_money_title"),
      ),
      content: SingleChildScrollView(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: nominalController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      r'^[0-9]*\.?[0-9]*$',
                    ), // Allows only numbers and an optional decimal point
                  ),
                ],
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  ).translate("wallet_nominal"),
                  errorText:
                      (double.tryParse(nominalController.text) ?? 0) < 0
                          ? AppLocalizations.of(
                            context,
                          ).translate("value_must_be_greater_than_zero")
                          : null,
                ),
                onChanged: (value) {
                  if ((double.tryParse(value) ?? 0) < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          ).translate("value_must_be_greater_than_zero"),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).translate("wallet_cancel")),
        ),
        FilledButton(
          onPressed: () async => await _add(),
          child: Text(AppLocalizations.of(context).translate("wallet_save")),
        ),
      ],
    );
  }
}
