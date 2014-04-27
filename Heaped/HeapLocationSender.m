//
//  HeapLocationSender.m
//  Heaped
//
//  Created by Michael Zhao on 4/5/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "HeapLocationSender.h"
#import "HeapSendDistDataDelegate.h"
#import "ESTBeaconManager.h"
#import "ESTBeaconRegion.h"

// Data points to collect before sending to database.
#define DATA_INTERVAL 2

@interface HeapLocationSender () <ESTBeaconManagerDelegate>
@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *region;
@property ESTBeacon *beacon0;
@property ESTBeacon *beacon1;
@property ESTBeacon *beacon2;

@property NSNumber *curMajor;
@property NSNumber *minor0;
@property NSNumber *minor1;
@property NSNumber *minor2;
@property int numberBeacons;

@property NSURLConnection *distanceConnection;
@property NSURLConnection *storeConnection;

@property NSInteger counter;
@property NSMutableArray *arr;

@property NSDictionary *storeInfo;

@end

@implementation HeapLocationSender

-(void)storeInfoNotification
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"storeInfo"
     object:nil
     userInfo:_storeInfo];
    
}

//  TODO: Complete the function to relay d0, d1, d2 to the notification center.
-(void)sendNotification:(NSNumber *)d0 distance1:(NSNumber *)d1 distance2:(NSNumber *)d2
{
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:@[d0, d1, d2] forKeys:@[@"d0", @"d1", @"d2"]];
    
    [[NSNotificationCenter defaultCenter]
        postNotificationName:@"distanceUpdate"
        object:self
        userInfo:dataDict];
}

- (void)makeBeaconManager
{
    //  Initialize data array
    self.arr = [[NSMutableArray alloc] init];
    
    // Beacon Manager discovers beacons.
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = NO;
    
    // Set the region (could be used to identify a store).
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"ParsnipEnterprises"];
    
    // Start ranging beacons
    [self.beaconManager startRangingBeaconsInRegion:self.region];
}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    
        _numberBeacons = (int) [beacons count];
//        NSLog(@"Num Beacons: %d", _numberBeacons);
        // If we don't detect enough beacons (customer isn't in a store),
        // then stop ranging for beacons.
//        if ([beacons count] <=2){
//            [self.beaconManager stopRangingBeaconsInRegion:self.region];
//            NSLog(@"wtf");
//        }
        // Must have at least 3 beacons to trilaterate.
//        NSAssert([beacons count] > 2, @"Cannot find three beacons.");
        if (_numberBeacons > 0)
            _beacon0 = [beacons objectAtIndex:0];
        if (_numberBeacons > 1)
            _beacon1 = [beacons objectAtIndex:1];
        if (_numberBeacons > 2)
            _beacon2 = [beacons objectAtIndex:2];
    
        // Only ask for store information if user is new to store (major),
        // or store changes.
        if (_curMajor == NULL || [_curMajor intValue] != [_beacon0.major intValue])
            {
                _curMajor = _beacon0.major;
                [self getStoreInfo];
            }
    
        // Increment counter, and send data every {DATA_INTERVAL} detections.
        if (self.counter++ > DATA_INTERVAL && _numberBeacons >= 2) {
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"dealInfo"
             object:nil
             userInfo:_storeInfo];
            
            [self sendData];
            // Reset variables.
            self.counter = 0;
        }
}

-(void)setBeacons:(ESTBeacon *)beacon0 b1:(ESTBeacon *)beacon1 b2:(ESTBeacon *)beacon2
{
    NSLog(@"setBeacons");
    // Map distances to correct beacons.
    if (beacon0.minor == _minor0)
        _beacon0 = beacon0;
    else if (beacon1.minor == _minor0)
        _beacon0 = beacon1;
    else if (beacon2.minor == _minor0)
        _beacon0 = beacon2;
    
    if (beacon0.minor == _minor1)
        _beacon1 = beacon0;
    else if (beacon1.minor == _minor1)
        _beacon1 = beacon1;
    else if (beacon2.minor == _minor1)
        _beacon1 = beacon2;
    
    if (beacon0.minor == _minor2)
        _beacon2 = beacon0;
    else if (beacon2.minor == _minor2)
        _beacon2 = beacon1;
    else if (beacon2.minor == _minor2)
        _beacon2 = beacon2;
}

// Send minor value to database and ask for rest of beacon minor info.
-(void)getStoreInfo
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://heaped.ngrok.com/beacon/get_store_information"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject: @"00000" forKey:@"major"];
    
    if (_curMajor != NULL)
        dataDict = [NSDictionary dictionaryWithObject:_curMajor forKey:@"major"];
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options: 0 error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[str length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:data];
    
    self.storeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

// Send distances.
-(void)sendData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://heaped.ngrok.com/beacon/add_coordinate_data"]];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSNumber *major = [NSNumber numberWithInt:0];
    
    if (_curMajor != nil || _curMajor != NULL)
    major = _curMajor;
    
    NSArray *p0;
    NSArray *p1;
    NSArray *p2;
    
    if (_numberBeacons > 0)
        p0 = @[_beacon0.major, _beacon0.minor, _beacon0.distance];
    if (_numberBeacons > 1)
        p1 = @[_beacon1.major, _beacon1.minor, _beacon1.distance];
    if (_numberBeacons > 2)
        p2 = @[_beacon2.major, _beacon2.minor, _beacon2.distance];
    
    NSArray *points = NULL;
    if (_numberBeacons > 2)
        points = @[p0, p1, p2];
    else if (_numberBeacons > 1)
        points = @[p0, p1];
    else if (_numberBeacons > 0)
        points = @[p0];
    
    NSString *userID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // minor, major values
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:@[points, @"B9407F30-F5F8-466E-AFF9-25556B57FE6D", userID] forKeys:@[@"points", @"UUID", @"userID"]];
    
    // Data to send to Jason.
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
    NSString *str = [data description];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[str length]] forHTTPHeaderField:@"Content-length"];

    [request setHTTPBody:data];
    
    HeapSendDistDataDelegate *dataDelegate = [[HeapSendDistDataDelegate alloc] init];
    
    // Delegate is self to set class minor variables.
    self.distanceConnection = [[NSURLConnection alloc] initWithRequest:request delegate:dataDelegate];
}


#pragma mark - Store info URL Connection response

// Handles response data from HTTP request for minor information.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Store beacons in database.
    _storeInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSLog(@"Received data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    // Send store info to notification center.
    [self storeInfoNotification];
}

-(void)dealloc
{
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
}
@end