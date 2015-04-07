//
//  ViewController.m
//  LayerAnimation3
//
//  Created by Steven Shatz on 4/6/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import "ViewController.h"

#define kMaxTransCount 4

@interface ViewController () {
    NSString * _prevTrans;
    NSString * _prevSubtrans;
    int _transCount;
}

@property (nonatomic, weak) IBOutlet UIView *layerView;
@property (nonatomic, strong) CALayer *colorLayer;
@property (nonatomic, strong) CATransition *transition;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _prevTrans = @"";
    _prevSubtrans = @"";
    _transCount = kMaxTransCount;
    
    double colorLayerWidth;
    double colorLayerHeight;
    if (self.view.bounds.size.width < self.view.bounds.size.height) {
        colorLayerWidth = self.view.bounds.size.width / 3.0;
        colorLayerHeight = colorLayerWidth;
    } else {
        colorLayerHeight = self.view.bounds.size.height / 3.0;
        colorLayerWidth = colorLayerHeight;
    }

    //create sublayer
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(0, 0, colorLayerWidth, colorLayerHeight);
    self.colorLayer.anchorPoint = CGPointMake(0.5, 0.5);    // make anchor point the center of the layer
    self.colorLayer.position = self.view.center; // set layer's position to center of its superlayer
    self.colorLayer.backgroundColor = [self randomColor].CGColor;
    
    self.layerView.backgroundColor = [self randomColor];
    
    //add a custom action
    self.transition = [CATransition animation];
    self.transition.type = [self randomizeTransitionType];
    self.transition.subtype = [self randomizeTransitionSubtype];
    self.colorLayer.actions = @{@"backgroundColor":self.transition};
    
    //self.layerView.clipsToBounds = YES;

    //add it to our view's backing layer
    [self.layerView.layer addSublayer:self.colorLayer];
    
    //launch automatic color change every 6 seconds
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeColor:)];
    displayLink.frameInterval = 120;   // refresh display once every 120 frames
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    self.colorLayer.position = CGPointMake(self.colorLayer.position.y,self.colorLayer.position.x);
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (IBAction)changeColor:(id)sender {
    //begin a new transaction
    [CATransaction begin];
    
    //set the animation duration to 1 second
    [CATransaction setAnimationDuration:1.0];
    
    //add spin animation on completion
    [CATransaction setCompletionBlock:^{
        //rotate the layer 45 degrees
        CGAffineTransform transform = self.colorLayer.affineTransform;
        transform = CGAffineTransformRotate(transform, M_PI_4);
        self.colorLayer.affineTransform = transform;
    }];
    
    //create a new random color
    self.colorLayer.backgroundColor = [self randomColor].CGColor;
    self.layerView.backgroundColor = [self randomColor];

    //randomize the animation transition
    if (--_transCount < 1) {   // Only change transition type once every 4 color changes (4->3, 3->2, 2->1, 1->0->change)
        _transCount = kMaxTransCount;
        self.transition.type = [self randomizeTransitionType];
    }
    
    self.transition.subtype = [self randomizeTransitionSubtype];
    
    //commit the transaction
    [CATransaction commit];
    
//    //create a basic animation
//    CABasicAnimation *animation =[CABasicAnimation animation];
//    animation.keyPath = @"backgroundColor";
//    animation.toValue = (__bridge id)color.CGColor;
//    animation.duration = 4.0;   // 4 seconds (at 60 frames per second?)
//    animation.delegate = self;
//    
//    [self.colorLayer addAnimation:animation forKey:nil];
}

- (UIColor *)randomColor {
    CGFloat red = arc4random_uniform(255)/ 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    return color;
}

- (NSString *)randomizeTransitionType {
    NSString *newTrans;
    do {
        NSUInteger type = arc4random_uniform(3); //returns 0 - 2
        switch (type) {
            case 0:
                newTrans = kCATransitionMoveIn;
                break;
            case 1:
                newTrans = kCATransitionPush;
                break;
            default:
                newTrans = kCATransitionFade;
        }
    } while ([newTrans isEqualToString:_prevTrans]);
    _prevTrans = newTrans;
    return newTrans;
}

- (NSString *)randomizeTransitionSubtype {
    NSString *newSubtrans;
    do {
        NSUInteger type = arc4random_uniform(4); //returns 0 - 3
        switch (type) {
            case 0:
                newSubtrans = kCATransitionFromBottom;
                break;
            case 1:
                newSubtrans = kCATransitionFromTop;
                break;
            case 2:
                newSubtrans = kCATransitionFromLeft;
                break;
            default:
                newSubtrans = kCATransitionFromRight;
        }
    } while ([newSubtrans isEqualToString:_prevSubtrans]);
    _prevSubtrans = newSubtrans;
    return newSubtrans;
}

#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag {
    if (!flag) { return; }  // animation did not finish
    //set the backgroundColor property to match animation toValue
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.colorLayer.backgroundColor = (__bridge CGColorRef)anim.toValue;
    [CATransaction commit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
