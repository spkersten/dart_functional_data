library functional_data;

import 'package:collection/collection.dart';

export 'lenses.dart';

class FunctionalData { const FunctionalData(); }

class CustomEquality {
  final Equality equality;

  const CustomEquality(this.equality);
}
