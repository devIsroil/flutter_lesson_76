import '../data/restaurant_model.dart';

class RestaurantCubit {
  static Future<List<Restaurant>> searchRestaurant(String name) async {
    await Future.delayed(Duration(seconds: 1));

    return [
      Restaurant(
        name: 'Afsona Restaurant',
        latitude: 41.3003,
        longitude: 69.2679,
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQaNDW06GO5tViY6JJfaEh804rlDkf15n5CVw&s',
      ),
      Restaurant(
        name: 'Beshqozon Restaurant',
        latitude: 41.3135,
        longitude: 69.2851,
        imageUrl: 'https://images.pexels.com/photos/262047/pexels-photo-262047.jpeg?auto=compress&cs=tinysrgb&w=600',
      ),
    ];
  }
}