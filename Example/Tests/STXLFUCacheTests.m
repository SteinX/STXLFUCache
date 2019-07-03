//
//  STXLFUCacheTests.m
//  STXLFUCache_Tests
//
//  Created by Yiming XIA on 2019/6/30.
//  Copyright © 2019 SteinX. All rights reserved.
//

#import "STXLFUCacheTests.h"

#import <STXLFUCache.h>

@implementation STXLFUCacheTests

- (void)testObjectAccessibility {
    __auto_type cache = [STXLFUCache shared];
    
    NSString * const testKey = @"test_key";
    
    [cache setObject:@(15) forKey:testKey];
    XCTAssert(cache.size == 1, "Size is not correct after adding a new cache");
    
    id cachedObj = [cache objectForKey:testKey];
    XCTAssert([cachedObj isEqual:@(15)], "Size is not correct after adding a new cache");
    
    [cache setObject:@(20) forKey:testKey];
    XCTAssert([[cache objectForKey:testKey] isEqual:@(20)], "The cached value has not been updated successfully");
}

- (void)testEvictionPolicy {
    __auto_type cache = [[STXLFUCache alloc] initWithCapacity:5];
    
    for (NSInteger i = 0; i < 5; i++) {
        __auto_type identifier = [NSString stringWithFormat:@"identifier-%zd", i];
        __auto_type value = [NSString stringWithFormat:@"value-%zd", i];
        
        [cache setObject:value forKey:identifier];
    }
    
    __auto_type mostFrequentItemKey = @"identifier-1";
    __auto_type nextFrequentItemKey = @"identifier-2";
    __auto_type next2FrequentItemKey = @"identifier-3";
    
    for (NSInteger i = 0; i < 10; i++) {
        [cache objectForKey:mostFrequentItemKey];
        
        if (i < 7) {
            [cache objectForKey:nextFrequentItemKey];
        }
        
        if (i < 5) {
            [cache objectForKey:next2FrequentItemKey];
        }
    }
    
    [cache evict:1];
    
    __auto_type evictionCandidateKey = @"identifier-4";
    __auto_type evictionCandidateKey2 = @"identifier-0";
    
    __auto_type evictedObjectFlag = (![cache objectForKey:evictionCandidateKey] || ![cache objectForKey:evictionCandidateKey2]);
    XCTAssert(cache.size == 4 && evictedObjectFlag, @"One of the candidate must be evicated");
    
    [cache evict:1];
    evictedObjectFlag = (![cache objectForKey:evictionCandidateKey] && ![cache objectForKey:evictionCandidateKey2]);
    XCTAssert(cache.size == 3 && evictedObjectFlag, @"Both of the candidates must be evicated");
    
    [cache evict:2];
    evictedObjectFlag = ![cache objectForKey:nextFrequentItemKey] && ![cache objectForKey:next2FrequentItemKey];
    XCTAssert(cache.size == 1 && evictedObjectFlag, @"Only the most frequently accessed cache remain");
}

- (void)testEvictionOverCapacity {
    __auto_type cache = [[STXLFUCache alloc] initWithCapacity:5];
    cache.activeEvictionCount = 1;
    
    for (NSInteger i = 0; i < 5; i++) {
        __auto_type identifier = [NSString stringWithFormat:@"identifier-%zd", i];
        __auto_type value = [NSString stringWithFormat:@"value-%zd", i];
        
        [cache setObject:value forKey:identifier];
    }
    
    __auto_type mostFrequentItemKey = @"identifier-1";
    __auto_type nextFrequentItemKey = @"identifier-2";
    __auto_type next2FrequentItemKey = @"identifier-3";
    
    for (NSInteger i = 0; i < 10; i++) {
        [cache objectForKey:mostFrequentItemKey];
        
        if (i < 7) {
            [cache objectForKey:nextFrequentItemKey];
        }
        
        if (i < 5) {
            [cache objectForKey:next2FrequentItemKey];
        }
    }
    
    [cache setObject:@"testcache-overpass1" forKey:@"identifier-6"];
    
    __auto_type evictionCandidateKey = @"identifier-4";
    __auto_type evictionCandidateKey2 = @"identifier-0";
    __auto_type evictionCandidateKey3 = @"identifier-6";
    
    __auto_type evictedObjectFlag = (![cache objectForKey:evictionCandidateKey] || ![cache objectForKey:evictionCandidateKey2]);
    XCTAssert(cache.size == 5 && evictedObjectFlag, @"One of the candidate must be evicated");
    
    cache.activeEvictionCount = 2;
    
    [cache setObject:@"testcache-overpass1" forKey:@"identifier-7"];
    evictedObjectFlag = (![cache objectForKey:evictionCandidateKey] && ![cache objectForKey:evictionCandidateKey2] && ![cache objectForKey:evictionCandidateKey3]);
    XCTAssert(cache.size == 4 && evictedObjectFlag, @"All of the candidates must be evicated");
    
    [cache evict:10];
    XCTAssert(cache.size == 0 && evictedObjectFlag, @"Evicition over the size of the cache will purge all it's content");
}

- (void)testMemoryWarningCase {
    __auto_type cache = [[STXLFUCache alloc] initWithCapacity:5];
    
    for (NSInteger i = 0; i < 50000; i++) {
        __auto_type identifier = [NSString stringWithFormat:@"identifier-%zd", i];
        __auto_type value = [NSString stringWithFormat:@"value-%zd", i];
        
        [cache setObject:value forKey:identifier];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification
                                                        object:nil];
    
    XCTAssert(cache.size == 0, @"All the cache will be purged on receiving memory warning");
}

@end
