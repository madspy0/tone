import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mercure_client/mercure_client.dart';
import 'package:ton/etc/contact_class.dart';
import 'package:ton/etc/custom_exceptions.dart';

class ApiClient {

  static String _jwt='';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.33.102:8000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ),
  );

  Future<Response> login(String username, String password) async {
    Response? response;
    try {
      response = await _dio.post(
        '/api/login',
        data: {'username': username, 'password': password},
        //   queryParameters: {'apikey': 'YOUR_API_KEY'},
        // options: Options(contentType: Headers.formUrlEncodedContentType),
        options: Options(validateStatus: (_) => true),
      );
      if (response.statusCode != 200) {
        throw CustomException(response.data['message'].toString());
      }
    } catch (e) {
      rethrow;
    }
    // List<dynamic> otv = response.data;
    _jwt = "${response.data['token']}";
    return Response(requestOptions: response.requestOptions);
  }

  Future<void> subscribeToTopic() async {
    final Mercure mercure = Mercure(
      url: 'http://192.168.33.102/.well-known/mercure', // your mercure hub url
      topics: ['https://example.com/my-private-topic'], // your mercure topics
      token: _jwt, // Bearer authorization
      // lastEventId: 'last_event_id', // in case your stored last recieved event
    );

    mercure.listen((event) {
      print(event.data);
    });
  }

  Future<List<Contact>> contacts() async {
    try {
      final response = await _dio.get(
        '/api/users',
        options: Options(
          headers: {'Authorization': 'Bearer $_jwt'},
        ),
      );
      switch (response.statusCode) {
        case 200:
          final parced = await json.decode(response.data as String);
          return (parced as List<dynamic>)
              .map((e) => Contact.fromJson(e as Map<String, dynamic>))
              .toList();
        default:
          print(response);
          throw CustomException(response.data['message'].toString());
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

/*extension DioErrorX on DioError {
  bool get isNoConnectionError =>
      type == DioErrorType.unknown && error is SocketException;   // import 'dart:io' for SocketException
}*/
