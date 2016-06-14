//
//  CHDocumentsLogic.h
//  CHGotoDoc
//
//  Created by Jiang on 16/6/13.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHDocumentItem.h"

@interface CHDocumentsLogic : NSObject
+ (void)installDoc;
+ (NSArray <CHDocumentItem*>*)getRecentDocuments;
+ (void)updateCurrentApp:(NSNotification*)notification;
@end
