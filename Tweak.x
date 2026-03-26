#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
static NSString *authURL = @"http://webudid.gt.tc/main.html";

@interface AuthViewController : UIViewController <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation AuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authURL]];
    [self.webView loadRequest:request];
}

// 認証成功（script.html に遷移）したら画面を閉じる
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString containsString:@"script.html"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        AuthViewController *authVC = [[AuthViewController alloc] init];
        authVC.modalPresentationStyle = UIModalPresentationFullScreen;
        
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [root presentViewController:authVC animated:YES completion:nil];
    }];
}
