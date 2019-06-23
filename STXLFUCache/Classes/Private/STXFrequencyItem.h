//
//  STXFrequencyItem.h
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import <Foundation/Foundation.h>

@class STXCacheItem;

NS_ASSUME_NONNULL_BEGIN

@interface STXFrequencyItem : NSObject

@property (nonatomic, readonly) NSSet<STXCacheItem *> *members;
@property (nonatomic, readonly, assign) NSUInteger frequency;

+ (instancetype)itemWithFrequency:(NSUInteger)frequency;

- (void)addMember:(STXCacheItem *)member;
- (void)removeMember:(STXCacheItem *)member;

@end

NS_ASSUME_NONNULL_END
