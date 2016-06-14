//
//  CHGotoDoc.m
//  CHGotoDoc
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "CHGotoDoc.h"
#import "NSNotification+CHPlugin.h"
#import "CHDocumentsLogic.h"
#import "CHDocumentsCache.h"

static NSString * const kCHPluginsMenuTitle = @"Plugins";
static NSString * const kDocListMenuTitle = @"Documents Files List";
static NSString * const kDocsListMenuTitle = @"Documents List";
static NSString * const kInfoWithNotFoundDocuments = @"Maybe the documents of your app not created yet. Try again until your app run. If it still doesn't work, send email to jch.main@gmail.com.";
static NSString * const kInfoWithUnkownDevice = @"Only surport simulator! If it still doesn't work, send email to jch.main@gmail.com.";

@interface CHGotoDoc ()
@property (nonatomic) NSMenuItem *pluginsMenuItem;
@property (nonatomic) NSMenuItem *appDocsMenuItem;
@property (nonatomic) NSMenuItem *pluginDocsMenuItem;
@property (nonatomic) NSMenuItem *groupDocsMenuItem;

//@property (nonatomic) NSMenuItem *gotoDocItem;
//@property (nonatomic) NSMenuItem *docListMenuItem;
//@property (nonatomic) NSMenuItem *docsListMenuItem;

//@property (nonatomic) NSArray *currentBundleId;
//@property (nonatomic) NSArray *currentDeviceAppPath;
//@property (nonatomic) NSArray *currentDocuments;

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
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(buildWillStart:)
//                                                     name:@"IDEBuildOperationWillStartNotification"
//                                                   object:nil];
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

- (void)updateDocList
{
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

- (void)gotoButtonClick:(NSMenuItem*)menu
{
    NSString *open = [NSString stringWithFormat:@"open %@",menu.representedObject];
    const char *str = [open UTF8String];
    system(str);
}

//- (void)buildWillStart:(NSNotification *)notification
//{
//    NSLog(@"[CHPlugin] Xcode build will start.");
//    self.currentBundleId = [notification chGetBundleId];
//    self.currentDeviceAppPath = [notification chGetDeviceAppPath];
//    
//    NSString *device = [notification chGetDeviceType];
//    NSString *osVerison = [notification chGetOSVersion];
//    NSString *scheme = [notification chGetSchemeName];
//    
//    [self gotoDoc:self.currentDocuments.count
//           device:device
//        osVersion:osVerison
//           scheme:scheme];
//}



#pragma mark - Go to documents
//- (void)gotoDocuments
//{
//    NSString *currentDocuments = self.currentDocuments.firstObject;
//    if (currentDocuments.length == 0) {
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert addButtonWithTitle:@"OK"];
//        [alert setMessageText:@"Not found documents!"];
//        [alert setInformativeText:kInfoWithNotFoundDocuments];
//        [alert setAlertStyle:NSWarningAlertStyle];
//        [alert runModal];
//        return;
//    }
//    
//    NSString *open = [NSString stringWithFormat:@"open %@",self.currentDocuments.firstObject];
//    const char *str = [open UTF8String];
//    system(str);
//}
//
//- (void)gotoUnkown
//{
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert addButtonWithTitle:@"OK"];
//    [alert setMessageText:@"Unkown device!"];
//    [alert setInformativeText:kInfoWithUnkownDevice];
//    [alert setAlertStyle:NSWarningAlertStyle];
//    [alert runModal];
//}
//
//- (void)gotoDoc:(BOOL)gotoDoc device:(NSString*)device osVersion:(NSString*)osVersion scheme:(NSString*)scheme
//{
//    _gotoDocItem.target = self;
//    if (gotoDoc) {
//        self.gotoDocItem.title = [NSString stringWithFormat:@"Go To Documents ($0) (%@,%@,%@)", device, osVersion,scheme];
//        self.gotoDocItem.action = @selector(gotoDocuments);
//    } else {
//        self.gotoDocItem.title = @"Go To Documents (Unkown)";
//        self.gotoDocItem.action = @selector(gotoUnkown);
//    }
//}

#pragma mark - Documents list
//- (void)clickDocListWithMenu:(NSMenuItem*)menu
//{
//    __block NSString *fileName = menu.title;
//    [self.currentDocuments enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//        if (obj.length == 0) {
//            return ;
//        }
//        obj = [obj stringByAppendingString:@"/"];
//        NSString *occur = [NSString stringWithFormat:@"($%ld)",(long)idx];
//        fileName = [fileName stringByReplacingOccurrencesOfString:occur withString:obj];
//    }];
//    NSString *open = [NSString stringWithFormat:@"open %@", fileName];
//    const char *str = [open UTF8String];
//    system(str);
//}
//
//- (void)clickDocsListWithMenu:(NSMenuItem*)menu
//{
//    if (self.currentDocuments.count <= menu.tag) {
//        NSAlert *alert = [[NSAlert alloc] init];
//        [alert addButtonWithTitle:@"OK"];
//        [alert setMessageText:@"Not found documents!"];
//        [alert setInformativeText:kInfoWithNotFoundDocuments];
//        [alert setAlertStyle:NSWarningAlertStyle];
//        [alert runModal];
//        return;
//    }
//    
//    NSString *open = [NSString stringWithFormat:@"open %@",self.currentDocuments[menu.tag]];
//    const char *str = [open UTF8String];
//    system(str);
//}

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
    [_pluginsMenuItem.submenu addItem:self.appDocsMenuItem];
    [_pluginsMenuItem.submenu addItem:self.pluginDocsMenuItem];
    [_pluginsMenuItem.submenu addItem:self.groupDocsMenuItem];
    return _pluginsMenuItem;
}

