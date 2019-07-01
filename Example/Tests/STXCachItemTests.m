//
//  STXCachItemTests.m
//  STXLFUCache_Tests
//
//  Created by Yiming XIA on 2019/6/29.
//  Copyright © 2019 SteinX. All rights reserved.
//

#import "STXCachItemTests.h"

#import <STXCacheItem.h>

@implementation STXCachItemTests

- (void)testHashCorrectness {
    __auto_type instance1 = [STXCacheItem itemWithKey:@"test" value:@(5)];
    __auto_type instance2 = [STXCacheItem itemWithKey:@"test" value:@(5)];
    
    XCTAssert(instance1.hash == instance2.hash, @"Hash must be equal with the same key/value pair.");
    
    instance2 = [STXCacheItem itemWithKey:@"test" value:@"test"];
    
    XCTAssert(instance1.hash != instance2.hash, @"Hash must not be equal with the different key/value pair.");
    
    instance2 = [STXCacheItem itemWithKey:@"test2" value:@(5)];
    
    XCTAssert(instance1.hash != instance2.hash, @"Hash must not be equal with the different key/value pair.");
}

@end
