//
//  StructGenTest.swift
//  FlatBuffersSwiftCodeGenTests
//
//  Created by Maxim Zaks on 05.03.19.
//

import Foundation
import XCTest
@testable import FlatBuffersSwiftCodeGenCore

class StructGenTests: XCTestCase {
    let s: StaticString = """
struct S1 {
    i: int;
    b: bool;
    d: double;
    i8: byte;
    u8: ubyte;
    i16: short;
    u16: ushort;
    u32: uint;
    f32: float;
    i64: long;
    u64: ulong;
}

struct S2 {
    s: S1;
    e: E;
}

enum E: byte {A, B}
"""

    func testStructFromJsonObjectScalarasOnly() {
        let expected = """
extension S1 {
    static func from(jsonObject: [String: Any]?) -> S1? {
        guard let object = jsonObject else { return nil }
       guard let iInt = object["i"] as? Int, let i = Int32(exactly: iInt) else { return nil }
       guard let b = object["b"] as? Bool else { return nil }
       guard let d = object["d"] as? Double else { return nil }
       guard let i8Int = object["i8"] as? Int, let i8 = Int8(exactly: i8Int) else { return nil }
       guard let u8Int = object["u8"] as? Int, let u8 = UInt8(exactly: u8Int) else { return nil }
       guard let i16Int = object["i16"] as? Int, let i16 = Int16(exactly: i16Int) else { return nil }
       guard let u16Int = object["u16"] as? Int, let u16 = UInt16(exactly: u16Int) else { return nil }
       guard let u32Int = object["u32"] as? Int, let u32 = UInt32(exactly: u32Int) else { return nil }
       guard let f32Double = object["f32"] as? Double, let f32 = Optional.some(Float32(f32Double)) else { return nil }
       guard let i64Int = object["i64"] as? Int, let i64 = Int64(exactly: i64Int) else { return nil }
       guard let u64Int = object["u64"] as? Int, let u64 = UInt64(exactly: u64Int) else { return nil }
        return S1(
            i: i,
            b: b,
            d: d,
            i8: i8,
            u8: u8,
            i16: i16,
            u16: u16,
            u32: u32,
            f32: f32,
            i64: i64,
            u64: u64
        )
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let s1 = lookup?.structs["S1"]
        let result = s1?.genFromJsonObjectExtension(lookup!)
        XCTAssertEqual(expected, result!)
    }

    func testStructFromJsonObjectWithEmbeddedStruct() {
        let expected = """
extension S2 {
    static func from(jsonObject: [String: Any]?) -> S2? {
        guard let object = jsonObject else { return nil }
        guard let s = S1.from(jsonObject: object["s"] as? [String: Any]) else { return nil }
        guard let e = E.from(jsonValue: object["e"]) else { return nil }
        return S2(
            s: s,
            e: e
        )
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let s1 = lookup?.structs["S2"]
        let result = s1?.genFromJsonObjectExtension(lookup!)
        XCTAssertEqual(expected, result!)
    }


    static var allTests = [
        ("testProtocolReaderExtension", testStructFromJsonObjectScalarasOnly),
        ("testStructFromJsonObjectWithEmbeddedStruct", testStructFromJsonObjectWithEmbeddedStruct)
    ]
}

