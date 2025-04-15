import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/wallet.dart';
import 'package:mobile/tools/api_servicer/api_order.dart';
import 'package:mobile/tools/api_servicer/api_wallet.dart';

class TransactionHistoryPage extends StatefulWidget {
  final Wallet wallet;

  const TransactionHistoryPage({Key? key, required this.wallet})
    : super(key: key);

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    // Fetch orders
    final orders = await OrderApiService().getOrdersByWalletId(
      widget.wallet.id,
    );
    final ordersList = List<Map<String, dynamic>>.from(orders);

    // Fetch wallets and create an ID-to-name map
    final walletList = await WalletApiService().read(context);
    final walletMap = {
      for (var wallet in walletList)
        '${wallet['id']}': wallet['currency'] ?? 'Unknown',
    };

    // Replace wallet IDs with their corresponding names
    for (var order in ordersList) {
      final fiatId = order['fiat_wallet_id']?.toString();
      final cryptoId = order['crypto_wallet_id']?.toString();

      order['fiatWallet'] = fiatId != null ? walletMap[fiatId] ?? fiatId : '-';
      order['cryptoWallet'] =
          cryptoId != null ? walletMap[cryptoId] ?? cryptoId : '-';
    }

    return ordersList;
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '-';
    return DateFormat('y/MM/dd • HH:mm').format(date);
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isSell = order['side'] == 'ORDER_SIDE_SELL';
    final walletDisplay = isSell ? order['cryptoWallet'] : order['fiatWallet'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${order['id'] ?? "-"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Add delete functionality if needed
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Status: ${order['status'] ?? "-"}'),
            Text('Side: ${order['side'] ?? "-"}'),
            Text('Nominal: ${order['nominal'] ?? "-"}'),
            Text('Price: ${order['price'] ?? "-"}'),
            Text('Cash Qty: ${order['cash_quantity'] ?? "-"}'),
            Text('Fiat Wallet: ${walletDisplay ?? "-"}'),
            const SizedBox(height: 4),
            Text('Created: ${formatDate(order['date_created'])}'),
            Text('Executed: ${formatDate(order['date_executed'])}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.wallet.currency} Wallet Orders')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading orders: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderCard(orders[index]),
          );
        },
      ),
    );
  }
}
