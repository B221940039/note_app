import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';

      await db.execute('''
        CREATE TABLE todos (
          id $idType,
          title $textType,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          createdDate $textType,
          deadline TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      // Remove old columns if they exist
      try {
        await db.execute('DROP TABLE IF EXISTS todos');
        const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
        const textType = 'TEXT NOT NULL';
        await db.execute('''
          CREATE TABLE todos (
            id $idType,
            title $textType,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            createdDate $textType,
            deadline TEXT
          )
        ''');
      } catch (e) {
        print('Error upgrading todos table: $e');
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    // Notes table with embedded todoItems (for note todos)
    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content $textType,
        tag $textType,
        color INTEGER,
        dateCreated $textType,
        audioPath TEXT,
        videoPath TEXT,
        todoItems TEXT
      )
    ''');

    // User todos table (standalone todos)
    await db.execute('''
      CREATE TABLE todos (
        id $idType,
        title $textType,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdDate $textType,
        deadline TEXT
      )
    ''');
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.insert('notes', note);
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'dateCreated DESC');
  }

  Future<int> updateNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.update(
      'notes',
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // User Todo CRUD operations (standalone todos)
  Future<int> insertTodo(Map<String, dynamic> todo) async {
    final db = await database;
    return await db.insert('todos', todo);
  }

  Future<List<Map<String, dynamic>>> getAllTodos() async {
    final db = await database;
    return await db.query('todos', orderBy: 'createdDate DESC');
  }

  Future<int> updateTodo(Map<String, dynamic> todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo,
      where: 'id = ?',
      whereArgs: [todo['id']],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // Note todos are stored within the notes table as part of the todoItems JSON field

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
