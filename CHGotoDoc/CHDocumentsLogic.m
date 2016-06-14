//
//  CHDocumentsLogic.m
//  CHGotoDoc
//
//  Created by Jiang on 16/6/13.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "CHDocumentsLogic.h"
#import "CHDocumentsCache.h"

@implementation CHDocumentsLogic
+ (void)installDoc
{
    NSString *devicesPath = [self devicesPath];
    NSArray *deviceIds = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:devicesPath error:nil];
    if (deviceIds.count == 0) {
        return ;
    }
    for (NSString *deviceId in deviceIds) {
        NSString *devicePath = [devicesPath stringByAppendingPathComponent:deviceId];
        
        NSString *devicePlist = [devicePath stringByAppendingPathComponent:@"device.plist"];
        NSString *appPath = [devicePath stringByAppendingString:@"/data/Containers/Data/Application"];
        NSString *pluginPath = [devicePath stringByAppendingString:@"/data/Containers/Data/PluginKitPlugin"];
        NSString *groupPath = [devicePath stringByAppendingString:@"/data/Containers/Shared/AppGroup"];
        
        NSArray <CHDocumentItem*>* partItemsApp = [self installDocWithAppPath:appPath isGroup:NO];
        if (partItemsApp.count == 0) {
            continue;
        }
        NSArray <CHDocumentItem*>* partItemsPlugin = [self installDocWithAppPath:pluginPath isGroup:NO];
        NSArray <CHDocumentItem*>* partItemsGroup = [self installDocWithAppPath:groupPath isGroup:YES];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:devicePlist]){
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:devicePlist];
            NSString *deviceType = [dict[@"deviceType"] componentsSeparatedByString:@"."].lastObject ?: @"";
            NSString *osVersion = [dict[@"runtime"] componentsSeparatedByString:@"."].lastObject ?: @"";
            [partItemsApp enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
                obj.device = deviceType;
                obj.osVersion = osVersion;
                [[CHDocumentsCache sharedInstance] addAppPath:obj];
            }];
            [partItemsPlugin enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
                obj.device = deviceType;
                obj.osVersion = osVersion;
                [[CHDocumentsCache sharedInstance] addPluginPath:obj];
            }];
            [partItemsGroup enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
                obj.device = deviceType;
                obj.osVersion = osVersion;
                [[CHDocumentsCache sharedInstance] addGroupPath:obj];
            }];
        }
    }
    [[CHDocumentsCache sharedInstance] sort];
}

+ (NSArray <CHDocumentItem*>*)installDocWithAppPath:(NSString *)appsPath isGroup:(BOOL)isGroup
{
    NSArray *appIds = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appsPath error:nil];
    if (appIds.count == 0) {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *appId in appIds) {
        NSString *appPath = [appsPath stringByAppendingPathComponent:appId];
        NSString *appPlist = [appPath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:appPlist]){
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:appPlist];
            NSString *bundleId = [dict valueForKeyPath:@"MCMMetadataIdentifier"];
            
            if (bundleId.length == 0) {
                continue;
            }
            if (isGroup) {
                if ([bundleId hasPrefix:@"group.com.apple."]) {
                    continue;
                }
            }
            // group has bundleId with com.apple...
            if ([bundleId hasPrefix:@"com.apple."]) {
                continue;
            }
            
            CHDocumentItem *item = [[CHDocumentItem alloc] init];
            item.path = appPath;
            if (!isGroup) {
                item.path = [item.path stringByAppendingPathComponent:@"Documents"];
            }
            item.bundleId = bundleId;
            [result addObject:item];
        }
    }
    return result;
}

+ (NSString*)devicesPath
{
    return [NSString stringWithFormat:@"%@/Library/Developer/CoreSimulator/Devices/", NSHomeDirectory()];
}
@end
