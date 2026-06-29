import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import 'package:dio/dio.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';

import 'exceptions/http_exceptions.dart';

mixin DioHttpService {
  final _cacheOptions = CacheOptions(
    store: HiveCacheStore(null),
    policy: CachePolicy.request,
  );

  Dio? _dio;

  Dio get dio {
    _dio ??= Dio(BaseOptions());
    _dio!.interceptors.add(DioCacheInterceptor(options: _cacheOptions));
    return _dio!;
  }

  Future<dynamic> getCachedQuery(Uri url, {Map<String, String>? headers, Duration? maxStale}) async {
    late Response response;

    try {
      Options? options;
      if (maxStale != null) {
        options = _cacheOptions.copyWith(maxStale: maxStale).toOptions();
        options.headers = headers;
      }

      options ??= Options(headers: headers);

      response = await dio.get(url.toString(), options: options);
    } catch (error) {
      throw NoInternetException({"message": error.toString()});
    }

    final body = response.data;

    _processStatusCode(response.statusCode ?? 500, body);

    return body;
  }

  void _processStatusCode(int statusCode, Map<String, dynamic> body) {
    if (statusCode >= 500) {
      throw ServerException(body);
    }

    if (statusCode == 401) {
      throw UnauthorizedException(body);
    }

    if (statusCode == 403) {
      throw ForbiddenException(body);
    }

    if (statusCode >= 400) {
      throw BadRequestException(body, statusCode);
    }
  }

  Future<dynamic> post(Uri url, {Map<String, String>? headers, dynamic body}) async {
    late Response response;
    try {
      response = await dio.post(
        url.toString(),
        data: body,
        options: Options(headers: headers),
      );
    } catch (error) {
      throw NoInternetException({"message": error.toString()});
    }

    final data = response.data;
    _processStatusCode(response.statusCode ?? 500, data);
    return data;
  }
}
