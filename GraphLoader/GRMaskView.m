//
//  GRMaskView.m
//  GraphLoader
//
//  Created by Michael Scaria on 7/11/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import "GRMaskView.h"


#define CORAL [UIColor colorWithRed:1 green:106/255.0 blue:25/255.0 alpha:1]



@implementation GRMaskView
/*- (void)drawRect:(CGRect)rect {
    for (UIView *subview in self.subviews) subview.alpha = 1;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    unsigned char* data = CGBitmapContextGetData(context);
    NSAssert(data != NULL, @"WAT");
    NSLog(@"%@", NSStringFromCGRect(self.frame));
    unsigned long length = self.frame.size.height * self.frame.size.width * 4 * 2 * 2;
    for (unsigned long i = 1200000; i < length; i+=4) {
        if (data[i] == 247) {
            data[i] = 125; data[i + 1] = 136; data[i + 2] = 255;
        }
        else {
            data[i] = 247; data[i + 1] = 247; data[i + 2] = 247;
        }
    }
    for (UIView *subview in self.subviews) subview.alpha = 0;

}*/
@end
