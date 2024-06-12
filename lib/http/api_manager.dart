import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

class ApiManager {
  static late String accessToken;

  static Future<void> loadAccessToken() async {
    String? passKey = dotenv.dotenv.env['PASSKEY'];
    String? xClientId = dotenv.dotenv.env['X_CLIENT_ID'];
    try {
      final response = await http.get(
        Uri.parse('https://openapi.emtmadrid.es/v1/mobilitylabs/user/login/'),
        headers: {
          'passKey': '$passKey',
          'X-ClientId': '$xClientId',
        },
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        accessToken = decodedResponse['data'][0]['accessToken'];
      } else {
        throw Exception('Failed to load access token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load access token: $e');
    }
  }

  static Future<Map<String, int>> fetchStopData(String stop) async {
    try {
      DateTime now = new DateTime.now();
      var formatter = DateFormat('yyyyMMdd');
      String formattedDate = formatter.format(now);
      final response = await http.post(
        Uri.parse(
            'https://openapi.emtmadrid.es/v2/transport/busemtmad/stops/$stop/arrives/'),
        headers: {
          'accessToken': accessToken,
        },
        body: json.encode({
          'cultureInfo': 'ES',
          'Text_StopRequired_YN': 'Y',
          'Text_EstimationsRequired_YN': 'Y',
          'Text_IncidencesRequired_YN': 'Y',
          'DateTime_Referenced_Incidencies_YYYYMMDD': formattedDate,
        }),
      );
      if (response.statusCode == 200) {
        Map<String, int> stopData = {};
        var arrivals = json.decode(response.body)['data'][0]['Arrive'];
        for (var arrive in arrivals) {
          if (stopData[arrive['line']] == null) {
            stopData[arrive['line']] = arrive['estimateArrive'];
          }
        }
        return stopData;
      } else {
        throw Exception('Failed to load stop data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load stop data: $e');
    }
  }
}
