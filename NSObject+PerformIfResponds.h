@import Foundation;

// Generic compatibility trampoline: forwards messages to the receiver only if it responds to it.
@interface NSObject (PerformIfResponds)

- (instancetype)performIfResponds;

- (instancetype)performOr:(id)obj_;

#define performOrValue(pod)	_performOrValue:({typeof(pod) _pod = pod; [NSValue valueWithBytes:&_pod objCType:@encode(typeof(_pod))]; })
- (instancetype)_performOrValue:(NSValue*)value_;

@end
