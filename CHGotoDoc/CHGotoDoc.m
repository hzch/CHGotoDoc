//
//  CHGotoDoc.m
//  CHGotoDoc
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "CHGotoDoc.h"
#import "NSNotification+CHPlugin.h"
static NSString * const kCHPluginsMenuTitle = @"Plugins";
static NSString * const kInfoWithNotFoundDocuments = @"Maybe the documents of your app not created yet. Try again until your app run. If it still doesn't work, send email to jch.main@gmail.com.";
static NSString * const kInfoWithUnkownDevice = @"Only surport simulator! If it still doesn't work, send email to jch.main@gmail.com.";

@interface CHGotoDoc ()
@property (nonatomic) NSMenuItem *pluginsMenuItem;
@property (nonatomic) NSString *currentBundleId;
@property (nonatomic) NSString *currentDeviceAppPath;
@property (nonatomic) NSString *currentDocuments;
@property (nonatomic) NSFileManager *fileManager;
@property (nonatomic) NSMenuItem* gotoDocItem;
@end

@implementation CHGotoDoc
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(buildWillStart:)
                                                     name:@"IDEBuildOperationWillStartNotification"
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    [self addPluginMenu];
}

#pragma mark - Plugin menu
- (void)addPluginMenu
{
    [self.pluginsMenuItem.submenu addItem:self.gotoDocItem];
}

- (void)gotoDocuments
{
    NSString *currentDocuments = self.currentDocuments;
    if (currentDocuments.length == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Not found documents!"];
        [alert setInformativeText:kInfoWithNotFoundDocuments];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return;
    }
    
    NSString *open = [NSString stringWithFormat:@"open %@",self.currentDocuments];
    const char *str = [open UTF8String];
    system(str);
}

- (void)gotoUnkown
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Unkown device!"];
    [alert setInformativeText:kInfoWithUnkownDevice];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

#pragma mark - install BundleId and Simulator
- (void)buildWillStart:(NSNotification *)notification
{
    NSLog(@"[CHPlugin] Xcode build will start.");
    self.currentDocuments = nil;
    self.currentBundleId = [notification chGetBundleId];
    self.currentDeviceAppPath = [notification chGetDeviceAppPath];
    
    NSString *device = [notification chGetDeviceType];
    NSString *osVerison = [notification chGetOSVersion];
    NSString *scheme = [notification chGetSchemeName];
    
    [self gotoDoc:self.currentBundleId.length && self.currentDeviceAppPath.length && device.length
           device:device
        osVersion:osVerison
           scheme:scheme];
}

- (void)gotoDoc:(BOOL)gotoDoc device:(NSString*)device osVersion:(NSString*)osVersion scheme:(NSString*)scheme
{
    _gotoDocItem.target = self;
    if (gotoDoc) {
        self.gotoDocItem.title = [NSString stringWithFormat:@"Go To Documents (%@,%@,%@)", device, osVersion,scheme];
        self.gotoDocItem.action = @selector(gotoDocuments);
    } else {
        self.gotoDocItem.title = @"Go To Documents (Unkown)";
        self.gotoDocItem.action = @selector(gotoUnkown);
    }
}

#pragma mark - setter & getter
- (NSMenuItem *)gotoDocItem
{
    if (_gotoDocItem != nil) {
        return _gotoDocItem;
    }
    
    _gotoDocItem = [NSMenuItem new];
    _gotoDocItem.title = @"Go To Documents (Build first!)";
    _gotoDocItem.target = nil;
    return _gotoDocItem;
}

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
    return _pluginsMenuItem;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSString *)currentDocuments
{
    if (_currentDocuments) {
        return _currentDocuments;
    }
    
    if (self.currentDeviceAppPath.length == 0 || self.currentBundleId.length == 0) {
        return nil;
    }
    
    NSArray *paths = [self.fileManager contentsOfDirectoryAtPath:self.currentDeviceAppPath error:nil];
    for (NSString *pathName in paths) {
        NSString *fileName = [self.currentDeviceAppPath stringByAppendingPathComponent:pathName];
        NSString *fileUrl = [fileName stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        
        if([self.fileManager fileExistsAtPath:fileUrl]){
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fileUrl];
            NSString *bundleId = [dict valueForKeyPath:@"MCMMetadataIdentifier"];
            if (bundleId.length != 0 && [self.currentBundleId isEqualToString:bundleId]) {
                _currentDocuments = [fileName stringByAppendingPathComponent:@"Documents"];
                return _currentDocuments;
            }
        }
    }
    
    return nil;
}
@end
