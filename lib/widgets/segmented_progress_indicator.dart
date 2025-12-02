import 'package:flutter/material.dart';

class SegmentedProgressIndicator extends StatelessWidget {
  final int totalSegments;
  final int currentSegment;
  final double segmentHeight;
  final Color segmentColor;
  final Color unfilledSegmentColor;
  final double gapWidth;

  const SegmentedProgressIndicator({
    super.key,
    required this.totalSegments,
    required this.currentSegment,
    this.segmentHeight = 4.0,
    required this.segmentColor,
    required this.unfilledSegmentColor,
    this.gapWidth = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSegments, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: gapWidth / 2),
            height: segmentHeight,
            decoration: BoxDecoration(
              color:
                  index <= currentSegment ? segmentColor : unfilledSegmentColor,
              borderRadius: BorderRadius.circular(segmentHeight / 2),
            ),
          ),
        );
      }),
    );
  }
}
