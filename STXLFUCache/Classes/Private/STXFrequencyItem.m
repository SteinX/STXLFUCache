//
//  STXFrequencyItem.m
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import "STXFrequencyItem.h"

@interface STXFrequencyItem ()
@property (nonatomic, assign) NSUInteger frequency;
@property (nonatomic) NSMutableSet<STXCacheItem *> *mutableMember;
@end

@implementation STXFrequencyItem

+ (instancetype)itemWithFrequency:(NSUInteger)frequency {
    __auto_type instance = [STXFrequencyItem new];
    instance.frequency = frequency;
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _mutableMember = [NSMutableSet set];
    }
    return self;
}

- (void)addMember:(STXCacheItem *)member {
    @synchronized(_mutableMember) {
        [_mutableMember addObject:member];
    }
}

- (void)removeMember:(STXCacheItem *)member {
    @synchronized(_mutableMember) {
        [_mutableMember removeObject:member];
    }
}

- (NSSet<STXCacheItem *> *)members {
    return [_mutableMember copy];
}

@end
