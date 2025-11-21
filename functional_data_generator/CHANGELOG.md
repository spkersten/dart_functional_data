## 2.2.2

- Update analyzer dependency to `^8.0.0`

## 2.2.1

- Update analyzer dependency to `^7.4.0`

## 2.2.0

- Sets Dart SDK constraint to `>=2.19.0 <4.0.0`
- Update analyzer dependency to `>=2.0.0 <7.0.0`

## 2.1.0

- Support for project level configuration. Supported configs:
  -  generateCopyWith
  -  generateCopyUsing
  -  generateLenses

## 2.0.0

- Update to dart 3
- Support for code generation arguments that controls what features are generated
- **[Breaking change]** Generated data class (e.g. `$Foo`) and change class (e.g. `Foo$Change`) are now private.
  - To migrate your code change `class Foo extends $Foo` to `class Foo extends _$Foo`

## 1.1.5

- Update analyzer dependency to >=2.0.0 <6.0.0

## 1.1.4

- Update analyzer dependency to >=2.0.0 <5.0.0

## 1.1.3

- Update analyzer dependency to >=2.0.0 <4.0.0

## 1.1.2

- Fix custom equality object sometimes not constructed with const

## 1.1.1

- Fix order of fields in generated code

## 1.1.0

- Add copyUsing to allow creating a copy where a nullable field is set to null
- Allow positional arguments in the constructor used by copyWith/copyUsing

## 1.0.2

- Fix InconsistentAnalysisException

## 1.0.1

- Updated dependencies
- Improved formatting of generated code for better readability
- Only suppress warnings in generated code where needed

## 1.0.0

- Fix handling of prefixed types
- Don't use dynamic in generated code
- Make generated code support null-safety

## 0.3.7

- Fix handling of prefixed types

## 0.3.6

- Don't use dynamic in generated code

## 0.3.5

- Update analyzer dependency

## 0.3.4

- Update analyzer dependency

## 0.3.3

- Fix bug where question mark would appear in generated code when using certain values
  for CustomEquality

## 0.3.2

- Fix some warnings in generated code

## 0.3.1

- Fix bug where code generation fails for field of Function type

## 0.3.0

- Support for extension methods
- Suppress warnings on generated code

## 0.2.4

- Relax version dependency on analyzer

## 0.2.3

- Support types from prefixed imports

## 0.2.2

- Add link to documentation of `function_data` package in README

## 0.2.1

- Add changelog
- Format code
- Add description

## 0.2.0

- First published version
