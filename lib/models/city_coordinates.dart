class CityCoordinates {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  CityCoordinates({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

/// Pakistani Cities Coordinates Database
class PakistanCities {
  static final Map<String, CityCoordinates> cities = {
    // Major Cities
    'karachi': CityCoordinates(
      name: 'Karachi',
      country: 'Pakistan',
      latitude: 24.8607,
      longitude: 67.0011,
    ),
    'lahore': CityCoordinates(
      name: 'Lahore',
      country: 'Pakistan',
      latitude: 31.5497,
      longitude: 74.3436,
    ),
    'islamabad': CityCoordinates(
      name: 'Islamabad',
      country: 'Pakistan',
      latitude: 33.6844,
      longitude: 73.0479,
    ),
    'rawalpindi': CityCoordinates(
      name: 'Rawalpindi',
      country: 'Pakistan',
      latitude: 33.5731,
      longitude: 73.1898,
    ),
    'faisalabad': CityCoordinates(
      name: 'Faisalabad',
      country: 'Pakistan',
      latitude: 31.4181,
      longitude: 72.9521,
    ),
    'multan': CityCoordinates(
      name: 'Multan',
      country: 'Pakistan',
      latitude: 30.1575,
      longitude: 71.4522,
    ),
    'hyderabad': CityCoordinates(
      name: 'Hyderabad',
      country: 'Pakistan',
      latitude: 25.3960,
      longitude: 68.4753,
    ),
    'peshawar': CityCoordinates(
      name: 'Peshawar',
      country: 'Pakistan',
      latitude: 34.0151,
      longitude: 71.5780,
    ),
    'quetta': CityCoordinates(
      name: 'Quetta',
      country: 'Pakistan',
      latitude: 30.1798,
      longitude: 66.9750,
    ),
    'gujranwala': CityCoordinates(
      name: 'Gujranwala',
      country: 'Pakistan',
      latitude: 32.1815,
      longitude: 74.1864,
    ),

    // Other Major Pakistani Cities
    'sialkot': CityCoordinates(
      name: 'Sialkot',
      country: 'Pakistan',
      latitude: 32.4945,
      longitude: 74.5229,
    ),
    'sargodha': CityCoordinates(
      name: 'Sargodha',
      country: 'Pakistan',
      latitude: 32.0836,
      longitude: 72.6411,
    ),
    'bahawalpur': CityCoordinates(
      name: 'Bahawalpur',
      country: 'Pakistan',
      latitude: 29.3956,
      longitude: 71.6857,
    ),
    'mardan': CityCoordinates(
      name: 'Mardan',
      country: 'Pakistan',
      latitude: 34.1972,
      longitude: 71.9897,
    ),
    'muzaffarabad': CityCoordinates(
      name: 'Muzaffarabad',
      country: 'Pakistan',
      latitude: 34.3750,
      longitude: 73.4833,
    ),
    'murree': CityCoordinates(
      name: 'Murree',
      country: 'Pakistan',
      latitude: 34.1921,
      longitude: 73.4384,
    ),
    'gilgit': CityCoordinates(
      name: 'Gilgit',
      country: 'Pakistan',
      latitude: 35.9280,
      longitude: 74.3149,
    ),
    'skardu': CityCoordinates(
      name: 'Skardu',
      country: 'Pakistan',
      latitude: 35.2854,
      longitude: 75.5733,
    ),
    'swat': CityCoordinates(
      name: 'Swat',
      country: 'Pakistan',
      latitude: 34.7654,
      longitude: 72.3465,
    ),
    'hunza': CityCoordinates(
      name: 'Hunza',
      country: 'Pakistan',
      latitude: 36.8469,
      longitude: 74.8721,
    ),
    'naran': CityCoordinates(
      name: 'Naran',
      country: 'Pakistan',
      latitude: 34.9165,
      longitude: 73.6633,
    ),

    // International Cities for Reference
    'london': CityCoordinates(
      name: 'London',
      country: 'United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
    ),
    'new york': CityCoordinates(
      name: 'New York',
      country: 'United States',
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    'dubai': CityCoordinates(
      name: 'Dubai',
      country: 'United Arab Emirates',
      latitude: 25.2048,
      longitude: 55.2708,
    ),
    'tokyo': CityCoordinates(
      name: 'Tokyo',
      country: 'Japan',
      latitude: 35.6762,
      longitude: 139.6503,
    ),
    'paris': CityCoordinates(
      name: 'Paris',
      country: 'France',
      latitude: 48.8566,
      longitude: 2.3522,
    ),
    'sydney': CityCoordinates(
      name: 'Sydney',
      country: 'Australia',
      latitude: -33.8688,
      longitude: 151.2093,
    ),
  };

  /// Get coordinates for a city (case-insensitive)
  static CityCoordinates? getCoordinates(String cityName) {
    return cities[cityName.toLowerCase()];
  }

  /// Get all available city names
  static List<String> getAllCityNames() {
    return cities.keys.toList();
  }

  /// Get Pakistani cities only
  static List<CityCoordinates> getPakistaniCities() {
    return cities.values
        .where((city) => city.country == 'Pakistan')
        .toList();
  }
}
