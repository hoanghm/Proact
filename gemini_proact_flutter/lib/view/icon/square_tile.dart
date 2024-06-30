import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final double size;

  const SquareTile({
    super.key,
    required this.imagePath,
    this.size = 40
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.375),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(size * 0.5),
        color: Colors.grey[200],
      ),
      child: Image.asset(
        imagePath, 
        height: size,
      )
    );
  }

}