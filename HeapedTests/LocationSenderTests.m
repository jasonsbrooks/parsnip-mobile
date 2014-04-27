//
//  LocationSenderTests.m
//  Heaped
//
//  Created by Michael Zhao on 4/21/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HeapLocationSender.h"

@interface LocationSenderTests : XCTestCase 

@property HeapLocationSender *ranger;

@end

@implementation LocationSenderTests



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

-(void)testSendStoreInfoNotification
{
    _ranger = [[HeapLocationSender alloc] init];
    [_ranger makeBeaconManager];

}

@end
