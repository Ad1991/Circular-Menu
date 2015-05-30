//
//  RotatingWheel.m
//  CircularMenu
//

#import <UIKit/UIKit.h>

@protocol MenuSelectionProtocol <NSObject>
-(void)circularMenuSelectedAtIndex:(NSUInteger)index;
@optional
- (void) viewWillRotate:(UIView*)view;
- (void) view:(UIView*)rotatingView rotatedByAngle:(CGFloat)angle;
- (void) viewDidEndRotating:(UIView*)view;
- (void) viewDidEndDecelerating:(UIView*)view;
- (void) view:(UIView*)rotatingView rotationStoppedAtSection:(NSInteger)sectionNumber;

@end

@interface RotatingWheel : UIControl

@property (nonatomic) CGFloat filterTouchDistance;
@property (nonatomic) BOOL shouldDecelerate;
@property (nonatomic) int numberOfSectors;
@property (nonatomic) CGFloat currentAngle;
@property (strong) UIDynamicAnimator *animator;;

- (id) initWithView:(CGRect)frame
           delegate:(id)delegate
               items:(NSArray*)items;

//Rotates the wheel to an angle (in radians) w.r.t the positive X Axis
- (void)rotateToAngle:(CGFloat)angle animated:(BOOL)animated;

@end
