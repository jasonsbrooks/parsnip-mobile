//
//  HeapSendDataDelegate.m
//  Heaped
//
//  Created by Michael Zhao on 4/13/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "HeapSendDistDataDelegate.h"

@implementation HeapSendDistDataDelegate

// Upon establishing connection.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

// Handles response data from HTTP request.
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"\n\nReceived data: %@\n\n", dataStr);
}

// Handles response metadata?
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    //    Receiver's URL.
    NSString *recURL = [response.URL absoluteString];
    
    // Request status code.
    NSString *status = [NSString stringWithFormat:@"%d", (int) [response statusCode]];
    
//    NSLog(@"\nstatus: %@\nurl: %@", status, recURL);
}


@end
