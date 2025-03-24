import 'package:flutter/widgets.dart';

abstract class apiCalls{
  final String baseUrl = 'http://10.0.2.2:80/api';

  Future<List<dynamic>> read(BuildContext context);
  Future<Map<String, dynamic>> readById ({dynamic id = 0, required BuildContext context});
  Future<Map<String, dynamic>> create (Map<String, dynamic> dataObject, BuildContext context);
  Future<void> update (Map<String, dynamic> dataObject, BuildContext context);
  Future<Map<String, dynamic>> delete (dynamic objectId, BuildContext context);
}