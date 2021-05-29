// @dart=2.11

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:functional_data/functional_data.dart';
import 'package:source_gen/source_gen.dart';

Builder functionalData(BuilderOptions options) => SharedPartBuilder([FunctionalDataGenerator()], 'functional_data');

class FunctionalDataGenerator extends GeneratorForAnnotation<FunctionalData> {
  @override
  Future<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) =>
      _generateDataType(element);
}

String _getCustomEquality(List<ElementAnnotation> annotations) {
  final annotation = annotations.firstWhere(
      (a) => a.computeConstantValue().type.getDisplayString(withNullability: false) == "CustomEquality",
      orElse: () => null);
  if (annotation != null) {
    final source = annotation.toSource();
    return source.substring("@CustomEquality(".length, source.length - 1).replaceAll('?', '');
  } else
    return null;
}

Future<String> _generateDataType(Element element) async {
  if (element is! ClassElement) throw Exception('FunctionalData annotation must only be used on classes');

  final resolvedLibrary = await element.session.getResolvedLibraryByElement2(element.library) as ResolvedLibraryResult;
  resolvedLibrary.getElementDeclaration(element).node;

  final className = element.name.replaceAll('\$', '');

  final classElement = element as ClassElement;

  final fields = classElement.fields.where((f) => !f.isSynthetic && !f.isStatic).map((f) {
    return Field(
      f.name,
      ((resolvedLibrary.getElementDeclaration(f).node as VariableDeclaration).parent as VariableDeclarationList)
          .type
          .toSource(),
      _getCustomEquality(f.metadata),
    );
  });

  final fieldDeclarations = fields.map((f) => '${f.type} get ${f.name};');
  final toString =
      '@override\nString toString() => "$className(${fields.map((f) => '${f.name}: \$${f.name}').join(', ')})";';
  final copyWith =
      '$className copyWith({${fields.map((f) => '${f.optionalType} ${f.name}').join(', ')}}) => $className(${fields.map((f) => '${f.name}: ${f.name} ?? this.${f.name}').join(', \n')});';

  final suppressMutableClass = '  // ignore: avoid_equals_and_hash_code_on_mutable_classes';
  final equality = '@override\n$suppressMutableClass\nbool operator ==(Object other) => ${([
        'other is $className',
        'other.runtimeType == runtimeType'
      ] + fields.map((f) => '${_generateEquality(f)}').toList()).join(' && \n')};';

  String hashBody;
  if (fields.isEmpty) {
    hashBody = 'return ${className.hashCode};';
  } else if (fields.length == 1) {
    hashBody = 'return ${_generateHash(fields.single)};';
  } else {
    hashBody = 'var result = 17;\n'
        '${fields.map((f) => 'result = 37 * result + ${_generateHash(f)};').join('\n')}\n'
        'return result;';
  }

  final hash = '@override\n$suppressMutableClass\nint get hashCode {\n$hashBody\n}';

  final lenses = fields.map((f) {
    final name = f.name;
    final type = f.type;
    final containerName = '${f.name}Container';
    return 'static final $name = Lens<$className, $type>(\n'
        '($containerName) => $containerName.$name,\n'
        '($containerName, $name) => $containerName.copyWith($name: $name),\n);\n\n';
  });

  final constructor = 'const \$$className();';

  final dataClass =
      'abstract class \$$className { $constructor \n\n ${fieldDeclarations.join()} \n\n $copyWith \n\n $toString \n\n $equality \n\n $hash }\n\n';

  const suppressClassWithStatics = '// ignore: avoid_classes_with_only_static_members';
  final lensesClass = '$suppressClassWithStatics\nclass $className\$ { ${lenses.join()} }\n\n';

  return '$dataClass $lensesClass';
}

String _generateEquality(Field f) {
  if (f.customEquality != null) {
    return '${f.customEquality}.equals(${f.name}, other.${f.name})';
  } else {
    return '${f.name} == other.${f.name}';
  }
}

String _generateHash(Field f) {
  if (f.customEquality != null) {
    return '${f.customEquality}.hash(${f.name})';
  } else {
    return '${f.name}.hashCode';
  }
}

class Field {
  final String name;
  final String type;

  String get optionalType => type[type.length - 1] == '?' ? type : "$type?";
  final String customEquality;

  const Field(this.name, this.type, this.customEquality);
}
