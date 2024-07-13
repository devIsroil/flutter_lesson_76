import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RestaurantItem extends StatefulWidget {
  const RestaurantItem({super.key});

  @override
  State<RestaurantItem> createState() => _RestaurantItemState();
}

class _RestaurantItemState extends State<RestaurantItem> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(itemBuilder: (context, index) {
        return ListTile();
      },),
    );
  }
}
