//
//  KeepScreenOn.m
//  KeepScreenOn
//
//  Created by Mark Jamieson on 2016-10-18.
//  Copyright © 2016 Mark Jamieson. All rights reserved.
//

#import "KeepScreenOn.h"

// delegate type to pass tap event back to module
@protocol AutoDimTapDelegate
- (void)handleTap;
@end


// need to subclass view so we can catch tap events and
// still pass them all through without interfering
@interface AutoDimView : UIView

@property (nonatomic, weak) id<AutoDimTapDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<AutoDimTapDelegate>)delegate;

@end

@implementation AutoDimView

- (id)initWithFrame:(CGRect)frame delegate:(id<AutoDimTapDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        _delegate = delegate;
    }
    
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // just send all events through to delegate
    if (self.delegate) {
        [self.delegate handleTap];
    }
    // send all events onward
    return NO;
}

@end

@interface KeepScreenOn() {
    CGFloat _originalBrightness;
    CGFloat _dimmedBrightness;
    BOOL _shouldAutoDim; // is autoDim currently enabled
    BOOL _autoDimWasEnabled; // was autoDim enabled when the app was last active
    CGFloat _dimTimeout;
    UIGestureRecognizer *_gestureRecognizer;
}

@end

@implementation KeepScreenOn

RCT_EXPORT_MODULE();

- (id)init {
    self = [super init];
    
    if (self) {
        _shouldAutoDim = NO;
        _autoDimWasEnabled = NO;

        // defaults
        _dimTimeout = 5.0f;
        _originalBrightness = fmax(0.7f, [UIScreen mainScreen].brightness);
        _dimmedBrightness = 0.2f;
        
        UIView *root = [self getRootView];
        AutoDimView *newView = [[AutoDimView alloc] initWithFrame:root.bounds delegate:self];
        
        newView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [root addSubview:newView];
    }
    
    return self;
}

// get the Root React native View
- (UIView *)getRootView {
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    if (window && window.rootViewController) {
        return window.rootViewController.view;
    }
    
    return nil;
}

// user tapped the screen
- (void)handleTap {
    [self cancelAutoDim];
    [self unDimScreen];
    
    if (_shouldAutoDim) {
        [self startAutoDim];
    }
}

// dim the screen after a timeout
- (void)startAutoDim {
    [self performSelector:@selector(dimScreen) withObject:nil afterDelay:_dimTimeout];
}

// cancel currently queued dim command
- (void)cancelAutoDim {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

// is autodim currently enabled
- (BOOL)isDimmingEnabled {
    return _shouldAutoDim;
}

// turn on auto dimming and set dim value and timeout duration
- (void)enableAutoDimWithTimeout:(CGFloat)timeout
                      brightness:(CGFloat)brightness
{
    _dimTimeout = timeout;
    _dimmedBrightness = brightness;
    
    if (!_shouldAutoDim) {
        _shouldAutoDim = YES;
        [self startAutoDim];
    }
}

// turn off auto dim
- (void)disableAutoDim {
    _shouldAutoDim = NO;
    [self unDimScreen];
    [self cancelAutoDim];
}

// set the device brightness to the dim setting
- (void)dimScreen {
    [[UIScreen mainScreen] setBrightness:fmin(_dimmedBrightness, [UIScreen mainScreen].brightness)];
}

// restore device brightness
- (void)unDimScreen {
    [[UIScreen mainScreen] setBrightness:_originalBrightness];
}

#pragma mark React Native Module Methods

RCT_EXPORT_METHOD(setKeepScreenOn:(BOOL)screenShouldBeKeptOn)
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:screenShouldBeKeptOn];
}

RCT_EXPORT_METHOD(setBrightness:(CGFloat)brightness)
{
    [[UIScreen mainScreen] setBrightness:brightness];
}

RCT_EXPORT_METHOD(setOriginalBrightness:(CGFloat)brightness)
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        _originalBrightness = brightness;
    }];
}

RCT_EXPORT_METHOD(getBrightness:(RCTResponseSenderBlock)callback)
{
    NSNumber *brightness = [NSNumber numberWithFloat:[UIScreen mainScreen].brightness];
    callback(@[brightness]);
}

RCT_EXPORT_METHOD(getAutoDimEnabled:(RCTResponseSenderBlock)callback)
{
    // hmm, is this ok on the JS thread?
    BOOL enabled = [self isDimmingEnabled];
    callback(@[@(enabled)]);
}

RCT_EXPORT_METHOD(setEnableAutoDim:(CGFloat)timeout
                  brightness:(CGFloat)brightness)
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self enableAutoDimWithTimeout:timeout brightness:brightness];
    }];
}

RCT_EXPORT_METHOD(setDisableAutoDim)
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self disableAutoDim];
    }];
}

RCT_EXPORT_METHOD(autoDimOnChangedAppState:(NSString *)appState)
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        if ([appState isEqualToString:@"inactive"]) {
            _autoDimWasEnabled = _shouldAutoDim;
            [self disableAutoDim];
        } else if ([appState isEqualToString:@"active"]) {
            _originalBrightness = [UIScreen mainScreen].brightness;

            if (_autoDimWasEnabled) {
                [self enableAutoDimWithTimeout:_dimTimeout brightness:_dimmedBrightness];
            }
        }
    }];
}


@end
