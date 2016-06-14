//
//  CHDocumentsCache.h
//  CHGotoDoc
//
//  Created by Jiang on 16/6/13.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDocumentItem.h"

@interface CHDocumentsCache : NSObject
@property (nonatomic, readonly) NSArray <CHDocumentItem*>*appDocumentsPath;
@property (nonatomic, readonly) NSArray <CHDocumentItem*>*pluginDocumentsPath;
@property (nonatomic, readonly) NSArray <CHDocumentItem*>*groupDocumentsPath;

+ (instancetype)sharedInstance;

- (void)addAppPath:(CHDocumentItem*)item;
- (void)addPluginPath:(CHDocumentItem*)item;
- (void)addGroupPath:(CHDocumentItem*)item;

- (void)sort;
@end
