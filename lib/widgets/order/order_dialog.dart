import 'package:flutter/material.dart';

class OrderDialogWidget extends StatefulWidget {
  final String cryptoName;
  final double cryptoPrice;
  final bool isBuy;

  const OrderDialogWidget({
    super.key,
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

  @override
  void initState() {
    super.initState();

    // Default value for specific price
    specificPriceController.text = widget.cryptoPrice.toStringAsFixed(2);

    amountController.addListener(_onAmountChanged);
    nominalController.addListener(_onNominalChanged);
    specificPriceController.addListener(_validateSpecificPrice);
  }

  void _onAmountChanged() {
    if (_isUpdatingFromNominal) return;

    final amount = double.tryParse(amountController.text);
    if (amount != null) {
      _isUpdatingFromAmount = true;
      final nominal = amount / widget.cryptoPrice;
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
      final amount = nominal * widget.cryptoPrice;
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
              'Current ${widget.cryptoName} price: ${widget.cryptoPrice.toStringAsFixed(2)} USD',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown(['USD (1,000.00)'])),
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
                  ? () {
                    // TODO: Handle the actual order logic here
                    Navigator.pop(context);
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

  Widget _buildDropdown(List<String> options) {
    return DropdownButtonFormField<String>(
      value: options.first,
      items:
          options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
      onChanged: (_) {},
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
