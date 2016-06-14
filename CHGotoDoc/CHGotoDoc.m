//
//  CHGotoDoc.m
//  CHGotoDoc
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "CHGotoDoc.h"
#import "CHDocumentsLogic.h"
#import "CHDocumentsCache.h"

static NSString * const kCHPluginsMenuTitle = @"Plugins";

@interface CHGotoDoc ()
@property (nonatomic) NSMenuItem *pluginsMenuItem;
@property (nonatomic) NSMenuItem *recentDocsMenuItem;
@property (nonatomic) NSMenuItem *appDocsMenuItem;
@property (nonatomic) NSMenuItem *pluginDocsMenuItem;
@property (nonatomic) NSMenuItem *groupDocsMenuItem;

@property (nonatomic) NSFileManager *fileManager;
@end

@implementation CHGotoDoc

#pragma mark - life cycle
/// 系统接口，Xcode启动时会调
+(void)pluginDidLoad:(NSBundle *)plugin
{
    [self sharedInstance];
}

/// 保证生命周期与Xcode相同
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
    if (self = [super init]) {
        [CHDocumentsLogic installDoc];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addPluginMenu)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(buildWillStart:)
                                                     name:@"IDEBuildOperationWillStartNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateDocList)
                                                     name:@"NSMenuDidBeginTrackingNotification"
                                                   object:nil];
    }
    return self;
}

#pragma mark - NSNotification
- (void)addPluginMenu
{
    [self pluginsMenuItem];
    [self updateDocList];
}

- (void)gotoButtonClick:(NSMenuItem*)menu
{
    NSString *open = [NSString stringWithFormat:@"open %@",menu.representedObject];
    const char *str = [open UTF8String];
    system(str);
}

- (void)buildWillStart:(NSNotification *)notification
{
    [CHDocumentsLogic installDoc];
    [CHDocumentsLogic updateCurrentApp:notification];
}

- (void)updateDocList
{
    [self.recentDocsMenuItem.submenu removeAllItems];
    
    NSArray <CHDocumentItem*>*recentDocs = [CHDocumentsLogic getRecentDocuments];
    if (recentDocs.count == 0) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.title = @"Not found!";
        [self.recentDocsMenuItem.submenu addItem:item];
    } else {
        [recentDocs enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
            [self addDocsToMenu:self.recentDocsMenuItem doc:obj];
        }];
    }
    
    [self.appDocsMenuItem.submenu removeAllItems];
    NSArray <CHDocumentItem*>*appDocs = [CHDocumentsCache sharedInstance].appDocumentsPath;
    [appDocs enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        [self addDocsToMenu:self.appDocsMenuItem doc:obj];
    }];
    
    [self.pluginDocsMenuItem.submenu removeAllItems];
    NSArray <CHDocumentItem*>*pluginDocs = [CHDocumentsCache sharedInstance].pluginDocumentsPath;
    [pluginDocs enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        [self addDocsToMenu:self.pluginDocsMenuItem doc:obj];
    }];
    
    [self.groupDocsMenuItem.submenu removeAllItems];
    NSArray <CHDocumentItem*>*groupDocs = [CHDocumentsCache sharedInstance].groupDocumentsPath;
    [groupDocs enumerateObjectsUsingBlock:^(CHDocumentItem *obj, NSUInteger idx, BOOL *stop) {
        [self addDocsToMenu:self.groupDocsMenuItem doc:obj];
    }];
}

#pragma mark - Add Menu
- (void)addDocsToMenu:(NSMenuItem*)menu doc:(CHDocumentItem*)doc
{
    if (![self.fileManager fileExistsAtPath:doc.path]) {
        return;
    }
    [menu.submenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.representedObject = doc.path;
    item.title = doc.description;
    item.target = self;
    item.action = @selector(gotoButtonClick:);
    [menu.submenu addItem:item];
    
    [self addFilesToMenu:menu path:doc.path];
}

- (void)addFilesToMenu:(NSMenuItem*)menu path:(NSString*)path
{
    if (path.length == 0) {
        return ;
    }
    NSArray *files = [self.fileManager contentsOfDirectoryAtPath:path error:nil];
    if (files.count == 0) {
        return;
    }
    
    for (NSString *file in files) {
        if ([file isEqualToString:@".com.apple.mobile_container_manager.metadata.plist"] ||
            [file isEqualToString:@"Library"]) {
            continue;
        }
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.representedObject = [path stringByAppendingPathComponent:file];
        item.title = file;
        item.target = self;
        item.action = @selector(gotoButtonClick:);
        [menu.submenu addItem:item];
    }
}


#pragma mark - setter & getter
- (NSMenuItem *)pluginsMenuItem
{
    if (_pluginsMenuItem != nil) {
        return _pluginsMenuItem;
    }
    
    NSMenu *mainMenu = [NSApp mainMenu];
    _pluginsMenuItem = [mainMenu itemWithTitle:kCHPluginsMenuTitle];
    if (!_pluginsMenuItem) {
        _pluginsMenuItem = [[NSMenuItem alloc] init];
        _pluginsMenuItem.title = kCHPluginsMenuTitle;
        _pluginsMenuItem.submenu = [[NSMenu alloc] initWithTitle:kCHPluginsMenuTitle];
        [mainMenu addItem:_pluginsMenuItem];
    }
    [_pluginsMenuItem.submenu addItem:self.recentDocsMenuItem];
    [_pluginsMenuItem.submenu addItem:self.appDocsMenuItem];
    [_pluginsMenuItem.submenu addItem:self.pluginDocsMenuItem];
    [_pluginsMenuItem.submenu addItem:self.groupDocsMenuItem];
    return _pluginsMenuItem;
}

- (NSMenuItem *)recentDocsMenuItem
{
    if (_recentDocsMenuItem != nil) {
        return _recentDocsMenuItem;
    }
    _recentDocsMenuItem = [[NSMenuItem alloc] init];
    _recentDocsMenuItem.title = @"Recent Documents";
    _recentDocsMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"Recent Documents"];
    return _recentDocsMenuItem;
}

- (NSMenuItem *)appDocsMenuItem
{
    if (_appDocsMenuItem != nil) {
        return _appDocsMenuItem;
    }
    _appDocsMenuItem = [[NSMenuItem alloc] init];
    _appDocsMenuItem.title = @"App Documents";
    _appDocsMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"App Documents"];
    return _appDocsMenuItem;
}

- (NSMenuItem *)pluginDocsMenuItem
{
    if (_pluginDocsMenuItem != nil) {
        return _pluginDocsMenuItem;
    }
    _pluginDocsMenuItem = [[NSMenuItem alloc] init];
    _pluginDocsMenuItem.title = @"Plugin documents";
    _pluginDocsMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"Plugin Documents"];
    return _pluginDocsMenuItem;
}

- (NSMenuItem *)groupDocsMenuItem
{
    if (_groupDocsMenuItem != nil) {
        return _groupDocsMenuItem;
    }
    _groupDocsMenuItem = [[NSMenuItem alloc] init];
    _groupDocsMenuItem.title = @"Group documents";
    _groupDocsMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"Group Documents"];
    return _groupDocsMenuItem;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

@end
