//
//  STXCacheItem.m
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import "STXCacheItem.h"

@interface STXCacheItem ()
@property (nonatomic) NSString *key;
@property (nonatomic) id value;
@end

@implementation STXCacheItem

+ (instancetype)itemWithKey:(NSString *)key value:(id)value {
    __auto_type instance = [STXCacheItem new];
    instance.key = key;
    instance.value = value;
    return instance;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:STXCacheItem.class]) {
        return NO;
    }
    
    return [self isEqualToCacheItem:object];
}

- (BOOL)isEqualToCacheItem:(STXCacheItem *)cacheItem {
    return [_key isEqualToString:cacheItem.key] &&
    [_value isEqual:cacheItem.key];
}

- (NSUInteger)hash {
    return [_key hash] ^ [_value hash];
}

@end
