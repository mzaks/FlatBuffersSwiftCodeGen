# FlatBuffersSwiftCodeGen

FlatBuffersSwiftCodeGen is a code generator for FlatBuffersSwift (https://github.com/mzaks/FlatBuffersSwift)

## Arguments description:
- First argument is the path to `.fbs` file
- Second argument is the path to `.swift` file you want to generate
- Third argument is optional, it can be `download` which will avoid `import FlatBuffersSwift` statement in generated file and  download _FlatBuffersSwift_ infrastructure files. Or you can tell the generator to just avoid `import FlatBuffersSwift` statement by writing `noImport` as third argument

## Example usage:
`fbsCG contacts.fbs contacts.swift`
