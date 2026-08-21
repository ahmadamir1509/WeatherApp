import 'package:flutter/material.dart' hide ErrorWidget;
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/weather_widgets.dart';
import '../utils/datetime_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;
  Weather? _currentWeather;
  List<Forecast>? _forecast;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final lastCity = await LocalStorageService.getLastCity();
      if (lastCity != null && lastCity.isNotEmpty) {
        setState(() {
          _searchController.text = lastCity;
        });
        await _fetchWeather(lastCity);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load last searched city';
      });
    }
  }

  Future<void> _fetchWeather(String cityName) async {
    if (cityName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await WeatherService().getWeatherByCity(cityName);
      final forecast = await WeatherService().getForecastByCity(cityName);

      await LocalStorageService.saveLastCity(cityName);

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get background gradient based on weather icon (day/night) with timezone awareness
  LinearGradient _getBackgroundGradient() {
    bool isDaytime;
    
    if (_currentWeather != null) {
      // Use timezone-aware time checking
      final now = DateTime.now();
      final localTime = now.add(Duration(seconds: _currentWeather!.timezone));
      final hour = localTime.hour;
      isDaytime = hour >= 6 && hour < 18; // 6am to 6pm
    } else {
      isDaytime = WeatherService.isDaytime();
    }
    
    if (isDaytime) {
      // Beautiful sky blue gradient like heaven
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E90FF), // Dodger blue (top)
          const Color(0xFF87CEEB), // Sky blue (middle)
          const Color(0xFFB0E0E6), // Powder blue (bottom)
        ],
      );
    } else {
      // Nighttime: dark blue/black gradient
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0a0e27),
          const Color(0xFF1a1f3a),
          const Color(0xFF2d1b4e),
        ],
      );
    }
  }

  /// Get decorative background widget (sun for day, stars for night)
  Widget _getBackgroundDecoration() {
    final isDaytime = _currentWeather != null 
        ? WeatherService.isWeatherDaytime(_currentWeather!.weatherIcon)
        : WeatherService.isDaytime();
    
    if (isDaytime) {
      return Positioned(
        top: -100,
        right: -80,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.yellow.withOpacity(0.15),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.1),
                blurRadius: 100,
              ),
            ],
          ),
        ),
      );
    } else {
      // Stars scattered in night sky
      return Stack(
        children: [
          Positioned(top: 60, left: 30, child: _buildStar(2)),
          Positioned(top: 120, right: 40, child: _buildStar(1.5)),
          Positioned(top: 200, left: 50, child: _buildStar(1.2)),
          Positioned(top: 280, right: 60, child: _buildStar(2.5)),
          Positioned(top: 150, left: 20, child: _buildStar(1.8)),
        ],
      );
    }
  }

  /// Build a small star widget
  Widget _buildStar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: size * 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: _getBackgroundGradient()),
        child: Stack(
          children: [
            _getBackgroundDecoration(),
            SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Search bar
                _buildSearchBar(),
                const SizedBox(height: 30),
                // Weather content
                if (_isLoading)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const LoadingWidget(),
                  )
                else if (_errorMessage != null)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ErrorWidget(
                      errorMessage: WeatherService.getFormattedError(_errorMessage),
                      onRetry: () {
                        _fetchWeather(_searchController.text);
                      },
                    ),
                  )
                else if (_currentWeather != null)
                  Column(
                    children: [
                      _buildCurrentWeatherCard(),
                      const SizedBox(height: 30),
                      _buildForecastSection(),
                      const SizedBox(height: 20),
                      _buildAdditionalDetails(),
                      const SizedBox(height: 30),
                    ],
                  )
                else
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_queue,
                            size: 80,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search for a city to see the weather',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          prefixIcon: Icon(
            Icons.location_on,
            color: Colors.white.withOpacity(0.7),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              _fetchWeather(_searchController.text);
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onSubmitted: (value) {
          _fetchWeather(value);
        },
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (_currentWeather == null) return const SizedBox();

    return Column(
      children: [
        // City name and emoji
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              WeatherService.getWeatherEmojiWithTime(
                _currentWeather!.description,
                _currentWeather!.timezone,
              ),
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _currentWeather!.cityName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003D82),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _currentWeather!.description,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF003D82).withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        // Temperature display
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0F6FF).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF87CEEB).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      WeatherService.getWeatherIconUrl(_currentWeather!.weatherIcon),
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.cloud,
                          color: const Color(0xFF0077BE),
                          size: 100,
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentWeather!.temperature.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003D82),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '°C',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003D82),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Feels like ${_currentWeather!.feelsLike.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0077BE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastSection() {
    if (_forecast == null || _forecast!.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3-Days Forecast',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _forecast!.map((forecast) {
              final dateOnly = forecast.date.substring(0, 10);
              final dateFormatted = DateTimeUtils.formatDateShort(dateOnly);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ForecastCard(
                  date: dateFormatted,
                  tempMax: '${forecast.tempMax.toStringAsFixed(0)}°',
                  tempMin: '${forecast.tempMin.toStringAsFixed(0)}°',
                  description: forecast.description,
                  iconUrl: WeatherService.getWeatherIconUrl(forecast.weatherIcon),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    if (_currentWeather == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: [
            WeatherCard(
              title: 'Humidity',
              value: '${_currentWeather!.humidity.toStringAsFixed(0)}%',
              icon: Icons.water_drop,
              iconColor: Colors.cyan,
            ),
            WeatherCard(
              title: 'Wind Speed',
              value: '${_currentWeather!.windSpeed.toStringAsFixed(1)} m/s',
              icon: Icons.air,
              iconColor: Colors.lightBlue,
            ),
            WeatherCard(
              title: 'Pressure',
              value: '${_currentWeather!.pressure} mb',
              icon: Icons.dashboard,
              iconColor: Colors.white70,
            ),
            WeatherCard(
              title: 'Visibility',
              value: '${_currentWeather!.visibility.toStringAsFixed(1)} km',
              icon: Icons.visibility,
              iconColor: Colors.white70,
            ),
            WeatherCard(
              title: 'Cloud Coverage',
              value: '${_currentWeather!.clouds}%',
              icon: Icons.cloud,
              iconColor: Colors.white70,
            ),
            WeatherCard(
              title: 'Feels Like',
              value: '${_currentWeather!.feelsLike.toStringAsFixed(0)}°C',
              icon: Icons.thermostat,
              iconColor: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}
