//
//  GRBubble.m
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import "GRBubble.h"

#define GRAVITY 1.5

@implementation GRBubble

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _forces = [NSArray array];
    }
    return self;
}

- (NSComparisonResult)compareHeight:(GRBubble *)otherBubble {
    return self.center.y < otherBubble.center.y;
}

- (float)radius {
    return self.frame.size.width/2 - (self.layer.borderWidth - 3);
}

- (GRForce *)weight {
//    return [GRForce forceWithMagnitude:GRAVITY * M_PI * pow(self.radius, 2) direction:-90];
    return [GRForce forceWithMagnitude:GRAVITY * M_PI direction:-90];
}

- (GRForce *)getNetForce {
    return [GRForce sumForces:[_forces arrayByAddingObject:self.weight]];
}
@end
