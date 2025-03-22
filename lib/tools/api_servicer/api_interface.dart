abstract class apiCalls{
  final String baseUrl = 'http://10.0.2.2:80/api';

  Future<List<dynamic>> read();
  Future<Map<String, dynamic>> readById ({dynamic id = 0});
  Future<Map<String, dynamic>> create (Map<String, dynamic> dataObject);
  Future<void> update (Map<String, dynamic> dataObject);
  Future<Map<String, dynamic>> delete (dynamic objectId);
}