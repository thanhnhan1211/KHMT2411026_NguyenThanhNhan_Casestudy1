import '../database/database_helper.dart';
import '../models/transaction_model.dart';

/// Lớp trung gian giữa Screen và Database.
/// Screen chỉ gọi các hàm ở đây, không viết SQL trực tiếp.
class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _table = DatabaseHelper.tableTransactions;

  // ---------- CREATE ----------
  /// Thêm giao dịch, trả về id vừa tạo.
  Future<int> insert(TransactionModel t) async {
    final db = await _dbHelper.database;
    final map = t.toMap()..remove('id'); // để SQLite tự tăng id
    return db.insert(_table, map);
  }

  // ---------- READ ----------
  /// Lấy toàn bộ giao dịch, mới nhất trước.
  Future<List<TransactionModel>> getAll() async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table);
    return _sortNewestFirst(rows.map(TransactionModel.fromMap).toList());
  }

  /// Lấy theo loại: 'expense' hoặc 'income'.
  Future<List<TransactionModel>> getByType(String type) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: 'type = ?', whereArgs: [type]);
    return _sortNewestFirst(rows.map(TransactionModel.fromMap).toList());
  }

  /// Lấy các giao dịch gần đây (dùng cho Dashboard).
  Future<List<TransactionModel>> getRecent({int limit = 3}) async {
    final all = await getAll();
    return all.take(limit).toList();
  }

  /// Tìm kiếm theo danh mục hoặc ghi chú.
  Future<List<TransactionModel>> search(String keyword) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'category LIKE ? OR note LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return _sortNewestFirst(rows.map(TransactionModel.fromMap).toList());
  }

  Future<TransactionModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return TransactionModel.fromMap(rows.first);
  }

  // ---------- UPDATE ----------
  /// Sửa giao dịch (theo id), trả về số dòng đã sửa.
  Future<int> update(TransactionModel t) async {
    final db = await _dbHelper.database;
    return db.update(
      _table,
      t.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  // ---------- DELETE ----------
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- THỐNG KÊ (cho Dashboard) ----------
  Future<double> _sumByType(String type) async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM $_table WHERE type = ?',
      [type],
    );
    return (res.first['total'] as num).toDouble();
  }

  Future<double> getTotalIncome() => _sumByType('income');

  Future<double> getTotalExpense() => _sumByType('expense');

  Future<double> getBalance() async =>
      await getTotalIncome() - await getTotalExpense();

  // ---------- HỖ TRỢ ----------
  // Ngày lưu dạng dd/MM/yyyy nên sắp xếp bằng Dart thay vì ORDER BY.
  DateTime _parseDate(String s) {
    final p = s.split('/');
    if (p.length != 3) return DateTime(1970);
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  List<TransactionModel> _sortNewestFirst(List<TransactionModel> list) {
    list.sort((a, b) {
      final c = _parseDate(b.date).compareTo(_parseDate(a.date));
      return c != 0 ? c : (b.id ?? 0).compareTo(a.id ?? 0);
    });
    return list;
  }
}
