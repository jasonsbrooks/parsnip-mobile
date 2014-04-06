//
//  HeapTriangulate.m
//  Heaped
//
//  Created by Michael Zhao on 4/3/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "HeapTrilaterate.h"
#import <math.h>

@implementation HeapTrilaterate
- (instancetype)initWithBeacons:(NSArray *)x y:(NSArray *)y
{
    self = [super init];
    
    if (self) {
        [self setValues:x y:y];
    }
    return self;
}

-(void)setValues:(NSArray *)x y:(NSArray *)y
{
    
    float x0 = [[x objectAtIndex:0] doubleValue];
    float x1 = [[x objectAtIndex:1] doubleValue];
    float x2 = [[x objectAtIndex:2] doubleValue];
    
    float y0 = [[y objectAtIndex:0] doubleValue];
    float y1 = [[y objectAtIndex:1] doubleValue];
    float y2 = [[y objectAtIndex:2] doubleValue];
    
    //P0,P1,P2 is the point and 2-dimension vector
    P0 = [[NSMutableArray alloc] initWithCapacity:0];
    [P0 addObject:[NSNumber numberWithDouble:x0]];
    [P0 addObject:[NSNumber numberWithDouble:y0]];
    
    
    P1 = [[NSMutableArray alloc] initWithCapacity:0];
    [P1 addObject:[NSNumber numberWithDouble:x1]];
    [P1 addObject:[NSNumber numberWithDouble:y1]];
    
    P2 = [[NSMutableArray alloc] initWithCapacity:0];
    [P2 addObject:[NSNumber numberWithDouble:x2]];
    [P2 addObject:[NSNumber numberWithDouble:y2]];
}
-(NSArray *)trilaterate:(NSArray *)dist
{
    if ([dist count] < 3)
        
    [NSException raise:@"Invalid beacon distances" format:@"Trilateration function only received %lu distances", (unsigned long)[dist count]];
    
    //this is the distance between all the points and the unknown point
    double DistA = [[dist objectAtIndex:0] doubleValue];
    double DistB = [[dist objectAtIndex:1] doubleValue];
    double DistC = [[dist objectAtIndex:2] doubleValue];
    
    // ex = (P1 - P0)/(numpy.linalg.norm(P1 - P0))
    NSMutableArray *ex = [[NSMutableArray alloc] initWithCapacity:0];
    double temp = 0;
    for (int i = 0; i < [P0 count]; i++) {
        double t1 = [[P1 objectAtIndex:i] doubleValue];
        double t2 = [[P0 objectAtIndex:i] doubleValue];
        double t = t1 - t2;
        temp += (t*t);
    }
    for (int i = 0; i < [P0 count]; i++) {
        double t1 = [[P1 objectAtIndex:i] doubleValue];
        double t2 = [[P0 objectAtIndex:i] doubleValue];
        double exx = (t1 - t2)/sqrt(temp);
        [ex addObject:[NSNumber numberWithDouble:exx]];
    }
    
    // i = dot(ex, P2 - P0)
    NSMutableArray *P2P0 = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [P2 count]; i++) {
        double t1 = [[P2 objectAtIndex:i] doubleValue];
        double t2 = [[P0 objectAtIndex:i] doubleValue];
        double t3 = t1 - t2;
        [P2P0 addObject:[NSNumber numberWithDouble:t3]];
    }
    
    double ival = 0;
    for (int i = 0; i < [ex count]; i++) {
        double t1 = [[ex objectAtIndex:i] doubleValue];
        double t2 = [[P2P0 objectAtIndex:i] doubleValue];
        ival += (t1*t2);
    }
    
    // ey = (P2 - P0 - i*ex)/(numpy.linalg.norm(P2 - P0 - i*ex))
    NSMutableArray *ey = [[NSMutableArray alloc] initWithCapacity:0];
    double P2P0i = 0;
    for (int  i = 0; i < [P2 count]; i++) {
        double t1 = [[P2 objectAtIndex:i] doubleValue];
        double t2 = [[P0 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double t = t1 - t2 -t3;
        P2P0i += (t*t);
    }
    for (int i = 0; i < [P2 count]; i++) {
        double t1 = [[P2 objectAtIndex:i] doubleValue];
        double t2 = [[P0 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double eyy = (t1 - t2 - t3)/sqrt(P2P0i);
        [ey addObject:[NSNumber numberWithDouble:eyy]];
    }
    
    
    // ez = numpy.cross(ex,ey)
    // if 2-dimensional vector then ez = 0
    NSMutableArray *ez = [[NSMutableArray alloc] initWithCapacity:0];
    double ezx;
    double ezy;
    double ezz;
    if ([P0 count] !=3){
        ezx = 0;
        ezy = 0;
        ezz = 0;
        
    }else{
        ezx = ([[ex objectAtIndex:1] doubleValue]*[[ey objectAtIndex:2]doubleValue]) - ([[ex objectAtIndex:2]doubleValue]*[[ey objectAtIndex:1]doubleValue]);
        ezy = ([[ex objectAtIndex:2] doubleValue]*[[ey objectAtIndex:0]doubleValue]) - ([[ex objectAtIndex:0]doubleValue]*[[ey objectAtIndex:2]doubleValue]);
        ezz = ([[ex objectAtIndex:0] doubleValue]*[[ey objectAtIndex:1]doubleValue]) - ([[ex objectAtIndex:1]doubleValue]*[[ey objectAtIndex:0]doubleValue]);
        
    }
    
    [ez addObject:[NSNumber numberWithDouble:ezx]];
    [ez addObject:[NSNumber numberWithDouble:ezy]];
    [ez addObject:[NSNumber numberWithDouble:ezz]];
    
    
    // d = numpy.linalg.norm(P1 - P0)
    double d = sqrt(temp);
    
    // j = dot(ey, P2 - P0)
    double jval = 0;
    for (int i = 0; i < [ey count]; i++) {
        double t1 = [[ey objectAtIndex:i] doubleValue];
        double t2 = [[P2P0 objectAtIndex:i] doubleValue];
        jval += (t1*t2);
    }
    
    // x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
    double xval = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d);
    
    // y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
    double yval = ((pow(DistA,2) - pow(DistC,2) + pow(ival,2) + pow(jval,2))/(2*jval)) - ((ival/jval)*xval);
    
    // z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
    // if 2-dimensional vector then z = 0
    double zval;
    if ([P0 count] !=3){
        zval = 0;
    }else{
        zval = sqrt(pow(DistA,2) - pow(xval,2) - pow(yval,2));
    }
    
    // triPt = P0 + x*ex + y*ey + z*ez
    NSMutableArray *triPt = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [P0 count]; i++) {
        double t1 = [[P0 objectAtIndex:i] doubleValue];
        double t2 = [[ex objectAtIndex:i] doubleValue] * xval;
        double t3 = [[ey objectAtIndex:i] doubleValue] * yval;
        double t4 = [[ez objectAtIndex:i] doubleValue] * zval;
        double triptx = t1+t2+t3+t4;
        [triPt addObject:[NSNumber numberWithDouble:triptx]];
    }
    
    NSLog(@"ex %@",ex);
    NSLog(@"i %f",ival);
    NSLog(@"ey %@",ey);
    NSLog(@"d %f",d);
    NSLog(@"j %f",jval);
    NSLog(@"x %f",xval);
    NSLog(@"y %f",yval);
    NSLog(@"y %f",yval);
    NSLog(@"final result %@",triPt);

    return triPt;
}

@end
