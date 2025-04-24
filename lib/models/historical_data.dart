import 'dart:developer';

class DataChunk {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  DataChunk({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory DataChunk.fromJson(Map<String, dynamic> json) {
    return DataChunk(
        date: json['date'],
        open: json['open'],
        high: json['high'],
        low: json['low'],
        close: json['close']
    );
  }
}

class HistoricalData {
  final List<DataChunk> chunks;

  HistoricalData({required this.chunks});

  static empty() {
    return HistoricalData(chunks: []);
  }

  int get length => chunks.length;

  DataChunk operator [](int index) => chunks[index];

  factory HistoricalData.fromJson(Map<String, dynamic> json) {
    var data = json['data'];

    List<double> open = List<double>.from(data['open']);
    List<double> high = List<double>.from(data['high']);
    List<double> low = List<double>.from(data['low']);
    List<double> close = List<double>.from(data['close']);
    List<DateTime> dates = List<double>.from(data['timestamp'])
        .map((ts) => DateTime.fromMillisecondsSinceEpoch(ts.toInt()))
        .toList();

    List<DataChunk> chunksList = List.generate(dates.length, (index) {
      return DataChunk(
        date: dates[index],
        open: open[index],
        high: high[index],
        low: low[index],
        close: close[index],
      );
    });

    chunksList.sort((a, b) => a.date.compareTo(b.date));

    return HistoricalData(chunks: chunksList);
  }
}
