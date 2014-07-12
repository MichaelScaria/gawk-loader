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

//- (void)drawRect:(CGRect)rect {
////    return;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    unsigned char* data = CGBitmapContextGetData(context);
//    NSAssert(data != NULL, @"WAT");
//    NSLog(@"%@", NSStringFromCGRect(self.frame));
//    unsigned long length = self.frame.size.height * self.frame.size.width * 4 * 2 * 2;
//    for (unsigned long i = 0; i < length; i+=4) {
//        if (data[i] == 247) {
//            data[i] = 125; data[i + 1] = 136; data[i + 2] = 255;
//        }
//        else {
//            data[i] = 247; data[i + 1] = 247; data[i + 2] = 247;
//        }
//    }
//}
@end
