//
//  STXFrequencyItemTests.m
//  STXLFUCache_Tests
//
//  Created by Yiming XIA on 2019/6/29.
//  Copyright © 2019 SteinX. All rights reserved.
//

#import "STXFrequencyItemTests.h"
#import "STXFrequencyItem+PrivateExposure.h"

#import <list>
#import <STXFrequencyItem.h>
#import <STXCacheItem.h>

@implementation STXFrequencyItemTests

- (void)testFactoryMethods {
    std::list<STXFrequencyItem *> testList;
    
    auto instance1 = [STXFrequencyItem itemWithFrequency:1 toList:&testList];
    auto instance2 = [STXFrequencyItem itemWithFrequency:3 toList:&testList];
    
    XCTAssert(testList.size() == 2, "Incorrect number of frequency items in the list");
    
    auto firstListItem = testList.front();
    XCTAssert(firstListItem == instance1, "Incorrect order of the frequency item in the list");
    
    auto lastListItem = testList.back();
    XCTAssert(lastListItem == instance2, "Incorrect order of the frequency item in the list");
    
    auto instance3 = [STXFrequencyItem itemWithFrequency:2 toList:&testList afterNode:instance1.listNode];
    
    auto it = testList.begin();
    it++;
    auto secondOne = *it;
    
    XCTAssert(secondOne == instance3, "Incorrect order of the frequency item in the list");
}

- (void)testAddMember {
    auto cacheItem = [STXCacheItem itemWithKey:@"test" value:@(10)];
    
    std::list<STXFrequencyItem *> testList;
    auto instance1 = [STXFrequencyItem itemWithFrequency:1 toList:&testList];
    [instance1 addMember:cacheItem];
    
    XCTAssert(instance1.members.count > 0, "Add member do not work correctly");
}

- (void)testRemoveMember {
    auto cacheItem = [STXCacheItem itemWithKey:@"test" value:@(10)];
    
    std::list<STXFrequencyItem *> testList;
    auto instance1 = [STXFrequencyItem itemWithFrequency:1 toList:&testList];
    [instance1 addMember:cacheItem];
    
    [instance1 removeMember:cacheItem];
    
    XCTAssert(instance1.members.count == 0, "Remove member do not work correctly");
}

- (void)testDropMember {
    auto cacheItem = [STXCacheItem itemWithKey:@"test" value:@(10)];
    auto cacheItem2 = [STXCacheItem itemWithKey:@"test" value:@(20)];
    
    std::list<STXFrequencyItem *> testList;
    auto instance1 = [STXFrequencyItem itemWithFrequency:1 toList:&testList];
    [instance1 addMember:cacheItem];
    [instance1 addMember:cacheItem2];
    
    [instance1 dropMember];
    
    XCTAssert(instance1.members.count == 1, "Drop member do not work correctly");
}

- (void)testNextListNode {
    std::list<STXFrequencyItem *> testList;
    
    auto instance1 = [STXFrequencyItem itemWithFrequency:1 toList:&testList];
    auto instance2 = [STXFrequencyItem itemWithFrequency:3 toList:&testList];
    
    XCTAssert(instance1.nextListNode == instance2.listNode, "Next list node do not work correctlty");
    XCTAssert(*(instance1.nextListNode) == instance2, "Next list node do not work correctlty");
}

- (void)testEraseFromList {
    std::list<STXFrequencyItem *> testList;
    
    auto instance1 = [STXFrequencyItem itemWithFrequency:1 toList:&testList];
    auto instance2 = [STXFrequencyItem itemWithFrequency:3 toList:&testList];
    
    [instance1 eraseFromList:&testList];
    
    XCTAssert(testList.size() == 1, "The size of list must be 1 after erasing");
    
    XCTAssert(*(testList.begin()) == instance2, "The instance2 must be the only element in the list");
    
    [instance2 eraseFromList:&testList];
    
    XCTAssert(testList.size() == 0, "The size of list must be 0 after erasing");
    
}

@end
