//
//  HeapTriangulate.m
//  Heaped
//
//  Created by Michael Zhao on 4/3/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "HeapTriangulate.h"
#import <math.h>

@implementation HeapTriangulate
-(NSArray *)triangulate:(NSArray *)dist
{
    int s0 = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
    int s1 = sqrt(pow(x0 - x2, 2) + pow(y0 - y2, 2));
    int s2 = sqrt(pow(x1 - x0, 2) + pow(y1 - y0, 2));
    
    NSArray *arr = [[NSArray alloc] init];
    return arr;
}

// Use law of cosines to calculate angle opposite side c.
-(float)angle:(float)c a:(float)a b:(float)b
{
    float cosC = (c*c - b*b - a*a) / (-2 * a * b);
    float res = acos(cosC);
    return res;
}
@end
