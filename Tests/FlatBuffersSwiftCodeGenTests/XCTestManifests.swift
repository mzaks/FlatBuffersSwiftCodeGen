import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ASTNodeTests.allTests),
        testCase(CommentTests.allTests),
        testCase(EnumTests.allTests),
        testCase(FieldTests.allTests),
        testCase(IdentTests.allTests),
        testCase(MetaDataTests.allTests),
        testCase(SchemaTests.allTests),
        testCase(StringLiteralTests.allTests),
        testCase(TableGenTests.allTests),
        testCase(TableTests.allTests),
        testCase(TypeTests.allTests),
        testCase(UnionTests.allTests),
        testCase(ValueLiteralTests.allTests),
    ]
}
#endif
