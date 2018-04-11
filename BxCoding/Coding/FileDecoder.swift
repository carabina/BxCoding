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
import BxUtility

/// The `FileDecoder` protocol is adapted by all coders that decode
/// `FileCodable` objects from portable web formats such as JSON and XML.
public protocol FileDecoder: class {
    
    associatedtype Element: FileElement
    
    var rawValue: Element { get }
    
    #if DEBUG
        init(rawValue: Element, keyPath: [FileCodingKey])
        var keyPath: [FileCodingKey] { get }
    #else
        init(rawValue: Element)
    #endif
}

extension FileDecoder {
    
    public static func decode<T: FileDecodable>(_ data: Data, to: T.Type = T.self) throws -> T {
        return try Self.decode(Element(reading: data))
    }
    
    public static func decode<T: FileDecodable>(_ object: Element, to: T.Type = T.self) throws -> T {
        #if DEBUG
            do {
                return try Self.init(rawValue: object, keyPath: []).decode()
            } catch BxCodingFramework.InternalError.decodingFailed(type: let type, keyPath: let keyPath) {
                BxCodingFramework.logger?.log(
                    "Decoding failed:\n" +
                    "    Failing keypath: \(keyPath.map(String.init(describing:)).joined(separator: ", "))\n" +
                    "    Failing type: \(type)\n"
                )
                throw BxCodingFramework.Error.decodingFailed
            } catch {
                throw error
            }
        #else
            return try Self.init(rawValue: object).decode()
        #endif
    }
    
    /// Decodes a `FileCodable` object for a specified
    /// key. If no object exists for this key or its value is `nil`,
    /// `nil` is returned.
    ///
    /// - parameter keyPath: The key path to decode the object for.
    ///
    /// - returns: Returns the object if it exists for the specified
    ///            key, returns `nil` otherwise.
    public func decode<T: FileDecodable>(for keyPath: FileCodingKey..., to: T.Type = T.self) throws -> T {
        #if DEBUG
            let decoder = Self.init(rawValue: rawValue(for: keyPath), keyPath: self.keyPath + keyPath)
        #else
            let decoder = Self.init(rawValue: rawValue(for: keyPath))
        #endif
        
        return try T.init(from: decoder)
    }
    
    internal func decode<T: FileDecodable>(_ rawValue: Element, to: T.Type = T.self,
                                           for keyPath: FileCodingKey...) throws -> T {
        #if DEBUG
            let decoder = Self.init(rawValue: rawValue, keyPath: self.keyPath + keyPath)
        #else
            let decoder = Self.init(rawValue: rawValue)
        #endif
        return try T.init(from: decoder)
    }
    
    /// Returns a boolean whether there exists a value for the given key path.
    ///
    /// - Parameter keyPath: The key path for which to check if a value exists.
    /// - Returns: A boolean indicating if there exists a value.
    public func exists(for keyPath: FileCodingKey...) -> Bool {
        return rawValue(for: keyPath).isValue
    }
    
    @inline(__always)
    private func rawValue(for keyPath: [FileCodingKey]) -> Element {
        var current = self.rawValue
        for key in keyPath {
            switch key.value {
            case .integer(let index):
                current = current[index]
            case .string(let object):
                current = current[object]
            }
        }
        return current
    }
}
