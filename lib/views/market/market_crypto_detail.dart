import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/coin.dart';
import 'package:mobile/models/currency.dart';
import 'package:mobile/widgets/currency/fiat/fiat_currency_selector.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mobile/dialogs/order_dialog.dart';

import '../../models/historical_data.dart';
import '../../tools/repositories/market_repository.dart';

enum ChartType { line, candle }

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

  String selectedFiat = 'USD'; // Default fiat currency
  int chartDays= 1;
  double? _yMin;
  double? _yMax;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true); // Initialize tooltip
    _getChartData();
  }

  // --- Random Data Generation (Adapted for Syncfusion) ---
  void _getChartData() async {
    DateTime currentDay = DateTime.now().subtract(Duration(hours: 2));
    String end = currentDay.toIso8601String();
    String start = currentDay.subtract(Duration(days: chartDays)).toIso8601String();
    HistoricalData _fiatCurrencyList = await MarketRepository.fetchHistoricalDataForCoin(
      selectedFiat.toLowerCase(),
      widget.cryptocurrency.id,
      start,
      end,
      true
    );

    final List<ChartDataPoint> dataPoints = [];

    for (DataChunk chunk in _fiatCurrencyList.chunks) {
      dataPoints.add(
        ChartDataPoint(
          timestamp: chunk.date,
          open: chunk.open,
          high: chunk.high, // Use high as the value for line chart as well
          low: chunk.low,
          close: chunk.close,
        ),
      );
    }

    setState(() {
      _chartData = dataPoints;
    });

    double minY = _chartData.map((e) => e.low).reduce((a, b) => a < b ? a : b);
    double maxY = _chartData.map((e) => e.high).reduce((a, b) => a > b ? a : b);

    double buffer = (maxY - minY) * 0.1;
    minY -= buffer;
    maxY += buffer;

    setState(() {
      _chartData = dataPoints;
      _yMin = minY;
      _yMax = maxY;
    });
  }

  void _showOrderDialog({required bool isBuy}) {
    showDialog(
      context: context,
      builder:
          (context) => OrderDialogWidget(
            selectedFiat: selectedFiat,
            cryptoName: widget.cryptocurrency.name,
            cryptoPrice: widget.cryptocurrency.currentPrice,
            isBuy: isBuy,
          ),
    );
  }

  Widget _buildChartRangeButtons() {
    final List<int> ranges = [1, 7, 30, 180, 365];
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: ranges.map((int days) => _buildChartRangeButton(days)).toList(),
    );
  }

  Widget _buildChartRangeButton(int days) {
    bool isSelected = chartDays == days;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        if (chartDays != days) {
          setState(() {
            chartDays = days;
          });
          _getChartData();
        }
      },
      child: Text(
        '$days D',
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextRow('Fiat selection'),
                      const SizedBox(height: 8),
                      FiatCurrencySelector(
                        selectedCurrency: Currency(
                          name: selectedFiat,
                        ),
                        onCurrencySelected: (currency) {
                          setState(() {
                            selectedFiat = currency.name;
                          });
                          Logger().i('Selected Currency: ${currency.name}');
                          _getChartData();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        AppLocalizations.of(context).translate('market_price'),
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
                        '24h Max',
                        '\$${widget.cryptocurrency.high24h.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        '24h Min',
                        '\$${widget.cryptocurrency.low24h.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
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
                      Column(
                        children: [
                          _buildChartRangeButtons(),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 350,
                            child: _buildSyncfusionChart(),
                          ),
                        ],
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
  Widget _buildSyncfusionChart() {
    if (_chartData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    List<CartesianSeries<ChartDataPoint, DateTime>> series = [];

    if (_selectedChartType == ChartType.line) {
      series = <CartesianSeries<ChartDataPoint, DateTime>>[
        LineSeries<ChartDataPoint, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartDataPoint data, _) => data.timestamp,
          yValueMapper:
              (ChartDataPoint data, _) =>
                  data.high,
          name: widget.cryptocurrency.name,
          color: Theme.of(context).colorScheme.primary,
          width: 2,
          enableTooltip: true,
        ),
      ];
    } else {
      series = <CartesianSeries<ChartDataPoint, DateTime>>[
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
          bearColor: Colors.red,
          bullColor: Colors.green,
        ),
      ];
    }

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        dateFormat: DateFormat.yMd(),
        intervalType: DateTimeIntervalType.auto,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      primaryYAxis: NumericAxis(
        minimum: _yMin,
        maximum: _yMax,
        interval: ((_yMax ?? 0) - (_yMin ?? 0)) / 5,
        labelFormat: '{value}',
        opposedPosition: false,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
        numberFormat: NumberFormat.compactSimpleCurrency(
          name: selectedFiat.toUpperCase(),
        ),
      ),
      series: series,
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
          format:
              _selectedChartType == ChartType.candle
                  ? 'Date: point.x\nOpen: point.open\nHigh: point.high\nLow: point.low\nClose: point.close'
                  : 'Date: point.x\nPrice: point.y',
        ),
        lineType: TrackballLineType.vertical,
        lineWidth: 1,
        shouldAlwaysShow: false,
      ),
    );
  }

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
