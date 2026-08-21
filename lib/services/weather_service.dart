import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/weather_model.dart';
import '../models/city_coordinates.dart';

class WeatherService {
  // Replace with your OpenWeatherMap API key from https://openweathermap.org/api
  static const String apiKey = '0417b701715427496627cdad57596036';
  
  // OpenWeatherMap OneCall API 3.0 endpoint
  static const String baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';
  
  // Fallback to 2.5 API for current weather
  static const String baseUrlV25 = 'https://api.openweathermap.org/data/2.5';

  /// Fetch weather by city name using v2.5 API (most reliable)
  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      // Use v2.5 API which is more reliable
      return await _getWeatherByNameLegacy(cityName);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch weather using OneCall API 3.0 with latitude and longitude
  /// 
  /// Parameters:
  /// - [latitude]: City latitude coordinate
  /// - [longitude]: City longitude coordinate
  /// - [cityName]: Display name of the city
  /// 
  /// Excludes: minutely, alerts from response to reduce payload
  Future<Weather> _getWeatherByCoordinates(
    double latitude,
    double longitude,
    String cityName,
  ) async {
    try {
      // Construct OneCall API URL with parameters
      final String url =
          '$baseUrl?lat=$latitude&lon=$longitude&exclude=minutely,alerts&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        // Parse OneCall API response
        final currentData = json['current'];
        if (currentData == null) {
          throw Exception('Invalid weather data received');
        }

        return Weather(
          cityName: cityName,
          temperature: (currentData['temp'] as num).toDouble(),
          description: currentData['weather'][0]['main'] ?? 'Unknown',
          humidity: (currentData['humidity'] as num).toDouble(),
          windSpeed: (currentData['wind_speed'] as num).toDouble(),
          weatherIcon: currentData['weather'][0]['icon'] ?? '01d',
          feelsLike: (currentData['feels_like'] as num).toDouble(),
          pressure: currentData['pressure'] as int,
          visibility: ((currentData['visibility'] as num) / 1000).toDouble(),
          clouds: currentData['clouds'] as int,
        );
      } else if (response.statusCode == 401) {
        throw Exception('Invalid . Please check your configuration.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load weather data. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fallback: Fetch weather using legacy v2.5 API by city name
  /// 
  /// This is used when city is not in our database
  Future<Weather> _getWeatherByNameLegacy(String cityName) async {
    try {
      final String url =
          '$baseUrlV25/weather?q=$cityName&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Weather.fromJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the spelling.');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else {
        throw Exception('Failed to load weather data. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch 5-day forecast by city name using v2.5 API (most reliable)
  Future<List<Forecast>> getForecastByCity(String cityName) async {
    try {
      // Use v2.5 API which is more reliable
      return await _getForecastByNameLegacy(cityName);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch forecast using OneCall API 3.0 with coordinates
  /// 
  /// Returns daily forecast from OneCall API
  Future<List<Forecast>> _getForecastByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final String url =
          '$baseUrl?lat=$latitude&lon=$longitude&exclude=minutely,alerts,hourly&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> daily = json['daily'] ?? [];

        // Take first 3 days of forecast
        final forecasts = daily.take(3).map((day) {
          return Forecast(
            date: DateTime.fromMillisecondsSinceEpoch(
              day['dt'] * 1000,
            ).toString(),
            tempMax: (day['temp']['max'] as num).toDouble(),
            tempMin: (day['temp']['min'] as num).toDouble(),
            description: day['weather'][0]['main'] ?? 'Unknown',
            weatherIcon: day['weather'][0]['icon'] ?? '01d',
            humidity: (day['humidity'] as num).toDouble(),
            windSpeed: (day['wind_speed'] as num).toDouble(),
          );
        }).toList();

        return forecasts;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else {
        throw Exception('Failed to load forecast data. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Fallback: Fetch forecast using legacy v2.5 API by city name
  Future<List<Forecast>> _getForecastByNameLegacy(String cityName) async {
    try {
      final String url =
          '$baseUrlV25/forecast?q=$cityName&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> forecasts = json['list'];

        // Get daily forecasts with proper min/max temperatures
        final Map<String, Map<String, dynamic>> dailyForecasts = {};

        for (var forecast in forecasts) {
          final dateTime = DateTime.parse(forecast['dt_txt']);
          final dateKey = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = {
              'tempMax': (forecast['main']['temp_max'] as num).toDouble(),
              'tempMin': (forecast['main']['temp_min'] as num).toDouble(),
              'description': forecast['weather'][0]['main'] ?? 'Unknown',
              'weatherIcon': forecast['weather'][0]['icon'] ?? '01d',
              'humidity': (forecast['main']['humidity'] as num).toDouble(),
              'windSpeed': (forecast['wind']['speed'] as num).toDouble(),
              'date': dateKey,
            };
          } else {
            // Update min/max temperatures throughout the day
            final currentMax = dailyForecasts[dateKey]!['tempMax'] as double;
            final currentMin = dailyForecasts[dateKey]!['tempMin'] as double;
            final forecastMax = (forecast['main']['temp_max'] as num).toDouble();
            final forecastMin = (forecast['main']['temp_min'] as num).toDouble();
            
            dailyForecasts[dateKey]!['tempMax'] = max(currentMax, forecastMax);
            dailyForecasts[dateKey]!['tempMin'] = min(currentMin, forecastMin);
          }
        }

        final result = dailyForecasts.values.map((day) {
          return Forecast(
            date: day['date'],
            tempMax: day['tempMax'] as double,
            tempMin: day['tempMin'] as double,
            description: day['description'] as String,
            weatherIcon: day['weatherIcon'] as String,
            humidity: day['humidity'] as double,
            windSpeed: day['windSpeed'] as double,
          );
        }).toList().take(3).toList();

        return result;
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the spelling.');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else {
        throw Exception('Failed to load forecast data. Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get weather icon URL from OpenWeatherMap
  /// 
  /// Parameters:
  /// - [iconCode]: Icon code from API (e.g., "01d", "02n")
  /// 
  /// Returns: URL to 4x resolution icon image
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }

  /// Get emoji representation for weather condition
  /// 
  /// Provides quick visual representation of weather type
  static String getWeatherEmoji(String description) {
    switch (description.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// Get emoji with time awareness - shows crescent for night (6pm-6am) and sun for day
  /// 
  /// Parameters:
  /// - [description]: Weather condition description
  /// - [timezone]: Timezone offset in seconds from UTC
  static String getWeatherEmojiWithTime(String description, int timezone) {
    final now = DateTime.now();
    final localTime = now.add(Duration(seconds: timezone));
    final hour = localTime.hour;
    
    // Night time: 6pm (18) to 6am (6)
    final isNight = hour >= 18 || hour < 6;
    
    // For Clear weather, show sun during day and crescent+star at night
    if (description.toLowerCase() == 'clear') {
      return isNight ? '🌙✨' : '☀️';
    }
    
    // For other weather, use default emoji but adapt for night
    switch (description.toLowerCase()) {
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// Get all available cities with coordinates
  /// 
  /// Useful for city suggestions and autocomplete
  static List<String> getAllAvailableCities() {
    return PakistanCities.getAllCityNames();
  }

  /// Get all Pakistani cities
  /// 
  /// Returns list of Pakistani cities in the database
  static List<CityCoordinates> getPakistaniCities() {
    return PakistanCities.getPakistaniCities();
  }

  /// Check if current weather is daytime based on icon code
  /// Icon codes end with 'd' for day, 'n' for night (e.g., "01d", "02n")
  static bool isWeatherDaytime(String iconCode) {
    return iconCode.endsWith('d');
  }

  /// Check if current time is daytime (6 AM - 6 PM)
  static bool isDaytime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  /// Get formatted error message for display (hides stack traces)
  static String getFormattedError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('socket') || errorStr.contains('connection') || 
        errorStr.contains('timeout') || errorStr.contains('unreachable') ||
        errorStr.contains('network')) {
      return 'Network Error: Check your internet connection';
    } else if (errorStr.contains('city not found') || errorStr.contains('404')) {
      return 'City not found. Please check the spelling';
    } else if (errorStr.contains('api') || errorStr.contains('401')) {
      return 'Service unavailable. Try again later';
    } else if (errorStr.contains('rate limit') || errorStr.contains('429')) {
      return 'Too many requests. Try again in a moment';
    }
    
    return 'Error fetching weather. Please try again';
  }
}
