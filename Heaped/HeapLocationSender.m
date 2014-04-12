//
//  HeapLocationSender.m
//  Heaped
//
//  Created by Michael Zhao on 4/5/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "HeapLocationSender.h"
#import "ESTBeaconManager.h"
#import "ESTBeaconRegion.h"

@interface HeapLocationSender () <ESTBeaconManagerDelegate>
@property ESTBeaconManager *beaconManager;
@property ESTBeaconRegion *region;
@property ESTBeacon *beacon0;
@property ESTBeacon *beacon1;
@property ESTBeacon *beacon2;

@property NSURLConnection *connection;

@property NSInteger counter;
@property NSMutableArray *arr;
@end

@implementation HeapLocationSender


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
{// Detected a beacon
    if([beacons count] > 0)
    {
        // Show its distance in distance0.
        self.beacon0 = [beacons objectAtIndex:0];
        
        NSLog(@"Beacon0 Unique: %@", [self.beacon0.proximityUUID UUIDString]);
        NSLog(@"Beacon0 distance: %@", [self.beacon0.distance stringValue]);
        
        // If more than 1 beacon, show its distance as well.
        if([beacons count] > 1) {
            self.beacon1 = [beacons objectAtIndex:1];
            
            if ([beacons count] > 2) {
                self.beacon2 = [beacons objectAtIndex:2];
            }
            else
                NSLog(@"Couldn't find beacon 2.");
            
        }
        else
            NSLog(@"Couldn't find beacon 1.");
        
        //      Append a new point to the data array.
        
        NSDate *now = [NSDate date];
        NSNumber *x = [NSNumber numberWithInteger:0];
        NSNumber *y = [NSNumber numberWithInteger:0];
        NSNumber *z = [NSNumber numberWithInteger:0];

        [self addPoint:[self makePoint:x d1:y d2:z time:now]];
        
        //  Increment counter, and send data every 10 detections.
        self.counter++;
        NSLog(@"counter: %d\n", self.counter);
        
        if (self.counter > 2) {
            [self sendData];
            self.counter = 0;
        }
    }
    else
        NSLog(@"Couldn't find beacon 0.");
}

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

-(NSData *)dummyData
{
    
//    {"points":[{"x":0,"y":0,"t":0},
//                {"x":2,"y":3,"t":1},
//                {"x":5,"y":6,"t":2}]}
    
    NSDictionary *p0 = [[NSDictionary alloc] initWithObjects:@[@0, @0, @0] forKeys:@[@"x", @"y", @"t"]];
    NSDictionary *p1 = [[NSDictionary alloc] initWithObjects:@[@2, @3, @1] forKeys:@[@"x", @"y", @"t"]];
    NSDictionary *p2 = [[NSDictionary alloc] initWithObjects:@[@5, @6, @2] forKeys:@[@"x", @"y", @"t"]];
    
    NSArray *arr = @[p0, p1, p2];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    [dict setObject:arr forKey:@"points"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:0];
    
//    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
//    NSLog(@"Your dummy data: %@\n", dataStr);
    
    return data;
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
                                                 URLWithString:@"http://4654b395.ngrok.com/floorplan/michael"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [self packData];
    NSString *dummyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dummyString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:data];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


// Upon establishing connection.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

// Handles response data from HTTP request.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", dataStr);
}

// Handles response metadata?
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    //    Receiver's URL.
    NSString *recURL = [response.URL absoluteString];
    
    // Request status code.
    NSString *status = [NSString stringWithFormat:@"%d", (int) [response statusCode]];
    
    NSLog(@"\nstatus: %@\nurl: %@", status, recURL);
}
@end
