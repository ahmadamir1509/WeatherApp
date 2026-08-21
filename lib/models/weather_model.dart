class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  final String weatherIcon;
  final double feelsLike;
  final int pressure;
  final double visibility;
  final int clouds;
  final int timezone; // Timezone offset in seconds

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.weatherIcon,
    required this.feelsLike,
    required this.pressure,
    required this.visibility,
    required this.clouds,
    this.timezone = 0,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['main'] ?? 'Unknown',
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      weatherIcon: json['weather'][0]['icon'] ?? '01d',
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      pressure: json['main']['pressure'] as int,
      visibility: ((json['visibility'] as num) / 1000).toDouble(),
      clouds: json['clouds']['all'] as int,
      timezone: json['timezone'] ?? 0,
    );
  }
}

class Forecast {
  final String date;
  final double tempMax;
  final double tempMin;
  final String description;
  final String weatherIcon;
  final double humidity;
  final double windSpeed;

  Forecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.description,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: json['dt_txt'] ?? '',
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      description: json['weather'][0]['main'] ?? 'Unknown',
      weatherIcon: json['weather'][0]['icon'] ?? '01d',
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }
}
