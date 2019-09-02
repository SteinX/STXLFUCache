//
//  STXSEMLock.h
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/9/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STXSEMLock : NSObject

- (void)lock:(NS_NOESCAPE void(^)(void))ops;

@end

NS_ASSUME_NONNULL_END
