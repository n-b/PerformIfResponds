@import XCTest;
#import "NSObject+PerformIfResponds.h"

// Test API
@interface SampleClass : NSObject
@property id existingObject;
@property BOOL existingBOOL;
@end
@implementation SampleClass
@end

@interface SampleClass (FakeMethods)
@property id fakeObject;
@property BOOL fakeBOOL;
@property CGRect fakeRect;
@end

@interface PerformIfRespondsTests : XCTestCase
@end

@implementation PerformIfRespondsTests

- (void)testCorrectlyForwards
{
    // Given
    SampleClass* sut = [SampleClass new];
    
    // When
    sut.performIfResponds.existingObject = @"foo";
    
    // Then
    XCTAssertEqualObjects(sut.existingObject, @"foo");
}

- (void)testCorrectlyMasks
{
    // Given
    SampleClass* sut = [SampleClass new];

    // When
    XCTAssertThrows(sut.fakeObject = @"foo");
    
    // Then
    XCTAssertNoThrow(sut.performIfResponds.fakeObject = @"foo");
}

- (void)testCorrectlyReturns
{
    // Given
    SampleClass* sut = [SampleClass new];

    // Then
    XCTAssertEqualObjects([sut performOr:@"foo"].fakeObject, @"foo");
}

- (void)testDoesntLeak
{
    // Given
    SampleClass* sut = [SampleClass new];
    id __weak weakObject;

    // When
    @autoreleasepool {
        weakObject = NSDate.date.description;
        __unused id result = [sut performOr:weakObject].fakeObject;
    }
    
    // Then
    XCTAssertNil(weakObject);
}


- (void)testPOD
{
    // Given
    SampleClass* sut = [SampleClass new];

    // Then
    XCTAssertEqual([sut performOrValue(YES)].fakeBOOL, YES);
    
    XCTAssertEqual([sut performOrValue(CGRectMake(0, 0, 0, 42))].fakeRect.size.height, 42);

    XCTAssertEqual([sut performOrValue(CGRectMake(0, 0, 0, 42))].fakeRect.size.height, 42);
}

@end
