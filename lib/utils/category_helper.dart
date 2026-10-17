import 'package:flutter/material.dart';

/// Danh sách danh mục + icon + màu, dùng chung cho Dashboard và form.
class CategoryHelper {
  static const List<String> expenseCategories = [
    'Ăn uống',
    'Mua sắm',
    'Đi lại',
    'Học tập',
    'Giải trí',
    'Hóa đơn',
    'Khác',
  ];

  static const List<String> incomeCategories = [
    'Lương',
    'Thưởng',
    'Khác',
  ];

  static List<String> byType(String type) =>
      type == 'income' ? incomeCategories : expenseCategories;

  static IconData icon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Đi lại':
        return Icons.directions_car;
      case 'Học tập':
        return Icons.menu_book;
      case 'Giải trí':
        return Icons.movie;
      case 'Hóa đơn':
        return Icons.receipt_long;
      case 'Lương':
        return Icons.account_balance_wallet;
      case 'Thưởng':
        return Icons.card_giftcard;
      default:
        return Icons.more_horiz;
    }
  }

  static Color color(String category) {
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFF5A5F);
      case 'Mua sắm':
        return const Color(0xFF29B6F6);
      case 'Đi lại':
        return const Color(0xFF9C6ADE);
      case 'Học tập':
        return const Color(0xFF7E57C2);
      case 'Giải trí':
        return const Color(0xFFFFA726);
      case 'Hóa đơn':
        return const Color(0xFF5C6BC0);
      case 'Lương':
        return const Color(0xFF4CAF50);
      case 'Thưởng':
        return const Color(0xFF26A69A);
      default:
        return Colors.grey;
    }
  }

  static String formatMoney(double v) => v
      .toInt()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
}
