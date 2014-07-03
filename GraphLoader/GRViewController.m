//
//  GRViewController.m
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import "GRViewController.h"

#import "GRBubble.h"

#define CORAL [UIColor colorWithRed:1 green:136/255.0 blue:125/255.0 alpha:1]
#define OFFWHITE [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]
#define DEFAULT_TOUCH_SIZE 40
#define RATE_OF_EXPANSION -1
#define BORDER_WIDTH 6

@interface GRViewController ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray *bubbles;
@property (nonatomic, strong) GRBubble *loaderView;

//@property (nonatomic, strong) UIDynamicAnimator *animator;
//@property (nonatomic, strong) UIGravityBehavior *gravity;
//@property (nonatomic, strong) UICollisionBehavior *collider;
//@property (nonatomic, strong) UIDynamicItemBehavior *elasticity;
@end

@implementation GRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _bubbles = [[NSMutableArray alloc] init];
    self.view.backgroundColor = OFFWHITE;
    int viewSize = 170;
    _loaderView = [[GRBubble alloc] initWithFrame:CGRectMake(0, 0, viewSize, viewSize)];
    _loaderView.status = GRBubbleFalling;
    _loaderView.center = CGPointMake(self.view.center.x, 140);
    _loaderView.layer.borderColor = CORAL.CGColor; _loaderView.layer.borderWidth = BORDER_WIDTH; _loaderView.layer.cornerRadius = _loaderView.frame.size.width/2;
    _loaderView.layer.contents = (__bridge id)[UIImage imageNamed:@"loading"].CGImage;
    _loaderView.layer.masksToBounds = YES;
    [self.view addSubview:_loaderView];
    [_bubbles addObject:_loaderView];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createBubble:)];
    recognizer.minimumPressDuration = .05;
    [self.view addGestureRecognizer:recognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_displayLink) _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animate)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)createBubble:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint center = [recognizer locationInView:self.view];
            GRBubble *bubble = [[GRBubble alloc] initWithFrame:CGRectMake(center.x - DEFAULT_TOUCH_SIZE/2, center.y - DEFAULT_TOUCH_SIZE/2, DEFAULT_TOUCH_SIZE, DEFAULT_TOUCH_SIZE)];
            __block BOOL intersection= NO;
            [_bubbles enumerateObjectsUsingBlock:^(GRBubble *otherBubble, NSUInteger idx, BOOL *stop) {
                if (bubble != otherBubble) {
                    //check if intersection with anyother bubble
                    if ([self bubble:bubble intersects:otherBubble elasticCollision:NO]) {
                        intersection = YES;
                        *stop = YES;
                    }
                }
            }];
            if (!intersection) {
                bubble.layer.masksToBounds = YES;
                bubble.status = GRBubbleExpanding;
                bubble.layer.borderColor = CORAL.CGColor; bubble.layer.borderWidth = BORDER_WIDTH; bubble.layer.cornerRadius = bubble.frame.size.width/2;
                [self.view addSubview:bubble];
                [_bubbles addObject:bubble];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_bubbles enumerateObjectsUsingBlock:^(GRBubble *bubble, NSUInteger idx, BOOL *stop) {
                if (bubble.status == GRBubbleExpanding) {
                    bubble.status = GRBubbleFalling;
                }
            }];
            break;
        }
        default:
            break;
    }
}


