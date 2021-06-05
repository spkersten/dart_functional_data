// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// FunctionalDataGenerator
// **************************************************************************

abstract class $Foo {
  const $Foo();

  int get number;
  String get name;
  my_types.Enum? get enu;

  Foo copyWith({int? number, String? name, my_types.Enum? enu}) =>
      Foo(number: number ?? this.number, name: name ?? this.name, enu: enu ?? this.enu);

  @override
  String toString() => "Foo(number: $number, name: $name, enu: $enu)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is Foo &&
      other.runtimeType == runtimeType &&
      number == other.number &&
      name == other.name &&
      enu == other.enu;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + number.hashCode;
    result = 37 * result + name.hashCode;
    result = 37 * result + enu.hashCode;
    return result;
  }
}

// ignore: avoid_classes_with_only_static_members
class Foo$ {
  static final number = Lens<Foo, int>(
    (numberContainer) => numberContainer.number,
    (numberContainer, number) => numberContainer.copyWith(number: number),
  );

  static final name = Lens<Foo, String>(
    (nameContainer) => nameContainer.name,
    (nameContainer, name) => nameContainer.copyWith(name: name),
  );

  static final enu = Lens<Foo, my_types.Enum?>(
    (enuContainer) => enuContainer.enu,
    (enuContainer, enu) => enuContainer.copyWith(enu: enu),
  );
}

abstract class $Bar {
  const $Bar();

  Foo get foo;
  List<Foo> get foos;
  String get driver;
  String? get cache;

  Bar copyWith({Foo? foo, List<Foo>? foos, String? driver, String? cache}) =>
      Bar(foo: foo ?? this.foo, foos: foos ?? this.foos, driver: driver ?? this.driver, cache: cache ?? this.cache);

  @override
  String toString() => "Bar(foo: $foo, foos: $foos, driver: $driver, cache: $cache)";

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is Bar &&
      other.runtimeType == runtimeType &&
      foo == other.foo &&
      const DeepCollectionEquality().equals(foos, other.foos) &&
      const MyEquality<String>().equals(driver, other.driver) &&
      const Ignore().equals(cache, other.cache);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    var result = 17;
    result = 37 * result + foo.hashCode;
    result = 37 * result + const DeepCollectionEquality().hash(foos);
    result = 37 * result + const MyEquality<String>().hash(driver);
    result = 37 * result + const Ignore().hash(cache);
    return result;
  }
}

// ignore: avoid_classes_with_only_static_members
class Bar$ {
  static final foo = Lens<Bar, Foo>(
    (fooContainer) => fooContainer.foo,
    (fooContainer, foo) => fooContainer.copyWith(foo: foo),
  );

  static final foos = Lens<Bar, List<Foo>>(
    (foosContainer) => foosContainer.foos,
    (foosContainer, foos) => foosContainer.copyWith(foos: foos),
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

  Baz copyWith({math.Point? prefixedField}) => Baz(prefixedField: prefixedField ?? this.prefixedField);

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

// ignore: avoid_classes_with_only_static_members
class Baz$ {
  static final prefixedField = Lens<Baz, math.Point>(
    (prefixedFieldContainer) => prefixedFieldContainer.prefixedField,
    (prefixedFieldContainer, prefixedField) => prefixedFieldContainer.copyWith(prefixedField: prefixedField),
  );
}
