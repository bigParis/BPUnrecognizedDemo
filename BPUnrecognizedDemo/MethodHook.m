//
//  MethodHook.m
//  MyTestDemos
//
//  Created by yy on 16/4/20.
//  Copyright © 2016年 yy. All rights reserved.
//

#import "MethodHook.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@implementation MethodHook

void crashFunction(id self, SEL _cmd, ...) {
    id value = nil;
    NSString *selString = NSStringFromSelector(_cmd);
    
    int cnt = 0, length = (int)selString.length;
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [selString rangeOfString: @":" options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            cnt++;
        }
    }
    
    va_list arg_ptr;
    va_start(arg_ptr, _cmd);
    
    for(int i = 0; i < cnt; i++)
    {
        value = va_arg(arg_ptr, id);
        NSLog(@"value%d=%@", i+1, value);
    }
    va_end(arg_ptr);
    NSLog(@"程序崩溃!");
    
}

+ (void)hookMethedClass:(Class)class hookSEL:(SEL)hookSEL originalSEL:(SEL)originalSEL myselfSEL:(SEL)mySelfSEL
{
    Method hookMethod = class_getInstanceMethod(class, hookSEL);
    Method mySelfMethod = class_getInstanceMethod(self, mySelfSEL);
    
    IMP hookMethodIMP = method_getImplementation(hookMethod);
    class_addMethod(class, originalSEL, hookMethodIMP, method_getTypeEncoding(hookMethod));
    
    IMP hookMethodMySelfIMP = method_getImplementation(mySelfMethod);
    class_replaceMethod(class, hookSEL, hookMethodMySelfIMP, method_getTypeEncoding(hookMethod));
}

+ (void)hookNotRecognizeSelector {
    [MethodHook hookMethedClass:[NSObject class] hookSEL:@selector(methodSignatureForSelector:) originalSEL:@selector(methodSignatureForSelectorOriginal:) myselfSEL:@selector(methodSignatureForSelectorMySelf:)];
    
    [MethodHook hookMethedClass:[NSObject class] hookSEL:@selector(forwardInvocation:) originalSEL:@selector(forwardInvocationOriginal:) myselfSEL:@selector(forwardInvocationMySelf:)];
    
}

- (NSMethodSignature *)methodSignatureForSelectorMySelf:(SEL)aSelector {
//    NSString *clsString = NSStringFromClass([self class]);
//    if ([clsString rangeOfString:@"MF"].location == NSNotFound) {
//        return [self methodSignatureForSelectorOriginal:aSelector];
//    }
    NSString *sel = NSStringFromSelector(aSelector);
    if ([sel rangeOfString:@"set"].location == 0) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
}

- (NSMethodSignature *)methodSignatureForSelectorOriginal:(SEL)aSelector {
    return nil;
}

- (void)forwardInvocationMySelf:(NSInvocation *)anInvocation {
    Class cls = [anInvocation.target class];
    class_addMethod(cls, anInvocation.selector, (IMP)crashFunction, "v@:@@");
    if ([anInvocation.target respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:anInvocation.target];
    }
}

- (void)forwardInvocationOriginal:(NSInvocation *)anInvocation {
    
}
@end
