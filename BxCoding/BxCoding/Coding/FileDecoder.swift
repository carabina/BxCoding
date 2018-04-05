// Copyright 2018 Oliver Borchert
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// The `FileDecoder` protocol is adapted by all coders that decode
/// `FileCodable` objects from portable web formats such as JSON and XML.
public protocol FileDecoder: class {
    
    associatedtype Element
    
    init(rawValue: Element)
    var rawValue: Element { get }
    
    static func decode<T: FileDecodable>(_ data: Data, to: T.Type) throws -> T
    static func decode<T: FileDecodable>(_ object: Element, to: T.Type) throws -> T
    
    func decode<T: FileDecodable>(for keyPath: DecodingKey..., to: T.Type) throws -> T
    func exists(for keyPath: DecodingKey...) -> Bool
}

extension FileDecoder where Element: FileElement {
    
    public static func decode<T: FileDecodable>(_ data: Data, to: T.Type = T.self) throws -> T {
        return try Self.decode(Element(reading: data))
    }
    
    public static func decode<T: FileDecodable>(_ object: Element, to: T.Type = T.self) throws -> T {
        return try Self.init(rawValue: object).decode()
    }
    
    /// Decodes a `FileCodable` object for a specified
    /// key. If no object exists for this key or its value is `nil`,
    /// `nil` is returned.
    ///
    /// - parameter keyPath: The key path to decode the object for.
    ///
    /// - returns: Returns the object if it exists for the specified
    ///            key, returns `nil` otherwise.
    public func decode<T: FileDecodable>(for keyPath: DecodingKey..., to: T.Type = T.self) throws -> T {
        let decoder = Self.init(rawValue: rawValue(for: keyPath))
        #if DEBUG
        do {
            return try T.init(from: decoder)
        } catch let error {
            if case MorphInternalError.initialDecodingFailed = error {
                print(">>> WebParsing: Decoding failed...")
                print("    Failing keypath: \(keyPath)")
                let jsonString = rawValue.description(forOffset: "\t\t", prettyPrinted: true, truncatesStrings: true)
                print("    Available keypaths: \(rawValue.propertyKeys ?? [])")
                print("    Failing object:\n\(jsonString)")
                print("<<< ... end of failure.")
                throw MorphError.decodingFailed
            }
            throw error
        }
        #else
        return try T.init(from: decoder)
        #endif
    }
    
    /// Returns a boolean whether there exists a value for the given key path.
    ///
    /// - Parameter keyPath: The key path for which to check if a value exists.
    /// - Returns: A boolean indicating if there exists a value.
    public func exists(for keyPath: DecodingKey...) -> Bool {
        return rawValue(for: keyPath).isValue
    }
    
    @inline(__always)
    private func rawValue(for keyPath: [DecodingKey]) -> Element {
        var current = self.rawValue
        for key in DecodingKeyPathElement.elements(from: keyPath) {
            key.evaluate({ current = current[$0] }, { current = current[$0] })
        }
        return current
    }
}
