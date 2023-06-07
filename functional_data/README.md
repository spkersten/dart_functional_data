# functional_data

Simple and non-intrusive code generator for boilerplate of data types. The package generates a simple mixin with
`operator==`, `hashCode`, `copyWith`, `toString`, as well as lenses.

## Boiler plate

Because the boiler plate is generated as a mixin, it is minimally intrusive on the interface of the class. You
only have to provide a constructor with named arguments for all fields and extend the generated mixin.

```dart
@FunctionalData()
class Person extends _$Person {
  final String name;
  final int age;

  const Person({this.name, this.age});

  const Person.anonymous() : this(name: "John Doe", age: null);

  int get ageInDays => 356 * age;
}
```

Because of this design, you have complete control over the class. You can, for example, add named constructors
or methods to the class like you're used to.

## Using

To use functional_data, add the following dependencies to your package:

```yaml
dependencies:
  functional_data:

dev_dependencies:
  build_runner:
  functional_data_generator:
```

And run `flutter packages pub run build_runner build lib` to generate code.

## Lenses

For every class, lenses are generated for all fields which allow viewing a field or creating a new
instance of the classes with that field modified in some way. For example, the lens of `Person`'s `name` is
`Person$.name`. To focus a lens on a specific instance use its `of` method:

```dart
final teacher = Person(name: "Arthur", age: 53);

print(Person$.name.of(teacher).value);
// -> "Arthur"

print(Person$.age.of(teacher).update(60);
// -> Person(name: "Arthur", age: 60)

print(Person$.name.of(teacher).map((name) => name.toUpperCase()));
// -> Person(name: "ARTHUR", age: 53)
```

This isn't very exciting yet. The power of lenses comes to light when you combine them. It allows you to easily
create a copy of a large nested data structure with one of the fields in a leaf modified. Two lenses can be chained
using `then`.

```dart
class Course extends _$Course {
  final String name;
  final List<Person> students;

  const Course({this.students});
}

final programming = Course(name: "Programming 101", students: [Person(name: "Jane", age: 21), Person(name: "Tom", age: 20)]);

final firstStudentsName = Course$.students.then(List$.first<Person>()).then(Person$.name);

print(firstStudentsName.of(programming).update("Marcy"));
// -> Course(students: [Person(name: "Marcy", age: 21), Person(name: "Tom", age: 20)]
```

Compare this with the alternative:

```dart
final firstStudent = programming.students.first;
final updatedFirstStudent = Person(name: "Marcy", age: firstStudent.age);
final updatedStudents = [updatedFirstStudent] + programming.students.skip(1);
final updatedCourse = Course(name: programming.name, students: updatedStudents);
```

This is much less readable and error prone. Imagine what happens when one of the classes gains a field.

### Class level configuration

To specify which features should be generated for the class, you can send arguments to `@FunctionalData` generator.

Example:
```dart
@FunctionalData(
  generateCopy: false,
  generateLenses: false,
)
class Foo extends _$Foo {}
```

### Project level configuration

To specify which features should be generated for you whole project, create a file called `functional_data_options.yaml`
in the root of your project.
Class specific arguments will override the project level configuration.

Example with all possible configurations:
```yaml
generateCopyWith: false
generateCopyUsing: false
generateLenses: false
```

### Full example:

```dart
// lens.dart
import 'package:collection/collection.dart';

import 'package:functional_data/functional_data.dart';

part 'lens.g.dart';

// Only requirement is that it has a constructor with named arguments for all fields
@FunctionalData()
class Foo extends _$Foo {
  final int number;
  final String name;

  const Foo({this.number, this.name});
}

@FunctionalData()
class Bar extends _$Bar {
  final Foo foo;

  @CustomEquality(DeepCollectionEquality())
  final List<Foo> foos;

  final String driver;

  const Bar({this.foo, this.foos, this.driver});
}

void main() {
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
```
