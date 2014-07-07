//
//  GRBubble.h
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRForce.h"

#define GRAVITY 17

typedef NS_ENUM(NSUInteger, GRBubbleStatus) {
    GRBubbleExpanding,
    GRBubbleFalling
};



@interface GRBubble : UIView
@property (nonatomic, assign) GRBubbleStatus status;
@property (nonatomic, assign) float radius;
@property (nonatomic, strong) NSArray *forces;
@property (nonatomic, strong) GRForce *weight;
@property (nonatomic, assign) float vx;
@property (nonatomic, assign) float vy;

- (CGFloat)mass;
- (GRForce *)getNetForce;
@end
