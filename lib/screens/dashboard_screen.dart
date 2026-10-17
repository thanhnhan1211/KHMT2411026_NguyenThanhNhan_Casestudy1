import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../utils/category_helper.dart';
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

  final _repo = TransactionRepository();

  List<TransactionModel> _recent = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Đọc dữ liệu từ SQLite để hiển thị lên Dashboard.
  Future<void> _loadData() async {
    final recent = await _repo.getRecent(limit: 3);
    final income = await _repo.getTotalIncome();
    final expense = await _repo.getTotalExpense();
    if (!mounted) return;
    setState(() {
      _recent = recent;
      _totalIncome = income;
      _totalExpense = expense;
      _loading = false;
    });
  }

  /// Mở form Thêm (t == null) hoặc Sửa (t != null), quay lại thì tải lại.
  Future<void> _openForm([TransactionModel? t]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TransactionFormScreen(transaction: t)),
    );
    if (saved == true) _loadData();
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
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4)),
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
                Text(
                  '${balance < 0 ? '-' : ''}${CategoryHelper.formatMoney(balance.abs())} đ',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
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
            Text('${CategoryHelper.formatMoney(value)} đ',
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
                  color: CategoryHelper.color(t.category),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(CategoryHelper.icon(t.category), color: Colors.white),
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
              '${isIncome ? '+' : '-'}${CategoryHelper.formatMoney(t.amount)} đ',
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

  Widget _recentList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text('Chưa có giao dịch nào.\nBấm nút + để thêm mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
        ),
      );
    }
    return Column(children: _recent.map(_item).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SafeArea(bottom: false, child: _header()),
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
                        _summaryCard('Thu nhập', _totalIncome,
                            Icons.arrow_upward, _green, const Color(0xFFDFF3E6)),
                        const SizedBox(width: 14),
                        _summaryCard('Chi tiêu', _totalExpense,
                            Icons.arrow_downward, _red, const Color(0xFFFDE4E4)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Giao dịch gần đây',
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
                    _recentList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
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
