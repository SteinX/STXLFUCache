//
//  STXFrequencyItem.m
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import "STXFrequencyItem.h"
#import "STXCacheItem.h"

@interface STXFrequencyItem ()
@property (nonatomic, assign) NSUInteger frequency;
@property (nonatomic, assign) STXFrequencyListNode listNode;

@property (nonatomic) NSMapTable<STXCacheItem *, id> *members;
@end

@implementation STXFrequencyItem

+ (instancetype)itemWithFrequency:(NSUInteger)frequency toList:(std::list<STXFrequencyItem *>)frequencyList {
    return [self itemWithFrequency:frequency toList:frequencyList afterNode:frequencyList.end()];
}

+ (instancetype)itemWithFrequency:(NSUInteger)frequency
                           toList:(std::list<STXFrequencyItem *>)frequencyList
                        afterNode:(STXFrequencyListNode)previousNode
{
    auto instance = [STXFrequencyItem new];
    instance.frequency = frequency;
    
    if (previousNode != frequencyList.end()) {
        auto nextNode = std::next(previousNode);
        frequencyList.insert(nextNode, instance);
        instance.listNode = std::prev(nextNode);
    } else {
        frequencyList.push_back(instance);
        instance.listNode = std::prev(frequencyList.end());
    }
    
    return instance;
    
}

- (instancetype)init {
    if (self = [super init]) {
        _members = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

- (void)addMember:(STXCacheItem *)member {
    @synchronized(_members) {
        if ([_members objectForKey:member]) {
            return;
        }
        
        [_members setObject:@(1) forKey:member];
    }
}

- (void)removeMember:(STXCacheItem *)member {
    @synchronized(_members) {
        if (![_members objectForKey:member]) {
            return;
        }
        
        [_members removeObjectForKey:member];
    }
}

- (void)dropMember {
    @synchronized (_members) {
        [_members removeObjectForKey:_members.keyEnumerator.nextObject];
    }
}

- (STXFrequencyListNode)nextListNode {
    return std::next(_listNode);
}

- (BOOL)hasNoMember {
    return _members.count == 0;
}

- (void)eraseFromList:(std::list<STXFrequencyItem *>)list {
    list.erase(_listNode);
}

@end
