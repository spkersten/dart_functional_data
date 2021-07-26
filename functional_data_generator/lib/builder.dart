import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:functional_data/functional_data.dart';
import 'package:source_gen/source_gen.dart';

Builder functionalData(BuilderOptions options) => SharedPartBuilder([FunctionalDataGenerator()], 'functional_data');

class FunctionalDataGenerator extends GeneratorForAnnotation<FunctionalData> {
  @override
  Future<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) =>
      _generateDataType(element, buildStep);
}

String? _getCustomEquality(List<ElementAnnotation> annotations) {
  final annotation = annotations.firstWhereOrNull(
      (a) => a.computeConstantValue()?.type?.getDisplayString(withNullability: false) == 'CustomEquality');
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

Future<String> _generateDataType(Element element, BuildStep buildStep) async {
  if (element is! ClassElement) {
    throw Exception('FunctionalData annotation must only be used on classes');
  }

  final className = element.name.replaceAll('\$', '');

  final classElement = element;

  // The one that can be used to specify every field
  final genericConstructor = classElement.constructors.firstWhere((element) => element.name.isEmpty);
  final positionalFields = genericConstructor.parameters.where((p) => p.isPositional).map((p) => p.name).toList();

  final fieldsWithIndex =
      await Future.wait(classElement.fields.where((f) => !f.isSynthetic && !f.isStatic).map((f) async {
    final declaration = await buildStep.resolver.astNodeFor(f) as VariableDeclaration?;
    final declarationList = declaration?.parent as VariableDeclarationList?;
    final positionalIndex = positionalFields.indexOf(f.name);
    return Pair(
      positionalIndex == -1 ? 9999 : positionalIndex,
      Field(
        f.name,
        declarationList?.type?.toSource() ?? 'dynamic',
        _getCustomEquality(f.metadata),
        isPositional: positionalIndex != -1,
      ),
    );
  }));
  // Using merge sort so the sorting is stable and doesn't change the order of non-positional parameters
  mergeSort<Pair<int, Field>>(fieldsWithIndex, compare: (a, b) => a.first.compareTo(b.first));
  final fields = fieldsWithIndex.map((e) => e.second).toList();

  final fieldDeclarations = fields.map((f) => '${f.type} get ${f.name};');
  final toString =
      '@override\nString toString() => "$className(${fields.map((f) => '${f.name}: \$${f.name}').join(', ')})";';
  final copyWith = '$className copyWith({${fields.map((f) => '${f.optionalType} ${f.name}').join(', ')},\n}) =>\n'
      '$className(${fields.map((f) => '${f.asConstructorParameterLabel}${f.name} ?? this.${f.name}').join(', \n')},\n);';

  final copyUsing = '$className copyUsing(void Function($className\$Change change) mutator) {\n'
      'final change = $className\$Change._(\n'
      '${fields.map((f) => 'this.${f.name},\n').join()}'
      ');\n'
      'mutator(change);\n'
      'return $className(\n'
      '${fields.map((f) => '${f.asConstructorParameterLabel}change.${f.name},\n').join()}'
      ');\n'
      '}';

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

  final lenses = fields.map((f) {
    final name = f.name;
    final type = f.type;
    final containerName = '${f.name}Container';
    return 'static final $name = Lens<$className, $type>(\n'
        '($containerName) => $containerName.$name,\n'
        '($containerName, $name) => $containerName.copyWith($name: $name),\n);\n\n';
  });

  final constructor = 'const \$$className();';

  final dataClass = 'abstract class \$$className {\n'
      '$constructor \n\n ${fieldDeclarations.join()} \n\n $copyWith \n\n $copyUsing \n\n $toString \n\n $equality \n\n $hash\n'
      '}\n\n';

  final changeConstructor = '$className\$Change._(\n${fields.map((f) => 'this.${f.name}').join(',\n')},\n);';
  final changeFieldDeclarations = fields.map((f) => '${f.type} ${f.name};');
  final changeClass = 'class $className\$Change {\n'
      '$changeConstructor\n\n'
      '${changeFieldDeclarations.join('\n')}\n'
      '}\n\n';

  const suppressClassWithStatics = '// ignore: avoid_classes_with_only_static_members';
  final lensesClass = '$suppressClassWithStatics\nclass $className\$ { ${lenses.join()} }\n\n';

  return '$dataClass $changeClass $lensesClass';
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
