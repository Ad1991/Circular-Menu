//
//  CircularMenuView.h
//  CircularMenu
//

#import <UIKit/UIKit.h>
#import "RotatingWheel.h"

@interface CircularMenuView : UIView
-(instancetype)initWithFrame:(CGRect)frame andBackground:(UIImage*)bgImage NS_DESIGNATED_INITIALIZER;
-(void)setBackgroundImage:(UIImage*)image;

@property (assign, nonatomic) NSUInteger selectedIndex;
@property (weak, nonatomic) id<MenuSelectionProtocol> delegate;
@end
