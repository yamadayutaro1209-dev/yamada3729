#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface _0xM : UIViewController <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *_0xW;
@end
static UIButton *_0xB = nil; 
static _0xM *_0xV = nil;
@implementation _0xM
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor]; 
    WKWebViewConfiguration *c = [[WKWebViewConfiguration alloc] init];
    [c.userContentController addScriptMessageHandler:self name:@"closeHandler"];
    self._0xW = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:c];
    self._0xW.backgroundColor = [UIColor clearColor];
    self._0xW.opaque = NO;
    self._0xW.navigationDelegate = self;
    [self.view addSubview:self._0xW];
    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *l = [NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u];
    [self._0xW loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:l]]];
}
- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:@"closeHandler"]) {
        self.view.hidden = YES; 
        _0xB.hidden = NO; 
    }
}
@end

@interface _0xH : NSObject
@end
@implementation _0xH
+ (void)_0xToggle {
    _0xV.view.hidden = !_0xV.view.hidden;
    _0xB.hidden = !_0xV.view.hidden;
}
+ (void)_0xDrag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
@end
%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            UIWindow *w = [UIApplication sharedApplication].windows.firstObject;
            _0xV = [[_0xM alloc] init];
            _0xV.view.frame = w.bounds; 
　　　　　　　[w addSubview:_0xV.view];
            _0xB = [UIButton buttonWithType:UIButtonTypeCustom];
            _0xB.frame = CGRectMake(20, 150, 50, 50);
            _0xB.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.5];
            _0xB.layer.cornerRadius = 25;
            _0xB.layer.borderWidth = 2;
            _0xB.layer.borderColor = [UIColor whiteColor].CGColor;
            [_0xB setTitle:@"MOD" forState:UIControlStateNormal];
            _0xB.titleLabel.font = [UIFont boldSystemFontOfSize:12];        
            [_0xB addTarget:[_0xH class] action:@selector(_0xToggle) forControlEvents:UIControlEventTouchUpInside];
            [_0xB addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:[_0xH class] action:@selector(_0xDrag:)]];

            [w addSubview:_0xB];
        });
    }];
}
