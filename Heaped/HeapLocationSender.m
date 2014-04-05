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
@end

@implementation HeapLocationSender
- (void)makeBeaconManager
{
    [self sendData];
    
    // Beacon Manager discovers beacons.
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    // Set the region (could be used to identify a store).
    self.region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
    
    // Search for beacons within region.
    //    [self.beaconManager startRangingBeaconsInRegion:self.region];
}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    // Detected a beacon
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
    }
    else
        NSLog(@"Couldn't find beacon 0.");
}


- (IBAction)startData:(id)sender
{
    [self.beaconManager startRangingBeaconsInRegion:self.region];
}

- (IBAction)stopData:(id)sender
{
    [self.beacon0 disconnectBeacon];
    [self.beacon1 disconnectBeacon];
    [self.beacon2 disconnectBeacon];
    
    //    Issue POST request here.
}

-(void)sendData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:@"http://www.michaelhzhao.com/test.php"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain"
   forHTTPHeaderField:@"Content-type"];
    
    NSString *xmlString = @"This is a test. a";
    
    [request setValue:[NSString stringWithFormat:@"%lu",
                       (unsigned long)[xmlString length]]
   forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[xmlString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

// Upon establishing connection.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Success.");
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
    //    NSString *recURL = [response.URL absoluteString];
    
    // Request status code.
    NSString *status = [NSString stringWithFormat:@"%d", (int) [response statusCode]];
    
    NSLog(@"status: %@", status);
}
@end
