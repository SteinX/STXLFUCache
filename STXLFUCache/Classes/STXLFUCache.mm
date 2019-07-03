//
//  STXLFUCache.m
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/23.
//

#import "STXLFUCache.h"
#import "STXFrequencyItem.h"
#import "STXCacheItem.h"

#import <list>
#import <atomic>

static NSUInteger _defaultCacheCapacity = 100;

@implementation STXLFUCache {
    dispatch_queue_t _syncQueue;
    
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
        
        auto identifier = [NSUUID UUID].UUIDString;
        auto queueName = [@"com.stx.lfucache.sync." stringByAppendingString:identifier];
        auto attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0);
        _syncQueue = dispatch_queue_create([queueName UTF8String], attributes);
        
        _activeEvictionCount = MAX(_capacity / 5, 1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onRecevingMemorWarningNotif:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Public
- (void)setObject:(id)object forKey:(NSString *)key {
    auto cacheItem = [STXCacheItem itemWithKey:key value:object];
    
    __block STXCacheItem *exsitingCacheItem;
    dispatch_sync(_syncQueue, ^{
        exsitingCacheItem = [self->_cacheMap objectForKey:key];
    });
    
    if ([self _reachCapcaity]) {
        [self evict:_activeEvictionCount];
    }
    
    dispatch_barrier_sync(_syncQueue, ^{
        [self->_cacheMap setObject:cacheItem forKey:key];
        
        [self _incrementCacheFrequency:cacheItem];
    });
}

- (void)removeObjectForKey:(NSString *)key {
    dispatch_barrier_sync(_syncQueue, ^{
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
    });
}

- (id)objectForKey:(NSString *)key {
    __block STXCacheItem *object;
    dispatch_sync(_syncQueue, ^{
        object = [self->_cacheMap objectForKey:key];
    });
    
    if (!object) {
        return nil;
    }
    
    dispatch_barrier_sync(_syncQueue, ^{
        [self _incrementCacheFrequency:object];
    });
    
    return object.value;
}

- (void)evict:(NSUInteger)count {
    auto size = self.size;
    if (!size) {
        return;
    }
    
    dispatch_barrier_sync(_syncQueue, ^{
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
    });
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
    dispatch_sync(_syncQueue, ^{
        size = self->_cacheMap.count;
    });
    
    return size;
}

@end
