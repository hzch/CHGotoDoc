//
//  NSNotification+CHPlugin.m
//  CHPlugin
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "NSNotification+CHPlugin.h"
#import "NSObject+CHIgnoreUndefinedKey.h"

typedef NS_ENUM(NSUInteger, CHTargetType) {
    CHTargetTypeUnkown,
    CHTargetTypeApp,
    CHTargetTypeEx,
};

@implementation NSNotification (CHPlugin)
- (NSString*)chGetDeviceAppPath
{
    NSString *deviceId = [self chGetDeviceId];
    if (deviceId.length == 0) {
        return nil;
    }
    CHTargetType type = [self chGetTargetType];
    switch (type) {
        case CHTargetTypeApp:
            return [NSString stringWithFormat:@"%@/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Data/Application", NSHomeDirectory(),deviceId];
            break;
        case CHTargetTypeEx:
            return [NSString stringWithFormat:@"%@/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Data/PluginKitPlugin", NSHomeDirectory(),deviceId];
            break;
            
        default:
            return nil;
    }
}

- (CHTargetType)chGetTargetType
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return CHTargetTypeUnkown;
    }
    
    id Xcode3TargetProduct = buildables[0];
    NSString *typeStr = [Xcode3TargetProduct valueForKeyPath:@"_filePath._pathString"];
    if (![typeStr isKindOfClass:NSString.class]) {
        return CHTargetTypeUnkown;
    }
    NSString *fileExtension = [self chFileExtensionWithString:typeStr];
    if ([fileExtension isEqualToString:@"app"]) {
        return CHTargetTypeApp;
    } else if ([fileExtension isEqualToString:@"appex"]) {
        return CHTargetTypeEx;
    }
    return CHTargetTypeUnkown;
}

- (NSString*)chGetBundleId2
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
    return [self.object valueForKeyPath:@"_buildParameters._activeRunDestination._targetDevice._identifier"];
}

- (NSString*)chGetDeviceType
{
    return [[self.object valueForKeyPath:@"_buildParameters._activeRunDestination._targetDevice._device._deviceTypeIdentifier"] componentsSeparatedByString:@"."].lastObject;
}

- (NSString*)chGetOSVersion
{
    return [[self.object valueForKeyPath:@"_buildParameters._activeRunDestination._targetDevice._device._runtimeIdentifier"] componentsSeparatedByString:@"."].lastObject;
}

- (NSString*)chGetSchemeName
{
    return [self.object valueForKeyPath:@"_schemeIdentifier._entityName"];
}

- (NSString*)chGetInfoPath
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    id Xcode3TargetProduct = buildables[0];
    return [Xcode3TargetProduct valueForKeyPath:@"_blueprint._pbxTarget._infoPlistRef._absolutePath"];
}

- (NSString*)chGetBundleId
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    id Xcode3TargetProduct = buildables[0];
    NSArray *subsections = [Xcode3TargetProduct valueForKeyPath:@"_blueprint._integrityLog._subsections"];
    NSString *bundleId;
    if (![subsections isKindOfClass:NSArray.class]) {
        bundleId = [self chGetBundleId2];
    } else {
        id IDEActivityLogSection = subsections[0];
        bundleId = [IDEActivityLogSection valueForKeyPath:@"_representedObject._infoPlistSettings.CFBundleIdentifier"];
        
    }
    if (![bundleId hasPrefix:@"$(PRODUCT_BUNDLE_IDENTIFIER)"]) {
        return bundleId;
    }
    
    NSString *projectPath = [self chGetProjectPath];
    if (projectPath.length == 0) {
        return nil;
    }
    projectPath = [projectPath stringByAppendingString:@"/project.pbxproj"];
    NSString *project = [NSString stringWithContentsOfFile:projectPath encoding:NSUTF8StringEncoding error:nil];
    NSRange range = [project rangeOfString:@"PRODUCT_BUNDLE_IDENTIFIER"];
    if (range.length == 0) {
        return nil;
    }
    
    NSString *tmp = [project substringWithRange:NSMakeRange(range.location + range.length + 3, 100)];
    range = [tmp rangeOfString:@";"];
    NSString *productBI = [tmp substringToIndex:range.location];
    return [bundleId stringByReplacingOccurrencesOfString:@"$(PRODUCT_BUNDLE_IDENTIFIER)" withString:productBI];
}

- (NSString*)chGetProjectPath
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    id Xcode3TargetProduct = buildables[0];
    return [Xcode3TargetProduct valueForKeyPath:@"_blueprint._proxy._indexableObject._project._filePath._pathString"];
}
#pragma mark - Misc
- (NSString *)chFileExtensionWithString:(NSString*)string
{
    NSString* file_name = [string lastPathComponent];
    NSRange range = [file_name rangeOfString:@"." options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return @"";
    }
    
    return [file_name substringFromIndex:range.location + 1];
}
@end
