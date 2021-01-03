import 'package:collection/collection.dart';

class FunctionalData {
  const FunctionalData();
}

class CustomEquality {
  final Equality equality;

  const CustomEquality(this.equality);
}

/// This can be used as:
///
/// * An equality annotation - making the computed equality ignore this field.
///
///   `@CustomEquality(Ignore())`
///   
/// * A field annotation - making the functional data generator ignore this field alltogether.
///
///   `@Ignore()`
class Ignore implements Equality<dynamic> {
  const Ignore();

  @override
  bool equals(dynamic _, dynamic __) => true;

  @override
  int hash(dynamic _) => 0;

  @override
  bool isValidKey(Object o) => true;
}
