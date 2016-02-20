@import Foundation;

// Generic compatibility trampoline: forwards messages to the receiver only if it responds to it.
@interface NSObject (PerformProxy)

- (instancetype)performIfResponds;
- (instancetype)performOrReturn:(id)value;

#define performOrReturn(value)\
    performOrReturn: _Generic(value,\
                              id: value,\
                              default: ({typeof(value) _value = value;\
                                         _BoxedValue(&_value, @encode(typeof(_value)));\
                                        })\
                              )
id _BoxedValue(const void * bytes_, const char* type_);
@end

