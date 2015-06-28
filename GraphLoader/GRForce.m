//
//  GRForce.m
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import "GRForce.h"

//#define TO_RADIANS(degrees) ((degrees) / 180.0 * M_PI)


@implementation GRForce
+ (GRForce *)forceWithFx:(CGFloat)fx fy:(CGFloat)fy {
    GRForce *force = [[GRForce alloc] init];
    force.fx = fx; force.fy = fy;
    return force;
}

+ (GRForce *)sumForces:(NSArray *)forces logs:(BOOL)logs {
    __block CGFloat fxSum = 0; __block CGFloat fySum = 0;
    [forces enumerateObjectsUsingBlock:^(GRForce *force, NSUInteger idx, BOOL *stop) {
        //        NSLog(@"%@", force);
        /*NSLog(@"%d - %f", 90 - abs(90 - (int)force.direction), cos(TO_RADIANS((int)(90 - abs(90 - (int)force.direction)))));
         CGFloat angle = TO_RADIANS((int)(90 - abs(90 - (int)force.direction)));
         dxSum += force.magnitude * cos(angle) * (abs(force.direction) > 90 ? -1 : 1);
         dySum += force.magnitude * sin(angle);*/
        fxSum += force.fx;
        fySum += force.fy;
        
    }];
    if (logs) NSLog(@"Force Count:%lu", (unsigned long)forces.count);
    fxSum = truncf(roundf(fxSum));
    fySum = truncf(roundf(fySum));
    //    float hypotenuse = sqrtf(powf(dxSum, 2) + powf(dySum, 2));
    //    CGFloat angle = asin((dySum)/hypotenuse);
    GRForce *f = [GRForce forceWithFx:fxSum fy:fySum];
    return f;
}

+ (GRForce *)sumForces:(NSArray *)forces {
    __block CGFloat fxSum = 0; __block CGFloat fySum = 0;
    [forces enumerateObjectsUsingBlock:^(GRForce *force, NSUInteger idx, BOOL *stop) {
//        NSLog(@"%@", force);
        /*NSLog(@"%d - %f", 90 - abs(90 - (int)force.direction), cos(TO_RADIANS((int)(90 - abs(90 - (int)force.direction)))));
        CGFloat angle = TO_RADIANS((int)(90 - abs(90 - (int)force.direction)));
        dxSum += force.magnitude * cos(angle) * (abs(force.direction) > 90 ? -1 : 1);
        dySum += force.magnitude * sin(angle);*/
        fxSum += force.fx;
        fySum += force.fy;
        
    }];
//    NSLog(@"Force Count:%lu", (unsigned long)forces.count);
    fxSum = truncf(roundf(fxSum));
    fySum = truncf(roundf(fySum));
//    float hypotenuse = sqrtf(powf(dxSum, 2) + powf(dySum, 2));
//    CGFloat angle = asin((dySum)/hypotenuse);
    GRForce *f = [GRForce forceWithFx:fxSum fy:fySum];
    return f;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Force:fx:%f fy:%f>", _fx, _fy];
}
@end
