//
//  STXCacheItem.h
//  Pods-STXLFUCache_Example
//
//  Created by Yiming XIA on 2019/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STXCacheItem : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) id value;
@property (nonatomic) void* frequencyNode;

@end

NS_ASSUME_NONNULL_END
