// FILE: lib/services/wavelog_service.dart
// ==============================
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'settings_service.dart';
import '../models/rst_report.dart';

class WavelogService {
  
  static Future<bool> postQso({
    required String callsign,
    required String band,
    required String mode,
    required double freq, // in MHz
    required DateTime timeOn,
    required RstReport rstSent,
    required RstReport rstRcvd,
    String? grid, 
    String? name, 
  }) async {
    
    // 1. Load Settings
    String baseUrl = await AppSettings.getString(AppSettings.keyWavelogUrl);
    String apiKey = await AppSettings.getString(AppSettings.keyWavelogKey);
    String stationIdStr = await AppSettings.getString(AppSettings.keyWavelogStationId);
    String myGrid = await AppSettings.getString(AppSettings.keyMyGrid); 
    String stationCall = await AppSettings.getString(AppSettings.keyMyCallsign);

    if (baseUrl.isEmpty || apiKey.isEmpty) {
      print("Wavelog Error: Missing URL or API Key");
      return false; 
    }

    if (baseUrl.endsWith('/')) baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    final Uri apiUri = Uri.parse("$baseUrl/qso");
    
    // Parse Station ID
    int stationProfileId = -1;
    if (stationIdStr.isNotEmpty) {
      int? parsedId = int.tryParse(stationIdStr);
      if (parsedId != null) stationProfileId = parsedId;
    }

    // 2. BUILD RAW ADIF STRING
    // This is the "Gold Standard" format. It looks like: <TAG:LEN>DATA
    
    bool isCW = mode == 'CW';
    
    // Date format: YYYYMMDD
    String qsoDate = "${timeOn.year}${timeOn.month.toString().padLeft(2,'0')}${timeOn.day.toString().padLeft(2,'0')}";
    // Time format: HHMMSS (UTC)
    String timeOnStr = "${timeOn.hour.toString().padLeft(2,'0')}${timeOn.minute.toString().padLeft(2,'0')}${timeOn.second.toString().padLeft(2,'0')}";

    StringBuffer adif = StringBuffer();
    
    // Helper to format tags
    void add(String tag, String value) {
      if (value.isNotEmpty) {
        adif.write("<$tag:${value.length}>$value");
      }
    }

    add("CALL", callsign.toUpperCase());
    add("BAND", band);
    add("MODE", mode);
    add("FREQ", freq.toString());
    add("QSO_DATE", qsoDate);
    add("TIME_ON", timeOnStr);
    add("RST_SENT", rstSent.formatted(isCW));
    add("RST_RCVD", rstRcvd.formatted(isCW));
    add("STATION_CALLSIGN", stationCall);
    add("MY_GRIDSQUARE", myGrid);
    
    if (grid != null && grid != "---") add("GRIDSQUARE", grid);
    if (name != null && name != "Not Found") add("NAME", name);
    
    adif.write("<EOR>"); // End of Record

    print("Generated ADIF: ${adif.toString()}");

    // 3. Construct Payload
    // We send 'type':'adif' and put the raw string in 'string'
    Map<String, dynamic> payload = {
      "key": apiKey,
      "station_profile_id": stationProfileId,
      "type": "adif",
      "string": adif.toString() 
    };

    // 4. Send Request
    try {
      print("Wavelog: Sending QSO -> $callsign (Station ID: $stationProfileId)...");
      
      final response = await http.post(
        apiUri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("Wavelog Status: ${response.statusCode}");
      print("Wavelog Body:   ${response.body}");

      // Cloudlog often returns a body like: {"message":"QSO Added","count":1}
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Wavelog Network Error: $e");
      return false;
    }
  }
}