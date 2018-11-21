//
//  main.swift
//  CodeGen
//
//  Created by Maxim Zaks on 10.07.17.
//  Copyright © 2017 maxim.zaks. All rights reserved.
//

import Foundation
import FlatBuffersSwiftCodeGenCore

if CommandLine.arguments.count < 2 {
    print("⚠️ Please provide path to .fbs file as first argument")
    exit(1)
}

let fbsPath = CommandLine.arguments[1]
let fbsUrl = URL(fileURLWithPath: fbsPath)

guard let fileContent = try?Data(contentsOf: fbsUrl) else {
    print("⚠️ Could not read content of the .fbs file \(fbsUrl)")
    exit(1)
}



if CommandLine.arguments.count < 3 {
    print("⚠️ Please provide path to .swift file (which you want to generate) as second argument")
    exit(1)
}

let swiftPath = CommandLine.arguments[2]
let swiftUrl = URL(fileURLWithPath: swiftPath)

print("Generating: \(fbsPath) -> \(swiftPath)")



let schema = fileContent.withUnsafeBytes { (p: UnsafePointer<UInt8>) -> Schema? in
    return Schema.with(pointer: p, length: fileContent.count)?.0
}

let withoutImport = CommandLine.arguments.count > 3
                    && (CommandLine.arguments[3] == "download" || CommandLine.arguments[3] == "noImport")

if let swiftFileContent = schema?.swift(withImport: !withoutImport) {
    try!swiftFileContent.data(using: .utf8)?.write(to: swiftUrl)
    print("✅ Completed")
} else {
    print("❌ Could not generate")
}

if CommandLine.arguments.count > 3
    && CommandLine.arguments[3] == "download" {
    print("🕐 Downloading FlatBuffersBuilder")
    let builderData = try Data(contentsOf: URL(string: "https://raw.github.com/mzaks/FlatBuffersSwift/1.0.0/FlatBuffersSwift/FlatBuffersBuilder.swift")!)
    try!builderData.write(to: swiftUrl.deletingLastPathComponent().appendingPathComponent("FlatBuffersBuilder.swift"))
    print("✅ Completed")
    print("🕐 Downloading FlatBuffersReader")
    let readerData = try Data(contentsOf: URL(string: "https://raw.githubusercontent.com/mzaks/FlatBuffersSwift/1.0.0/FlatBuffersSwift/FlatBuffersReader.swift")!)
    try!readerData.write(to: swiftUrl.deletingLastPathComponent().appendingPathComponent("FlatBuffersReader.swift"))
    print("✅ Completed")
}
