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

/// This protocol is used for key paths in a Json object. It is implemented by `Int` and `String`
/// only. The former is used to identify an array's index, the latter is used to refer to a
/// value in a dictionary.
///
/// The protocol shall _not_ be implemented by any other type! It would break the workings of
/// the `FileDecoder` when being used with types other than `Int` and `String`.
public protocol DecodingKey { }

extension String: DecodingKey { }
extension Int: DecodingKey { }

internal enum DecodingKeyPathElement {
    
    case key(String)
    case index(Int)
    
    static func elements(from paths: [DecodingKey]) -> LazyMapCollection<[DecodingKey], DecodingKeyPathElement> {
        return paths.lazy.map { DecodingKeyPathElement($0)! }
    }
    
    init?(_ any: Any) {
        if let string = any as? String {
            self = .key(string)
        } else if let integer = any as? Int {
            self = .index(integer)
        } else {
            return nil
        }
    }
    
    @inline(__always)
    func evaluate(_ dictionary: (String) -> Void,
                  _ array: (Int) -> Void) {
        switch self {
        case .key(let string):
            dictionary(string)
        case .index(let integer):
            array(integer)
        }
    }
    
}
