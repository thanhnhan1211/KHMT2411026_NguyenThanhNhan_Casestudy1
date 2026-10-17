import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _blue = Color(0xFF1565C0);
  static const Color _green = Color(0xFF2E9E5B);
  static const Color _red = Color(0xFFE53935);

  // Dữ liệu mẫu (buổi 5-6 sẽ thay bằng dữ liệu từ SQLite)
  final List<TransactionModel> _transactions = [
    TransactionModel(
        id: 1,
        type: 'expense',
        category: 'Ăn uống',
        amount: 100000,
        date: '12/04/2025',
        note: 'Ăn trưa'),
    TransactionModel(
        id: 2,
        type: 'expense',
        category: 'Mua sắm',
        amount: 500000,
        date: '10/04/2025'),
    TransactionModel(
        id: 3,
        type: 'income',
        category: 'Lương',
        amount: 10000000,
        date: '05/04/2025'),
    TransactionModel(
        id: 4,
        type: 'expense',
        category: 'Hóa đơn',
        amount: 4400000,
        date: '01/04/2025'),
  ];

  double get _totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (s, t) => s + t.amount);

  String _money(double v) => v
      .toInt()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  IconData _icon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Lương':
        return Icons.account_balance_wallet;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Giải trí':
        return Icons.movie;
      case 'Hóa đơn':
        return Icons.receipt_long;
      default:
        return Icons.more_horiz;
    }
  }

  Color _color(String category) {
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFF5A5F);
      case 'Mua sắm':
        return const Color(0xFF29B6F6);
      case 'Lương':
        return const Color(0xFF4CAF50);
      case 'Di chuyển':
        return const Color(0xFF9C6ADE);
      case 'Giải trí':
        return const Color(0xFFFFA726);
      case 'Hóa đơn':
        return const Color(0xFF5C6BC0);
      default:
        return Colors.grey;
    }
  }

  Future<void> _openForm([TransactionModel? t]) async {
    final result = await Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(builder: (_) => TransactionFormScreen(transaction: t)),
    );
    if (result == null) return;
    setState(() {
      if (t == null) {
        _transactions.insert(
            0,
            TransactionModel(
              id: DateTime.now().millisecondsSinceEpoch,
              type: result.type,
              category: result.category,
              amount: result.amount,
              date: result.date,
              note: result.note,
            ));
      } else {
        final i = _transactions.indexWhere((x) => x.id == t.id);
        if (i != -1) _transactions[i] = result;
      }
    });
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 70),
      decoration: const BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xin chào!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Hôm nay là một ngày tốt lành!',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Color(0xFFBBDEFB), shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard() {
    final balance = _totalIncome - _totalExpense;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số dư hiện tại',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 6),
                Text('${_money(balance)} đ',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet,
                color: _blue, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      String label, double value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
            const SizedBox(height: 4),
            Text('${_money(value)} đ',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _item(TransactionModel t) {
    final isIncome = t.type == 'income';
    return InkWell(
      onTap: () => _openForm(t),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: _color(t.category),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(_icon(t.category), color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(t.date,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${_money(t.amount)} đ',
              style: TextStyle(
                  color: isIncome ? _green : _red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = _transactions.take(3).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SafeArea(
                        bottom: false,
                        child: _header(),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: -40,
                        child: _balanceCard(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _summaryCard(
                                'Thu nhập',
                                _totalIncome,
                                Icons.arrow_upward,
                                _green,
                                const Color(0xFFDFF3E6)),
                            const SizedBox(width: 14),
                            _summaryCard(
                                'Chi tiêu',
                                _totalExpense,
                                Icons.arrow_downward,
                                _red,
                                const Color(0xFFFDE4E4)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Chi tiêu gần đây',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: () {},
                              child: const Text('Xem tất cả',
                                  style: TextStyle(
                                      color: _blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...recent.map(_item),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Giao dịch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Cá nhân'),
        ],
      ),
    );
  }
}
