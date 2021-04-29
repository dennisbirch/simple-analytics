//
//  AnalyticsManager.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnalyticsManager : NSObject

+ (void)initializeEndpoint;
+ (void)addCounter:(NSString *) name;
+ (void)addAnalyticsItem:(NSString *) name details:(nullable NSDictionary *) details;

@end

NS_ASSUME_NONNULL_END
