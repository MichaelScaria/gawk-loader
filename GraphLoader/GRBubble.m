//
//  GRBubble.m
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import "GRBubble.h"



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

- (CGFloat)mass {
    return M_PI * pow(self.radius, 2);
}

- (GRForce *)weight {
    return [GRForce forceWithFx:0 fy:GRAVITY * [self mass]];
}

- (GRForce *)getNetForce {
    return [GRForce sumForces:[_forces arrayByAddingObject:self.weight]];
}

@end
