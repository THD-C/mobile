import 'package:flutter/material.dart';
import 'package:mobile/models/crypto_statistic.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PortfolioChart extends StatelessWidget {
  final List<CryptoStatistic> statistics;

  const PortfolioChart({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<CryptoStatistic, String>(
          dataSource: statistics,
          xValueMapper: (data, _) => data.cryptocurrency,
          yValueMapper: (data, _) => data.shareInPortfolio,
          dataLabelMapper: (data, _) =>
          '${data.cryptocurrency}\n${data.shareInPortfolio.toStringAsFixed(1)}%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          pointColorMapper: (data, _) => getCryptoColor(data.cryptocurrency),
        ),
      ],
    );
  }

  Color getCryptoColor(String cryptocurrency) {
    final Map<String, Color> colors = {
      'BITCOIN': Colors.orange,
      'ETHEREUM': Colors.blue,
      'RIPPLE': Colors.indigo,
      'XRP': Colors.indigo,
      'TETHER': Colors.green,
      'BNB': Colors.yellow.shade700,
      'DOGECOIN': Colors.amber,
      'SOLANA': Colors.purple,
      'CARDANO': Colors.blue.shade800,
      'LITECOIN': Colors.grey.shade800,
    };

    return colors[cryptocurrency] ??
        Colors.primaries[cryptocurrency.hashCode % Colors.primaries.length];
  }
}