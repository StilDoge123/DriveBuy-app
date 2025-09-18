import 'package:dio/dio.dart';
import '../../../config/api_config.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  AuthInterceptor(this.getToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getToken();
    print('🔍 AuthInterceptor: Token retrieved: ${token != null ? 'Yes' : 'No'}');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      print('🔍 AuthInterceptor: Authorization header added');
    } else {
      print('🔍 AuthInterceptor: No token available, request will be sent without auth');
    }
    options.headers.addAll(ApiConfig.defaultHeaders);
    //print('🔍 AuthInterceptor: Final headers: ${options.headers}');
    handler.next(options);
  }
} 