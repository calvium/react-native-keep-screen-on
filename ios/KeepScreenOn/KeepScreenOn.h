//
//  KeepScreenOn.h
//  KeepScreenOn
//
//  Created by Mark Jamieson on 2016-10-18.
//  Copyright © 2016 Mark Jamieson. All rights reserved.
//

#import <Foundation/Foundation.h>

// handle the RN 0.39 - 0.40 import breaking change
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#if __has_include("RCTView.h")
#import "RCTView.h"
#else
#import <React/RCTView.h>
#endif

@interface KeepScreenOn : NSObject <RCTBridgeModule>

@end
