library simple_data;

import 'package:collection/collection.dart';

export 'lenses.dart';

class SimpleData { const SimpleData(); }

class FunctionalData { const FunctionalData(); }

class CustomEquality {
  final Equality equality;

  const CustomEquality(this.equality);
}
