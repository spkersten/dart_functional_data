import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:simple_data/simple_data.dart';

part 'lens.g.dart';

// Only requirement is that it has a constructor with named arguments for all fields
@FunctionalData()
class Foo with $Foo {
  final int number;
  final String name;

  // Can't be const because of mixin
  Foo({this.number, this.name});
}

// BUILDER2 WILL GENERATE:
//
//abstract class $Foo {
//  int get number;
//
//  String get name;
//
//  Foo copyWith({int number, String name}) => Foo(number: number ?? this.number, name: name ?? this.name);
//
//  String toString() => "Foo(number: $number, name: $name)";
//
//  bool operator ==(dynamic other) => other.runtimeType == runtimeType && number == other.number && name == other.name;
//
//  @override
//  int get hashCode {
//    var result = 0;
//    result = Jenkins.combine(result, number.hashCode);
//    result = Jenkins.combine(result, name.hashCode);
//    return Jenkins.finish(result);
//  }
//}
//
//class Foo$ {
//  static final number = Lens<Foo, int>((s_) => s_.number, (s_, number) => s_.copyWith(number: number));
//  static final name = Lens<Foo, String>((s_) => s_.name, (s_, name) => s_.copyWith(name: name));
//}

@FunctionalData()
class Bar with $Bar {
  final Foo foo;

  @CustomEquality(DeepCollectionEquality())
  final List<Foo> foos;

  final String driver;

  Bar({this.foo, this.foos, this.driver});
}

class LensExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

    final a = A();
    print("hh: ${a.hashCode}  ${a.copyWith(foo: 55)}");

    return Center(child: Container(child: Text("x")));
  }
}

// ALTERNATIVE FOR BUILDER
//
//@SimpleData()
//abstract class $Foo {
//  int get number;
//
//  String get name;
//
//  const $Foo();
//}
//
//
//@SimpleData()
//abstract class $Bar {
//  $Foo get foo;
//
//  @CustomEquality(DeepCollectionEquality())
//  List<$Foo> get foos;
//
//  String get driver;
//
//  const $Bar();
//}