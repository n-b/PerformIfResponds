#import "NSObject+PerformIfResponds.h"
#import <objc/runtime.h>

id _BoxedValue(const void * bytes_, const char* type_) {
    id value = [NSValue valueWithBytes:bytes_ objCType:type_];
    objc_setAssociatedObject(value, "box", @0, OBJC_ASSOCIATION_RETAIN);
    return value;
}

@interface PerformProxy : NSObject
@property id target;
@property const char * returnType;
@property id returnValue;
@end

@implementation NSObject (PerformProxy)

- (instancetype)performIfResponds
{
    PerformProxy * proxy = [PerformProxy new];
    proxy.target = self;
    proxy.returnType = @encode(void);
    return proxy;
}

- (instancetype)performOrReturn:(id)value_
{
    PerformProxy * proxy = [PerformProxy new];
    proxy.target = self;
    proxy.returnValue = value_;
    if(objc_getAssociatedObject(value_, "box")) {
        proxy.returnType = [value_ objCType];
    } else {
        proxy.returnType = @encode(id);
    }
    return proxy;
}

@end

@implementation PerformProxy

- (id)forwardingTargetForSelector:(SEL)sel_
{
    if ([_target respondsToSelector:sel_]) {
        return _target;
    } else {
        return self;
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel_
{
    NSAssert(![_target respondsToSelector:sel_], @"forwardingTargetForSelector: should have forwarded");
    return [NSMethodSignature signatureWithObjCTypes:
            [NSString stringWithFormat:@"%s%s%s",_returnType,@encode(id),@encode(SEL)].UTF8String];
}

- (void)forwardInvocation:(NSInvocation *)invocation_
{
    NSAssert(![_target respondsToSelector:invocation_.selector], @"forwardingTargetForSelector: should have forwarded");
    if (strcmp(_returnType,@encode(void))) {
        // return placeholder value
        if(objc_getAssociatedObject(_returnValue, "box")) {
            // boxed literal
            char buf[invocation_.methodSignature.methodReturnLength];
            [_returnValue getValue:&buf];
            [invocation_ setReturnValue:&buf];
        } else {
            // id
            [invocation_ setReturnValue:&_returnValue];
        }
    } else {
        // void
    }
}

@end
