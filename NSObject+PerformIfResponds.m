#import "NSObject+PerformIfResponds.h"

@interface CATPerformProxy : NSProxy
@end

@implementation CATPerformProxy
{
    id _target;

    id _obj;
    NSValue * _value;
    NSString *_types;
}

- (id)initWithTarget:(id)target_
{
    _target = target_;
    _types = [self selectorTypesForReturnType:@encode(void)];
    return self;
}

- (id)withObject:(id)value_
{
    _obj = value_;
    _types = [self selectorTypesForReturnType:@encode(id)];
    return self;
}

- (id)withNSValue:(NSValue*)pod_
{
    _value = pod_;
    _types = [self selectorTypesForReturnType:pod_.objCType];
    return self;
}

- (NSString *)selectorTypesForReturnType:(const char *)type_
{
    return [NSString stringWithFormat:@"%s%s%s",type_,@encode(id),@encode(SEL)];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel_
{
    if ([_target respondsToSelector:sel_]) {
        return [_target methodSignatureForSelector:sel_];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:_types.UTF8String];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation_
{
    if ([_target respondsToSelector:invocation_.selector]) {
        [invocation_ invokeWithTarget:_target];
    } else if (_obj) {
        [invocation_ setReturnValue:&_obj];
    } else if(_value) {
        char buf[invocation_.methodSignature.methodReturnLength];
        [_value getValue:&buf];
        [invocation_ setReturnValue:&buf];
    }
}

@end

@implementation NSObject (CATCompatibilityProxy)
- (instancetype)performIfResponds
{
    return (id)[[CATPerformProxy alloc] initWithTarget:self];
}
- (instancetype)performOr:(id)obj_;
{
    return (id)[[[CATPerformProxy alloc] initWithTarget:self] withObject:obj_];
}
- (instancetype)_performOrValue:(NSValue*)value_
{
    return (id)[[[CATPerformProxy alloc] initWithTarget:self] withNSValue:value_];
}
@end
