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

extension Optional: FileDecodable where Wrapped: FileDecodable {
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        let wrapped = decoder.rawValue
        switch wrapped.value {
        case .null:
            self = nil
        default:
            self = try Decoder.decode(wrapped)
        }
    }
}

extension Optional: FileEncodable where Wrapped: FileEncodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        switch self {
        case .some(let wrapped):
            try encoder.encode(wrapped)
        case .none:
            throw MorphInternalError.optionalNone
        }
    }
}

extension Array: FileDecodable where Element: FileDecodable {
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let array = decoder.rawValue.arrayValue else {
            throw MorphInternalError.initialDecodingFailed
        }
        self = try array.map { try Decoder.decode($0) }
    }
}

extension Array: FileEncodable where Element: FileEncodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        var result = [Encoder.Element]()
        result.reserveCapacity(self.count)
        for value in self {
            do {
                let encoder = Encoder.init(rawValue: Encoder.Element.init(value: .object([:])))
                try encoder.encode(value)
                result.append(encoder.rawValue)
            } catch MorphInternalError.optionalNone {
                continue
            } catch {
                throw error
            }
        }
        encoder.rawValue = Encoder.Element.init(value: .array(result))
    }
}

extension Dictionary: FileDecodable where Key == String, Value: FileDecodable {
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let dictionary = decoder.rawValue.dictionaryValue else {
            throw MorphInternalError.initialDecodingFailed
        }
        self = try dictionary.mapValues { try Decoder.decode($0) }
    }
}

extension Dictionary: FileEncodable where Key == String, Value: FileEncodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        for (key, value) in self {
            try encoder.encode(value, for: key)
        }
    }
}

extension Json: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        guard let coder = encoder as? JsonEncoder else {
            throw MorphError.invalidEncoder
        }
        coder.rawValue = self
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let coder = decoder as? JsonDecoder else {
            throw MorphError.invalidDecoder
        }
        self = coder.rawValue
    }
}

extension Plist: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        guard let coder = encoder as? PlistEncoder else {
            throw MorphError.invalidEncoder
        }
        coder.rawValue = self
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let coder = decoder as? PlistDecoder else {
            throw MorphError.invalidDecoder
        }
        self = coder.rawValue
    }
}

extension String: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        encoder.rawValue = Encoder.Element(value: .string(self))
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        guard let string = decoder.rawValue.stringValue else {
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
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
            throw MorphInternalError.initialDecodingFailed
        }
        self = boolean
    }
}

extension UUID: FileCodable {
    
    public func encode<Encoder: FileEncoder>(to encoder: Encoder) throws {
        try encoder.encode(self.uuidString)
    }
    
    public init<Decoder: FileDecoder>(from decoder: Decoder) throws {
        self = try UUID(uuidString: try decoder.decode()).unwrap()
    }
}
