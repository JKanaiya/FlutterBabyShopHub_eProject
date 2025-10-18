import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final int cartCount;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  static const Color _activeColor = Color(0xff006876);
  static const Color _inactiveColor = Colors.grey;

  Widget _buildItem({
    required int index,
    required IconData icon,
    String? label,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final bool active = index == currentIndex;

    // Icon with circular highlighted background when active
    final Widget iconWidget = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? _activeColor.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 22,
          color: active ? _activeColor : _inactiveColor,
        ),
      ),
    );

    // Badge overlay for cart
    final Widget withBadge = Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        if (showBadge && badgeCount > 0)
          Positioned(
            right: -6,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4)
                ],
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );

    // Label — only show label for a few items if desired
    final Widget labelWidget = label == null
        ? const SizedBox.shrink()
        : Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: active ? _activeColor : _inactiveColor,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            withBadge,
            labelWidget,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(index: 0, icon: Icons.storefront_rounded, label: 'Shop'),
          _buildItem(index: 1, icon: Icons.search, label: 'Search'),
          _buildItem(index: 2, icon: Icons.shopping_cart_outlined, label: 'Cart', showBadge: true, badgeCount: cartCount),
          _buildItem(index: 3, icon: Icons.local_shipping_outlined, label: 'Orders'),
          _buildItem(index: 4, icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}
