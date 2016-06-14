//
//  CHDocumentItem.m
//  CHGotoDoc
//
//  Created by Jiang on 16/6/13.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "CHDocumentItem.h"

static NSString* const kCHDocumnetItemDevice = @"device";
static NSString* const kCHDocumnetItemOSVersion = @"osVersion";
static NSString* const kCHDocumnetItemBundleId = @"bundleId";
static NSString* const kCHDocumnetItemPath = @"path";

@implementation CHDocumentItem

- (instancetype)initWithJson:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        _device = json[kCHDocumnetItemDevice];
        _osVersion = json[kCHDocumnetItemOSVersion];
        _bundleId = json[kCHDocumnetItemBundleId];
        _path = json[kCHDocumnetItemPath];
    }
    return self;
}

- (NSDictionary*)encodeTo
{
    return @{kCHDocumnetItemDevice:self.device?:@"",
             kCHDocumnetItemOSVersion:self.osVersion?:@"",
             kCHDocumnetItemBundleId:self.bundleId?:@"",
             kCHDocumnetItemPath:self.path?:@""};
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ %@ %@",self.device, self.osVersion, self.bundleId];
}

@end
