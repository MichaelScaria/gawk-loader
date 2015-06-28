//
//  GRForce.h
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRForce : NSObject
//@property (nonatomic, assign) CGFloat magnitude;
//@property (nonatomic, assign) CGFloat direction;
@property (nonatomic, assign) CGFloat fx;
@property (nonatomic, assign) CGFloat fy;

+ (GRForce *)forceWithFx:(CGFloat)fx fy:(CGFloat)fy;
+ (GRForce *)sumForces:(NSArray *)forces logs:(BOOL)logs;
+ (GRForce *)sumForces:(NSArray *)forces;
@end
