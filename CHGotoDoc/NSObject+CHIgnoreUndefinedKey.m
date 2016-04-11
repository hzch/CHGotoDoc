//
//  NSObject+CHIgnoreUndefinedKey.m
//  CHPlugin
//
//  Created by Jiang on 16/4/11.
//  Copyright © 2016年 hzch. All rights reserved.
//

#import "NSObject+CHIgnoreUndefinedKey.h"

@implementation NSObject (CHIgnoreUndefinedKey)

- (nullable id)valueForUndefinedKey:(NSString *)key
{
    NSLog(@"No %@ in %@.", key, self.class);
    return nil;
}

@end
