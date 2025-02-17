import 'package:drift/drift.dart';

/// {@template type_converter}
/// A converter that converts a Dart type to a SQL type and vice versa.
/// {@endtemplate}
class Uint8ListConverter extends TypeConverter<Uint8List, Uint8List> {
  /// {@macro type_converter}
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
