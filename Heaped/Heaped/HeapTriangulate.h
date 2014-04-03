//
//  HeapTriangulate.h
//  Heaped
//
//  Created by Michael Zhao on 4/3/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeapTriangulate : NSObject
{
    int x0;
    int x1;
    int x2;
    
    int y0;
    int y1;
    int y2;
}

-(NSArray *)triangulate:(NSArray *)dist;
-(float)angle:(float)c a:(float)a b:(float)b;

@end
