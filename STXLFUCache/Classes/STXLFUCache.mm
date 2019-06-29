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
    std::atomic<NSUInteger> _size;
    std::atomic<NSUInteger> _capacity;
    
    dispatch_queue_t _syncQueue;
    
    NSMapTable<NSString *, STXCacheItem *> *_cacheMap;
    std::list<STXFrequencyItem *> _frequencyList;
}
@dynamic size, capacity;

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
        auto queueName = [@"com.stx.cache.sync." stringByAppendingString:identifier];
        auto attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0);
        _syncQueue = dispatch_queue_create([queueName UTF8String], attributes);
        
        _passiveEvictionCount = 20;
        
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
        exsitingCacheItem = [_cacheMap objectForKey:key];
    });
    
    if (!exsitingCacheItem) {
        _size++;
    }
    
    if ([self _reachCapcaity]) {
        [self evict:_passiveEvictionCount];
    }
    
    dispatch_barrier_sync(_syncQueue, ^{
        [_cacheMap setObject:cacheItem forKey:key];
        
        [self _incrementCacheFrequency:cacheItem];
    });
}

- (void)removeObjectForKey:(NSString *)key {
    dispatch_barrier_sync(_syncQueue, ^{
        auto cacheItem = [_cacheMap objectForKey:key];
        auto frequencyNode = cacheItem.frequencyNode;
        
        if (!cacheItem) {
            return;
        }
        
        [_cacheMap removeObjectForKey:key];
        
        if (!frequencyNode) {
            return;
        }
        
        [frequencyNode removeMember:cacheItem];
        if (frequencyNode.hasNoMember) {
            [frequencyNode eraseFromList:_frequencyList];
        }
        
        _size--;
    });
}

- (id)objectForKey:(NSString *)key {
    __block STXCacheItem *object;
    dispatch_sync(_syncQueue, ^{
        object = [_cacheMap objectForKey:key];
    });
    
    dispatch_barrier_sync(_syncQueue, ^{
        [self _incrementCacheFrequency:object];
    });
    
    return object.value;
}

- (void)evict:(NSUInteger)count {
    dispatch_barrier_sync(_syncQueue, ^{
        NSInteger i = 0;
        
        for (auto it = _frequencyList.begin(); it != _frequencyList.end(); it++) {
            auto frequencyItem = *it;
            
            while (i < count && !frequencyItem.hasNoMember) {
                [frequencyItem dropMember];
                i++;
            }
            
            if (i >= count) {
                break;
            }
        }
    });
}

#pragma mark - Private
- (void)_incrementCacheFrequency:(STXCacheItem *)cacheItem {
    auto currentFrequency = cacheItem.frequencyNode;
    
    NSInteger nextFrequency;
    STXFrequencyListNode nextFrequnecyListNode = _frequencyList.end();
    
    // Find the next frequency node
    if (!currentFrequency) {
        nextFrequency = 1;
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
            newFrequencyItem = [STXFrequencyItem itemWithFrequency:nextFrequency toList:_frequencyList];
        } else {
            newFrequencyItem = [STXFrequencyItem itemWithFrequency:nextFrequency toList:_frequencyList afterNode:currentFrequency.listNode];
        }
    } else {
        newFrequencyItem = *nextFrequnecyListNode;
    }
    
    [newFrequencyItem addMember:cacheItem];
}

- (BOOL)_reachCapcaity {
    return self.capacity <= _cacheMap.count;
}

- (void)onRecevingMemorWarningNotif:(NSNotification *)notif {
    [_cacheMap removeAllObjects];
}

#pragma mark - Getter && Setter
+ (NSUInteger)defaultCapacity {
    return _defaultCacheCapacity;
}

+ (void)setDefaultCapacity:(NSUInteger)defaultCapacity {
    _defaultCacheCapacity = defaultCapacity;
}


@end
