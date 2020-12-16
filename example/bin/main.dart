import 'package:collection/collection.dart';
import 'package:functional_data/functional_data.dart';
import 'dart:math' as math;

part 'main.g.dart';

enum Enum { a, b }

extension EnumPlus on Enum {
  String someText() => "text";
}

// Only requirement is that it has a constructor with named arguments for all fields
@FunctionalData()
class Foo extends $Foo {
  final int number;
  final String name;
  final Enum? enu;

  String get displayString => "$name[$number]";

  const Foo({required this.number, this.name = "default", this.enu});
}

class MyEquality<T> implements Equality {
  const MyEquality();

  @override
  bool equals(e1, e2) => true;

  @override
  int hash(e) => 0;

  @override
  bool isValidKey(Object? o) => true;
}

@FunctionalData()
class Bar extends $Bar {
  final Foo foo;

  static const int constant = 5;

  @CustomEquality(DeepCollectionEquality())
  final List<Foo> foos;

  @CustomEquality(MyEquality<String>())
  final String driver;

  @CustomEquality(Ignore())
  final String? cache;

  const Bar({required this.foo, required this.foos, required this.driver, this.cache = null});
}

@FunctionalData()
class Baz extends $Baz {
  final math.Point prefixedField;

  const Baz({required this.prefixedField});
}

main(List<String> arguments) {
  final foo = Foo(number: 42, name: "Marvin");
  final bar = Bar(foo: foo, foos: [Foo(number: 101, name: "One"), Foo(number: 102, name: "Two")], driver: "One");

  final fooName = Bar$.foo.then(Foo$.name);
  // print(fooName.map((name) => name.toUpperCase(), bar));
  print(fooName.of(bar).map((name) => name.toUpperCase()));
  // Bar(foo: Foo(number: 42, name: MARVIN), foos: [Foo(number: 101, name: One), Foo(number: 102, name: Two)], driver: One)

  final firstFooName = Bar$.foos.then(List$.atIndex<Foo>(0)).then(Foo$.name);
  // print(firstFooName.update(bar, "Twee"));
  print(firstFooName.of(bar).update("Twee"));
  // Bar(foo: Foo(number: 42, name: Marvin), foos: [Foo(number: 101, name: Twee), Foo(number: 102, name: Two)], driver: One)

  final nameOfFooNamedTwo = Bar$.foos.then(List$.where<Foo>((foo) => foo.name == "Two")).then(Foo$.name);
  print(nameOfFooNamedTwo.update(bar, "Due"));
  // Bar(foo: Foo(number: 42, name: Marvin), foos: [Foo(number: 101, name: One), Foo(number: 102, name: Due)], driver: One)

  final driversNumber =
      Bar$.foos.thenWithContext((bar) => List$.where<Foo>((foo) => foo.name == bar.driver).then(Foo$.number));
  print(driversNumber.of(bar).value);
  // 101
}
