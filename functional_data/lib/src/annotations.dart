import 'package:collection/collection.dart';

class FunctionalData {
  const FunctionalData({
    this.generateCopy,
    this.generateCopyWith,
    this.generateCopyUsing,
    this.generateLenses,
  });

  /// Whether the generator should generate the copy methods.
  ///
  /// When set, it overrides the settings of [generateCopyWith] and [generateCopyUsing].
  final bool? generateCopy;

  /// Whether the generator should generate the copyWith method.
  ///
  /// Defaults to `true`.
  final bool? generateCopyWith;

  /// Whether the generator should generate the copyUsing method.
  ///
  /// When set to `true`, a helper class will also be generated (called `ClassName$Change`).
  ///
  /// Defaults to `true`.
  final bool? generateCopyUsing;

  /// Whether the generator should generate the lenses class.
  ///
  /// The lenses class uses the `copyWith` method. So if [generateLenses] is set to `true`,
  /// it will ignore [generateCopyWith] configuration and force generate the copyWith method.
  ///
  /// Defaults to `false`.
  final bool? generateLenses;
}

class CustomEquality {
  final Equality equality;

  const CustomEquality(this.equality);
}

class Ignore implements Equality {
  const Ignore();

  @override
  bool equals(dynamic _, dynamic __) => true;

  @override
  int hash(_) => 0;

  @override
  bool isValidKey(Object? o) => true;
}
