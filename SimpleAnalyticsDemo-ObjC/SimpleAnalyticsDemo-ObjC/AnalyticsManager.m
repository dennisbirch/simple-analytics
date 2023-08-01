//
//  AnalyticsManager.m
//

#import "AnalyticsManager.h"
@import SimpleAnalytics;

@implementation AnalyticsManager

// To test this with your own back-end setup, change the following line to reflect the URL string for your analytics server
NSString *webServiceURLString = @"https://analytics.example.com";

+ (void)initializeEndpoint {
    [AppAnalytics setEndpoint:webServiceURLString deviceID: [AnalyticsManager deviceIdentifier] submissionCompletionCallback: nil];
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

+ (NSString *)deviceIdentifier {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSURL *folderURL = [fileMgr URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask][0];
    NSString *demoFolderName = @"SimpleAnalyticsDemo";
    NSString *fileName = @"Device Identifier";
    NSURL *idSupportFolder = [folderURL URLByAppendingPathComponent: demoFolderName];
    NSError *error = nil;
    // make sure folder exists
    if ([fileMgr fileExistsAtPath:[idSupportFolder path]] == NO) {
        [fileMgr createDirectoryAtURL:idSupportFolder withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            NSLog(@"%@", @"Failed to create the device identifier directory");
            return @"";
        }
    }
    // check to see if file exists
    NSURL *fileURL = [idSupportFolder URLByAppendingPathComponent:fileName];
    if ([fileMgr fileExistsAtPath:[fileURL path]] == NO) {
        NSString *idString = [[NSUUID UUID] UUIDString];
        [idString writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error != nil) {
            NSLog(@"%@", @"Writing device identifier to disk failed.");
            return  @"";;
        }
        
        return idString;
    } else {
        NSString *idString = [NSString stringWithContentsOfURL:fileURL encoding:(NSUTF8StringEncoding) error:&error];
        if (idString == nil) {
            return @"";
        }
        
        return idString;
    }
}

@end
