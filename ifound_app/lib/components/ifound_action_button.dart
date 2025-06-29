import 'package:flutter/material.dart';

class IFoundActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const IFoundActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
          height: 70,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
