import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:logger/logger.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/coin.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/widgets/currency/fiat/fiat_currency_selector.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mobile/widgets/order/order_dialog.dart';

enum ChartType { line, candle }

// Keep the data class (or adapt if Syncfusion needs a specific format)
class ChartDataPoint {
  final DateTime timestamp;
  final double? open; // Nullable for line chart points
  final double high;
  final double low;
  final double? close; // Nullable for line chart points (use high as value)

  ChartDataPoint({
    required this.timestamp,
    this.open,
    required this.high, // For line chart, this will be the 'y' value
    required this.low,
    this.close,
  });
}

class CryptoDetail extends StatefulWidget {
  final Coin cryptocurrency;
  const CryptoDetail({required this.cryptocurrency, super.key});

  @override
  State<CryptoDetail> createState() => _CryptoDetailState();
}

class _CryptoDetailState extends State<CryptoDetail> {
  ChartType _selectedChartType = ChartType.line;
  List<ChartDataPoint> _chartData = []; // Use a single list
  // TooltipBehavior for chart interactions
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true); // Initialize tooltip
    _generateRandomData();
  }

  // --- Random Data Generation (Adapted for Syncfusion) ---
  void _generateRandomData() {
    final random = Random();
    final List<ChartDataPoint> dataPoints = [];
    double lastPrice =
        widget.cryptocurrency.currentPrice > 0
            ? widget.cryptocurrency.currentPrice
            : 10000; // Start near current price or a default
    double open = lastPrice;
    DateTime date = DateTime.now().subtract(
      const Duration(days: 60),
    ); // Start date

    // Generate 60 data points for example
    for (int i = 0; i < 60; i++) {
      double high, low, close;
      close =
          open +
          random.nextDouble() * (open * 0.1) - // Fluctuate up to 10%
          (open * 0.05);
      if (close <= 0) close = open * 0.5; // Ensure positive close

      if (open > close) {
        // Bearish candle
        high =
            open +
            random.nextDouble() * (open * 0.02); // High slightly above open
        low =
            close -
            random.nextDouble() * (open * 0.02); // Low slightly below close
      } else {
        // Bullish candle
        high =
            close +
            random.nextDouble() * (open * 0.02); // High slightly above close
        low =
            open -
            random.nextDouble() * (open * 0.02); // Low slightly below open
      }
      if (low <= 0) low = close * 0.5; // Ensure positive low

      dataPoints.add(
        ChartDataPoint(
          timestamp: date,
          open: open,
          high: high, // Use high as the value for line chart as well
          low: low,
          close: close,
        ),
      );

      open = close; // Next candle opens where the previous one closed
      date = date.add(const Duration(days: 1)); // Increment date
    }

    setState(() {
      _chartData = dataPoints;
    });
  }
  // --- End Random Data Generation ---

  void _showOrderDialog({required bool isBuy}) {
    showDialog(
      context: context,
      builder:
          (context) => OrderDialogWidget(
            cryptoName: widget.cryptocurrency.name,
            cryptoPrice: widget.cryptocurrency.currentPrice,
            isBuy: isBuy,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cryptocurrency.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Fiat Selector Card --- (Keep as is)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextRow('Wybór fiat'),
                      const SizedBox(height: 8),
                      FiatCurrencySelector(
                        selectedCurrency: Currency(
                          name: 'USD',
                        ), // Consider making this stateful
                        onCurrencySelected: (currency) {
                          Logger().i('Selected Currency: ${currency.name}');
                          // TODO: Potentially refetch data or update prices based on currency
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- Info Card --- (Keep as is, but consider formatting based on selected currency)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        AppLocalizations.of(context).translate('market_price'),
                        // TODO: Format based on selected fiat currency
                        '\$${widget.cryptocurrency.currentPrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        AppLocalizations.of(
                          context,
                        ).translate('market_change_24h'),
                        '${widget.cryptocurrency.priceChangePercentage24h > 0 ? "+" : ""}${widget.cryptocurrency.priceChangePercentage24h.toStringAsFixed(2)}%',
                        valueColor:
                            widget.cryptocurrency.priceChangePercentage24h >= 0
                                ? Colors.green
                                : Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        '24h Max', // TODO: Localize
                        // TODO: Format based on selected fiat currency
                        '\$${widget.cryptocurrency.high24h.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        '24h Min', // TODO: Localize
                        // TODO: Format based on selected fiat currency
                        '\$${widget.cryptocurrency.low24h.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- Chart Card ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Chart Type Selector Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildChartTypeButton(ChartType.line, 'Line'),
                          const SizedBox(width: 10),
                          _buildChartTypeButton(ChartType.candle, 'Candle'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Chart Widget Area
                      SizedBox(
                        height: 350, // Adjust height as needed
                        child: _buildSyncfusionChart(), // Use Syncfusion chart
                      ),
                      // BUY and SELL Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showOrderDialog(isBuy: false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'SELL',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showOrderDialog(isBuy: true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'BUY',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildChartTypeButton(ChartType type, String label) {
    bool isSelected = _selectedChartType == type;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected
                ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
        side: BorderSide(
          color:
              isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        if (_selectedChartType != type) {
          setState(() {
            _selectedChartType = type;
            // Optional: Re-initialize tooltip if needed, though usually not required
            // _tooltipBehavior = TooltipBehavior(enable: true);
          });
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Builds the Syncfusion Chart dynamically
  // Builds the Syncfusion Chart dynamically
  Widget _buildSyncfusionChart() {
    if (_chartData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Change the list type here VVV
    List<CartesianSeries<ChartDataPoint, DateTime>> series = [];
    // ^^^ Use CartesianSeries as the base type for the list

    if (_selectedChartType == ChartType.line) {
      series = <CartesianSeries<ChartDataPoint, DateTime>>[
        // Keep specific type here too
        LineSeries<ChartDataPoint, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartDataPoint data, _) => data.timestamp,
          yValueMapper:
              (ChartDataPoint data, _) =>
                  data.high, // Using high for line value
          name: widget.cryptocurrency.name,
          color: Theme.of(context).colorScheme.primary,
          width: 2,
          enableTooltip: true,
        ),
      ];
    } else {
      // ChartType.candle
      series = <CartesianSeries<ChartDataPoint, DateTime>>[
        // Keep specific type here too
        CandleSeries<ChartDataPoint, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartDataPoint data, _) => data.timestamp,
          lowValueMapper: (ChartDataPoint data, _) => data.low,
          highValueMapper: (ChartDataPoint data, _) => data.high,
          openValueMapper: (ChartDataPoint data, _) => data.open,
          closeValueMapper: (ChartDataPoint data, _) => data.close,
          name: widget.cryptocurrency.name,
          enableTooltip: true,
          enableSolidCandles: true,
          // Example: Customize colors based on price movement
          bearColor: Colors.red,
          bullColor: Colors.green,
        ),
      ];
    }

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        dateFormat: DateFormat.Md(),
        intervalType: DateTimeIntervalType.auto,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}',
        opposedPosition: false,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
        // Optional: Improve number formatting based on magnitude
        numberFormat: NumberFormat.compactSimpleCurrency(
          locale: 'en_US',
        ), // e.g., $1.5K, $2M
      ),
      series: series, // Now the list type matches the parameter type
      tooltipBehavior: _tooltipBehavior,
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enablePinching: true,
        zoomMode: ZoomMode.x,
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        tooltipSettings: InteractiveTooltip(
          enable: true,
          // More detailed candle tooltip format
          format:
              _selectedChartType == ChartType.candle
                  ? 'Date: point.x\nOpen: point.open\nHigh: point.high\nLow: point.low\nClose: point.close'
                  : 'Date: point.x\nPrice: point.y',
          // Optional: Style the tooltip
          // color: Colors.black87,
          // textStyle: TextStyle(color: Colors.white),
        ),
        lineType: TrackballLineType.vertical,
        lineWidth: 1,
        shouldAlwaysShow: false, // Only show when activated
      ),
    );
  }

  // Keep original helper methods
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextRow(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
