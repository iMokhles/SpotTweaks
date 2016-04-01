#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <iMoMacros.h>
#include <substrate.h>
#import "TLLibrary.h"
#import "XMLReader.h"

static BOOL isTweakInstalled(NSString *tweakID) {
    return [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/lib/dpkg/info/%@.list", tweakID]];
}
@interface NSString (private)
-(id)objectForKeyedSubscript:(id)arg1;
@end

@implementation NSString (private)
-(id)objectForKeyedSubscript:(id)arg1 {
    return nil;
}
@end
@interface TLTweaksDatastore : NSObject <TLSearchDatastore> {
    BOOL $usingInternet;
}
@end

@implementation TLTweaksDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
    NSString *searchString = [query searchString];
    NSString *format = [NSString stringWithFormat:@"http://planet-iphones.com/cydia/feed/nameanddescription/%@", searchString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:2];
    
    TLRequireInternet(YES);
    $usingInternet = YES;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (data != nil) {
            NSMutableArray *searchResults = [NSMutableArray array];
            
            NSError *parseError = nil;
            NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:data error:&parseError];
            NSDictionary *mainRSSChannel = xmlDictionary[@"rss"][@"channel"];
            id itemsObjects = mainRSSChannel[@"item"];

            if ([itemsObjects isKindOfClass:[NSArray class]]) {
                // int searchLimit = 0;
                for (NSDictionary *package in (NSArray *)itemsObjects) {

                    NSDictionary *titleDict = package[@"title"];
                    NSString *titleString = [NSString stringWithFormat:@"%@",titleDict[@"text"]];
                    
                    NSDictionary *descDict = package[@"description"];
                    NSString *descString = [NSString stringWithFormat:@"%@",descDict[@"text"]];
                    
                    NSDictionary *linkDict = package[@"link"];
                    NSString *linkString = [NSString stringWithFormat:@"%@",linkDict[@"text"]];
                    
                    NSString *packageID = [linkString lastPathComponent];
                    
                     SPSearchResult *result = [[SPSearchResult alloc] init];
                    
                    if (isTweakInstalled(packageID)) {
                        [result setSummary:@"Installed"];
                    }
                    
                    [result setTitle:titleString];
                    [result setSubtitle:descString];
                    [result setUrl:linkString];
                    [searchResults addObject:result];
                    // searchLimit++;
                }
            } else if ([itemsObjects isKindOfClass:[NSDictionary class]]) {
                NSDictionary *newDict = (NSDictionary *)itemsObjects;
                NSDictionary *titleDict = newDict[@"title"];
                NSString *titleString = [NSString stringWithFormat:@"%@",titleDict[@"text"]];
                    
                NSDictionary *descDict = newDict[@"description"];
                NSString *descString = [NSString stringWithFormat:@"%@",descDict[@"text"]];
                    
                NSDictionary *linkDict = newDict[@"link"];
                NSString *linkString = [NSString stringWithFormat:@"%@",linkDict[@"text"]];
                    
                NSString *packageID = [linkString lastPathComponent];
                    
                SPSearchResult *result = [[SPSearchResult alloc] init];
                    
                if (isTweakInstalled(packageID)) {
                    [result setSummary:@"Installed"];
                }
                    
                [result setTitle:titleString];
                [result setSubtitle:descString];
                [result setUrl:linkString];
                [searchResults addObject:result];

            }
            TLCommitResults(searchResults, TLDomain(@"com.saurik.Cydia", @"SpotTweaks"), results);
        }
        TLRequireInternet(NO);
        $usingInternet = NO;
        [results storeCompletedSearch:self];
        
        TLFinishQuery(results);
        
    }];
}

- (NSArray *)searchDomains {
    return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.saurik.Cydia", @"SpotTweaks")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
    return @"com.saurik.Cydia";
}

- (BOOL)blockDatastoreComplete {
    return $usingInternet;
}
@end
