import 'dart:convert';

import 'package:flutter/cupertino.dart';

class JwtToken extends StatelessWidget {
  const JwtToken(this.jwt, this.payload);

  factory JwtToken.fromBase64(String jwt) =>
      JwtToken(
          jwt,
          json.decode(
              ascii.decode(
                  base64.decode(base64.normalize(jwt.split(".")[1])),
              ),
          ),
      );

  final String jwt;
  final payload;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}