- (NSMenuItem *)appDocsMenuItem
{
    if (_appDocsMenuItem != nil) {
        return _appDocsMenuItem;
    }
    _appDocsMenuItem = [[NSMenuItem alloc] init];
    _appDocsMenuItem.title = @"app documents";
    _appDocsMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"app documents"];
    return _appDocsMenuItem;
}

- (NSMenuItem *)pluginDocsMenuItem
{
    if (_pluginDocsMenuItem != nil) {
        return _pluginDocsMenuItem;
    }
    _pluginDocsMenuItem = [[NSMenuItem alloc] init];
    _pluginDocsMenuItem.title = @"plugin documents";
    _pluginDocsMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"plugin documents"];
    return _pluginDocsMenuItem;
}

- (NSMenuItem *)groupDocsMenuItem
{
    if (_groupDocsMenuItem != nil) {
        return _groupDocsMenuItem;
    }
    _groupDocsMenuItem = [[NSMenuItem alloc] init];
    _groupDocsMenuItem.title = @"group documents";
    _groupDocsMenuItem.submenu = [[NSMenu alloc] initWithTitle:@"group documents"];
    return _groupDocsMenuItem;
}

//- (NSMenuItem *)docListMenuItem
//{
//    if (_docListMenuItem != nil) {
//        return _docListMenuItem;
//    }
//    
//    if (!_docListMenuItem) {
//        _docListMenuItem = [[NSMenuItem alloc] init];
//        _docListMenuItem.title = kDocListMenuTitle;
//        _docListMenuItem.submenu = [[NSMenu alloc] initWithTitle:kDocListMenuTitle];
//        [self.pluginsMenuItem.submenu addItem:_docListMenuItem];
//    }
//    return _docListMenuItem;
//}
//
//- (NSMenuItem *)docsListMenuItem
//{
//    if (_docsListMenuItem != nil) {
//        return _docsListMenuItem;
//    }
//    
//    if (!_docsListMenuItem) {
//        _docsListMenuItem = [[NSMenuItem alloc] init];
//        _docsListMenuItem.title = kDocsListMenuTitle;
//        _docsListMenuItem.submenu = [[NSMenu alloc] initWithTitle:kDocsListMenuTitle];
//        [self.pluginsMenuItem.submenu addItem:_docsListMenuItem];
//    }
//    return _docsListMenuItem;
//}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

//- (NSArray *)currentDocuments
//{
//    if (_currentDocuments) {
//        return _currentDocuments;
//    }
//    
//    if (self.currentDeviceAppPath.count == 0 || self.currentBundleId.count == 0) {
//        return nil;
//    }
//    NSHashTable *documents = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
//    [self.currentDeviceAppPath enumerateObjectsUsingBlock:^(NSString *appPath, NSUInteger idx, BOOL *stop) {
//        if (appPath.length == 0) {
//            return ;
//        }
//        NSArray *paths = [self.fileManager contentsOfDirectoryAtPath:appPath error:nil];
//        for (NSString *pathName in paths) {
//            NSString *fileName = [appPath stringByAppendingPathComponent:pathName];
//            NSString *fileUrl = [fileName stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
//            
//            if([self.fileManager fileExistsAtPath:fileUrl]){
//                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fileUrl];
//                NSString *bundleId = [dict valueForKeyPath:@"MCMMetadataIdentifier"];
//                
//                if (bundleId.length == 0) {
//                    return;
//                }
//                
//                [self.currentBundleId enumerateObjectsUsingBlock:^(NSString *bid, NSUInteger idx, BOOL *stop) {
//                    if ([bid isEqualToString:bundleId]) {
//                        [documents addObject:[fileName stringByAppendingPathComponent:@"Documents"]];
//                        
//                        
//                        *stop = YES;
//                    }
//                }];
//            }
//        }
//    }];
//    
//    if (documents.count != 0) {
//        _currentDocuments = [documents allObjects];
//        [self.docsListMenuItem.submenu removeAllItems];
//        [_currentDocuments enumerateObjectsUsingBlock:^(NSString *pathName, NSUInteger idx, BOOL *stop) {
//            NSMenuItem *item = [[NSMenuItem alloc] init];
//            item.title = [pathName stringByAppendingString:[NSString stringWithFormat:@" ($%ld)",(long)idx]];
//            item.target = self;
//            item.tag = idx;
//            item.action = @selector(clickDocsListWithMenu:);
//            [self.docsListMenuItem.submenu addItem:item];
//        }];
//    }
//    
//    return _currentDocuments;
//}

@end
