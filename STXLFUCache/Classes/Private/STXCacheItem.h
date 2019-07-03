//
//  STXCacheItem.h
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import <Foundation/Foundation.h>

@class STXFrequencyItem;

NS_ASSUME_NONNULL_BEGIN

@interface STXCacheItem : NSObject

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) id value;

@property (nonatomic, weak, nullable) STXFrequencyItem *frequencyItem;

+ (instancetype)itemWithKey:(NSString *)key value:(id)value;

- (BOOL)isEqualToCacheItem:(STXCacheItem *)cacheItem;

@end

NS_ASSUME_NONNULL_END
