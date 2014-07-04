//
//  GRViewController.m
//  GraphLoader
//
//  Created by Michael Scaria on 7/3/14.
//  Copyright (c) 2014 michaelscaria. All rights reserved.
//

#import "GRViewController.h"

#import "GRBubble.h"
#import "GRForce.h"

#define CORAL [UIColor colorWithRed:1 green:136/255.0 blue:125/255.0 alpha:1]
#define OFFWHITE [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]
#define DEFAULT_TOUCH_SIZE 40
#define RATE_OF_EXPANSION -1
#define BORDER_WIDTH 6
#define TO_DEGREES(radians) radians * 57.2957795

#define HYPOTENUSE(bubbleCenter, otherBubbleCenter) sqrtf(powf(bubbleCenter.x - otherBubbleCenter.x, 2) + powf(bubbleCenter.y - otherBubbleCenter.y, 2))
#define ANGLE(otherBubbleCenter, bubbleCenter, hypotenuse) asin((otherBubbleCenter.y - bubbleCenter.y)/hypotenuse);


@interface GRViewController ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray *bubbles;
@property (nonatomic, strong) NSMutableArray *sortedBubbles;
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
    _sortedBubbles = [[NSMutableArray alloc] init];
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
    [_sortedBubbles addObject:_loaderView];

    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createBubble:)];
    recognizer.minimumPressDuration = .05;
    [self.view addGestureRecognizer:recognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_displayLink) _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animate)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    lastUpdate = _displayLink.timestamp;
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
                [_sortedBubbles addObject:bubble];
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
    //sort all the bubbles out
    _sortedBubbles = [[_sortedBubbles sortedArrayUsingSelector:NSSelectorFromString(@"compareHeight:")] mutableCopy];
    [_sortedBubbles enumerateObjectsUsingBlock:^(GRBubble *bubble, NSUInteger idx, BOOL *stop) {
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
        if (bubble.status == GRBubbleFalling) {
            /*[_bubbles enumerateObjectsUsingBlock:^(GRBubble *otherBubble, NSUInteger idx, BOOL *stop) {
                if (bubble != otherBubble) {
                    //check if intersection with any other bubble
                    if ([self bubble:bubble intersects:otherBubble elasticCollision:YES]) {
                        *stop = YES;
                    }
                }
            }];
            
            if (bubble.center.y + bubble.frame.size.height/2 > self.view.frame.size.height) {
                [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    bubble.frame = CGRectMake(bubble.frame.origin.x, self.view.frame.size.height - bubble.frame.size.height, bubble.frame.size.width, bubble.frame.size.height);
                } completion:nil];
            }*/
            
            
            NSMutableArray *forces = [[NSMutableArray alloc] initWithCapacity:_bubbles.count];
            //limit within boundaries
//            int threshold = 10;
//            if (bubble.center.y > self.view.frame.size.height - bubble.frame.size.height/2 + threshold) {
//                NSLog(@"%f - %f", bubble.center.y, self.view.frame.size.height - bubble.frame.size.height/2);
//                bubble.center = CGPointMake(MIN(MAX(bubble.center.x, bubble.frame.size.width/2 + threshold), self.view.frame.size.width - bubble.frame.size.width/2 - threshold), MIN(bubble.center.y, self.view.frame.size.height - bubble.frame.size.height/2));
//                NSLog(@"%f - %f", bubble.center.y, self.view.frame.size.height - bubble.frame.size.height/2);
//            }
            
//            bubble.frame = CGRectMake(MIN(self.view.frame.size.width - bubble.frame.size.width, bubble.frame.origin.x), MIN(self.view.frame.size.height - bubble.frame.size.height, bubble.frame.origin.y), bubble.frame.size.width, bubble.frame.size.height);
            [_sortedBubbles enumerateObjectsUsingBlock:^(GRBubble *otherBubble, NSUInteger idx, BOOL *stop) {
                if (bubble != otherBubble && otherBubble.status == GRBubbleFalling) {
                    //remove entropy
                    //bubbles push up, so only push bubbles above current
                    if (bubble.center.y >= otherBubble.center.y) {
                        //otherBubble needs to move if intersection
                        [self bubble:otherBubble intersects:bubble elasticCollision:YES];
                    }
                    
                    //add forces acting on bubble
                    if ([self bubble:bubble intersects:otherBubble elasticCollision:NO]) {
                        CGPoint bubbleCenter = bubble.center;
                        CGPoint otherBubbleCenter = otherBubble.center;
                        float hypotenuse = HYPOTENUSE(bubbleCenter,otherBubbleCenter);
                        CGFloat angle = ANGLE(otherBubbleCenter, bubbleCenter, hypotenuse);
                        CGFloat theta = M_PI_2 - angle;
                        NSLog(@"%f with %f", bubble.frame.size.width, TO_DEGREES(angle) + (bubble.center.x > otherBubble.center.x ? (90 * angle > 0 ? 1 : -1) : 0));
                        GRForce *force = [GRForce forceWithMagnitude:bubble.weight.magnitude * cos(theta) direction:TO_DEGREES(angle) + (bubble.center.x > otherBubble.center.x ? (90 * angle > 0 ? 1 : -1) : 0)];
                        [forces addObject:force];
                    }
                }
                
            }];
            //add forces for boundaries
            //bottom
            if (bubble.center.y > self.view.frame.size.height - bubble.frame.size.height/2) {
                [forces addObject:[GRForce forceWithMagnitude:bubble.weight.magnitude direction:90]];
            }
            //left
            if (bubble.center.x < bubble.frame.size.width/2) {
                [forces addObject:[GRForce forceWithMagnitude:bubble.weight.magnitude direction:0]];
            }
            //right
            if (bubble.center.x > self.view.frame.size.width - bubble.frame.size.width/2) {
                [forces addObject:[GRForce forceWithMagnitude:bubble.weight.magnitude direction:180]];
            }
            bubble.forces = (NSArray *)forces;

        }
        
    }];
    
    
    //sum up all forces
    [_bubbles enumerateObjectsUsingBlock:^(GRBubble *bubble, NSUInteger idx, BOOL *stop) {
        if (bubble.status == GRBubbleFalling) {
            GRForce *netForce = [bubble getNetForce];
            //delta is 1/2 acceleration * timeElasped^2
            //f=ma, a = f/(pi*r^2)
            NSLog(@"%f", netForce.dy);
            CFTimeInterval td = pow(_displayLink.timestamp - lastUpdate, 2);
            bubble.center = CGPointMake(bubble.center.x + (netForce.dx * td)/(2 * M_PI * pow(bubble.radius, 2)), bubble.center.y + (netForce.dy * td)/(2 * M_PI * pow(bubble.radius, 2)));
            NSLog(@"%@", NSStringFromCGPoint(bubble.center));
//            [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                bubble.center = CGPointMake(MIN(MAX(bubble.center.x + netForce.dx, bubble.frame.size.width/2), self.view.frame.size.width - bubble.frame.size.width/2), MIN(bubble.center.y + netForce.dy, self.view.frame.size.height - bubble.frame.size.height/2));

//            } completion:nil];
        }
    }];
    lastUpdate = _displayLink.timestamp;

}

