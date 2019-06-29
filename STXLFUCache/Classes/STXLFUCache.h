//
//  STXLFUCache.h
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STXLFUCache : NSObject

@property (nonatomic, assign, readonly) NSUInteger size;
@property (nonatomic, assign, readonly) NSUInteger capacity;
@property (nonatomic, assign) NSInteger passiveEvictionCount;

@property (nonatomic, class) NSUInteger defaultCapacity;

+ (instancetype)shared;
- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

- (void)evict:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
