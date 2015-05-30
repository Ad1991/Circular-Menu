//
//  RotatingWheel.m
//  CircularMenu
//

#import "RotatingWheel.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_VELOCITY 1000.0
#define MIN_VELOCITY 10.0
#define DECELERATION_RATE 0.92
#define BUTTON_WIDTH    44

#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define radiansToDegrees(x) (180 * (x) / M_PI)

@interface RotatingWheel ()

@property BOOL isWheelDecelerating;
@property double animationVelocity;
@property double startTouchTime;
@property double endTouchTime;
@property double angleChange;
@property CGFloat sectorAngle;
@property CGFloat initialAngle;
@property CADisplayLink *displayLink;

@property (weak) id <MenuSelectionProtocol> delegate;
@property (strong) NSArray *items;
@end

@implementation RotatingWheel

#pragma mark - Public functions

- (id) initWithView:(CGRect)frame
           delegate:(id)delegate
               items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.items=items;
        [self createRotatingViewWithFrame:self.bounds];
        _delegate = delegate;
        _currentAngle = 0;
    }
    return self;
}

-(void)createRotatingViewWithFrame:(CGRect)frame {
    CGFloat angleSize = 2*M_PI/self.items.count;
    for (int i=0; i<self.items.count; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(self.frame.size.width/2-BUTTON_WIDTH/2, self.frame.size.height/2-BUTTON_WIDTH/2, BUTTON_WIDTH, BUTTON_WIDTH);
        button.layer.anchorPoint=CGPointMake(0.5f, 0.5f);
        CGFloat deltaX=self.frame.size.width/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH)*cos(angleSize*i);//cx+r*cos(a)
        deltaX-=self.frame.size.width/2-BUTTON_WIDTH/2;
        CGFloat deltaY=self.frame.size.height/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH)*sin(angleSize*i);//cy+r*sin(a)
        deltaY-=self.frame.size.height/2-BUTTON_WIDTH/2;//because views are created in center and not at (0,0)
        
        CGFloat deltaXfar=self.frame.size.width/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH+20)*cos(angleSize*i);
        deltaXfar-=self.frame.size.width/2-BUTTON_WIDTH/2;
        CGFloat deltaYfar=self.frame.size.height/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH+20)*sin(angleSize*i);
        deltaYfar-=self.frame.size.height/2-BUTTON_WIDTH/2;
        
        CGFloat deltaXnear=self.frame.size.width/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH-12)*cos(angleSize*i);
        deltaXnear-=self.frame.size.width/2-BUTTON_WIDTH/2;
        CGFloat deltaYnear=self.frame.size.height/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH-12)*sin(angleSize*i);
        deltaYnear-=self.frame.size.height/2-BUTTON_WIDTH/2;
        
        CGFloat deltaXfar2=self.frame.size.width/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH+7)*cos(angleSize*i);
        deltaXfar2-=self.frame.size.width/2-BUTTON_WIDTH/2;
        CGFloat deltaYfar2=self.frame.size.height/2-(BUTTON_WIDTH/2)+(self.frame.size.width/2-BUTTON_WIDTH+7)*sin(angleSize*i);
        deltaYfar2-=self.frame.size.height/2-BUTTON_WIDTH/2;
        
        [UIView animateWithDuration:0.3 animations:^{
            button.transform = CGAffineTransformMakeTranslation(deltaXfar,deltaYfar);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.18 animations:^{
                button.transform = CGAffineTransformMakeTranslation(deltaXnear,deltaYnear);
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:0.14 animations:^{
                   button.transform = CGAffineTransformMakeTranslation(deltaXfar2,deltaYfar2);
                }completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                       button.transform = CGAffineTransformMakeTranslation(deltaX,deltaY);
                    }];
                }];
            }];
        }];
        button.tag=i;
        [button setImage:[UIImage imageNamed:self.items[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tagSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

-(void)tagSelected:(UIButton*)sender {
    CGRect parentBounds=self.superview.bounds;
    CGPoint touchPoint=[self.superview convertPoint:CGPointMake(sender.frame.size.width/2, sender.frame.size.height/2) fromView:sender];
    UIView *snapshot=[sender snapshotViewAfterScreenUpdates:YES];
    [self.superview addSubview:snapshot];
    snapshot.center=touchPoint;
    [self dampView];
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        snapshot.frame=CGRectMake(parentBounds.size.width-35, parentBounds.size.height-35, 30, 30);
    } completion:^(BOOL finished) {
        [snapshot removeFromSuperview];
        if ([self delegateRespondsToMethodWithName:@"circularMenuSelectedAtIndex:"]) {
            [[self delegate] circularMenuSelectedAtIndex:sender.tag];
        }
    }];
}

-(void)dampView {
    UIDynamicAnimator *animator1 = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self attachedToAnchor:self.center];
    [attachmentBehavior setFrequency:2.0];
    [attachmentBehavior setDamping:0.4];
    [animator1 addBehavior:attachmentBehavior];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = M_PI_4;
    pushBehavior.magnitude = 150.0;
    [animator1 addBehavior:pushBehavior];
    [pushBehavior setActive:TRUE];
    self.animator=animator1;
}

