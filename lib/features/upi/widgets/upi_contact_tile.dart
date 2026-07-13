import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/features/upi/provider/upi_provider.dart';

class UpiContactTile extends StatelessWidget {
  final RecentUpiContact contact;
  final VoidCallback onTap;

  const UpiContactTile({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: contact.avatarColor,
            child: Text(
              contact.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            contact.name.split(' ').first, // first name only
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}