- (void)animate {
    NSArray *reversedBubbles = [[_bubbles reverseObjectEnumerator] allObjects];
    [reversedBubbles enumerateObjectsUsingBlock:^(GRBubble *bubble, NSUInteger idx, BOOL *stop) {
        if (bubble.status == GRBubbleExpanding) {
            if (CGRectContainsRect(self.view.frame, bubble.frame)) {
                __block BOOL intersection= NO;
                [_bubbles enumerateObjectsUsingBlock:^(GRBubble *otherBubble, NSUInteger idx, BOOL *stop) {
                    if (bubble != otherBubble) {
                        //check if intersection with anyother bubble
                        if ([self bubble:bubble intersects:otherBubble elasticCollision:NO]) {
                            intersection = YES;
                            *stop = YES;
                        }
                    }
                }];
                if (!intersection) {
                    bubble.frame = CGRectInset(bubble.frame, RATE_OF_EXPANSION, RATE_OF_EXPANSION);
                    bubble.layer.cornerRadius = bubble.frame.size.width/2;
                }
                
            }
            else {
                bubble.status = GRBubbleFalling;
            }
            
        }
        else if (bubble.status == GRBubbleFalling) {
            //either falling or bouncing around
            __block BOOL intersection= NO;
            __block BOOL restart = YES;
            __block int retries = 3;
            while (_bubbles.count > 1 && restart && retries > 0) {
                [_bubbles enumerateObjectsUsingBlock:^(GRBubble *otherBubble, NSUInteger idx, BOOL *stop) {
                    if (bubble != otherBubble) {
                        //check if intersection with anyother bubble
                        if ([self bubble:bubble intersects:otherBubble elasticCollision:YES]) {
                            intersection = YES;
                            restart = YES;
                            retries--;
                            *stop = YES;
                        }
                        else restart = NO;
                    }
                }];
            }
            
            if (intersection) {
                bubble.status = GRBubbleStill;

            }
            else if (bubble.center.y + bubble.frame.size.height/2 > self.view.frame.size.height) {
                [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    bubble.frame = CGRectMake(bubble.frame.origin.x, self.view.frame.size.height - bubble.frame.size.height, bubble.frame.size.width, bubble.frame.size.height);
                } completion:nil];
                bubble.status = GRBubbleStill;
            }
            else {
                bubble.center = CGPointMake(bubble.center.x, bubble.center.y + [self gravity:bubble]);
            }

        }
    }];
}

- (BOOL)bubble:(GRBubble *)bubble intersects:(GRBubble *)otherBubble elasticCollision:(BOOL)elasticCollision {
    CGPoint bubbleCenter = bubble.center;
    CGPoint otherBubbleCenter = otherBubble.center;
    float bubbleRadius = bubble.frame.size.width/2 - BORDER_WIDTH/2;
    float otherBubbleRadius = otherBubble.frame.size.width/2 - BORDER_WIDTH/2;
    //find hypotenuse
    float hypotenuse = sqrtf(powf(bubbleCenter.x - otherBubbleCenter.x, 2) + powf(bubbleCenter.y - otherBubbleCenter.y, 2));
    BOOL intersect = hypotenuse < bubbleRadius + otherBubbleRadius;
    if (intersect && elasticCollision) {
        float newHypotenuse = bubbleRadius + otherBubbleRadius;
        //find angle and extrapolate
        CGFloat angle = asin((otherBubbleCenter.y - bubbleCenter.y)/hypotenuse);
        float dx = newHypotenuse * cosf(angle); // the new horizontal leg length
        float dy = newHypotenuse * sinf(angle); // the new vertical leg length
        
        NSLog(@"dx:%f", dx);
        NSLog(@"dy:%f", dy);
        //TODO:fix this NaN issue, in other words, stop it from ever happening
        if (!(isnan(dx) || isnan(dy))) {
            NSLog(@"valid");
            [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:(newHypotenuse - hypotenuse)/10 options:UIViewAnimationOptionCurveEaseOut animations:^{
                bubble.center = CGPointMake(otherBubbleCenter.x - dx * (bubbleCenter.x > otherBubbleCenter.x ? -1: 1), otherBubbleCenter.y - dy);
            } completion:nil];
            bubble.status = GRBubbleStill;
        }
        else {
            [bubble removeFromSuperview];
            [_bubbles removeObject:bubble];
        }
        
        
        
    }
    
    return intersect;
}

- (float)gravity:(GRBubble *)bubble {
    float distanceToBottom = self.view.frame.size.height - (bubble.center.y + bubble.frame.size.height/2);
    //tested values
    return 500/(.25 * (distanceToBottom + 25)) - 7 * -1;
}


@end
