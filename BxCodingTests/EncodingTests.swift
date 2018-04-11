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

class EncodingTests: XCTestCase {
    
    struct Foo: FileEncodable {
        
        let value1: String
        let value2: [Int]
        let value3: [String: Bar]
        
        init(value1: String, value2: [Int], value3: [String: Bar]) {
            self.value1 = value1
            self.value2 = value2
            self.value3 = value3
        }
        
        func encode<Encoder>(to encoder: Encoder) throws where Encoder: FileEncoder {
            try encoder.encode(value1, for: "value1")
            try encoder.encode(value2, for: "value2")
            try encoder.encode(value3, for: "value3")
        }
    }
    
    struct Bar: FileEncodable {
        
        let value1: UUID?
        let value2: [UInt16?]
        
        init(value1: UUID?, value2: [UInt16?]) {
            self.value1 = value1
            self.value2 = value2
        }
        
        func encode<Encoder>(to encoder: Encoder) throws where Encoder: FileEncoder {
            try encoder.encode(value1, for: "value1")
            try encoder.encode(value2, for: "value2")
        }
    }
    
    private let simpleEncoding =
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
    
    func testSimpleEncoding() {
        let foo = Foo(value1: "foo", value2: [1, 2], value3: ["first": Bar(value1: nil, value2: [])])
        guard let encoded = try? JsonEncoder.encode(foo) else {
            XCTFail()
            return
        }
        XCTAssertEqual(encoded.description(), Json(reading: simpleEncoding).description())
    }
}
