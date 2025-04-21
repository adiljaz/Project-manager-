// lib/widgets/common/empty_state.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? description;
  
  const EmptyState({
    Key? key,
    required this.icon,
    required this.message,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey[350]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                description!,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ),
        ],
      ),
    );
  }
}



class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  
  const ShimmerGrid({
    Key? key,
    this.itemCount = 6
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: itemCount,
        itemBuilder:
            (_, __) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
              ),
            ),
      ),
    );
  }
}

// lib/widgets/common/shimmer_list.dart


class ShimmerList extends StatelessWidget {
  final int itemCount;
  
  const ShimmerList({
    Key? key,
    this.itemCount = 3
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder:
            (_, __) => Card(
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 40, color: Colors.grey[300]),
                ],
              ),
            ),
      ),
    );
  }
}