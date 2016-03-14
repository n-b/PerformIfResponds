#import "NSObject+PerformIfResponds.h"

@interface PerformProxy : NSProxy

- (id) initWithTarget:(nonnull id)target_
           returnType:(nonnull const char*)returnType_
   returnValueHandler:(nonnull void(^)(NSInvocation*))handler_;

@end

@implementation NSObject (PerformProxy)

// Messages returning `void`: no need to set a fallback return value.
- (instancetype)performIfResponds
{
    return (id)[[PerformProxy alloc] initWithTarget:self returnType:@encode(void)
                                 returnValueHandler:^(NSInvocation* invocation_){}];
}

// Messages returning an object: simply set the fallback as the invocation return value.
- (instancetype)performOrReturn:(id)object_
{
    return (id)[[PerformProxy alloc] initWithTarget:self returnType:@encode(id)
                                 returnValueHandler:^(NSInvocation* invocation_){
                                     id obj = object_;
                                     [invocation_ setReturnValue:&obj];
                                 }];
}

// Messages returning a “value”: use the objcType of the passed NSValue, and “unbox” it into a local buffer to return it.
- (instancetype)performOrReturnValue:(NSValue*)value_
{
    return (id)[[PerformProxy alloc] initWithTarget:self returnType:value_.objCType
                                 returnValueHandler:^(NSInvocation* invocation_){
                                     char buf[invocation_.methodSignature.methodReturnLength];
                                     [value_ getValue:&buf];
                                     [invocation_ setReturnValue:&buf];
                                 }];
}

@end

@implementation PerformProxy
{
    id _target;
    const char * _returnType;
    void(^_returnValueHandler)(NSInvocation* invocation_);
}

- (id) initWithTarget:(nonnull id)target_
           returnType:(nonnull const char*)returnType_
   returnValueHandler:(nonnull void(^)(NSInvocation*))handler_
{
    _target = target_;
    _returnType = returnType_;
    _returnValueHandler = handler_;
    return self;
}

// Try to forward to the real target
- (id)forwardingTargetForSelector:(SEL)sel_
{
    if ([_target respondsToSelector:sel_]) {
        return _target;
    } else {
        return self;
    }
}

// Otherwise, handle the message ourselves
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel_
{
    NSString * types = [NSString stringWithFormat:@"%s%s%s",_returnType,@encode(id),@encode(SEL)];
    return [NSMethodSignature signatureWithObjCTypes:types.UTF8String];
}

- (void)forwardInvocation:(NSInvocation *)invocation_
{
    _returnValueHandler(invocation_);
}

@end
