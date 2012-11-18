//
//  DataManager.h
//  twinklr-ios-ipad
//
//  Created by cetauri on 12. 11. 18..
//
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject{
    NSMutableDictionary *zDictionary;
}
+ (id)sharedInstance;
-(NSArray *)starsInZ:(int)z;

@end
