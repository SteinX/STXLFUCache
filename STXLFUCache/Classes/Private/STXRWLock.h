//
//  STXRWLock.h
//  STXLFUCache
//
//  Created by Yiming XIA on 2019/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STXRWLock : NSObject

- (void)read:(NS_NOESCAPE void(^)(void))ops;
- (void)write:(NS_NOESCAPE void(^)(void))ops;

@end

NS_ASSUME_NONNULL_END
