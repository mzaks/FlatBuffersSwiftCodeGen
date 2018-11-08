//
//  main.swift
//  CodeGen
//
//  Created by Maxim Zaks on 10.07.17.
//  Copyright © 2017 maxim.zaks. All rights reserved.
//

import Foundation
import FlatBuffersSwiftCodeGenCore

 let arguments = Array(CommandLine.arguments.dropFirst()) // The first argument is this executable

if !(2 ... 3 ~= arguments.count) {
    print("⚠️ Wrong number of arguments provided. Expected (2...3), received \(arguments.count)")
    exit(1)
}

let inputURL = URL(fileURLWithPath: arguments[0])
let outputURL = URL(fileURLWithPath: arguments[1])

let withoutImport = arguments.count == 3 &&
    (arguments[2] == "download" || arguments[2] == "noImport")


let getURLs = {
    return FileManager.default.enumerator(at: inputURL,
                                          includingPropertiesForKeys: [],
                                          options: .skipsHiddenFiles)
}

guard let urlEnumerator = getURLs() else {
    print("⚠️ Could not get .fbs files from path \(inputURL)")
    exit(1)
}

let fbsURLs = (urlEnumerator.allObjects as! [URL])
    .filter { $0.pathExtension == "fbs"}

extension Array where Element == URL {
    func schemas() -> [(url: URL, schema: Schema)] {
        return self
            .compactMap { url -> (url: URL, data: Data)? in
                let data = try? Data(contentsOf: url)
                return data == nil ? nil : (url, data!)
            }
            .compactMap { (url: URL, data: Data) -> (url: URL, schema: Schema)? in
                let schema = data.withUnsafeBytes { (p: UnsafePointer<UInt8>) -> Schema? in
                    return Schema.with(pointer: p, length: data.count)?.0
                }
                return schema == nil ? nil : (url, schema!)
            }
    }
}

let swiftFileContents = fbsURLs
    .schemas()
    .compactMap { (url: URL, schema: Schema) -> (url: URL, data: Data)? in
        let data = schema.swift(withImport: !withoutImport).data(using: .utf8)
        return data == nil ? nil : (url, data!)
    }

for swiftFileContent in swiftFileContents {
    let suffix = swiftFileContent.url.path.replacingOccurrences(of: inputURL.path + "/", with: "")
    let newURL = outputURL.appendingPathComponent(suffix).deletingPathExtension().appendingPathExtension("swift")
    
    do {
        try FileManager.default.createDirectory(at: newURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try swiftFileContent.data.write(to: newURL)
        print("✅ Wrote swift file to \(newURL.path)")
    } catch(let error) {
        print("❌ Could not generate \(newURL.path), (\(error.localizedDescription)")
    }
}

if arguments.count == 3 && arguments[2] == "download" {
    print("🕐 Downloading FlatBuffersBuilder")
    let builderData = try Data(contentsOf: URL(string: "https://raw.github.com/mzaks/FlatBuffersSwift/1.0.0/FlatBuffersSwift/FlatBuffersBuilder.swift")!)
    try!builderData.write(to: outputURL.deletingLastPathComponent().appendingPathComponent("FlatBuffersBuilder.swift"))
    print("✅ Completed")
    print("🕐 Downloading FlatBuffersReader")
    let readerData = try Data(contentsOf: URL(string: "https://raw.githubusercontent.com/mzaks/FlatBuffersSwift/1.0.0/FlatBuffersSwift/FlatBuffersReader.swift")!)
    try!readerData.write(to: outputURL.deletingLastPathComponent().appendingPathComponent("FlatBuffersReader.swift"))
    print("✅ Completed")
}
