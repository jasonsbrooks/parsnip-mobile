//
//  DealModelTests.m
//  Heaped
//
//  Created by Michael Zhao on 4/26/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HeapInfoViewController.h"

@interface DealModelTests : XCTestCase

@end

@implementation DealModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInfoView
{
    HeapInfoViewController *view = [[HeapInfoViewController alloc] init];
    [view viewDidLoad];
}

@end
