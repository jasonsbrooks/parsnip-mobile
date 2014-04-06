//
//  HeapTriangulate.h
//  Heaped
//
//  Created by Michael Zhao on 4/3/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeapTrilaterate : NSObject
{
//  Points representing iBeacons.
    NSMutableArray *P0;
    NSMutableArray *P1;
    NSMutableArray *P2;
}

- (instancetype)initWithBeacons:(NSArray *)x y:(NSArray *)y;
-(NSArray *)trilaterate:(NSArray *)dist;

@end
