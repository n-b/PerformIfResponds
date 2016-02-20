@import XCTest;
#import "NSObject+PerformIfResponds.h"

//
// Use performIfResponds to safely call new API methods

@interface Demo_APIVersion : XCTestCase
@end

@interface NSProcessInfo (SeaLion)
@property (readonly) id quantumState; // NS_AVAILABLE(SEA_LION, NA);
@end

@implementation Demo_APIVersion

- (void)testDemoAPIVersion
{
    // Assume NSProcessInfo gains a new method in an upcoming OS version,
    // but your code needs to run on older OS as well.
    // Instead of:
    XCTAssertThrows(NSProcessInfo.processInfo.quantumState);
    // Call new methods through performIfResponds
    XCTAssertNoThrow([NSProcessInfo.processInfo performOrReturn:nil].quantumState);
}

@end
