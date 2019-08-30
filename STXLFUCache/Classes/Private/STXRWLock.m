//
//  STXRWLock.m
//  STXLFUCache
//
//  Created by Yiming XIA on 2019/8/31.
//

#import "STXRWLock.h"

#import <pthread.h>

@implementation STXRWLock {
    pthread_rwlock_t _lock;
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
        _lock = lock;
    }
    return self;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_lock);
}

- (void)read:(NS_NOESCAPE void(^)(void))ops {
    if (!ops) {
        return;
    }
    
    pthread_rwlock_rdlock(&_lock);
    ops();
    pthread_rwlock_unlock(&_lock);
}

- (void)write:(NS_NOESCAPE void (^)(void))ops {
    if (!ops) {
        return;
    }
    
    pthread_rwlock_wrlock(&_lock);
    ops();
    pthread_rwlock_unlock(&_lock);
}

@end
