#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#define DECODE_CHAR(c) (c ^ 0x5A) // 0x5A(Z)で簡単なXOR暗号化

static NSString *get_secure_url() {
    unsigned char enc[] = {
        46, 38, 38, 42, 110, 107, 107, 55, 39, 34, 43, 36, 34, 34, 110, 39, 38, 110, 34, 37, 107, 45, 33, 41, 46, 110, 40, 38, 45, 44, 110, 107, 45, 39, 33, 41, 110, 42, 46, 45, 33, 34, 110, 107, 107, 0 // 終端文字
    };
    
    NSMutableString *dec = [NSMutableString string];
    for (int i = 0; enc[i] != 0; i++) {
        [dec appendFormat:@"%c", (char)(enc[i] ^ 0x5A)];
    }
    return dec;
}

@interface AuthViewController : UIViewController <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation AuthViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    [self.view addSubview:self.webView];
    
    NSString *targetURL = get_secure_url();
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:targetURL]]];
}

// ...（以前のポップアップ許可コード runJavaScriptTextInputPanelWithPrompt はそのまま維持）...

@end
