@import XCTest;
#import "NSObject+PerformIfResponds.h"

//
// Use performIfResponds to safely call optional delegate methods

@interface Demo_Delegate : XCTestCase
@end

@protocol DemoDelegate <NSObject>
@optional
- (void) objectDidFoo:(id)object;
- (id) valueForBar:(id)bar;
@end
@interface SampleDelegate : NSObject <DemoDelegate>
@end
@implementation SampleDelegate
@end

@implementation Demo_Delegate

- (void)testDemoDelegate
{
    SampleDelegate *delegate = [SampleDelegate new];

    // Instead of:
    XCTAssertThrows([delegate objectDidFoo:self]);
    // Delegate methods can be simply called like that:
    XCTAssertNoThrow([delegate.performIfResponds objectDidFoo:self]);

    // It works when returning a value, too:
    XCTAssertNoThrow([delegate.performIfResponds valueForBar:self]);
    // The default is returning nil, which may not be appropriate:
    XCTAssertEqual([[delegate performOr:@"hello"] valueForBar:self], @"hello");
}

@end

