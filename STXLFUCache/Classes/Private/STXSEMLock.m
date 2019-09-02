//
//  STXSEMLock.m
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/9/3.
//

#import "STXSEMLock.h"

@implementation STXSEMLock {
    dispatch_semaphore_t _lock;
}

- (instancetype)init {
    if (self = [super init]) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)lock:(NS_NOESCAPE void(^)(void))ops {
    if (!ops) {
        return;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    ops();
    dispatch_semaphore_signal(_lock);
}

@end
