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

public struct FileCodingKey {
    
    internal enum Value {
        
        case integer(Int)
        case string(String)
    }
    
    internal let value: Value
    
    public init(_ value: Int) {
        self.value = .integer(value)
    }
    
    public init(_ value: String) {
        self.value = .string(value)
    }
}

extension FileCodingKey: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.value = .string(value)
    }
}

extension FileCodingKey: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int) {
        self.value = .integer(value)
    }
}

extension FileCodingKey: CustomStringConvertible {
    
    public var description: String {
        switch value {
        case .integer(let integer): return String(describing: integer)
        case .string(let string): return string
        }
    }
}
