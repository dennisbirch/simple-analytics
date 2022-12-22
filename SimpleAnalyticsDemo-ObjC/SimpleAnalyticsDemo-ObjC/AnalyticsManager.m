//
//  AnalyticsManager.m
//

#import "AnalyticsManager.h"
@import SimpleAnalytics;

@implementation AnalyticsManager

+ (void)initializeEndpoint {
    [AppAnalytics setEndpoint:@"URL FOR YOUR WEB SERVICE" submissionCompletionCallback: nil];
}

+ (void)addCounter:(NSString *) name {
    [AppAnalytics countItem:name];
    NSInteger count = AppAnalytics.itemCount;
    NSLog(@"Current analytics item count: %ld", count);
}

+ (void)addAnalyticsItem:(NSString *) name details:(nullable NSDictionary *) details {
    [AppAnalytics addItem:name params:details];
    NSInteger count = AppAnalytics.itemCount;
    NSLog(@"Current analytics item count: %ld", count);
}


@end
