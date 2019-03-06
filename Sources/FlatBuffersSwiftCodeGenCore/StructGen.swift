//
//  Struct.swift
//  CodeGen
//
//  Created by Maxim Zaks on 22.07.17.
//  Copyright © 2017 maxim.zaks. All rights reserved.
//

import Foundation

extension Struct {
    var swift: String {
        if fields.isEmpty {fatalError("struct \(name.value) has no fields")}
        for field in fields {
            if field.defaultIdent != nil || field.defaultValue != nil {fatalError("struct \(name.value).\(field.name.value) has a default value")}
            if field.type.string {fatalError("struct \(name.value).\(field.name.value) is a string")}
            if field.type.ref?.value == name.value {fatalError("struct \(name.value).\(field.name.value) is recursive")}
        }
        func genFields(_ fields: [Field]) -> String {
            let fieldStrings = fields.map {
                "    public let \($0.name.value): \($0.type.swift)"
            }
            return fieldStrings.joined(separator: "\n")
        }
        func genEquals(_ fields: [Field], _ typeName: String) -> String {
            let fieldStrings = fields.map {
                return "v1.\($0.name.value)==v2.\($0.name.value)"
            }
            return """
                public static func ==(v1:\(typeName), v2:\(typeName)) -> Bool {
                    return \(fieldStrings.joined(separator: " && "))
                }
            """
        }
        return """
        public struct \(name.value): Scalar {
        \(genFields(fields))
        \(genEquals(fields, name.value))
        }
        """
    }

    func genFromJsonObjectExtension(_ lookup: IdentLookup) -> String {
        if fields.isEmpty {
            return ""
        }

        func genGuardStatement(_ scalar: Type.Scalar, _ name: String) -> String {
            switch scalar {
            case .bool:
                return """
                guard let \(name) = object["\(name)"] as? Bool else { return nil }
                """
            case .f32:
                return """
                guard let \(name)Double = object["\(name)"] as? Double, let \(name) = Optional.some(\(scalar.swift)(\(name)Double)) else { return nil }
                """
            case .f64:
                return """
                guard let \(name) = object["\(name)"] as? Double else { return nil }
                """
            case .i16, .i32, .i64, .i8, .u16, .u32, .u64, .u8:
                return """
                guard let \(name)Int = object["\(name)"] as? Int, let \(name) = \(scalar.swift)(exactly: \(name)Int) else { return nil }
                """
            }
        }

        func genGuardStatements(_ fields: [Field]) -> String {
            var statements = [String]()
            for f in fields {
                if let scalar = f.type.scalar {
                    statements.append("       \(genGuardStatement(scalar, f.fieldName))")
                } else if f.type.isStruct(lookup),
                    let typeName = f.type.ref?.value {
                    statements.append("""
                            guard let \(f.fieldName) = \(typeName).from(jsonObject: object["\(f.fieldName)"] as? [String: Any]) else { return nil }
                    """)
                } else if f.type.isEnum(lookup),
                    let typeName = f.type.ref?.value {
                    statements.append("""
                            guard let \(f.fieldName) = \(typeName).from(jsonValue: object["\(f.fieldName)"]) else { return nil }
                    """)
                }
            }
            return statements.joined(separator: "\n")
        }

        func genInitParamStatements(_ fields: [Field]) -> String {
            var statements = [String]()
            for f in fields {
                statements.append("            \(f.fieldName): \(f.fieldName)")
            }
            return statements.joined(separator: ",\n")
        }

        return """
        extension \(name.value) {
            static func from(jsonObject: [String: Any]?) -> \(name.value)? {
                guard let object = jsonObject else { return nil }
        \(genGuardStatements(fields))
                return \(name.value)(
        \(genInitParamStatements(fields))
                )
            }
        }
        """
    }
}
