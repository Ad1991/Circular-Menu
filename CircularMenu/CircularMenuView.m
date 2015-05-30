//
//  CircularMenuView.m
//  CircularMenu
//

#import "CircularMenuView.h"

@interface CircularMenuView()<MenuSelectionProtocol>
@property (strong, nonatomic) RotatingWheel *wheel;
@property (strong, nonatomic) UIView *circularButtonView;
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIImageView *selectedItemImage;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) NSArray *items;
@end

@implementation CircularMenuView
@synthesize wheel;
@synthesize circularButtonView;
@synthesize selectedItemImage;
@synthesize tapGesture;
@synthesize items;

-(instancetype)initWithFrame:(CGRect)frame andBackground:(UIImage*)bgImage {
    self = [super initWithFrame:frame];
    if (self) {
        if (bgImage) {
            self.backgroundColor=[UIColor colorWithPatternImage:bgImage];
        }else {
            self.backgroundColor=[UIColor whiteColor];
        }
        tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTappedOutside:)];
        UIView *tappingView=[[UIView alloc]initWithFrame:self.bounds];
        tappingView.backgroundColor=[UIColor clearColor];
        [tappingView addGestureRecognizer:tapGesture];
        [self addSubview:tappingView];
        self.items=@[@"chat", @"checklist", @"computer", @"education", @"food", @"games", @"key", @"luggage", @"money", @"paper", @"party", @"settings", @"vespa", @"video_camera", @"watch"];
        wheel=[[RotatingWheel alloc]initWithView:CGRectMake(self.frame.size.width-250,self.frame.size.height-250,500,500)
                                        delegate:self
                                            items:items];
        wheel.filterTouchDistance = 0.0f;
        wheel.numberOfSectors = 5;
        wheel.shouldDecelerate = YES;
        [self addSubview:wheel];
        
        
        circularButtonView=[[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width-70, self.frame.size.height-70, 140, 140)];
        circularButtonView.backgroundColor=[UIColor colorWithRed:(3.0/255.0) green:(169.0/255.0) blue:(244.0/255.0) alpha:1];
        circularButtonView.layer.cornerRadius=70.0;
        [self addSubview:circularButtonView];
        
        selectedItemImage=[[UIImageView alloc]initWithFrame:CGRectMake(35, 35, 30, 30)];
        [circularButtonView addSubview:selectedItemImage];
    }
    return self;
}

-(void)didMoveToSuperview {
    selectedItemImage.image=[UIImage imageNamed:self.items[self.selectedIndex]];
}

-(void)setBackgroundImage:(UIImage*)image {
    tapGesture.enabled=YES;
    wheel.userInteractionEnabled=YES;
    self.backgroundColor=[UIColor colorWithPatternImage:image];
}
-(void)viewTappedOutside:(UITapGestureRecognizer*)tap {
    [self removeFromSuperview];
}

-(void)closeViewAfterAnimation {
    [self removeFromSuperview];
}

-(void)dampCircularButton {
    tapGesture.enabled=NO;
    wheel.userInteractionEnabled=NO;
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:circularButtonView attachedToAnchor:circularButtonView.center];
    [attachmentBehavior setFrequency:2.0];
    [attachmentBehavior setDamping:0.4];
    [animator addBehavior:attachmentBehavior];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[circularButtonView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = M_PI_4;
    pushBehavior.magnitude = 4.0;
    [animator addBehavior:pushBehavior];
    
    [pushBehavior setActive:TRUE];
    self.animator=animator;
}

#pragma mark TagFilterProtocol Methods

-(void)circularMenuSelectedAtIndex:(NSUInteger)index {
    [self performSelector:@selector(viewTappedOutside:) withObject:nil afterDelay:1.0];
    selectedItemImage.image=[UIImage imageNamed:self.items[index]];
    [self dampCircularButton];
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(circularMenuSelectedAtIndex:)]) {
        [[self delegate] circularMenuSelectedAtIndex:index];
    }
}

//-(void)filterFeedsForTag:(Tag *)tag {
//    [self performSelector:@selector(viewTappedOutside:) withObject:nil afterDelay:1.0];
//    NSString *imagePath=[[AppConfig tagImagesFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", tag.title]];
//    selectedTagImage.image=[UIImage imageWithContentsOfFile:imagePath];
//    
//    if ([self delegate] && [[self delegate] respondsToSelector:@selector(filterFeedsForTag:)]) {
//        [[self delegate] filterFeedsForTag:tag];
//    }
//}
//
//-(void)filterFeedsForUsersTags {
//    
//    selectedTagImage.image=[UIImage imageNamed:@"iconUsersTags"];
//    [self dampCircularButton];
//    if ([self delegate] && [[self delegate] respondsToSelector:@selector(filterFeedsForUsersTags)]) {
//        [[self delegate] filterFeedsForUsersTags];
//    }
//}
@end
