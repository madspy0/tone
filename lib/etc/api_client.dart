import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mercure_client/mercure_client.dart';
import 'package:ton/etc/contact_class.dart';
import 'package:ton/etc/custom_exceptions.dart';
import 'package:ton/widgets/jwt_token.dart';

class ApiClient {

  static late JwtToken _jwtToken;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.33.102:8000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ),
  );

  late final Mercure _mercure = Mercure(
    url: 'http://192.168.33.102/.well-known/mercure', // your mercure hub url
    topics: ['https://example.com/my-private-topic'], // your mercure topics
    token: _jwtToken.jwt, // Bearer authorization
    // lastEventId: 'last_event_id', // in case your stored last recieved event
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
        throw CustomException(response.data!.message.toString());
      }
    } catch (e) {
      rethrow;
    }
    // List<dynamic> otv = response.data;

     _jwtToken =  JwtToken.fromBase64(response.data!.token.toString()) ;
      subscribe();
    return Response(requestOptions: response.requestOptions);
  }

/*  Future<JwtToken> setJwtToken(String jwt) async {
    return JwtToken.fromBase64(jwt);
  }*/

  Future<void> subscribe() async {
    _mercure.listen((event) {
      print(event.data);
    });

  }

  Future<List<Contact>> contacts() async {
    try {
      final response = await _dio.get(
        '/api/users',
        options: Options(
          headers: {'Authorization': 'Bearer ${_jwtToken.jwt}'},
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
          throw CustomException(response.data!.message.toString());
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
