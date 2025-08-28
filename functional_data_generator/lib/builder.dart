import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:functional_data/functional_data.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

Builder functionalData(BuilderOptions options) => SharedPartBuilder([FunctionalDataGenerator()], 'functional_data');

class FunctionalDataGenerator extends GeneratorForAnnotation<FunctionalData> {
  @override
  Future<String> generateForAnnotatedElement(Element2 element, ConstantReader annotation, BuildStep buildStep) =>
      _generateDataType(element, annotation, buildStep);
}

String? _getCustomEquality(List<ElementAnnotation> annotations) {
  final annotation =
      annotations.firstWhereOrNull((a) => a.computeConstantValue()?.type?.getDisplayString() == 'CustomEquality');
  if (annotation != null) {
    final source = annotation.toSource();
    final customEquality = source.substring('@CustomEquality('.length, source.length - 1).replaceAll('?', '');
    if (!customEquality.startsWith('const ')) {
      return 'const $customEquality';
    } else {
      return customEquality;
    }
  } else {
    return null;
  }
}

class Pair<T, S> {
  Pair(this.first, this.second);

  final T first;
  final S second;
}

Future<String> _generateDataType(Element2 element, ConstantReader annotation, BuildStep buildStep) async {
  if (element is! ClassElement2) {
    throw Exception('FunctionalData annotation must only be used on classes');
  }

  final generateLensesParam = annotation.peek('generateLenses')?.literalValue as bool?;
  final generateCopyParam = annotation.peek('generateCopy')?.literalValue as bool?;
  final generateCopyWithParam = annotation.peek('generateCopyWith')?.literalValue as bool?;
  final generateCopyUsingParam = annotation.peek('generateCopyUsing')?.literalValue as bool?;

  if (generateCopyParam != null && (generateCopyWithParam != null || generateCopyUsingParam != null)) {
    throw Exception('[$element]: generateCopy cannot be defined if generateCopyWith or generateCopyUsing are defined');
  }

  final projectOptions = _loadProjectOptions();

  final generateLenses = generateLensesParam ?? projectOptions.generateLenses ?? true;
  final generateCopyWith = generateCopyParam ?? generateCopyWithParam ?? projectOptions.generateCopyWith ?? true;
  final generateCopyUsing = generateCopyParam ?? generateCopyUsingParam ?? projectOptions.generateCopyUsing ?? true;

  if (generateLenses && !generateCopyWith) {
    throw Exception('[$element]: generateLenses requires copyWith to be generated');
  }

  final className = (element.name3 ?? '').replaceAll('\$', '');

  final classElement = element;

  // The one that can be used to specify every field
  final genericConstructor = classElement.constructors2.firstWhere((element) => element.name3 == 'new');
  final positionalFields =
      genericConstructor.formalParameters.where((p) => p.isPositional).map((p) => p.name3).toList();

  final fieldsWithIndex =
      await Future.wait(classElement.fields2.where((f) => !f.isSynthetic && !f.isStatic).map((f) async {
    final declaration = await buildStep.resolver.astNodeFor(f.firstFragment) as VariableDeclaration?;
    final declarationList = declaration?.parent as VariableDeclarationList?;
    final positionalIndex = positionalFields.indexOf(f.name3);
    return Pair(
      positionalIndex == -1 ? 9999 : positionalIndex,
      Field(
        f.name3 ?? '',
        declarationList?.type?.toSource() ?? 'dynamic',
        _getCustomEquality(f.metadata2.annotations),
        isPositional: positionalIndex != -1,
      ),
    );
  }));
  // Using merge sort so the sorting is stable and doesn't change the order of non-positional parameters
  mergeSort<Pair<int, Field>>(fieldsWithIndex, compare: (a, b) => a.first.compareTo(b.first));
  final fields = fieldsWithIndex.map((e) => e.second).toList();

  final generatedClasses = [
    _generateDataClass(className, fields, generateCopyWith, generateCopyUsing),
    if (generateCopyUsing) _generateChangeClass(className, fields),
    if (generateLenses) _generateLenses(className, fields),
  ];

  return generatedClasses.join(' ');
}

_ProjectOptions _loadProjectOptions() {
  final optionsFile = File('functional_data_options.yaml');
  final yaml = (optionsFile.existsSync()) ? loadYaml(optionsFile.readAsStringSync()) : null;
  if (yaml is YamlMap) {
    return _ProjectOptions.fromYamlMap(yaml);
  } else {
    return const _ProjectOptions();
  }
}

