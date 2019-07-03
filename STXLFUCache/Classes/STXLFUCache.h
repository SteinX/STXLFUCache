//
//  STXLFUCache.h
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STXLFUCache : NSObject

/**
 Number of items stored in the cache
 */
@property (nonatomic, assign, readonly) NSUInteger size;

/**
 The capacity of the cache, the cache items will be evicted automatically when size > capcaity
 */
@property (nonatomic, assign, readonly) NSUInteger capacity;

/**
 When the size of cache is greater than it's own capacity, cache items will be evicted as per the LFU policy automatically.
 And this property will define how many to be evicted.
 @discussion default value will be 1/5 of the capacity. min value is 1.
 */
@property (nonatomic, assign) NSInteger activeEvictionCount;

/**
 By setting this property, you will define the capcity of all aftercomming instance of the cache.
 except those which specify explicitly the capacity of cache.
 */
@property (nonatomic, class) NSUInteger defaultCapacity;

+ (instancetype)shared;
- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;

- (nullable id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

/**
 Manually evict the cache item from the cache as per LFU rule

 @param count number of cache item to be evicted.
 */
- (void)evict:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
