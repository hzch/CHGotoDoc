//
//  CHDocumentsCache.m
//  CHGotoDoc
//
//  Created by Jiang on 16/6/13.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "CHDocumentsCache.h"

static NSString* const kCHDocumnetsUserDefaultKey = @"CHDocumnetsUserDefaultKey";
static NSString* const kCHDocumnetsUserDefaultKeyApp = @"CHDocumnetsUserDefaultKey";
static NSString* const kCHDocumnetsUserDefaultKeyPlugin = @"CHDocumnetsUserDefaultKey";
static NSString* const kCHDocumnetsUserDefaultKeyGroup = @"CHDocumnetsUserDefaultKey";

@interface CHDocumentsCache ()
@property (nonatomic) NSMutableArray <CHDocumentItem*>*appDocumentsPathInner;
@property (nonatomic) NSMutableArray <CHDocumentItem*>*pluginDocumentsPathInner;
@property (nonatomic) NSMutableArray <CHDocumentItem*>*groupDocumentsPathInner;
@end

@implementation CHDocumentsCache
+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _appDocumentsPathInner = [NSMutableArray array];
        _pluginDocumentsPathInner = [NSMutableArray array];
        _groupDocumentsPathInner = [NSMutableArray array];
    }
    return self;
}

- (void)addAppPath:(CHDocumentItem*)item
{
    if (item.path.length == 0) {
        return;
    }
    [self.appDocumentsPathInner enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.path isEqualToString:item.path]) {
            [self.appDocumentsPathInner removeObjectAtIndex:idx];
            *stop = YES
            ;
            return ;
        }
    }];
    [self.appDocumentsPathInner addObject:item];
}

- (void)addPluginPath:(CHDocumentItem*)item
{
    if (item.path.length == 0) {
        return;
    }
    [self.pluginDocumentsPathInner enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.path isEqualToString:item.path]) {
            [self.pluginDocumentsPathInner removeObjectAtIndex:idx];
            *stop = YES
            ;
            return ;
        }
    }];
    [self.pluginDocumentsPathInner addObject:item];
}

- (void)addGroupPath:(CHDocumentItem*)item
{
    if (item.path.length == 0) {
        return;
    }
    [self.groupDocumentsPathInner enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.path isEqualToString:item.path]) {
            [self.groupDocumentsPathInner removeObjectAtIndex:idx];
            *stop = YES
            ;
            return ;
        }
    }];
    [self.groupDocumentsPathInner addObject:item];
}

- (void)sort
{
    [self.appDocumentsPathInner sortUsingComparator:^NSComparisonResult(CHDocumentItem *obj1, CHDocumentItem *obj2) {
        return [obj1.description compare:obj2.description];
    }];
    [self.pluginDocumentsPathInner sortUsingComparator:^NSComparisonResult(CHDocumentItem *obj1, CHDocumentItem *obj2) {
        return [obj1.description compare:obj2.description];
    }];
    [self.groupDocumentsPathInner sortUsingComparator:^NSComparisonResult(CHDocumentItem *obj1, CHDocumentItem *obj2) {
        return [obj1.description compare:obj2.description];
    }];
}

- (NSArray<CHDocumentItem *> *)appDocumentsPath
{
    return [[self.appDocumentsPathInner reverseObjectEnumerator] allObjects];
}

- (NSArray<CHDocumentItem *> *)pluginDocumentsPath
{
    return [[self.pluginDocumentsPathInner reverseObjectEnumerator] allObjects];
}

- (NSArray<CHDocumentItem *> *)groupDocumentsPath
{
    return [[self.groupDocumentsPathInner reverseObjectEnumerator] allObjects];
}

#pragma mark - user default
- (void)loadDataFromGroup
{
    _appDocumentsPathInner = [NSMutableArray array];
    _pluginDocumentsPathInner = [NSMutableArray array];
    _groupDocumentsPathInner = [NSMutableArray array];
    
    NSDictionary *allDoc = [[NSUserDefaults standardUserDefaults] objectForKey:kCHDocumnetsUserDefaultKey];
    NSArray *appDoc = allDoc[kCHDocumnetsUserDefaultKeyApp];
    NSArray *pluginDoc = allDoc[kCHDocumnetsUserDefaultKeyPlugin];
    NSArray *groupDoc = allDoc[kCHDocumnetsUserDefaultKeyGroup];
    
    [appDoc enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [_appDocumentsPathInner addObject:[[CHDocumentItem alloc] initWithJson:obj]];
    }];
    [pluginDoc enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [_pluginDocumentsPathInner addObject:[[CHDocumentItem alloc] initWithJson:obj]];
    }];
    [groupDoc enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [_groupDocumentsPathInner addObject:[[CHDocumentItem alloc] initWithJson:obj]];
    }];
}

- (void)flushDataToGroup
{
    NSMutableArray *appDoc = [NSMutableArray array];
    NSMutableArray *pluginDoc = [NSMutableArray array];
    NSMutableArray *groupDoc = [NSMutableArray array];
    
    [_appDocumentsPathInner enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        [appDoc addObject:obj.encodeTo];
    }];
    [_pluginDocumentsPathInner enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        [pluginDoc addObject:obj.encodeTo];
    }];
    [_groupDocumentsPathInner enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        [groupDoc addObject:obj.encodeTo];
    }];
    
    NSDictionary *allDoc = @{kCHDocumnetsUserDefaultKeyApp:appDoc,
                             kCHDocumnetsUserDefaultKeyPlugin:pluginDoc,
                             kCHDocumnetsUserDefaultKeyGroup:groupDoc};
    [[NSUserDefaults standardUserDefaults] setObject:allDoc forKey:kCHDocumnetsUserDefaultKey];
}
@end
