//
//  NSNotification+CHPlugin.h
//  CHPlugin
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotification (CHPlugin)

- (NSString*)chGetDeviceAppPath;
- (NSString*)chGetBundleId;
- (NSString*)chGetDeviceId;
- (NSString*)chGetInfoPath;
- (NSString*)chGetDeviceType;
- (NSString*)chGetSchemeName;
- (NSString*)chGetOSVersion;
@end
