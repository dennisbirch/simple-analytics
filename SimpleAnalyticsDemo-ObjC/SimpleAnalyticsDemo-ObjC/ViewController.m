//
//  ViewController.m
//

#import "ViewController.h"
#import "AnalyticsManager.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [AnalyticsManager initializeEndpoint];
    [AnalyticsManager addAnalyticsItem:@"Displayed main view" details:nil];
}

- (IBAction)handleSoundButton:(NSButton *)sender {
    [self playSound:sender.title];
}

- (IBAction)repeatLast:(NSButton *)sender {
    [AnalyticsManager addCounter:@"Count Something"];
}

- (IBAction)repeatLastOther:(NSButton *)sender {
    [AnalyticsManager addCounter:@"Count Something Else"];
}

- (void)playSound:(NSString *)title {
    NSLog(@"Played sound: %@", title);
    NSString * randString = [self randomString];
    NSDictionary *demoDetail = @{@"Demo detail":randString};
    [AnalyticsManager addAnalyticsItem:title details:demoDetail];
}

- (NSString *)randomString {
    NSArray* words = [@"The quick brown fox jumped over the cow" componentsSeparatedByString:@" "];
    NSUInteger count = words.count;
    int index = arc4random_uniform((UInt32)count);
    return  words[index];
}
@end
