//
//  ViewController.m
//  CircularMenu
//

#import "ViewController.h"
#import "CircularMenuView.h"

@interface ViewController ()<MenuSelectionProtocol>

@end

@implementation ViewController{
    NSUInteger selectedMenuIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showCircularMenu:(UIButton *)sender {
    CircularMenuView *menu=[[CircularMenuView alloc]initWithFrame:self.view.bounds andBackground:[UIImage imageNamed:@"bgImage"]];
    menu.selectedIndex=selectedMenuIndex;
    menu.delegate=self;
    [self.view addSubview:menu];
}

#pragma mark MenuSelectionProtocol Method
-(void)circularMenuSelectedAtIndex:(NSUInteger)index {
    selectedMenuIndex=index;
}
@end
