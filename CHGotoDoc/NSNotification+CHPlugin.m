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

- (NSArray*)chGetDeviceAppPath
{
    NSString *deviceId = [self chGetDeviceId];
    if (deviceId.length == 0) {
        return nil;
    }
    NSArray *types = [self chGetTargetType];
    NSMutableArray *result = [NSMutableArray array];
    [types enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        CHTargetType type = obj.integerValue;
        NSString *path;
        switch (type) {
            case CHTargetTypeApp:
                path = [NSString stringWithFormat:@"%@/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Data/Application", NSHomeDirectory(),deviceId];
                break;
            case CHTargetTypeEx:
                path =  [NSString stringWithFormat:@"%@/Library/Developer/CoreSimulator/Devices/%@/data/Containers/Data/PluginKitPlugin", NSHomeDirectory(),deviceId];
                break;
            default:
                path =  @"";
        }
        [result addObject:path];
    }];
    return result;
}

- (NSArray*)chGetTargetType
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return CHTargetTypeUnkown;
    }
    NSMutableArray *result = [NSMutableArray array];
    [buildables enumerateObjectsUsingBlock:^(id  Xcode3TargetProduct, NSUInteger idx, BOOL *stop) {
        NSString *typeStr = [Xcode3TargetProduct valueForKeyPath:@"_filePath._pathString"];
        if (![typeStr isKindOfClass:NSString.class]) {
            [result addObject:@(CHTargetTypeUnkown)];
            return ;
        }
        NSString *fileExtension = [self chFileExtensionWithString:typeStr];
        if ([fileExtension isEqualToString:@"app"]) {
            [result addObject:@(CHTargetTypeApp)];
        } else if ([fileExtension isEqualToString:@"appex"]) {
            [result addObject:@(CHTargetTypeEx)];
        } else {
            [result addObject:@(CHTargetTypeUnkown)];
        }
        return ;
    }];
    return result;
}

- (NSArray*)chGetBundleId2
{
    NSArray *paths = [self chGetInfoPath];
    NSMutableArray *result = [NSMutableArray array];
    [paths enumerateObjectsUsingBlock:^(NSString *infoPath, NSUInteger idx, BOOL *stop) {
        if (infoPath.length == 0) {
            [result addObject:@""];
            return ;
        }
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:infoPath];
        [result addObject:dic[@"CFBundleIdentifier"]?:@""];
    }];
    return result;
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

- (NSArray*)chGetInfoPath
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    [buildables enumerateObjectsUsingBlock:^(id  Xcode3TargetProduct, NSUInteger idx, BOOL *stop) {
        NSString *path = [Xcode3TargetProduct valueForKeyPath:@"_blueprint._pbxTarget._infoPlistRef._absolutePath"];
        [result addObject:path ?: @""];
    }];
    return result;
}

- (NSArray*)chGetBundleId
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray array];
    NSArray *bundleId2 = [self chGetBundleId2];
    NSArray *projectPaths = [self chGetProjectPath];
    [buildables enumerateObjectsUsingBlock:^(id  Xcode3TargetProduct, NSUInteger idx, BOOL *stop) {
        NSArray *subsections = [Xcode3TargetProduct valueForKeyPath:@"_blueprint._integrityLog._subsections"];
        NSString *bundleId;
        if (![subsections isKindOfClass:NSArray.class]) {
            bundleId = bundleId2.count > idx ? bundleId2[idx] : @"";
        } else {
            id IDEActivityLogSection = subsections[0];
            bundleId = [IDEActivityLogSection valueForKeyPath:@"_representedObject._infoPlistSettings.CFBundleIdentifier"];
            
        }
        if (![bundleId hasPrefix:@"$(PRODUCT_BUNDLE_IDENTIFIER)"]) {
            [result addObject:bundleId?:@""];
            return ;
        }
        
        // 以下方法很脆 待改进
        NSString *projectPath = projectPaths.count > idx ? projectPaths[idx] : @"";
        if (projectPath.length == 0) {
            [result addObject:@""];
            return ;
        }
        projectPath = [projectPath stringByAppendingString:@"/project.pbxproj"];
        NSString *project = [NSString stringWithContentsOfFile:projectPath encoding:NSUTF8StringEncoding error:nil];
        NSRange range = [project rangeOfString:@"PRODUCT_BUNDLE_IDENTIFIER"];
        if (range.length == 0) {
            [result addObject:@""];
            return ;
        }
        
        NSString *tmp = [project substringWithRange:NSMakeRange(range.location + range.length + 3, 100)];
        range = [tmp rangeOfString:@";"];
        NSString *productBI = [tmp substringToIndex:range.location];
        NSString *bid = [bundleId stringByReplacingOccurrencesOfString:@"$(PRODUCT_BUNDLE_IDENTIFIER)" withString:productBI];
        [result addObject:bid];
    }];
    return result;
}

- (NSArray*)chGetProjectPath
{
    NSArray *buildables = [self.object valueForKey:@"_buildables"];
    if (![buildables isKindOfClass:NSArray.class]) {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray array];
    [buildables enumerateObjectsUsingBlock:^(id Xcode3TargetProduct, NSUInteger idx, BOOL *stop) {
        
        NSString *path = [Xcode3TargetProduct valueForKeyPath:@"_blueprint._proxy._indexableObject._project._filePath._pathString"];
        [result addObject:path ?: @""];
    }];
    return result;
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
