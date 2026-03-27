#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <mach/mach.h>

// --- メモリ書き換えエンジン ---
void writeMemory(uintptr_t address, int value) {
    vm_address_t addr = (vm_address_t)address;
    mach_msg_type_number_t size = sizeof(value);
    vm_protect(mach_task_self(), addr, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    vm_write(mach_task_self(), addr, (vm_offset_t)&value, size);
}

@interface H5UI : UIViewController <WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@end

static H5UI *mainMenu = nil;

@implementation H5UI

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // --- 魔法の仕掛け：script.phpを書き換えずに済む理由 ---
    // WebView内のJSに「h5gg」という偽の命令セットを注入します
    NSString *h5gg_inject = @"window.h5gg = { \
        setValue: function(addr, val, type) { \
            window.webkit.messageHandlers.h5_bridge.postMessage({a: addr, v: val}); \
        } \
    };";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:h5gg_inject injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addUserScript:script];
    [config.userContentController addScriptMessageHandler:self name:@"h5_bridge"];
    
    // UI作成（MyPlugin 7の構造を再現）
    self.view.frame = CGRectMake(0, 0, 300, 350);
    self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    self.view.layer.cornerRadius = 15;
    self.view.clipsToBounds = YES;
    self.view.layer.borderWidth = 1.5;
    self.view.layer.borderColor = [UIColor cyanColor].CGColor;

    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 40, 300, 310) configuration:config];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    [self.view addSubview:self.webView];

    // 閉じるボタン
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(260, 5, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];

    [self loadRequest];
}

// script.phpからの「h5gg.setValue」命令がここに届く
- (void)userContentController:(WKUserContentController *)u didReceiveScriptMessage:(WKScriptMessage *)m {
    if ([m.name isEqualToString:@"h5_bridge"]) {
        NSDictionary *dict = m.body;
        writeMemory([dict[@"a"] unsignedLongValue], [dict[@"v"] intValue]);
    }
}

- (void)loadRequest {
    NSString *u = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://webudid.gt.tc/main.php?udid=%@", u]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)hideMenu { self.view.hidden = YES; }
@end

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n){
        UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
        mainMenu = [[H5UI alloc] init];
        mainMenu.view.center = win.center;
        [win addSubview:mainMenu.view];

        // 起動用フローティングボタン
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 200, 50, 50);
        btn.backgroundColor = [UIColor cyanColor];
        btn.layer.cornerRadius = 25;
        [btn setTitle:@"M" forState:UIControlStateNormal];
        [btn addTarget:mainMenu action:@selector(loadRequest) forControlEvents:UIControlEventTouchUpInside];
        [[btn addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside] addBlock:^{ mainMenu.view.hidden = NO; }];
        [win addSubview:btn];
    }];
}
