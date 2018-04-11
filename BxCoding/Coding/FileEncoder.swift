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

/// The `FileEncoder` protocol is adapted by all coders that encode
/// `FileCodable` objects as portable web formats like JSON and XML.
public protocol FileEncoder: class {
    
    associatedtype Element: FileElement
    
    init(rawValue: Element)
    var rawValue: Element { get set }
}

extension FileEncoder {
    
    /// Encodes a `FileCodable` object as JSON.
    ///
    /// - parameter object: The object to encode.
    ///
    /// - returns: The JSON value.
    public static func encode<T: FileEncodable>(_ object: T) throws -> Element {
        let encoder = Self.init(rawValue: Element.dictionary)
        try encoder.encode(object)
        return encoder.rawValue
    }
    
    /// Encodes a `FileEncodable` object for no key.
    ///
    /// - Parameter value: The `FileEncodable` object to encode.
    public func encode<T: FileEncodable>(_ value: T) throws {
        do {
            try value.encode(to: self)
        } catch BxCodingFramework.InternalError.optionalEncodingFailed {
            return
        } catch {
            throw error
        }
    }
    
    /// Encodes a `FileEncodable` object for a specified key.
    ///
    /// - parameter value: The `FileEncodable` object to encode.
    /// - parameter key:   The key to encode the object for. In JSON
    ///                    for example it is used as the key for values
    ///                    of an object. The adopting class might
    ///                    however decide how to use the key. In a
    ///                    single class, the keys need to be distinct.
    ///                    Otherwise, only the last value for the
    ///                    specified key is encoded.
    public func encode<T: FileEncodable>(_ value: T, for key: String) throws {
        let encoder = Self.init(rawValue: Element.dictionary)
        do {
            try value.encode(to: encoder)
        } catch BxCodingFramework.InternalError.optionalEncodingFailed {
            return
        } catch let error {
            throw error
        }
        self.rawValue[key] = encoder.rawValue
    }
}
