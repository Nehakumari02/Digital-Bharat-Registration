import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  /// Fetches current weather for a given city name
  /// Returns a Map with 'temperature', 'weathercode', 'windspeed', and 'is_day'
  static Future<Map<String, dynamic>?> getCurrentWeather(String city) async {
    try {
      // Step 1: Geocoding
      final geoUrl = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1');
      final geoResponse = await http.get(geoUrl);
      
      if (geoResponse.statusCode != 200) return null;
      
      final geoData = jsonDecode(geoResponse.body);
      if (geoData['results'] == null || geoData['results'].isEmpty) return null;
      
      final lat = geoData['results'][0]['latitude'];
      final lon = geoData['results'][0]['longitude'];

      // Step 2: Forecast
      final weatherUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final weatherResponse = await http.get(weatherUrl);
      
      if (weatherResponse.statusCode != 200) return null;
      
      final weatherData = jsonDecode(weatherResponse.body);
      return weatherData['current_weather'] as Map<String, dynamic>?;
      
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  /// Helper to convert WMO weather codes to readable descriptions and emojis
  static Map<String, String> getWeatherDescription(int code, int isDay) {
    // WMO Weather interpretation codes (WW)
    // 0: Clear sky
    // 1, 2, 3: Mainly clear, partly cloudy, and overcast
    // 45, 48: Fog and depositing rime fog
    // 51, 53, 55: Drizzle: Light, moderate, and dense intensity
    // 61, 63, 65: Rain: Slight, moderate and heavy intensity
    // 71, 73, 75: Snow fall: Slight, moderate, and heavy intensity
    // 95: Thunderstorm: Slight or moderate
    
    switch (code) {
      case 0:
        return {'description': 'Clear Sky', 'emoji': isDay == 1 ? '☀️' : '🌙'};
      case 1:
      case 2:
      case 3:
        return {'description': 'Partly Cloudy', 'emoji': '⛅'};
      case 45:
      case 48:
        return {'description': 'Foggy', 'emoji': '🌫️'};
      case 51:
      case 53:
      case 55:
        return {'description': 'Drizzle', 'emoji': '🌦️'};
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return {'description': 'Rain', 'emoji': '🌧️'};
      case 71:
      case 73:
      case 75:
      case 85:
      case 86:
        return {'description': 'Snow', 'emoji': '❄️'};
      case 95:
      case 96:
      case 99:
        return {'description': 'Thunderstorm', 'emoji': '⛈️'};
      default:
        return {'description': 'Unknown', 'emoji': '🌡️'};
    }
  }

  /// Returns actionable farming tips based on the weather code
  static List<String> getFarmingTips(int code) {
    if (code == 0 || code == 1 || code == 2 || code == 3) { // Clear/Cloudy
      return [
        'Excellent time for applying fertilizers or pesticides.',
        'Good conditions for harvesting mature crops.',
        'Ensure proper irrigation if the temperature is high.'
      ];
    } else if (code >= 51 && code <= 65 || code >= 80 && code <= 82) { // Rain
      return [
        'Halt pesticide spraying as rain will wash it away.',
        'Ensure proper drainage to prevent waterlogging.',
        'Delay harvesting to prevent post-harvest mold and rot.'
      ];
    } else if (code == 95 || code == 96 || code == 99) { // Thunderstorm
      return [
        'Secure any loose equipment or temporary structures.',
        'Avoid working in open fields during thunderstorms.',
        'Check for structural damage to greenhouses after the storm passes.'
      ];
    } else {
      return [
        'Monitor weather forecasts closely before planning major field activities.',
        'Ensure all livestock have adequate shelter.',
      ];
    }
  }
}
