## 1.2.0

- Sets Dart SDK constraint to `>=2.19.0 <4.0.0`

## 1.1.1

- Relaxed annotation assert so it does not assume that generateLenses being null is the same as being true.
This is required if the generator wants to pick different defaults, e.g. from project configuration.

## 1.1.0

- Update to dart 3
- Add code generation arguments to control what features will be generated
  -  generateCopy
  -  generateCopyWith
  -  generateCopyUsing
  -  generateLenses

## 1.0.0

- Make lenses null-safe

## 0.3.0

- Use Optional form plain_optional
- Fix bug where List$.whereOptional lens would return null

## 0.2.2

- Add instructions for using functional data in README

## 0.2.1

- Add changelog
- Format code
- Add description

## 0.2.0

- First published version
