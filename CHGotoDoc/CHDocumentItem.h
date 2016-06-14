//
//  CHDocumentItem.h
//  CHGotoDoc
//
//  Created by Jiang on 16/6/13.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHDocumentItem : NSObject
@property (nonatomic) NSString *device;
@property (nonatomic) NSString *osVersion;
@property (nonatomic) NSString *bundleId;
@property (nonatomic) NSString *path;

- (instancetype)initWithJson:(NSDictionary*)json;
- (NSDictionary*)encodeTo;

@end
