@import Foundation;

/// Optional Message Proxy
///
/// Send any message without checking with `respondsToSelector:`.
///
@interface NSObject (PerformProxy)

/// Returns a proxy object for the receiver.
///
/// That proxy forwards messages to the original target, if it responds to it.
/// Unhandled messages are silently eaten.
/// Use this if actual method is expected to return `void`.
///
/// “instancetype”, of course, is a lie.
/// It makes clang and Xcode we’re still dealing with the original target type.
///
- (instancetype)performIfResponds;

/// Returns a proxy object for the receiver.
///
/// That proxy returns `object_` for messages unhandled by the original target.
/// Use this if the actual method is expected to return `id`.
///
- (instancetype)performOrReturn:(id)object_;

/// Returns a proxy object for the receiver.
///
/// returns `value`, unboxed, for messages unhandled by the original target.
/// Use this if the actual message is expected to return a literal, struct or any other non-object type.
/// `value_.objCType` should match the actual method return type.
///
/// Most raw types can be boxed using `@()`, and most Apple-provided structures have helpers for NSValue.
/// Otherwise, use `__attribute__((objc_boxable))` or `[NSValue valueWithBytes: objCType:]`.
///
- (instancetype)performOrReturnValue:(NSValue*)value_;

@end

