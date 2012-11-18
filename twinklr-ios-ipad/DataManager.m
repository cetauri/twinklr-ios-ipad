//
//  DataManager.m
//  twinklr-ios-ipad
//
//  Created by cetauri on 12. 11. 18..
//
//

#import "DataManager.h"
#import "JSONKit.h"
@implementation DataManager
+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(id) init
{
	if( (self=[super init])) {
        NSError *error = nil;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"twinklr" ofType:@"json"];
        NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

        zDictionary = [text objectFromJSONString];
    }
    return self;
}

-(NSArray *)starsInZ:(int)z{
    return (NSArray *)[zDictionary objectForKey:[NSString stringWithFormat:@"%i", z]];
}

- (void) dealloc
{
	[super dealloc];
    [zDictionary release];
}
@end
