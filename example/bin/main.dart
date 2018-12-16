import 'package:collection/collection.dart';
import 'package:functional_data/functional_data.dart';

part 'main.g.dart';

// Only requirement is that it has a constructor with named arguments for all fields
@FunctionalData()
class Foo with $Foo {
  final int number;
  final String name;

  // Can't be const because of mixin
  Foo({this.number, this.name});
}

@FunctionalData()
class Bar with $Bar {
  final Foo foo;

  @CustomEquality(DeepCollectionEquality())
  final List<Foo> foos;

  final String driver;

  Bar({this.foo, this.foos, this.driver});
}

main(List<String> arguments) {
  final foo = Foo(number: 42, name: "Marvin");
  final bar = Bar(foo: foo, foos: [Foo(number: 101, name: "One"), Foo(number: 102, name: "Two")], driver: "One");

  final fooName = Bar$.foo.then(Foo$.name);
  print(fooName.map((name) => name.toUpperCase(), bar));
  // Bar(foo: Foo(number: 42, name: MARVIN), foos: [Foo(number: 101, name: One), Foo(number: 102, name: Two)], driver: One)

  final firstFooName = Bar$.foos.then(List$.atIndex<Foo>(0)).then(Foo$.name);
  print(firstFooName.update(bar, "Twee"));
  // Bar(foo: Foo(number: 42, name: Marvin), foos: [Foo(number: 101, name: Twee), Foo(number: 102, name: Two)], driver: One)

  final fooNamedTwo = Bar$.foos.then(List$.where<Foo>((foo) => foo.name == "Two")).then(Foo$.name);
  print(fooNamedTwo.update(bar, "Due"));
  // Bar(foo: Foo(number: 42, name: Marvin), foos: [Foo(number: 101, name: One), Foo(number: 102, name: Due)], driver: One)

  final driversNumber =
  Bar$.foos.thenWithContext((bar) => List$.where<Foo>((foo) => foo.name == bar.driver).then(Foo$.number));
  print(driversNumber.get(bar));
  // 101
}
