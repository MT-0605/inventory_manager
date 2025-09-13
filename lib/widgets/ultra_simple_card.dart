import 'package:flutter/material.dart';

/// Ultra-simple card widget that never overflows
/// Use this for all cards throughout the app to ensure no overflow issues
class UltraSimpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? height;
  final Color? color;
  final VoidCallback? onTap;

  const UltraSimpleCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height ?? 100, // Fixed height to prevent overflow
          padding: padding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}

/// Ultra-simple stat card for displaying metrics
class UltraSimpleStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const UltraSimpleStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UltraSimpleCard(
      height: 120, // Increased height for better readability
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color), // Larger icon
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              // Larger text
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              // Larger text
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Ultra-simple product card for displaying products
class UltraSimpleProductCard extends StatelessWidget {
  final String name;
  final String category;
  final String price;
  final String stock;
  final bool isLowStock;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const UltraSimpleProductCard({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.isLowStock = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return UltraSimpleCard(
      height: 140, // Increased height for better readability
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            height: 40, // Larger image placeholder
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.image_outlined,
              size: 20, // Larger icon
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),

          // Product name
          Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              // Larger text
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              category,
              style: theme.textTheme.labelMedium?.copyWith(
                // Larger text
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Price and stock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: theme.textTheme.titleMedium?.copyWith(
                  // Larger text
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 12, // Larger icon
                    color: isLowStock
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    stock,
                    style: theme.textTheme.bodySmall?.copyWith(
                      // Larger text
                      color: isLowStock
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isLowStock
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Low stock warning
          if (isLowStock) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 10, // Larger icon
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Low Stock',
                    style: theme.textTheme.labelSmall?.copyWith(
                      // Larger text
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          if (showActions) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 12), // Larger icon
                    label: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 10),
                    ), // Larger text
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ), // Larger padding
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 12), // Larger icon
                    label: const Text(
                      'Delete',
                      style: TextStyle(fontSize: 10),
                    ), // Larger text
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ), // Larger padding
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
