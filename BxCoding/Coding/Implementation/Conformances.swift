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

extension Optional: FileDecodable where Wrapped: FileDecodable {
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        let wrapped = decoder.rawValue
        switch wrapped.value {
        case .null:
            self = nil
        default:
            self = try? decoder.decode(to: Wrapped.self)
        }
    }
}

extension Optional: FileEncodable where Wrapped: FileEncodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        switch self {
        case .some(let wrapped):
            try encoder.encode(wrapped)
        case .none:
            throw BxCodingFramework.InternalError.optionalEncodingFailed
        }
    }
}

extension Array: FileDecodable where Element: FileDecodable {
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let array = decoder.rawValue.arrayValue else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Array<Element>.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = try array.enumerated().map { try decoder.decode($0.element,
                                                               for: FileCodingKey(integerLiteral: $0.offset)) }
    }
}

extension Array: FileEncodable where Element: FileEncodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        let array = try self.compactMap { (value) -> Encoder.Element? in
            do {
                let encoder = Encoder.init(rawValue: Encoder.Element.dictionary)
                try encoder.encode(value)
                return encoder.rawValue
            } catch BxCodingFramework.InternalError.optionalEncodingFailed {
                return nil
            } catch {
                throw error
            }
        }
        encoder.rawValue = Encoder.Element.init(value: .array(array))
    }
}

extension Dictionary: FileDecodable where Key == String, Value: FileDecodable {
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let dictionary = decoder.rawValue.dictionaryValue else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Dictionary<Key, Value>.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        let mapping = try dictionary.map { ($0.key, try decoder.decode($0.value,
                                                                       to: Value.self,
                                                                       for: FileCodingKey(stringLiteral: $0.key))) }
        self = Dictionary(uniqueKeysWithValues: mapping)
    }
}

extension Dictionary: FileEncodable where Key == String, Value: FileEncodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        for (key, value) in self {
            try encoder.encode(value, for: key)
        }
    }
}

extension FileElement {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element.init(converting: self)
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        self = Self(converting: decoder.rawValue)
    }
}

extension String: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .string(self))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let string = decoder.rawValue.stringValue else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: String.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = string
    }
}

extension Int: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.intValue else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Int.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension Int64: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.int64Value else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Int64.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension Int32: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.int32Value else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Int32.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension Int16: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.int16Value else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Int16.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension UInt: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.uintValue else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: UInt.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension UInt64: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.uint64Value else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: UInt64.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension UInt32: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.uint32Value else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: UInt32.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension UInt16: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let integer = decoder.rawValue.uint16Value else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: UInt16.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = integer
    }
}

extension Double: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .number(self as NSNumber))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let double = decoder.rawValue.doubleValue else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Double.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = double
    }
}

extension Bool: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .boolean(self))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let boolean = decoder.rawValue.boolValue else {
            #if DEBUG
                throw BxCodingFramework.InternalError.decodingFailed(type: Bool.self, keyPath: decoder.keyPath)
            #else
                throw BxCodingFramework.Error.decodingFailed
            #endif
        }
        self = boolean
    }
}

extension UUID: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        try encoder.encode(self.uuidString)
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let initialized = try? decoder.decode() |> UUID.init(uuidString:),
              let wrapped = initialized, let uuid = wrapped else {
                #if DEBUG
                    throw BxCodingFramework.InternalError.decodingFailed(type: UUID.self, keyPath: decoder.keyPath)
                #else
                    throw BxCodingFramework.Error.decodingFailed
                #endif
        }
        self = uuid
    }
}

//extension Date: FileCodable {
//    
//    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
//        try encoder.encode(self.uuidString)
//    }
//    
//    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
//        guard let string = try? decoder.decode(to: String.self) else {
//            throw BxCodingFramework.InternalError.decodingFailed(type: Date.self)
//        }
//    }
//}
