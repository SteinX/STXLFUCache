//
//  STXLFUCache.m
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/23.
//

#import "STXLFUCache.h"
#import "STXFrequencyItem.h"
#import "STXCacheItem.h"
#import "STXRWLock.h"

#import <list>
#import <atomic>

static NSUInteger _defaultCacheCapacity = 100;

@implementation STXLFUCache {
    STXRWLock *_lock;
    
    NSMapTable<NSString *, STXCacheItem *> *_cacheMap;
    std::list<STXFrequencyItem *> _frequencyList;
}
@dynamic size;
@synthesize capacity = _capacity;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static STXLFUCache *instance;
    dispatch_once(&onceToken, ^{
        instance = [[STXLFUCache alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [self initWithCapacity:_defaultCacheCapacity]) {
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    if (self = [super init]) {
        _cacheMap = [NSMapTable strongToStrongObjectsMapTable];
        _capacity = capacity;
        
        _lock = [[STXRWLock alloc] init];
                
        _activeEvictionCount = MAX(_capacity / 5, 1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRecevingMemorWarningNotif:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public
- (void)setObject:(id)object forKey:(NSString *)key {
    auto cacheItem = [STXCacheItem itemWithKey:key value:object];
    
    __block STXCacheItem *exsitingCacheItem;
    [_lock read:^{
        exsitingCacheItem = [self->_cacheMap objectForKey:key];
    }];
    
    if ([self _reachCapcaity]) {
        [self evict:_activeEvictionCount];
    }
    
    [_lock write:^{
        [self->_cacheMap setObject:cacheItem forKey:key];
        
        [self _incrementCacheFrequency:cacheItem];
    }];
}

- (void)removeObjectForKey:(NSString *)key {
    [_lock write:^{
        auto cacheItem = [self->_cacheMap objectForKey:key];
        auto frequencyNode = cacheItem.frequencyItem;
        
        if (!cacheItem) {
            return;
        }
        
        [self->_cacheMap removeObjectForKey:key];
        
        if (!frequencyNode) {
            return;
        }
        
        [frequencyNode removeMember:cacheItem];
        if (frequencyNode.hasNoMember) {
            [frequencyNode eraseFromList:&self->_frequencyList];
        }
    }];
}

- (id)objectForKey:(NSString *)key {
    __block STXCacheItem *object;
    
    [_lock read:^{
        object = [self->_cacheMap objectForKey:key];
    }];
    
    if (!object) {
        return nil;
    }
    
    [_lock write:^{
        [self _incrementCacheFrequency:object];
    }];
    
    return object.value;
}

- (void)evict:(NSUInteger)count {
    auto size = self.size;
    if (!size) {
        return;
    }
    
    [_lock write:^{
        if (size <= count) {
            self->_frequencyList.clear();
            return [self->_cacheMap removeAllObjects];
        }
        
        NSInteger i = 0;
        
        for (auto it = self->_frequencyList.begin(); it != self->_frequencyList.end();) {
            @autoreleasepool {
                auto frequencyItem = *it;
                
                while (i < count && !frequencyItem.hasNoMember) {
                    auto removedCache = [frequencyItem dropMember];
                    [self->_cacheMap removeObjectForKey:removedCache.key];
                    
                    i++;
                }
                
                if (frequencyItem.hasNoMember) {
                    auto emptyFrequencyItem = it;
                    it++;
                    
                    self->_frequencyList.erase(emptyFrequencyItem);
                } else {
                    it++;
                }
                
                if (i >= count) {
                    break;
                }
            }
        }
    }];
}

#pragma mark - Private
- (void)_incrementCacheFrequency:(STXCacheItem *)cacheItem {
    if (!cacheItem) {
        return;
    }
    
    auto currentFrequency = cacheItem.frequencyItem;
    
    NSInteger nextFrequency;
    STXFrequencyListNode nextFrequnecyListNode = _frequencyList.end();
    
    // Find the next frequency node
    if (!currentFrequency) {
        nextFrequency = 1;
        nextFrequnecyListNode = _frequencyList.begin();
    } else {
        nextFrequency = currentFrequency.frequency + 1;
        nextFrequnecyListNode = [currentFrequency nextListNode];
    }
    
    // Delink with the current frequency node.
    if (currentFrequency) {
        [currentFrequency removeMember:cacheItem];
    }
    
    // No exisiting frequency node can be found, create a new one
    STXFrequencyItem *newFrequencyItem;
    if (nextFrequnecyListNode == _frequencyList.end()) {
        if (!currentFrequency) {
            newFrequencyItem = [STXFrequencyItem itemWithFrequency:nextFrequency toList:&_frequencyList];
        } else {
            newFrequencyItem = [STXFrequencyItem itemWithFrequency:nextFrequency toList:&_frequencyList afterNode:currentFrequency.listNode];
        }
    } else {
        newFrequencyItem = *nextFrequnecyListNode;
    }
    
    cacheItem.frequencyItem = newFrequencyItem;
    [newFrequencyItem addMember:cacheItem];
}

- (BOOL)_reachCapcaity {
    return _capacity <= _cacheMap.count;
}

#pragma mark - Event Handler
- (void)onRecevingMemorWarningNotif:(NSNotification *)notif {
    [self evict:_capacity];
}

#pragma mark - Getter && Setter
+ (NSUInteger)defaultCapacity {
    return _defaultCacheCapacity;
}

+ (void)setDefaultCapacity:(NSUInteger)defaultCapacity {
    _defaultCacheCapacity = defaultCapacity;
}

- (NSUInteger)capacity {
    return _capacity;
}

- (NSUInteger)size {
    __block NSUInteger size;
    
    [_lock read:^{
        size = self->_cacheMap.count;
    }];
    
    return size;
}

@end
