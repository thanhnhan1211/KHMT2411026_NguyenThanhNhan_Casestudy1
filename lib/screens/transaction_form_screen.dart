import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

/// Dùng chung cho cả "Thêm giao dịch" và "Sửa giao dịch".
/// transaction == null  -> Thêm
/// transaction != null  -> Sửa (điền sẵn dữ liệu)
class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  static const Map<String, IconData> _categories = {
    'Ăn uống': Icons.restaurant,
    'Di chuyển': Icons.directions_car,
    'Mua sắm': Icons.shopping_bag,
    'Giải trí': Icons.movie,
    'Hóa đơn': Icons.receipt_long,
    'Lương': Icons.account_balance_wallet,
    'Khác': Icons.more_horiz,
  };

  static const Color _expenseColor = Color(0xFFFF5A5F);
  static const Color _incomeColor = Color(0xFF2E9E5B);

  late String _type;
  late String _category;
  late DateTime _date;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _type = t?.type ?? 'expense';
    _category = t?.category ?? 'Ăn uống';
    _date = DateTime.now();
    if (t != null) {
      _amountCtrl.text = _formatMoney(t.amount);
      _noteCtrl.text = t.note;
      final p = t.date.split('/');
      if (p.length == 3) {
        _date = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
    }
    _dateCtrl.text = _formatDate(_date);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  String _formatMoney(double v) => v
      .toInt()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateCtrl.text = _formatDate(picked);
      });
    }
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll('.', '').trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }
    Navigator.pop(
      context,
      TransactionModel(
        id: widget.transaction?.id,
        type: _type,
        category: _category,
        amount: amount,
        date: _formatDate(_date),
        note: _noteCtrl.text.trim(),
      ),
    );
  }

  Widget _typeButton(String label, String value, Color color) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? color : Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      );

  InputDecoration _inputDecoration({String? hint, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _typeButton('Chi tiêu', 'expense', _expenseColor),
                        const SizedBox(width: 10),
                        _typeButton('Thu nhập', 'income', _incomeColor),
                      ],
                    ),
                    _label('Danh mục'),
                    DropdownButtonFormField<String>(
                      value: _category,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      decoration: _inputDecoration(),
                      items: _categories.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: _expenseColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(e.value,
                                          size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(e.key),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    _label('Số tiền'),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        hint: 'Nhập số tiền',
                        suffix: const Padding(
                          padding: EdgeInsets.only(right: 14),
                          child: Align(
                            alignment: Alignment.centerRight,
                            widthFactor: 1,
                            child: Text('đ'),
                          ),
                        ),
                      ),
                    ),
                    _label('Ngày giao dịch'),
                    TextField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _inputDecoration(
                        suffix: const Icon(Icons.calendar_today_outlined,
                            size: 20),
                      ),
                    ),
                    _label('Ghi chú'),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration:
                          _inputDecoration(hint: 'Nhập ghi chú (tùy chọn)'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Lưu',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
