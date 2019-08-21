import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:functional_data/functional_data.dart';

Builder functionalData(BuilderOptions options) =>
    new SharedPartBuilder([new FunctionalDataGenerator()], 'functional_data');

class FunctionalDataGenerator extends GeneratorForAnnotation<FunctionalData> {
  @override
  generateForAnnotatedElement(
          Element element, ConstantReader annotation, BuildStep buildStep) =>
      _generateDataType(element);
}

bool elementHasMetaAnnotation(Element e) =>
    e.metadata.any(isSimpleDataAnnotation);

bool isSimpleDataAnnotation(ElementAnnotation a) =>
    a.computeConstantValue().type.name.toString() == "FunctionalData";

class CustomEquality {
  final Equality equality;

  const CustomEquality(this.equality);
}

String _getCustomEquality(List<ElementAnnotation> annotations) {
  final annotation = annotations.firstWhere(
      (a) => a.computeConstantValue().type.name == "CustomEquality",
      orElse: () => null);
  if (annotation != null) {
    final source = annotation.toSource();
    return source.substring("@CustomEquality(".length, source.length - 1);
  } else
    return null;
}

String _generateDataType(Element element) {
  if (element is! ClassElement)
    throw new Exception(
        'FunctionalData annotation must only be used on classes');

  final className = element.name.replaceAll('\$', '');

  final classElement = element as ClassElement;

  final fields =
      classElement.fields.where((f) => !f.isSynthetic && !f.isStatic).map((f) {
    return Field(
        f.name, _typeAsCode(_findTypeNode(f)), _getCustomEquality(f.metadata));
  });

  final fieldDeclarations = fields.map((f) => '${f.type} get ${f.name};');
  final toString =
      'String toString() => "$className(${fields.map((f) => '${f.name}: \$${f.name}').join(', ')})";';
  final copyWith =
      '$className copyWith({${fields.map((f) => '${f.type} ${f.name}').join(', ')}}) => $className(${fields.map((f) => '${f.name}: ${f.name} ?? this.${f.name}').join(', ')});';

  final equality = 'bool operator ==(dynamic other) => ${([
        'other.runtimeType == runtimeType'
      ] + fields.map((f) => '${_generateEquality(f)}').toList()).join(' && ')};';

  final hash =
      '@override int get hashCode { var result = 17; ${fields.map((f) => 'result = 37 * result + ${_generateHash(f)};').join()} return result; }';

  final lenses = fields.map((f) {
    final name = f.name;
    final type = f.type;
    return 'static final $name = Lens<$className, $type>((s_) => s_.$name, (s_, $name) => s_.copyWith($name: $name));';
  });

  final constructor = 'const \$$className();';

  final dataClass =
      'abstract class \$$className { ${fieldDeclarations.join()} $constructor $copyWith $toString $equality $hash }';
  final lensesClass = 'class $className\$ { ${lenses.join()} }';

  return '$dataClass $lensesClass';
}

TypeAnnotation _findTypeNode(FieldElement element) {
  final parsedLibrary =
      element.session.getParsedLibraryByElement(element.library);
  final declaration = parsedLibrary.getElementDeclaration(element);
  return ((declaration.node as VariableDeclaration).parent
          as VariableDeclarationList)
      .type;
}

String _typeAsCode(TypeAnnotation type) {
  if (type == null) {
    return 'dynamic';
  }
  return type.toString();
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
  final String customEquality;

  const Field(this.name, this.type, this.customEquality);
}
