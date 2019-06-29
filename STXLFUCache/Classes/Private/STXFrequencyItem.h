//
//  STXFrequencyItem.h
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import <Foundation/Foundation.h>
#import <list>

@class STXCacheItem, STXFrequencyItem;

typedef std::list<STXFrequencyItem *>::iterator STXFrequencyListNode;

NS_ASSUME_NONNULL_BEGIN

@interface STXFrequencyItem : NSObject

@property (nonatomic, readonly, assign) NSUInteger frequency;
@property (nonatomic, readonly, assign) STXFrequencyListNode listNode;

@property (nonatomic, readonly) BOOL hasNoMember;

+ (instancetype)itemWithFrequency:(NSUInteger)frequency toList:(std::list<STXFrequencyItem *>)frequencyList;
+ (instancetype)itemWithFrequency:(NSUInteger)frequency
                           toList:(std::list<STXFrequencyItem *>)frequencyList
                        afterNode:(STXFrequencyListNode)previousNode;

- (void)addMember:(STXCacheItem *)member;
- (void)removeMember:(STXCacheItem *)member;
- (void)dropMember;

- (STXFrequencyListNode)nextListNode;
- (void)eraseFromList:(std::list<STXFrequencyItem *>)list;

@end

NS_ASSUME_NONNULL_END
