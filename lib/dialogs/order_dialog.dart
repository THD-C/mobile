import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mobile/tools/api_servicer/api_wallet.dart';
import 'package:mobile/tools/api_servicer/api_order.dart';

class OrderDialogWidget extends StatefulWidget {
  final String cryptoName;
  final double cryptoPrice;
  final bool isBuy;

  final String selectedFiat;

  const OrderDialogWidget({
    super.key,
    required this.selectedFiat,
    required this.cryptoName,
    required this.cryptoPrice,
    required this.isBuy,
  });

  @override
  State<OrderDialogWidget> createState() => _OrderDialogWidgetState();
}

class _OrderDialogWidgetState extends State<OrderDialogWidget> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController specificPriceController = TextEditingController();

  bool _isUpdatingFromAmount = false;
  bool _isUpdatingFromNominal = false;

  String orderType = 'instant';
  String? _specificPriceError;

  List wallets = [];
  Map<String, dynamic>? selectedWallet;

  @override
  void initState() {
    super.initState();

    specificPriceController.text = widget.cryptoPrice.toStringAsFixed(2);
    amountController.addListener(_onAmountChanged);
    nominalController.addListener(_onNominalChanged);
    specificPriceController.addListener(_validateSpecificPrice);
    specificPriceController.addListener(_onAmountChanged);

    _loadWallets(widget.selectedFiat);
  }

  Future<void> _loadWallets(String selectedFiat) async {
    try {
      final result = await WalletApiService().read(context);
      if (!mounted) return;

      setState(() {
        wallets = result;

        if (wallets.isEmpty) {
          selectedWallet = null;
        } else {
          final matchingWallet =
              wallets
                  .where(
                    (wallet) =>
                        wallet['currency']?.toString().toUpperCase() ==
                        selectedFiat.toUpperCase(),
                  )
                  .toList();

          selectedWallet =
              matchingWallet.isNotEmpty ? matchingWallet.first : null;
        }
      });

      // Show alert and close if no wallet found
      if (selectedWallet == null && mounted) {
        await Future.delayed(Duration.zero); // Let build() finish
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Wallet Required'),
                content: const Text(
                  'You need to create a FIAT currency wallet first.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        ).then((_) {
          if (mounted) Navigator.of(context).pop(); // Close Order Dialog
        });
      }
    } catch (e) {
      debugPrint('Error loading wallets: $e');
    }
  }

  void _onAmountChanged() {
    if (_isUpdatingFromNominal) return;

    final amount = double.tryParse(amountController.text);
    if (amount != null) {
      _isUpdatingFromAmount = true;
      double specificPrice;
      try
      {
        specificPrice = double.parse(specificPriceController.text);
      } catch (e) {
        specificPrice = 1;
      }

      final nominal =
          orderType == 'instant'
              ? amount / widget.cryptoPrice
              : amount / specificPrice;
      setState(() {
        nominalController.text = nominal.toStringAsFixed(6);
      });
      _isUpdatingFromAmount = false;
    }
  }

  void _onNominalChanged() {
    if (_isUpdatingFromAmount) return;

    final nominal = double.tryParse(nominalController.text);
    if (nominal != null && widget.cryptoPrice > 0) {
      _isUpdatingFromNominal = true;
      final amount =
          orderType == 'instant'
              ? nominal * widget.cryptoPrice
              : nominal * double.parse(specificPriceController.text);
      setState(() {
        amountController.text = amount.toStringAsFixed(2);
      });
      _isUpdatingFromNominal = false;
    }
  }

  void _validateSpecificPrice() {
    if (orderType != 'pending') return;

    final value = double.tryParse(specificPriceController.text);
    setState(() {
      _specificPriceError =
          (value == null || value <= 0)
              ? 'Specific price must be greater than 0'
              : null;
    });
  }

  bool get isFormValid {
    if (orderType == 'pending') {
      final value = double.tryParse(specificPriceController.text);
      if (value == null || value <= 0) return false;
    }
    return true;
  }

  @override
  void dispose() {
    amountController.dispose();
    nominalController.dispose();
    specificPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.isBuy ? "Buy" : "Sell"} Order'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current ${widget.cryptoName} price: ${widget.cryptoPrice.toStringAsFixed(2)} ${widget.selectedFiat.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Wallet: ${selectedWallet?['currency'] ?? 'None'} (${selectedWallet?['value'] ?? ''})',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField('Amount', amountController)),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildTextField('Nominal', nominalController)),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 16),
            _buildRadioOption('Instant', 'instant'),
            _buildRadioOption('Pending', 'pending'),
            if (orderType == 'pending') ...[
              const SizedBox(height: 12),
              _buildTextField(
                'Specific price',
                specificPriceController,
                errorText: _specificPriceError,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed:
              isFormValid
                  ? () async {
                    try {
                      final nominal = double.parse(nominalController.text);
                      final amount = double.parse(amountController.text);
                      final price =
                          orderType == 'instant'
                              ? widget.cryptoPrice
                              : double.parse(specificPriceController.text);

                      final type =
                          orderType == 'instant'
                              ? 'ORDER_TYPE_INSTANT'
                              : 'ORDER_TYPE_PENDING';

                      final side =
                          widget.isBuy ? 'ORDER_SIDE_BUY' : 'ORDER_SIDE_SELL';

                      final fiatWalletId = selectedWallet?['id'].toString();

                      if (fiatWalletId == null || fiatWalletId.isEmpty) {
                        throw Exception('Fiat wallet not selected');
                      }

                      await OrderApiService().createOrder(
                        cashQuantity: amount,
                        nominal: nominal,
                        price: price,
                        type: type,
                        side: side,
                        currencyTarget: widget.cryptoName.toLowerCase(),
                        currencyUsedWalletId: fiatWalletId,
                      );

                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to place order: $e')),
                        );
                      }
                    }
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isBuy ? Colors.green : Colors.red,
          ),
          child: const Text('CONFIRM ORDER'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio<String>(
        value: value,
        groupValue: orderType,
        onChanged: (val) {
          setState(() {
            orderType = val!;
            _validateSpecificPrice();
            _onAmountChanged();
          });
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title +
            (value == 'instant'
                ? ' (Buy at the current market price)'
                : ' (Buy if it rises or falls to specific price)'),
      ),
    );
  }
}