String _generateDataClass(String className, List<Field> fields, bool generateCopyWith, bool generateCopyUsing) {
  final constructor = 'const _\$$className();';

  final fieldDeclarations = fields.map((f) => '${f.type} get ${f.name};');

  final copyWith = '$className copyWith({${fields.map((f) => '${f.optionalType} ${f.name}').join(', ')},\n}) =>\n'
      '$className(${fields.map((f) => '${f.asConstructorParameterLabel}${f.name} ?? this.${f.name}').join(', \n')},\n);';

  final copyUsing = '$className copyUsing(void Function(_$className\$Change change) mutator) {\n'
      'final change = _$className\$Change._(\n'
      '${fields.map((f) => 'this.${f.name},\n').join()}'
      ');\n'
      'mutator(change);\n'
      'return $className(\n'
      '${fields.map((f) => '${f.asConstructorParameterLabel}change.${f.name},\n').join()}'
      ');\n'
      '}';

  final toString =
      '@override\nString toString() => "$className(${fields.map((f) => '${f.name}: \$${f.name}').join(', ')})";';

  const suppressMutableClass = '  // ignore: avoid_equals_and_hash_code_on_mutable_classes';
  final equality = '@override\n$suppressMutableClass\nbool operator ==(Object other) => ${([
        'other is $className',
        'other.runtimeType == runtimeType'
      ] + fields.map(_generateEquality).toList()).join(' && \n')};';

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

  final body = [
    constructor,
    fieldDeclarations.join(),
    if (generateCopyWith) copyWith,
    if (generateCopyUsing) copyUsing,
    toString,
    equality,
    hash,
  ];

  final dataClass = 'abstract class _\$$className {\n'
      '${body.join(' \n\n ')}\n'
      '}\n\n';
  return dataClass;
}

String _generateChangeClass(String className, List<Field> fields) {
  final changeConstructor = '_$className\$Change._(\n${fields.map((f) => 'this.${f.name}').join(',\n')},\n);';
  final changeFieldDeclarations = fields.map((f) => '${f.type} ${f.name};');
  final changeClass = 'class _$className\$Change {\n'
      '$changeConstructor\n\n'
      '${changeFieldDeclarations.join('\n')}\n'
      '}\n\n';
  return changeClass;
}

String _generateLenses(String className, List<Field> fields) {
  const suppressClassWithStatics = '// ignore: avoid_classes_with_only_static_members';

  final lenses = fields.map((f) {
    final name = f.name;
    final type = f.type;
    final containerName = '${f.name}Container';
    return 'static final $name = Lens<$className, $type>(\n'
        '($containerName) => $containerName.$name,\n'
        '($containerName, $name) => $containerName.copyWith($name: $name),\n);\n\n';
  });
  final lensesClass = '$suppressClassWithStatics\nclass $className\$ { ${lenses.join()} }\n\n';
  return lensesClass;
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

class _ProjectOptions {
  const _ProjectOptions({
    this.generateCopyWith,
    this.generateCopyUsing,
    this.generateLenses,
  }) : assert(
          !(generateLenses == true && generateCopyWith == false),
          'generateLenses requires copyWith to be generated',
        );

  factory _ProjectOptions.fromYamlMap(YamlNode yaml) => (yaml is YamlMap)
      ? _ProjectOptions(
          generateCopyWith: _getBool(yaml['generateCopyWith']),
          generateCopyUsing: _getBool(yaml['generateCopyUsing']),
          generateLenses: _getBool(yaml['generateLenses']),
        )
      : const _ProjectOptions();

  final bool? generateCopyWith;
  final bool? generateCopyUsing;
  final bool? generateLenses;
}

bool? _getBool(Object? value) {
  if (value == null || value is! bool) {
    return null;
  }

  return value;
}

class Field {
  const Field(this.name, this.type, this.customEquality, {required this.isPositional});

  final String name;
  final String type;
  final bool isPositional;

  String get optionalType => type[type.length - 1] == '?' ? type : '$type?';
  final String? customEquality;
}

extension AsConstructorParameter on Field {
  String get asConstructorParameterLabel => isPositional ? '' : '$name: ';
}
