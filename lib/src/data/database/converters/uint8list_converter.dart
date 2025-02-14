import 'package:drift/drift.dart';

class Uint8ListConverter extends TypeConverter<Uint8List, Uint8List> {
  const Uint8ListConverter();

  @override
  Uint8List fromSql(Uint8List fromDb) {
    return fromDb;
  }

  @override
  Uint8List toSql(Uint8List value) {
    return value;
  }
}
