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

  bool _isUpdatingFromAmount = false;
  bool _isUpdatingFromNominal = false;

  String orderType = 'instant';

  @override
  void initState() {
    super.initState();

    amountController.addListener(_onAmountChanged);
    nominalController.addListener(_onNominalChanged);
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

  @override
  void dispose() {
    amountController.dispose();
    nominalController.dispose();
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
                Expanded(child: _buildTextField('Amount', amountController)),
                const SizedBox(width: 10),
                Expanded(child: _buildDropdown(['USD (1,000.00)'])),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildTextField('Nominal', nominalController)),
                const SizedBox(width: 10),
                Expanded(child: _buildDropdown([widget.cryptoName])),
              ],
            ),
            const SizedBox(height: 16),
            _buildRadioOption('Instant', 'instant'),
            _buildRadioOption('Pending', 'pending'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Add confirmation logic
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isBuy ? Colors.green : Colors.red,
          ),
          child: const Text('CONFIRM ORDER'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
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
        onChanged: (val) => setState(() => orderType = val!),
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