- (void)rotateToAngle:(CGFloat)angle animated:(BOOL)animated
{
    [UIView animateWithDuration:(animated)? 0.4f : 0.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self setCurrentAngle:angle];
                     }
                     completion:nil];
}

#pragma mark - Setter functions

- (void)setNumberOfSectors:(int)numberOfSections
{
    _numberOfSectors = numberOfSections;
    self.sectorAngle = 2 * M_PI / _numberOfSectors;
}

- (void)setCurrentAngle:(CGFloat)currentAngle
{
    [self transformByAngle:currentAngle - _currentAngle];
    _currentAngle = currentAngle;
}

#pragma mark - Helper function
CGFloat angleOfAPointFromPositiveXAxis(CGFloat y, CGFloat x)
{
    CGFloat theAngle = atan2f(y, x);  //atan2 is from -pi to pi. 1st quadrant x-axis to y-axis 0 to -pi/2, 2nd quadrant y-axis to x-axis -pi/2 to -pi, 3rd quadrant x-axis to y-axis -pi to pi/2 and 4th quadrant y-axis to x-axis pi/2 to 0. But the transform works in anti clockwise direction 0 to 2pi.
    
    // atan2f() returns values based on a unit circle. We want to convert into a full 360 degrees rather than use any negative values.
    if (theAngle < 0)
    {
        theAngle += 2*M_PI;
    }
	return theAngle;
}

- (CGFloat) distanceFromCenterOfPoint:(CGPoint)point
{
    CGPoint center = self.center;
    CGFloat dx = point.x - center.x;
    CGFloat dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}

/**
 The function is called from continueTrackingWithTouch:withEvent: function. The parameters set within this fucntion 
 helps in identifying the velocity of rotation.
 */
-(void)recordMovementWithAngle:(CGFloat)angle time:(NSTimeInterval)time
{    
    self.startTouchTime = self.endTouchTime;
    self.endTouchTime = time;
    
    if (angle > 100.0f)
    {
        angle -=360.0f;
    }
    else if (angle < -100.0f)
    {
        angle +=360.0f;
    }
    self.angleChange = angle;
}

CGFloat rotationVelocity(double startTouchTime, double endTouchTime, double angleChange)
{
    double velocity = 0.0;
    
    if (startTouchTime != endTouchTime)
    {
        velocity = angleChange/(endTouchTime - startTouchTime);     // Speed = distance/time (degrees/seconds)
    }
    return (velocity > MAX_VELOCITY) ? MAX_VELOCITY : ((velocity < -MAX_VELOCITY) ? -MAX_VELOCITY : velocity);
}

- (void) transformByAngle:(CGFloat)angleInDegrees
{
    self.transform = CGAffineTransformRotate(self.transform, degreesToRadians(-angleInDegrees));
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.layer.anchorPoint=CGPointMake(0.5, 0.5);
            button.transform=CGAffineTransformRotate(button.transform, degreesToRadians(angleInDegrees));
        }
    }
}

- (BOOL)delegateRespondsToMethodWithName:(NSString*)methodName
{
    return (self.delegate != nil && [self.delegate respondsToSelector:NSSelectorFromString(methodName)]);
}

