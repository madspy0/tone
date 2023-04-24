import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tele_one/etc/contact_class.dart';
import 'package:tele_one/etc/custom_exceptions.dart';
import 'package:mercure_client/mercure_client.dart';

class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.33.102:8000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ),
  );

  static String jwt = "";

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
    jwt = "${response.data['token']}";
    return Response(requestOptions: response.requestOptions);
  }

  Future<void> subToTopic() async {
    final Mercure mercure = Mercure(
      url:
          'http://192.168.33.102/.well-known/mercure', // your mercure hub url
      topics: ['https://example.com/my-private-topic'], // your mercure topics
      token: jwt, // Bearer authorization
      // lastEventId: 'last_event_id', // in case your stored last recieved event
    );

    final subscription = mercure.listen((event) {
      print(event.data);
    });
  }

  Future<List<Contact>> contacts() async {
    try {
      final response = await _dio.get(
        '/api/users',
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
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
