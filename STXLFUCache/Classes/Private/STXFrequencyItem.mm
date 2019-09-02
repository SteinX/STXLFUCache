//
//  STXFrequencyItem.m
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import "STXFrequencyItem.h"
#import "STXCacheItem.h"
#import "STXSEMLock.h"

@interface STXFrequencyItem ()
@property (nonatomic, assign) NSUInteger frequency;
@property (nonatomic, assign) STXFrequencyListNode listNode;

@property (nonatomic) NSMapTable<STXCacheItem *, id> *members;
@end

@implementation STXFrequencyItem {
    STXSEMLock *_lock;
}

+ (instancetype)itemWithFrequency:(NSUInteger)frequency toList:(std::list<STXFrequencyItem *> *)frequencyList {
    return [self itemWithFrequency:frequency toList:frequencyList afterNode:frequencyList->end()];
}

+ (instancetype)itemWithFrequency:(NSUInteger)frequency
                           toList:(std::list<STXFrequencyItem *> *)frequencyList
                        afterNode:(STXFrequencyListNode)previousNode
{
    auto instance = [STXFrequencyItem new];
    instance.frequency = frequency;
    
    if (previousNode != frequencyList->end()) {
        auto nextNode = std::next(previousNode);
        frequencyList->insert(nextNode, instance);
        instance.listNode = std::prev(nextNode);
    } else {
        frequencyList->push_back(instance);
        instance.listNode = std::prev(frequencyList->end());
    }
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _members = [NSMapTable weakToStrongObjectsMapTable];
        _lock = [STXSEMLock new];
    }
    return self;
}

- (void)addMember:(STXCacheItem *)member {
    [_lock lock:^{
        [self->_members setObject:@(1) forKey:member];
    }];
}

- (void)removeMember:(STXCacheItem *)member {
    [_lock lock:^{
        [self->_members removeObjectForKey:member];
    }];
}

- (STXCacheItem *)dropMember {
    __block id removedKey;
    
    [_lock lock:^{
        removedKey = self->_members.keyEnumerator.nextObject;
        [self->_members removeObjectForKey:removedKey];
    }];
    
    return removedKey;
}

- (STXFrequencyListNode)nextListNode {
    return std::next(_listNode);
}

- (BOOL)hasNoMember {
    __block BOOL isEmpty;

    [_lock lock:^{
        isEmpty = self->_members.count == 0;
    }];
    
    return isEmpty;
}

- (void)eraseFromList:(std::list<STXFrequencyItem *> *)list {
    list->erase(_listNode);
}

@end
