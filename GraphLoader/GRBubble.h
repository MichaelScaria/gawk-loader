//
//  GRBubble.h
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GRBubbleStatus) {
    GRBubbleExpanding,
    GRBubbleStill
};



@interface GRBubble : UIView
@property (nonatomic, assign) GRBubbleStatus status;
@end
