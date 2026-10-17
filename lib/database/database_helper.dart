import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Quản lý việc mở/tạo database SQLite.
/// Dùng Singleton: toàn app chỉ có 1 kết nối.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const String dbName = 'expense_manager.db';
  static const int dbVersion = 1;

  // Tên bảng và tên cột
  static const String tableTransactions = 'transactions';
  static const String colId = 'id';
  static const String colType = 'type';
  static const String colCategory = 'category';
  static const String colAmount = 'amount';
  static const String colDate = 'date';
  static const String colNote = 'note';

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    return openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $colId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colType     TEXT    NOT NULL CHECK ($colType IN ('expense', 'income')),
        $colCategory TEXT    NOT NULL,
        $colAmount   REAL    NOT NULL CHECK ($colAmount > 0),
        $colDate     TEXT    NOT NULL,
        $colNote     TEXT    NOT NULL DEFAULT ''
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_transactions_type ON $tableTransactions ($colType)');
  }

  // Khi sau này đổi cấu trúc bảng: tăng dbVersion và xử lý tại đây.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
