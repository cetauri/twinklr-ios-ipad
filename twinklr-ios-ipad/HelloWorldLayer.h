//
//  HelloWorldLayer.h
//  twinklr-ios-ipad
//
//  Created by cetauri on 12. 11. 8..
//  Copyright __MyCompanyName__ 2012년. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer<CCStandardTouchDelegate, UITableViewDataSource, UITableViewDelegate>
{
    double _initialDistance;
//    NSSet *initPointSet;
//    NSSet *finalPointSet;
//    CGFloat _initialDistance;
//    CGFloat finalDistance;
    int _depth;
    
    int selectedWidth;
//    NSMutableArray *starPosArray;
    NSMutableDictionary *_historyPosDictionary;
    
    BOOL _isStarClicked;
    float _touchDistance;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
- (void)explorer:(CGFloat)distance;
- (void)shiftX:(CGFloat)distance;
@end
