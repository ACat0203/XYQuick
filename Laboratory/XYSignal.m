//
//  XYSignal.m
//  JoinShow
//
//  Created by heaven on 15/2/28.
//  Copyright (c) 2015年 Heaven. All rights reserved.
//

#import "XYSignal.h"
#import <objc/runtime.h>

#define kUXYSignalHandler_key "NSObject.signalHandler.key"

@implementation XYSignal

+ (id)signalWithName:(NSString *)name
{
    return nil;
}

- (BOOL)send
{
    /*
    NSObject *targetObject = self.target;
    if ( nil == targetObject )
    {
        return _isReach;
    }
    
    NSString *selectorName  = nil;
    SEL selector            = nil;
    
    NSString *selectorName2 = nil;
    SEL selector2           = nil;
    
    NSString *signalPrefix  = nil;
    NSString *signalClass   = nil;
    NSString *signalMethod  = nil;
    
    if ( self.name && [self.name hasPrefix:@"signal."] )
    {
        NSArray * array = [self.name componentsSeparatedByString:@"."];
        if ( array && array.count > 1 )
        {
            signalPrefix    = (NSString *)[array objectAtIndex:0];
            signalClass     = (NSString *)[array objectAtIndex:1];
            signalMethod    = (NSString *)[array objectAtIndex:2];
        }
    }
     */
    
    return YES;
}
@end

#pragma mark- UXYSignalHandler
@interface NSObject (UXYSignalHandler) <XYSignalTarget>
@end

@implementation NSObject (UXYSignalHandler)

@dynamic uxy_nextSignalHandler;

- (id)uxy_performSignal:(XYSignal *)signal
{
    id result;
    [signal send];
    
    if (signal.isDead == YES) return;
    if (signal.isReach == YES) return;
    
    id next = self.uxy_nextSignalHandler ?: self.uxy_defaultNextSignalHandler;
    
    result = [next uxy_performSignal:signal];
    
    return result;
}


/*
- (void)uxy_sendSignal:(XYSignal *)signal
{
    [signal send];
    
    if (signal.isDead == YES)
    {
        return;
    }
    
    if (signal.isReach == YES)
    {
        return;
    }
    
    id next = self.uxy_nextSignalHandler ?: [self uxy_defaultNextSignalHandler];
    if (next)
    {
        signal.jump++;
        [next uxy_sendSignal:signal];
    }
    else
    {
        signal.isReach = YES;
    }
}
*/

- (void)setUxy_NextSignalHandler:(id)nextSignalHandler
{
    objc_setAssociatedObject(self, kUXYSignalHandler_key, nextSignalHandler, OBJC_ASSOCIATION_ASSIGN);
}

- (id)uxy_NextSignalHandler
{
    return objc_getAssociatedObject(self, kUXYSignalHandler_key);
}

#pragma mark- private

- (id)uxy_defaultNextSignalHandler
{
    return nil;
}

@end

#pragma mark - UIView

@implementation UIView (UXYSignalHandler)

- (id)uxy_defaultNextSignalHandler
{
    return self.superview ?: self.nextResponder;
}

// 发送一个signal
- (XYSignal *)uxy_sendSignalWithName:(NSString *)name
{
   return [self uxy_sendSignalWithName:name userInfo:nil sender:self];
}
- (XYSignal *)uxy_sendSignalWithName:(NSString *)name userInfo:(id)userInfo
{
   return [self uxy_sendSignalWithName:name userInfo:userInfo sender:self];
}
- (XYSignal *)uxy_sendSignalWithName:(NSString *)name userInfo:(id)userInfo sender:(id)sender
{
    XYSignal *signal = [[XYSignal alloc] init];
    
    if ( signal )
    {
        signal.sender = sender ?: self;
       // signal.target = self;
        signal.name   = name;
        signal.userInfo = userInfo;
    }
    
  //  [self uxy_sendSignal:signal];
    
    return signal;
}

#pragma mark- private

@end

#pragma mark - UIViewController

@implementation UIViewController (UXYSignalHandler)

- (id)uxy_defaultNextSignalHandler
{
    id defaultNext;
    
    if ([self isKindOfClass:[UINavigationController class]])
    {
        //defaultNext = [(UINavigationController *)self topViewController];
    }
    else
    {
        defaultNext = [self parentViewController];
    }
    
    return defaultNext;
}

@end

#pragma mark -
@implementation XYSignalBus

+ (instancetype)defaultBus
{
    static dispatch_once_t once;
    static id __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}

@end