- (BOOL)bubble:(GRBubble *)bubble intersects:(GRBubble *)otherBubble elasticCollision:(BOOL)elasticCollision {
    CGPoint bubbleCenter = bubble.center;
    CGPoint otherBubbleCenter = otherBubble.center;
    float bubbleRadius = bubble.radius;
    float otherBubbleRadius = otherBubble.radius;
    //find hypotenuse
    float hypotenuse = HYPOTENUSE(bubbleCenter, otherBubbleCenter);
    BOOL intersect = hypotenuse < bubbleRadius + otherBubbleRadius;
    if (intersect && elasticCollision) {
        float newHypotenuse = bubbleRadius + otherBubbleRadius;
        //find angle and extrapolate
        CGFloat angle = ANGLE(otherBubbleCenter, bubbleCenter, hypotenuse);
        float dx = newHypotenuse * cosf(angle); // the new horizontal leg length
        float dy = newHypotenuse * sinf(angle); // the new vertical leg length
//        NSLog(@"dx:%f", dx);
//        NSLog(@"dy:%f", dy);
        //TODO:fix this NaN issue, in other words, stop it from ever happening
        if (!(isnan(dx) || isnan(dy))) {
            
            [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:(newHypotenuse - hypotenuse)/10 options:UIViewAnimationOptionCurveEaseOut animations:^{
                bubble.center = CGPointMake(otherBubbleCenter.x - dx * (bubbleCenter.x > otherBubbleCenter.x ? -1: 1), otherBubbleCenter.y - dy);
            } completion:nil];
//            bubble.status = GRBubbleStill;
        }
        else {
            [bubble removeFromSuperview];
            [_bubbles removeObject:bubble];
            [_sortedBubbles addObject:bubble];
        }
        
        
        
    }
    
    return intersect;
}


- (float)gravity:(GRBubble *)bubble {
    float distanceToBottom = self.view.frame.size.height - (bubble.center.y + bubble.frame.size.height/2);
    //tested values
    //TODO:take into account radius
    return 500/(.25 * (distanceToBottom + 25)) - 7 * -1;
}


@end
