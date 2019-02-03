import 'package:collection/collection.dart';

class FunctionalData {
  const FunctionalData();
}

class CustomEquality {
  final Equality equality;

  const CustomEquality(this.equality);
}

class Ignore implements Equality {
  const Ignore();

  @override
  bool equals(_, __) => true;

  @override
  int hash(_) => 0;

  @override
  bool isValidKey(Object o) => true;
}