/**
 The function is called after the wheel completed rotation and deceleration.
 Applies some transform to the rotating wheel view in case required. This depends on the number of sections
 the wheel is divided into in turn the angle of each section. 
 */
- (void)reposition
{
    CGAffineTransform transform = self.transform;
    CGFloat rotatedAngle = angleOfAPointFromPositiveXAxis(transform.b, transform.a);
    CGFloat diff = fmodf(rotatedAngle, self.sectorAngle);
    
    [UIView animateWithDuration:0.4f animations:^{
        if (diff < (self.sectorAngle/2))
        {
            self.transform = CGAffineTransformRotate(self.transform, -diff);
        }
        else
        {
            self.transform = CGAffineTransformRotate(self.transform, (self.sectorAngle - diff));
        }
    }];
}

#pragma mark - Deceleration related functions

-(void)beginDeceleration
{
    double velocity = rotationVelocity(self.startTouchTime, self.endTouchTime, self.angleChange);
    
    if (velocity >= MIN_VELOCITY || velocity <= -MIN_VELOCITY)
    {
        self.isWheelDecelerating = YES;
        self.animationVelocity = velocity;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(decelerationStep)];
        self.displayLink.frameInterval = 1;
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

-(void)decelerationStep
{
    double newVelocity = self.animationVelocity * DECELERATION_RATE;
    CGFloat angleToRotate = self.animationVelocity/60.0;                //60Hz is the screen refresh rate of iPhone
    
    if (angleToRotate <= 0.1 && angleToRotate >= -0.1)
    {
        [self endDeceleration];
    }
    else
    {
        self.animationVelocity = newVelocity;
        [self transformByAngle:angleToRotate];
    }
}

-(void)endDeceleration
{
    self.isWheelDecelerating = NO;
    [self.displayLink invalidate], self.displayLink = nil;

    if ([self delegateRespondsToMethodWithName:@"viewDidEndDecelerating:"])
    {
        [self.delegate viewDidEndDecelerating:self];
    }
    if ([self delegateRespondsToMethodWithName:@"view:rotationStoppedAtSection:"])
    {
        [self.delegate view:self rotationStoppedAtSection:0];
    }
}

- (BOOL) isTouchesTooCloseToCenter:(CGPoint)touchPoint      //To filter out touches too close to the center
{
    BOOL returnVal = NO;
    CGFloat dist = [self distanceFromCenterOfPoint:touchPoint];
    
    if (dist < self.filterTouchDistance)
    {
        returnVal = YES;
    }
    return returnVal;
}


#pragma mark - UIControl delegates

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.isWheelDecelerating)
    {
        [self endDeceleration];
    }
    
    CGPoint touchPoint = [touch locationInView:[self superview]];
    if ([self isTouchesTooCloseToCenter:touchPoint])
    {
        return NO;
    }
    
    self.initialAngle = angleOfAPointFromPositiveXAxis(self.center.y - touchPoint.y, touchPoint.x - self.center.x) * 180.0f/M_PI;
    self.startTouchTime = self.endTouchTime = [NSDate timeIntervalSinceReferenceDate];

    if ([self delegateRespondsToMethodWithName:@"viewWillRotate:"])
    {
        [self.delegate viewWillRotate:self];
    }
    return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[self superview]];
    CGFloat updatedAngle = angleOfAPointFromPositiveXAxis(self.center.y - touchPoint.y, touchPoint.x - self.center.x) * 180.0f/M_PI;
    CGFloat angleToRotate = updatedAngle - self.initialAngle;

    [self transformByAngle:angleToRotate];
    [self recordMovementWithAngle:angleToRotate time:[NSDate timeIntervalSinceReferenceDate]];
    
    
    self.initialAngle = updatedAngle;
    
    if ([self delegateRespondsToMethodWithName:@"view:rotatedByAngle:"])
    {
        [self.delegate view:self rotatedByAngle:angleToRotate];
    }
    return YES;
}


- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.shouldDecelerate == YES)
    {
        [self beginDeceleration];
    }
    if ([self delegateRespondsToMethodWithName:@"viewDidEndRotating:"])
    {
        [self.delegate viewDidEndRotating:self];
    }
}
@end
