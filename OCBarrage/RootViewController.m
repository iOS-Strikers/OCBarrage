#import "RootViewController.h"
#import "ViewController.h"

@implementation RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    ViewController *demo = [[ViewController alloc] init];
    [self addChildViewController:demo];
    demo.view.frame = self.view.bounds;
    demo.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:demo.view];
    [demo didMoveToParentViewController:self];
}
@end
