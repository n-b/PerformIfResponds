@import XCTest;
#import "NSObject+PerformIfResponds.h"

// Test API

typedef struct __attribute__((objc_boxable)) {
    int i;
} some_struct;

@interface SampleClass : NSObject
@property id existingObject;
@property BOOL existingBOOL;
@property CGRect existingRect;
@property some_struct existingStruct;
@end
@implementation SampleClass
@end

@interface SampleClass (FakeMethods)
@property id fakeObject;
@property BOOL fakeBOOL;
@property CGRect fakeRect;
@property some_struct fakeStruct;
@end

@interface PerformIfRespondsUsageTests : XCTestCase
@end

@implementation PerformIfRespondsUsageTests

- (void)testCorrectlyForwards
{
    // Given
    SampleClass* subject = [SampleClass new];
    
    // When
    subject.performIfResponds.existingObject = @"foo";
    // Then
    XCTAssertEqualObjects(subject.existingObject, @"foo");
    XCTAssertEqualObjects(subject.performIfResponds.existingObject, @"foo");

    // When
    subject.performIfResponds.existingBOOL = YES;
    // Then
    XCTAssertEqual(subject.existingBOOL, YES);
    XCTAssertEqual(subject.performIfResponds.existingBOOL, YES);

    // When
    subject.performIfResponds.existingRect = CGRectMake(1,2,3,4);
    // Then
    XCTAssertTrue(CGRectEqualToRect(subject.existingRect,CGRectMake(1,2,3,4)));
    XCTAssertTrue(CGRectEqualToRect(subject.performIfResponds.existingRect,CGRectMake(1,2,3,4)));

    // When
    subject.performIfResponds.existingStruct = (some_struct){42};
    // Then
    XCTAssertEqual(subject.existingStruct.i,42);
    XCTAssertEqual(subject.performIfResponds.existingStruct.i,42);
}

- (void)testCorrectlyMasks
{
    // Given
    SampleClass* subject = [SampleClass new];

    // When
    XCTAssertThrows([subject setFakeObject:@"foo"]);
    // Then
    XCTAssertNoThrow([subject.performIfResponds setFakeObject:@"foo"]);
}

- (void)testCorrectlyReturnsDefaultValue
{
    // Given
    SampleClass* subject = [SampleClass new];

    // Then
    XCTAssertEqualObjects([subject performOrReturn:@"foo"].fakeObject, @"foo");

    // Then
    XCTAssertEqual([subject performOrReturnValue:@YES].fakeBOOL, YES);

    // Then
    XCTAssertTrue(CGRectEqualToRect([subject performOrReturnValue:[NSValue valueWithRect:CGRectMake(1,2,3,4)]].fakeRect, CGRectMake(1,2,3,4)));

    // Then
    XCTAssertEqual([subject performOrReturnValue:@((some_struct){42})].fakeStruct.i, 42);
}

@end

@interface PerformIfRespondsSanityTests : XCTestCase
@end

@implementation PerformIfRespondsSanityTests

- (void)testDoesntLeakReturnedObject
{
    // Given
    SampleClass* subject = [SampleClass new];
    id __weak weakObject;

    // When
    @autoreleasepool {
        weakObject = NSDate.date.description;
        __unused id result = [subject performOrReturn:weakObject].fakeObject;
    }
    
    // Then
    XCTAssertNil(weakObject);
}

- (void)testPOD
{
    // Given
    SampleClass* subject = [SampleClass new];

    // Then
    XCTAssertEqual([subject performOrReturnValue:@YES].fakeBOOL, YES);
    XCTAssertThrows([subject performOrReturnValue:[NSValue valueWithRect:CGRectMake(0, 0, 0, 42)]].fakeObject); // WOOO CRASH AND BURN
    XCTAssertEqual([subject performOrReturn:@"yolo"].fakeObject, @"yolo");
}

@end
