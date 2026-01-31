import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmojiRating extends StatelessWidget {
  final int rating;
  final bool isSelected;
  final VoidCallback onTap;

  const EmojiRating({
    super.key,
    required this.rating,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: SvgPicture.asset(
              _getEmojiAssetPath(),
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 25,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? _getEmojiColor() : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmojiColor() {
    switch (rating) {
      case 1:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFFFF9800);
      case 3:
        return const Color(0xFFFFC107);
      case 4:
        return const Color(0xFF8BC34A);
      case 5:
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  String _getEmojiAssetPath() {
    switch (rating) {
      case 1:
        return 'assets/svg/rating_1.svg';
      case 2:
        return 'assets/svg/rating_2.svg';
      case 3:
        return 'assets/svg/rating_3.svg';
      case 4:
        return 'assets/svg/rating_4.svg';
      case 5:
        return 'assets/svg/rating_5.svg';
      default:
        return 'assets/svg/rating_3.svg';
    }
  }
}