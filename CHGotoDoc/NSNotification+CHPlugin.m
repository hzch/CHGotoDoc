//
//  NSNotification+CHPlugin.m
//  CHPlugin
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "NSNotification+CHPlugin.h"
#import "NSObject+CHIgnoreUndefinedKey.h"

@implementation NSNotification (CHPlugin)
- (NSString*)chGetDeviceAppPath
{
    NSString *deviceId = [self chGetDeviceId];
    if (deviceId.length == 0) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Data/Application", NSHomeDirectory(),deviceId];
}

- (NSString*)chGetBundleId
{
    NSString *infoPath = [self chGetInfoPath];
    if (infoPath.length == 0) {
        return nil;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:infoPath];
    return dic[@"CFBundleIdentifier"];
}

- (NSString*)chGetDeviceId
{
    return [self.object valueForKeyPath:@"_buildParameters._activeRuDestination._targetDevice._identifier"];
}

- (NSString*)chGetInfoPath
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    id Xcode3TargetProduct = buildables[0];
    if (![Xcode3TargetProduct isKindOfClass:NSClassFromString(@"Xcode3TargetProduct").class]) {
        NSLog(@"No Xcode3TargetProduct in buildables.");
        return nil;
    }
    return [self.object valueForKeyPath:@"_blueprint._pbxTarget._infoPlistRef._absolutePath"];
}
@end
