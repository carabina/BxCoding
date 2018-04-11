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

import XCTest
@testable import BxCoding

class DecodingTests: XCTestCase {
    
    struct Foo: FileDecodable {
        
        let value1: String
        let value2: [Int]
        let value3: [String: Bar]
        
        init<Decoder>(from decoder: Decoder) throws where Decoder: FileDecoder {
            self.value1 = try decoder.decode(for: "value1")
            self.value2 = try decoder.decode(for: "value2")
            self.value3 = try decoder.decode(for: "value3")
        }
    }
    
    struct Bar: FileDecodable {
        
        let value1: UUID?
        let value2: [UInt16?]
        
        init<Decoder>(from decoder: Decoder) throws where Decoder: FileDecoder {
            self.value1 = try decoder.decode(for: "value1")
            self.value2 = try decoder.decode(for: "value2")
        }
    }
    
    private let correct =
        """
        {
            "value1": "foo",
            "value2": [1, 2],
            "value3": {
                "first": {
                    "value2": []
                }
            }
        }
        """
    
    func testCorrect() {
        guard let data = try? JsonDecoder.decode(correct.data(using: .utf8)!, to: Foo.self) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data.value3["first"]?.value1, nil)
        XCTAssertEqual(data.value2, [1, 2])
    }
    
    private let optionalArrayValues =
        """
        {
            "value1": "foo",
            "value2": [1, 2],
            "value3": {
                "first": {
                    "value2": [null, 2, 3, null]
                }
            }
        }
        """
    
    func testOptionalArrayValues() {
        guard let data = try? JsonDecoder.decode(optionalArrayValues.data(using: .utf8)!, to: Foo.self) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data.value3["first"]?.value2, [nil, 2, 3, nil])
    }
    
    private let optionalSlackness =
        """
        {
            "value1": "foo",
            "value2": [1, 2],
            "value3": {
                "first": {
                    "value1": { "foo": 1 },
                    "value2": [[2, 3], 1]
                }
            }
        }
        """
    
    func testOptionalSlackness() {
        guard let data = try? JsonDecoder.decode(optionalSlackness.data(using: .utf8)!, to: Foo.self) else {
            XCTFail()
            return
        }
        XCTAssertEqual(data.value3["first"]?.value1, nil)
        XCTAssertEqual(data.value3["first"]?.value2, [nil, 1])
    }
}
