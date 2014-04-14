//
//  HeapLocationSender.m
//  Heaped
//
//  Created by Michael Zhao on 4/5/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "HeapLocationSender.h"
#import "HeapSendDataDelegate.h"
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

@property NSNumber *storeID;
@property NSNumber *minor0;
@property NSNumber *minor1;
@property NSNumber *minor2;

@property NSURLConnection *minorConnection;
@property NSURLConnection *dataConnection;

@property NSInteger counter;
@property NSMutableArray *arr;
@end

@implementation HeapLocationSender

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
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    // Set the region (could be used to identify a store).
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];

    // Search for beacons within region.
    [self.beaconManager startRangingBeaconsInRegion:self.region];

    //    [self sendData];

}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
        NSAssert([beacons count] > 2, @"Cannot find three beacons.");
    
        // Distances from beacons
        NSNumber *d0;
        NSNumber *d1;
        NSNumber *d2;
    
        // Show its distance in distance0.
        ESTBeacon *beacon0 = [beacons objectAtIndex:0];
        ESTBeacon *beacon1 = [beacons objectAtIndex:1];
        ESTBeacon *beacon2 = [beacons objectAtIndex:2];
        
        // If minors haven't already been established, set them.
        if (self.minor0 == NULL)
            [self askForMinors:beacon0.minor];

        if (self.beacon0.minor == self.minor0)
            self.beacon0 = beacon0;
        else if (self.beacon1.minor == self.minor0)
            self.beacon1 = beacon0;
        else
            self.beacon2 = beacon0;
    
    
        // Append a new point to the data array.
        NSDate *now = [NSDate date];
        d0 = self.beacon0.distance;
        d1 = self.beacon1.distance;
        d2 = self.beacon2.distance;

        [self sendNotification:d0 distance1:d1 distance2:d2];

        // Make sure to clear the array before sending new data.
        [self addPoint:[self makePoint:d0 d1:d1 d2:d2 time:now]];
        
        // Increment counter, and send data every 10 detections.
        self.counter++;
        // NSLog(@"counter: %d\n", self.counter);
        
        if (self.counter > DATA_INTERVAL) {
            [self sendData];
            self.counter = 0;
        }
    

}

// Send minor value to database and ask for rest of beacon minor info.
-(void)askForMinors:(NSNumber *)minor
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://www.michaelhzhao.com/test.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *str = [minor stringValue];
    NSData *data = [str dataUsingEncoding:4];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[str length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:data];
    
    // Delegate is self to set class minor variables.
    self.minorConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


# pragma mark - Handle data

-(NSDictionary *)makePoint:(NSNumber *)x d1:(NSNumber *)y d2:(NSNumber *)z time:(NSDate *)t
{
    
    NSString *time = [t description];
    
    //  point = {"x": x-coor, "y": y-coor, "t": date/time}
    NSDictionary *point = [[NSDictionary alloc] initWithObjects:@[x, y, z, time] forKeys:@[@"d0", @"d1", @"d2", @"time"]];
    
    return point;
}

-(void)addPoint:(NSDictionary *)point
{
    [self.arr addObject:point];
}

// Create a set of data as JSON object.
-(NSData *)packData
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dict setObject:self.arr forKey:@"points"];
    
    //  Change this depending on the user.
    NSNumber *userID = [NSNumber numberWithInteger:1];
    [dict setObject:userID forKey:@"userID"];
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:0];
    
    //    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"Your dummy data: %@\n", dataStr);
    
    return data;
}

-(void)sendData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://www.michaelhzhao.com/test.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [self packData];
    NSString *dummyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dummyString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:data];
    
    // Let data delegate handle data transmission response.
    HeapSendDataDelegate *dataDelegate = [[HeapSendDataDelegate alloc] init];
    
    self.dataConnection = [[NSURLConnection alloc] initWithRequest:request delegate:dataDelegate];
}


#pragma mark - URL Connection response

// Upon establishing connection.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

// Handles response data from HTTP request.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   
}

// Handles response metadata?
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{

}
@end
