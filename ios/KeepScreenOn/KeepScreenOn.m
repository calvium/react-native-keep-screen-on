//
//  KeepScreenOn.m
//  KeepScreenOn
//
//  Created by Mark Jamieson on 2016-10-18.
//  Copyright © 2016 Mark Jamieson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeepScreenOn.h"

@interface KeepScreenOn () {
    CGFloat _originalBrightness;
    CGFloat _dimmedBrightness;
}

@end

@implementation KeepScreenOn

RCT_EXPORT_MODULE ();

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _originalBrightness = fmax(0.7f, [UIScreen mainScreen].brightness);
        _dimmedBrightness = 0.2f;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(brightnessDidChange:)
                                                     name:UIScreenBrightnessDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// event coming from system brightness settings
- (void)brightnessDidChange:(NSNotification *)notification {
    _originalBrightness = [UIScreen mainScreen].brightness;
}


#pragma mark React Native Module Methods

// restore device brightness
RCT_EXPORT_METHOD (resetBrightness) {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIScreen mainScreen] setBrightness:_originalBrightness];
    }];
}

RCT_EXPORT_METHOD (setKeepScreenOn:(BOOL)screenShouldBeKeptOn)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:screenShouldBeKeptOn];
    });
}

RCT_EXPORT_METHOD (setCustomBrightness:(CGFloat)brightness)
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIScreen mainScreen] setBrightness:brightness];
    }];
}

RCT_EXPORT_METHOD (setOriginalBrightness:(CGFloat)brightness)
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _originalBrightness = brightness;
    }];
}

RCT_EXPORT_METHOD (getBrightness:(RCTResponseSenderBlock)callback)
{
    NSNumber *brightness = [NSNumber numberWithFloat:[UIScreen mainScreen].brightness];
    callback(@[brightness]);
}

@end
