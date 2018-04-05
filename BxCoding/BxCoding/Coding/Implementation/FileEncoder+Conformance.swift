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

/// This class is used to encode `FileCodable` objects as Json.
/// When attributes are tried to encode, the class simply does
/// nothing as Json doesn't support element attributes.
public final class JsonEncoder: FileEncoder {
    
    public var rawValue: Json
    
    public init(rawValue: Json) {
        self.rawValue = rawValue
    }
}

public final class PlistEncoder: FileEncoder {
    
    public var rawValue: Plist
    
    public init(rawValue: Plist) {
        self.rawValue = rawValue
    }
}
