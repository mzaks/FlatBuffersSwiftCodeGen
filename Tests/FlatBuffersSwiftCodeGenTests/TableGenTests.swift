//
//  TableGenTests.swift
//  CodeGenTests
//
//  Created by Maxim Zaks on 22.07.17.
//  Copyright © 2017 maxim.zaks. All rights reserved.
//

import Foundation
import XCTest
@testable import FlatBuffersSwiftCodeGenCore

class TableGenTests: XCTestCase {
    let s: StaticString = """
struct S1 {
    a: bool;
}
table T0 {
    a: string;
}
enum E: byte {A, B}
union U1 {T0, T1}
table T1 {
    i: int;
    b: bool;
    d: double (deprecated);
    bs: [bool];
    name: string;
    names: [string];
    _self: T0;
    selfs: [T0];
    s: S1;
    s_s: [S1];
    e: E;
    es: [E];
    u: U1;
}
"""
    
    func testProtocolReaderExtension() {
        let expected = """
extension T1.Direct {
    public init?<R : FlatBuffersReader>(reader: R, myOffset: Offset? = nil) {
        guard let reader = reader as? T else {
            return nil
        }
        self._reader = reader
        if let myOffset = myOffset {
            self._myOffset = myOffset
        } else {
            if let rootOffset = reader.rootObjectOffset {
                self._myOffset = rootOffset
            } else {
                return nil
            }
        }
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_myOffset)
    }
    public static func ==(t1 : T1.Direct<T>, t2 : T1.Direct<T>) -> Bool {
        return t1._reader.isEqual(other: t2._reader) && t1._myOffset == t2._myOffset
    }
    public var i: Int32 {

        return _reader.get(objectOffset: _myOffset, propertyIndex: 0, defaultValue: 0)
    }
    public var b: Bool {

        return _reader.get(objectOffset: _myOffset, propertyIndex: 1, defaultValue: false)
    }
    public var __d: Float64 {

        return _reader.get(objectOffset: _myOffset, propertyIndex: 2, defaultValue: 0)
    }
    public var bs: FlatBuffersScalarVector<Bool, T> {

        return FlatBuffersScalarVector(reader: _reader, myOffset: _reader.offset(objectOffset: _myOffset, propertyIndex:3))
    }
    public var name: Data? {
        guard let offset = _reader.offset(objectOffset: _myOffset, propertyIndex:4) else {return nil}
        return _reader.stringBuffer(stringOffset: offset)
    }
    public var names: FlatBuffersStringVector<T> {

        return FlatBuffersStringVector(reader: _reader, myOffset: _reader.offset(objectOffset: _myOffset, propertyIndex:5))
    }
    public var _self: T0.Direct<T>? {
        guard let offset = _reader.offset(objectOffset: _myOffset, propertyIndex:6) else {return nil}
        return T0.Direct(reader: _reader, myOffset: offset)
    }
    public var selfs: FlatBuffersTableVector<T0.Direct<T>, T> {

        return FlatBuffersTableVector(reader: _reader, myOffset: _reader.offset(objectOffset: _myOffset, propertyIndex:7))
    }
    public var s: S1? {

        return _reader.get(objectOffset: _myOffset, propertyIndex: 8)
    }
    public var s_s: FlatBuffersScalarVector<S1, T> {

        return FlatBuffersScalarVector(reader: _reader, myOffset: _reader.offset(objectOffset: _myOffset, propertyIndex:9))
    }
    public var e: E? {

        return E(rawValue:_reader.get(objectOffset: _myOffset, propertyIndex: 10, defaultValue: E.A.rawValue))
    }
    public var es: FlatBuffersEnumVector<Int8, T, E> {

        return FlatBuffersEnumVector(reader: _reader, myOffset: _reader.offset(objectOffset: _myOffset, propertyIndex:11))
    }
    public var u: U1.Direct<T>? {

        return U1.Direct.from(reader: _reader, propertyIndex : 12, objectOffset : _myOffset)
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let table = lookup?.tables["T1"]
        let result = table?.readerProtocolExtension(lookup: lookup!)
        XCTAssertEqual(expected, result!)
    }
    
    func testProtocolReaderExtensionWithExplicitIndex() {
        let s: StaticString = """
table T1 {
    i: int (id: 1);
    b: bool (id: 0);
    d: double (id: 2, deprecated);
}
"""
        let expected = """
extension T1.Direct {
    public init?<R : FlatBuffersReader>(reader: R, myOffset: Offset? = nil) {
        guard let reader = reader as? T else {
            return nil
        }
        self._reader = reader
        if let myOffset = myOffset {
            self._myOffset = myOffset
        } else {
            if let rootOffset = reader.rootObjectOffset {
                self._myOffset = rootOffset
            } else {
                return nil
            }
        }
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_myOffset)
    }
    public static func ==(t1 : T1.Direct<T>, t2 : T1.Direct<T>) -> Bool {
        return t1._reader.isEqual(other: t2._reader) && t1._myOffset == t2._myOffset
    }
    public var b: Bool {

        return _reader.get(objectOffset: _myOffset, propertyIndex: 0, defaultValue: false)
    }
    public var i: Int32 {

        return _reader.get(objectOffset: _myOffset, propertyIndex: 1, defaultValue: 0)
    }
    public var __d: Float64 {

        return _reader.get(objectOffset: _myOffset, propertyIndex: 2, defaultValue: 0)
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let table = lookup?.tables["T1"]
        let result = table?.readerProtocolExtension(lookup: lookup!)
        print(result!)
        XCTAssertEqual(expected, result)
    }
    
    func testSwiftClass() {
        let expected = """
public final class T1 {
    public var i: Int32
    public var b: Bool
    public var __d: Float64
    public var bs: [Bool]
    public var name: String?
    public var names: [String]
    public var _self: T0?
    public var selfs: [T0]
    public var s: S1?
    public var s_s: [S1]
    public var e: E?
    public var es: [E]
    public var u: U1?
    public init(i: Int32 = 0, b: Bool = false, __d: Float64 = 0, bs: [Bool] = [], name: String? = nil, names: [String] = [], _self: T0? = nil, selfs: [T0] = [], s: S1? = nil, s_s: [S1] = [], e: E? = E.A, es: [E] = [], u: U1? = nil) {
        self.i = i
        self.b = b
        self.__d = __d
        self.bs = bs
        self.name = name
        self.names = names
        self._self = _self
        self.selfs = selfs
        self.s = s
        self.s_s = s_s
        self.e = e
        self.es = es
        self.u = u
    }
    public struct Direct<T : FlatBuffersReader> : Hashable, FlatBuffersDirectAccess {
        fileprivate let _reader : T
        fileprivate let _myOffset : Offset
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let table = lookup?.tables["T1"]
        let result = table?.swiftClass(lookup: lookup!)
        print(result!)
        XCTAssertEqual(expected, result)
    }
    
    func testFromData() {
        let expected = """
extension T1 {
    public static func from(data: Data) -> T1? {
        let reader = FlatBuffersMemoryReader(data: data, withoutCopy: false)
        return T1.from(selfReader: Direct<FlatBuffersMemoryReader>(reader: reader))
    }
    fileprivate static func from(selfReader: Direct<FlatBuffersMemoryReader>?) -> T1? {
        guard let selfReader = selfReader else {
            return nil
        }
        if let o = selfReader._reader.cache?.objectPool[selfReader._myOffset] as? T1 {
            return o
        }
        let o = T1()
        selfReader._reader.cache?.objectPool[selfReader._myOffset] = o
        o.i = selfReader.i
        o.b = selfReader.b
        o.__d = selfReader.__d
        o.bs = selfReader.bs.compactMap{$0}
        o.name = selfReader.name§
        o.names = selfReader.names.compactMap{ $0§ }
        o._self = T0.from(selfReader:selfReader._self)
        o.selfs = selfReader.selfs.compactMap{ T0.from(selfReader:$0) }
        o.s = selfReader.s
        o.s_s = selfReader.s_s.compactMap{$0}
        o.e = selfReader.e
        o.es = selfReader.es.compactMap{$0}
        o.u = U1.from(selfReader: selfReader.u)

        return o
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let table = lookup?.tables["T1"]
        let result = table?.fromDataExtenstion(lookup: lookup!, isRoot: true)
        print(result!)
        XCTAssertEqual(expected, result)
    }
    
    func testInsertExtension() {
        let expected = """
extension FlatBuffersBuilder {
    public func insertT1(i: Int32 = 0, b: Bool = false, bs: Offset? = nil, name: Offset? = nil, names: Offset? = nil, _self: Offset? = nil, selfs: Offset? = nil, s: S1? = nil, s_s: Offset? = nil, e: E = E.A, es: Offset? = nil, u_type: Int8 = 0, u: Offset? = nil) throws -> (Offset, [Int?]) {
        var valueCursors = [Int?](repeating: nil, count: 14)
        try self.startObject(withPropertyCount: 14)
        valueCursors[1] = try self.insert(value: b, defaultValue: false, toStartedObjectAt: 1)
        if let s = s {
            self.insert(value: s)
            valueCursors[8] = try self.insertCurrentOffsetAsProperty(toStartedObjectAt: 8)
        }
        valueCursors[10] = try self.insert(value: e.rawValue, defaultValue: E.A.rawValue, toStartedObjectAt: 10)
        valueCursors[12] = try self.insert(value: u_type, defaultValue: 0, toStartedObjectAt: 12)
        valueCursors[0] = try self.insert(value: i, defaultValue: 0, toStartedObjectAt: 0)
        if let bs = bs {
            valueCursors[3] = try self.insert(offset: bs, toStartedObjectAt: 3)
        }
        if let name = name {
            valueCursors[4] = try self.insert(offset: name, toStartedObjectAt: 4)
        }
        if let names = names {
            valueCursors[5] = try self.insert(offset: names, toStartedObjectAt: 5)
        }
        if let _self = _self {
            valueCursors[6] = try self.insert(offset: _self, toStartedObjectAt: 6)
        }
        if let selfs = selfs {
            valueCursors[7] = try self.insert(offset: selfs, toStartedObjectAt: 7)
        }
        if let s_s = s_s {
            valueCursors[9] = try self.insert(offset: s_s, toStartedObjectAt: 9)
        }
        if let es = es {
            valueCursors[11] = try self.insert(offset: es, toStartedObjectAt: 11)
        }
        if let u = u {
            valueCursors[13] = try self.insert(offset: u, toStartedObjectAt: 13)
        }
        return try (self.endObject(), valueCursors)
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let table = lookup?.tables["T1"]
        let result = table?.insertExtenstion(lookup: lookup!)
        print(result!)
        XCTAssertEqual(expected, result)
    }
    
    func testInsertMethod() {
        let expected = """
extension T1 {
    func insert(_ builder : FlatBuffersBuilder) throws -> Offset {
        if builder.options.uniqueTables {
            if let myOffset = builder.cache[ObjectIdentifier(self)] {
                return myOffset
            }
        }
        if builder.inProgress.contains(ObjectIdentifier(self)){
            return 0
        }
        builder.inProgress.insert(ObjectIdentifier(self))
        let bs: Offset?
        if self.bs.isEmpty {
            bs = nil
        } else {
            try builder.startVector(count: self.bs.count, elementSize: MemoryLayout<Bool>.stride)
            for o in self.bs.reversed() {
                builder.insert(value: o)
            }
            bs = builder.endVector()
        }
        let name = self.name == nil ? nil : try builder.insert(value: self.name)
        let names: Offset?
        if self.names.isEmpty {
            names = nil
        } else {
            let offsets = try self.names.reversed().map{ try builder.insert(value: $0) }
            try builder.startVector(count: self.names.count, elementSize: MemoryLayout<Offset>.stride)
            for (_, o) in offsets.enumerated() {
                try builder.insert(offset: o)
            }
            names = builder.endVector()
        }
        let _self = try self._self?.insert(builder)
        let selfs: Offset?
        if self.selfs.isEmpty {
            selfs = nil
        } else {
            let offsets = try self.selfs.reversed().map{ try $0.insert(builder) }
            try builder.startVector(count: self.selfs.count, elementSize: MemoryLayout<Offset>.stride)
            for (_, o) in offsets.enumerated() {
                try builder.insert(offset: o)
            }
            selfs = builder.endVector()
        }
        let s_s: Offset?
        if self.s_s.isEmpty {
            s_s = nil
        } else {
            try builder.startVector(count: self.s_s.count, elementSize: MemoryLayout<S1>.stride)
            for o in self.s_s.reversed() {
                builder.insert(value: o)
            }
            s_s = builder.endVector()
        }
        let es: Offset?
        if self.es.isEmpty {
            es = nil
        } else {
            try builder.startVector(count: self.es.count, elementSize: MemoryLayout<E>.stride)
            for o in self.es.reversed() {
                builder.insert(value: o.rawValue)
            }
            es = builder.endVector()
        }
        let u = try self.u?.insert(builder)
        let u_type = self.u?.unionCase ?? 0
        let (myOffset, valueCursors) = try builder.insertT1(
            i: i,
            b: b,
            bs: bs,
            name: name,
            names: names,
            _self: _self,
            selfs: selfs,
            s: s,
            s_s: s_s,
            e: e ?? E.A,
            es: es,
            u_type: u_type,
            u: u
        )
        if u == 0,
           let o = self.u,
           let cursor = valueCursors[13] {
            builder.deferedBindings.append((o.value, cursor))
        }
        if builder.options.uniqueTables {
            builder.cache[ObjectIdentifier(self)] = myOffset
        }
        builder.inProgress.remove(ObjectIdentifier(self))
        return myOffset
    }

}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let table = lookup?.tables["T1"]
        let result = table?.insertMethod(lookup: lookup!, fileIdentifier: "nil")
        XCTAssertEqual(expected, result!)
    }

    func testGenFromJsonObjectExtension() {
        let expected = """
extension T1 {
    public static func from(jsonObject: [String: Any]?) -> T1? {
        guard let object = jsonObject else { return nil }
        let i = (object["i"] as? Int).flatMap { Int32(exactly: $0) } ?? 0
        let b = object["b"] as? Bool ?? false
        let __d = object["__d"] as? Double ?? 0.0
        let bs = object["bs"] as? [Bool] ?? []
        let name = object["name"] as? String
        let names = object["names"] as? [String] ?? []
        let _self = T0.from(jsonObject: object["_self"] as? [String: Any])
        let selfs = ((object["selfs"] as? [[String: Any]]) ?? []).compactMap { T0.from(jsonObject: $0)}
        let s = S1.from(jsonObject: object["s"] as? [String: Any])
        let s_s = ((object["s_s"] as? [[String: Any]]) ?? []).compactMap { S1.from(jsonObject: $0)}
        let e = E.from(jsonValue: object["e"])
        let es = ((object["es"] as? [Any]) ?? []).compactMap { E.from(jsonValue: $0)}
        let u = U1.from(type:object["u_type"] as? String, jsonObject: object["u"] as? [String: Any])
        return T1 (
            i: i,
            b: b,
            __d: __d,
            bs: bs,
            name: name,
            names: names,
            _self: _self,
            selfs: selfs,
            s: s,
            s_s: s_s,
            e: e,
            es: es,
            u: u
        )
    }
}
"""
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema?.identLookup
        let table = lookup?.tables["T1"]
        let result = table?.genFromJsonObjectExtension(lookup!)
        XCTAssertEqual(expected, result!)
    }
    
    func testGenAll() {
        let schema = Schema.with(pointer:s.utf8Start, length: s.utf8CodeUnitCount)?.0
        let lookup = schema!.identLookup
        print(lookup.enums["E"]!.swift)
        print(lookup.structs["S1"]!.swift)
        print(lookup.unions["U1"]!.swift)
        let t0 = lookup.tables["T0"]!
        print(t0.readerProtocolExtension(lookup: lookup))
        print(t0.swiftClass(lookup: lookup))
        print(t0.fromDataExtenstion(lookup: lookup))
        let t1 = lookup.tables["T1"]!
        print(t1.readerProtocolExtension(lookup: lookup))
        print(t1.swiftClass(lookup: lookup))
        print(t1.fromDataExtenstion(lookup: lookup))
    }

    static var allTests = [
        ("testProtocolReaderExtension", testProtocolReaderExtension),
        ("testProtocolReaderExtensionWithExplicitIndex", testProtocolReaderExtensionWithExplicitIndex),
        ("testSwiftClass", testSwiftClass),
        ("testFromData", testFromData),
        ("testInsertExtension", testInsertExtension),
        ("testInsertMethod", testInsertMethod),
        ("testGenAll", testGenAll),
        ("testGenFromJsonObjectExtension", testGenFromJsonObjectExtension)
    ]
}
