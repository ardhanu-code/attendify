import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueFontWeight;
  final double? valueFontSize;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontWeight,
    this.valueFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.lexend(
                fontSize: valueFontSize ?? 12,
                color: valueColor ?? Colors.black87,
                fontWeight: valueFontWeight ?? FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
