import 'package:flutter/material.dart';
import 'package:event_map/utils/constants.dart';

class PostPin extends StatelessWidget {
  final bool isActive;

  const PostPin({super.key, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? kPrimaryColor.withOpacity(0.8) : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(
        Icons.location_on,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}