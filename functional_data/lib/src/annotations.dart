import 'package:collection/collection.dart';

class FunctionalData {
  const FunctionalData({
    this.generateCopy,
    this.generateCopyWith,
    this.generateCopyUsing,
    this.generateLenses,
  })  : assert(generateCopy == null || (generateCopyWith == null && generateCopyUsing == null)),
        assert(generateLenses == false || (generateCopy != false && generateCopyWith != false));

  /// Whether the generator should generate the copy methods.
  ///
  /// Cannot be `false` when [generateLenses] is `true`
  ///
  /// Should not be defined together with [generateCopyWith] or [generateCopyUsing].
  final bool? generateCopy;

  /// Whether the generator should generate the copyWith method.
  ///
  /// Should not be defined together with [generateCopy].
  ///
  /// Cannot be `false` when [generateLenses] is `true`
  ///
  /// Defaults to `true`.
  final bool? generateCopyWith;

  /// Whether the generator should generate the copyUsing method.
  ///
  /// When set to `true`, a second data class used by the copyWith method
  /// will also be generated (called `_ClassName$Change`).
  ///
  /// Should not be defined together with [generateCopy].
  ///
  /// Defaults to `true`.
  final bool? generateCopyUsing;

  /// Whether the generator should generate the lenses class.
  ///
  /// The lenses class uses the `copyWith` method. So if [generateLenses] is set to `true`,
  /// the copyWith method needs to be generated (check [generateCopy] and [generateCopyWith]).
  ///
  /// Defaults to `true`.
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
