import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lesson_76/restaurant_app/cubit/restaurant_cubit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../data/restaurant_model.dart';
import '../../services/yandex_map_service.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late YandexMapController mapController;
  Point? selectedPoint;
  Point currentPoint = const Point(latitude: 41.2856806, longitude: 69.2034646);
  List<MapObject>? routePoints;
  String? distance;
  bool _nightModeEnabled = false;
  List<Restaurant> restaurants = [];

  TextEditingController _searchController = TextEditingController();
  MapType _currentMapType = MapType.vector;
  String _currentTravelMode = 'driving';

  @override
  void initState() {
    super.initState();
    getLiveLocation();
    loadRestaurants();
  }

  void loadRestaurants() async {
    try {
      List<Restaurant> fetchedRestaurants = await RestaurantCubit.searchRestaurant('');
      setState(() {
        restaurants = fetchedRestaurants;
      });
    } catch (e) {
      print('Error loading restaurants: $e');
    }
  }

  onMapController(YandexMapController controller) {
    mapController = controller;
    mapController.moveCamera(
      animation: const MapAnimation(
        duration: 0.5,
        type: MapAnimationType.smooth,
      ),
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentPoint),
      ),
    );
  }

  getLiveLocation() {
    LocationService.getCurrentLocation().listen((position) {
      currentPoint = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() {});
    });
  }

  Future<void> _searchLocation() async {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          Location loc = locations.first;
          Point newPoint = Point(latitude: loc.latitude, longitude: loc.longitude);
          mapController.moveCamera(
            animation: const MapAnimation(
              duration: 0.5,
              type: MapAnimationType.smooth,
            ),
            CameraUpdate.newCameraPosition(
              CameraPosition(target: newPoint, zoom: 20),
            ),
          );
          selectedPoint = newPoint;
          _calculateDistance();
          LocationService.getDirection(currentPoint, selectedPoint!).then((points) {
            routePoints = points;
            setState(() {});
          });
          setState(() {});
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _calculateDistance() {
    if (selectedPoint != null) {
      double distanceInMeters = _getDistanceFromLatLonInKm(
        currentPoint.latitude,
        currentPoint.longitude,
        selectedPoint!.latitude,
        selectedPoint!.longitude,
      );
      setState(() {
        distance = distanceInMeters.toStringAsFixed(2) + " km";
      });
    }
  }

  double _getDistanceFromLatLonInKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) {
    return deg * (math.pi / 180);
  }

  PlacemarkMapObject _buildRestaurantMarker(Restaurant restaurant) {
    Point restaurantPoint = Point(latitude: restaurant.latitude, longitude: restaurant.longitude);

    return PlacemarkMapObject(
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage(
            'assets/images/red_mark1.png',
          ),
        ),
      ),
      mapId: MapObjectId(restaurant.name),
      point: restaurantPoint,
      onTap: (placemark, point) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(restaurant.name),
              content: Image.network(
                restaurant.imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddLocationDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter location name',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  hintText: 'Enter image URL',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                Restaurant newRestaurant = Restaurant(
                  name: nameController.text,
                  latitude: 41.2956,
                  longitude: 69.2342,
                  imageUrl: imageUrlController.text,
                );

                setState(() {
                  restaurants.add(newRestaurant);
                });

                Point newLocation = Point(latitude: newRestaurant.latitude, longitude: newRestaurant.longitude);
                mapController.moveCamera(
                  animation: const MapAnimation(
                    duration: 0.5,
                    type: MapAnimationType.smooth,
                  ),
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: newLocation, zoom: 15),
                  ),
                );

                selectedPoint = newLocation;
                _calculateDistance();
                LocationService.getDirection(currentPoint, selectedPoint!).then((points) {
                  routePoints = points;
                  setState(() {});
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewLocation() async {
    try {
      Point newLocation = Point(latitude: 41.2956, longitude: 69.2342);
      mapController.moveCamera(
        animation: const MapAnimation(
          duration: 0.5,
          type: MapAnimationType.smooth,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(target: newLocation, zoom: 15),
        ),
      );
      selectedPoint = newLocation;
      _calculateDistance();
      LocationService.getDirection(currentPoint, selectedPoint!).then((points) {
        routePoints = points;
        setState(() {});
      });
      setState(() {});
    } catch (e) {
      print('Error adding new location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YandexMap(
            nightModeEnabled: _nightModeEnabled,
            onMapTap: (argument) {
              selectedPoint = argument;
              LocationService.getDirection(currentPoint, selectedPoint!).then((points) {
                routePoints = points;
                setState(() {});
              });
              _calculateDistance();
              setState(() {});
            },
            mapType: _currentMapType,
            fastTapEnabled: true,
            onMapCreated: onMapController,
            mapObjects: [
              PlacemarkMapObject(
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage(
                      'assets/images/place.png',
                    ),
                  ),
                ),
                mapId: const MapObjectId("currentLocation"),
                point: currentPoint,
              ),
              if (selectedPoint != null)
                PlacemarkMapObject(
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage(
                        'assets/images/route_end.png',
                      ),
                    ),
                  ),
                  mapId: const MapObjectId("selectedLocation"),
                  point: selectedPoint!,
                ),
              ...?routePoints,
              // Adding restaurant markers
              for (var restaurant in restaurants)
                _buildRestaurantMarker(restaurant),
            ],
          ),
          Positioned(
            top: 50,
            left: 25,
            right: 25,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(CupertinoIcons.search),
                        onPressed: _searchLocation,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 120,
            right: 15,
            child: PopupMenuButton(
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.map),
              ),
              onSelected: (value) {
                setState(() {
                  _currentMapType = value;
                });
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: MapType.map,
                    child: Text('Map'),
                  ),
                  const PopupMenuItem(
                    value: MapType.satellite,
                    child: Text('Satellite'),
                  ),
                  const PopupMenuItem(
                    value: MapType.vector,
                    child: Text('Vector'),
                  ),
                ];
              },
            ),
          ),
          Positioned(
            top: 120,
            left: 15,
            child: PopupMenuButton(
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.directions),
              ),
              onSelected: (value) {
                setState(() {
                  _currentTravelMode = value;
                });
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'walking',
                    child: Text('Walking'),
                  ),
                  const PopupMenuItem(
                    value: 'driving',
                    child: Text('Driving'),
                  ),
                  const PopupMenuItem(
                    value: 'bicycle',
                    child: Text('Bicycle'),
                  ),
                ];
              },
            ),
          ),
          Positioned(
            top: 180,
            right: 25,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _nightModeEnabled = !_nightModeEnabled;
                  });
                },
                icon: Icon(
                  _nightModeEnabled ? Icons.nights_stay : Icons.wb_sunny,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: 25,
            child: Column(
              children: [
                InkWell(
                  highlightColor: Colors.blue,
                  onTap: () {
                    mapController.moveCamera(CameraUpdate.zoomIn());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(CupertinoIcons.plus, size: 30),
                  ),
                ),
                const SizedBox(height: 15),
                InkWell(
                  highlightColor: Colors.blue,
                  onTap: () {
                    mapController.moveCamera(CameraUpdate.zoomOut());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(CupertinoIcons.minus, size: 30),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: InkWell(
              onTap: () {
                mapController.moveCamera(
                  animation: const MapAnimation(
                    duration: 0.5,
                    type: MapAnimationType.smooth,
                  ),
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: currentPoint, zoom: 15),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                ),
                child: const Icon(
                  CupertinoIcons.location_fill,
                  color: Colors.amber,
                  size: 30,
                ),
              ),
            ),
          ),
          if (distance != null)
            Positioned(
              bottom: 250,
              right: 25,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  'Distance: $distance',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: showAddLocationDialog,
        tooltip: 'Add Location',
        child: const Icon(Icons.add),
      ),
    );
  }
}
