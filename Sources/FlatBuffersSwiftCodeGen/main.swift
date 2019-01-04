//
//  main.swift
//  CodeGen
//
//  Created by Maxim Zaks on 10.07.17.
//  Copyright © 2017 maxim.zaks. All rights reserved.
//

import Foundation
import FlatBuffersSwiftCodeGenCore
import Utility

enum ImportType : String, StringEnumArgument, CaseIterable {
    static var completion: ShellCompletion {
        return ShellCompletion.values([(value: ImportType.download.rawValue,
                                        description: "download imports from github"),
                                       (value: ImportType.noImport.rawValue,
                                        description: "do not include imports")])
    }

    case download = "download"
    case noImport = "noImport"
}

typealias URL = Foundation.URL

let arguments = Array(CommandLine.arguments.dropFirst()) // The first argument is this executable

let parser = ArgumentParser(usage: "<InputURL> <OutputURL> [withoutImport]",
                            overview: "Used to generate Swift files from flatbuffers definitions")

let inputDirectoryOptionArgument = parser.add(option: "--input-directory",
                                shortName: "-i",
                                kind: PathArgument.self,
                                usage: "Path of the input directory")

let outputDirectoryOptionArgument = parser.add(option: "--output-directory",
                                 shortName: "-o",
                                 kind: PathArgument.self,
                                 usage: "Path of the output directory")

let importTypeOptionArgument = parser.add(option: "--import-type",
                            kind: ImportType.self,
                            usage: "Specifies if output files should include reader",
                            completion: ImportType.completion)

let parsedArguments: ArgumentParser.Result
do {
    parsedArguments = try parser.parse(arguments)
}
catch (let error) {
    print(error.localizedDescription)
    exit(1)
}

guard let inputDirectory = parsedArguments.get(inputDirectoryOptionArgument) else {
    print("⚠️ Could not parse input-directory")
    exit(1)
}

guard let outputDirectory = parsedArguments.get(outputDirectoryOptionArgument) else {
    print("⚠️ Could not parse output-directory")
    exit(1)
}

let withoutImport = parsedArguments.get(importTypeOptionArgument) != .download
let inputURL = URL(fileURLWithPath: inputDirectory.path.asString)
let outputURL = URL(fileURLWithPath: outputDirectory.path.asString)

let getFBSURLs = {
    return FileManager.default.enumerator(at: inputURL,
                                          includingPropertiesForKeys: [],
                                          options: .skipsHiddenFiles)?
        .allObjects
        .compactMap { $0 as? Foundation.URL }
        .filter { $0.pathExtension == "fbs"}
}

guard let fbsURLs = getFBSURLs() else {
    print("⚠️ Could not get .fbs files from path \(inputURL)")
    exit(1)
}

extension URL {
    func schema() -> Schema? {
        let resolveImports = { (include: String) -> Schema? in
            let url = self.deletingLastPathComponent().appendingPathComponent(include)
            return url.schema()
        }
        
        guard let data = try? Data(contentsOf: self) else { return nil }
        return data.withUnsafeBytes { (p: UnsafePointer<UInt8>) -> Schema? in
            return Schema.with(pointer: p, length: data.count, resolveImports: resolveImports)?.0
        }
    }
}

extension Array where Element == URL {
    func schemas() -> [(url: URL, schema: Schema)] {
        return self
            .compactMap { url in
                if let schema = url.schema() {
                    return (url, schema)
                }
                return nil
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

if parsedArguments.get(importTypeOptionArgument) == .download {
    print("🕐 Downloading FlatBuffersBuilder")
    let builderData = try Data(contentsOf: URL(string: "https://raw.github.com/mzaks/FlatBuffersSwift/1.0.0/FlatBuffersSwift/FlatBuffersBuilder.swift")!)
    try!builderData.write(to: outputURL.deletingLastPathComponent().appendingPathComponent("FlatBuffersBuilder.swift"))
    print("✅ Completed")
    print("🕐 Downloading FlatBuffersReader")
    let readerData = try Data(contentsOf: URL(string: "https://raw.githubusercontent.com/mzaks/FlatBuffersSwift/1.0.0/FlatBuffersSwift/FlatBuffersReader.swift")!)
    try!readerData.write(to: outputURL.deletingLastPathComponent().appendingPathComponent("FlatBuffersReader.swift"))
    print("✅ Completed")
}
