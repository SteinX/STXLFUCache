//
//  STXFrequencyItem+PrivateExposure.h
//  STXLFUCache_Tests
//
//  Created by Yiming XIA on 2019/6/29.
//  Copyright © 2019 SteinX. All rights reserved.
//

#import <STXFrequencyItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface STXFrequencyItem (PrivateExposure)

@property (nonatomic, assign) NSUInteger frequency;
@property (nonatomic, assign) STXFrequencyListNode listNode;

@property (nonatomic) NSMapTable<STXCacheItem *, id> *members;

@end

NS_ASSUME_NONNULL_END
