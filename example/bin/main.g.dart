// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

abstract class $Foo {
  const $Foo();

  String get name;
  int get number;
  my_types.Enum? get enu;

  Foo copyWith({
    String? name,
    int? number,
    my_types.Enum? enu,
  }) =>
      Foo(
        name: name ?? this.name,
        number: number ?? this.number,
        enu: enu ?? this.enu,
      );

  Foo copyUsing(void Function(Foo$Change change) mutator) {
    final change = Foo$Change._(
      this.name,
      this.number,
      this.enu,
    );
    mutator(change);
    return Foo(
      name: change.name,
      number: change.number,
      enu: change.enu,
    );
  }

  @override
  String toString() => "Foo(name: $name, number: $number, enu: $enu)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is Foo &&
      other.runtimeType == runtimeType &&
      name == other.name &&
      number == other.number &&
      enu == other.enu;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + name.hashCode;
    result = 37 * result + number.hashCode;
    result = 37 * result + enu.hashCode;
    return result;
  }
}

class Foo$Change {
  Foo$Change._(
    this.name,
    this.number,
    this.enu,
  );

  String name;
  int number;
  my_types.Enum? enu;
}

// ignore: avoid_classes_with_only_static_members
class Foo$ {
  static final name = Lens<Foo, String>(
    (nameContainer) => nameContainer.name,
    (nameContainer, name) => nameContainer.copyWith(name: name),
  );

  static final number = Lens<Foo, int>(
    (numberContainer) => numberContainer.number,
    (numberContainer, number) => numberContainer.copyWith(number: number),
  );

  static final enu = Lens<Foo, my_types.Enum?>(
    (enuContainer) => enuContainer.enu,
    (enuContainer, enu) => enuContainer.copyWith(enu: enu),
  );
}

abstract class $Bar {
  const $Bar();

  List<Foo> get foos;
  Foo get foo;
  String get driver;
  String? get cache;

  Bar copyWith({
    List<Foo>? foos,
    Foo? foo,
    String? driver,
    String? cache,
  }) =>
      Bar(
        foos ?? this.foos,
        foo ?? this.foo,
        driver: driver ?? this.driver,
        cache: cache ?? this.cache,
      );

  Bar copyUsing(void Function(Bar$Change change) mutator) {
    final change = Bar$Change._(
      this.foos,
      this.foo,
      this.driver,
      this.cache,
    );
    mutator(change);
    return Bar(
      change.foos,
      change.foo,
      driver: change.driver,
      cache: change.cache,
    );
  }

  @override
  String toString() => "Bar(foos: $foos, foo: $foo, driver: $driver, cache: $cache)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is Bar &&
      other.runtimeType == runtimeType &&
      const DeepCollectionEquality().equals(foos, other.foos) &&
      foo == other.foo &&
      const MyEquality<String>().equals(driver, other.driver) &&
      const Ignore().equals(cache, other.cache);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + const DeepCollectionEquality().hash(foos);
    result = 37 * result + foo.hashCode;
    result = 37 * result + const MyEquality<String>().hash(driver);
    result = 37 * result + const Ignore().hash(cache);
    return result;
  }
}

class Bar$Change {
  Bar$Change._(
    this.foos,
    this.foo,
    this.driver,
    this.cache,
  );

  List<Foo> foos;
  Foo foo;
  String driver;
  String? cache;
}

// ignore: avoid_classes_with_only_static_members
class Bar$ {
  static final foos = Lens<Bar, List<Foo>>(
    (foosContainer) => foosContainer.foos,
    (foosContainer, foos) => foosContainer.copyWith(foos: foos),
  );

  static final foo = Lens<Bar, Foo>(
    (fooContainer) => fooContainer.foo,
    (fooContainer, foo) => fooContainer.copyWith(foo: foo),
  );

  static final driver = Lens<Bar, String>(
    (driverContainer) => driverContainer.driver,
    (driverContainer, driver) => driverContainer.copyWith(driver: driver),
  );

  static final cache = Lens<Bar, String?>(
    (cacheContainer) => cacheContainer.cache,
    (cacheContainer, cache) => cacheContainer.copyWith(cache: cache),
  );
}

abstract class $Baz {
  const $Baz();

  math.Point get prefixedField;

  Baz copyWith({
    math.Point? prefixedField,
  }) =>
      Baz(
        prefixedField: prefixedField ?? this.prefixedField,
      );

  Baz copyUsing(void Function(Baz$Change change) mutator) {
    final change = Baz$Change._(
      this.prefixedField,
    );
    mutator(change);
    return Baz(
      prefixedField: change.prefixedField,
    );
  }

  @override
  String toString() => "Baz(prefixedField: $prefixedField)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is Baz && other.runtimeType == runtimeType && prefixedField == other.prefixedField;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    return prefixedField.hashCode;
  }
}

class Baz$Change {
  Baz$Change._(
    this.prefixedField,
  );

  math.Point prefixedField;
}

// ignore: avoid_classes_with_only_static_members
class Baz$ {
  static final prefixedField = Lens<Baz, math.Point>(
    (prefixedFieldContainer) => prefixedFieldContainer.prefixedField,
    (prefixedFieldContainer, prefixedField) => prefixedFieldContainer.copyWith(prefixedField: prefixedField),
  );
}
