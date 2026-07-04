import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Builds an [http.Response] carrying [fixture]'s bytes exactly as the live
/// Tautulli server sends them: UTF-8 encoded, with the
/// `application/json;charset=UTF-8` content type. Using a plain
/// `http.Response(String, …)` would encode Latin-1 and throw on the real
/// UTF-8 titles present in the captures.
http.Response fixtureResponse(String name, {int statusCode = 200}) =>
    http.Response.bytes(
      utf8.encode(fixture(name)),
      statusCode,
      headers: {'content-type': 'application/json;charset=UTF-8'},
    );
