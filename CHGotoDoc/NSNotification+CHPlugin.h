//
//  NSNotification+CHPlugin.h
//  CHPlugin
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotification (CHPlugin)

- (NSArray*)chGetDeviceAppPath;
- (NSArray*)chGetBundleId;
- (NSArray*)chGetInfoPath;
- (NSString*)chGetDeviceId;
- (NSString*)chGetDeviceType;
- (NSString*)chGetSchemeName;
- (NSString*)chGetOSVersion;
@end
