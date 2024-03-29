//
//  HelloWorldLayer.m
//  twinklr-ios-ipad
//
//  Created by cetauri on 12. 11. 8..
//  Copyright __MyCompanyName__ 2012년. All rights reserved.
//

#define MOVE_Penalty 20
#define MAX_TRANSITION_DISTANCE 150
#define MIN_TRANSITION_DISTANCE -80
#define Opacity_DISTANCE 300
enum CCNodeTag {
    CCNodeTag_status = 10,
    CCNodeTag_distance,
    CCNodeTag_count,
    CCNodeTag_background,
    CCNodeTag_touchLayer,
    CCNodeTag_tableview,
    CCNodeTag_BACK_STAR = 2000
};

// Import the interfaces
#import "HelloWorldLayer.h"
#import "SpaceLayer.h"
#import "DataManager.h"
#import "FontManager.h"
// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
    SpaceLayer *backlayer = [SpaceLayer node];
    backlayer.tag = CCNodeTag_background;
    [scene addChild:backlayer];
    
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
    [DataManager sharedInstance];
    return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

        _depth = 0;
        [self drawSpaces:_depth];
        
//        CCParticleSystem *particleTest = [CCParticleSun node];
//        particleTest.life = 2;
//        particleTest.lifeVar = 0.2f;
//
//        particleTest.duration = 1.5;
//        particleTest.startSize = 3.0f;
//
//        [self addChild:particleTest z:1000 tag:1000000];

        self.isTouchEnabled = YES;
        [CCDirector sharedDirector].openGLView.multipleTouchEnabled = true;

        CCLabelTTF *countlabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		countlabel.position =  ccp( size.width /2 , size.height/2 - 100);
		[self addChild:countlabel z:1 tag:CCNodeTag_count];
        
        CCLabelTTF *statuslabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		statuslabel.position =  ccp( size.width /2 - 200, 20);
		[self addChild:statuslabel z:1 tag:CCNodeTag_status];
        
        CCLabelTTF *scalelabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		scalelabel.position =  ccp( size.width /2 + 200 , 20);
        [self addChild:scalelabel z:1 tag:CCNodeTag_distance];
        
	}
	return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
    
    if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint convertedTouch = [self convertTouchToNodeSpace: touch];
		// single touch dragging needs to go here
        
        if (_isStarClicked) {
            //별 클릭 해제
            CCNode *touchLayer =  (CCNode *)[self getChildByTag:CCNodeTag_touchLayer];
            if (CGRectContainsPoint(touchLayer.boundingBox, convertedTouch)) {
                [self removeChildByTag:CCNodeTag_touchLayer cleanup:YES];
                [self shiftX:0];
            }
        }else{
            //별 클릭시
            NSArray *starPosArray = [[DataManager sharedInstance] starsInZ:_depth];
            for (int i = 0; i < starPosArray.count; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
                CGRect boundRect = star.boundingBox;
                
                if(CGSizeEqualToSize(CGSizeZero, boundRect.size)){
                    boundRect.size = CGSizeMake(54, 54);
                    boundRect.origin = CGPointMake(boundRect.origin.x - 54/2, boundRect.origin.y - 54/2);
                }

                if (CGRectContainsPoint(boundRect, convertedTouch)){
                    startID = [[starPosArray objectAtIndex:i] objectForKey:@"star_id"];
                    [self shiftX:-250];
                    break;
                }
            }
        }
	} else if ([touches count] == 2) {
		// Get points of both touches
		NSArray *twoTouch = [touches allObjects];
		UITouch *tOne = [twoTouch objectAtIndex:0];
		UITouch *tTwo = [twoTouch objectAtIndex:1];
		CGPoint firstTouch = [tOne locationInView:[tOne view]];
		CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
        
		// Find the distance between those two points
		_initialDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
    
	if ([touches count] == 1) {
		// drag methods
//      UITouch *touch = [touches anyObject];
//		CGPoint convertedTouch = [self convertTouchToNodeSpace: touch];
//		// single touch dragging needs to go here
//        
//        for (int i = 0; i < STAR_COUNT; i++) {
//            CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];      
//            if (CGRectContainsPoint(star.boundingBox, convertedTouch)){
//                NSLog(@"%@", NSStringFromCGPoint(convertedTouch));
//                star.position = convertedTouch;
//                break;
//            }
//        }

	}else if ([touches count] == 2) {
		NSArray *twoTouch = [touches allObjects];
        
		UITouch *tOne = [twoTouch objectAtIndex:0];
		UITouch *tTwo = [twoTouch objectAtIndex:1];
		CGPoint firstTouch = [tOne locationInView:[tOne view]];
		CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
		CGFloat currentDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
        
		if (_initialDistance == 0) {
			_initialDistance = currentDistance;
		} else{
            [self explorer:(currentDistance - _initialDistance)];
        }
	}
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
    CCLabelTTF *distLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_distance];
    CCLabelTTF *statusLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_status];
    CCLabelTTF *countLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_count];

    CGSize size = [[CCDirector sharedDirector] winSize];
    if(_initialDistance != 0){
        CGFloat distance ;
        if ([touches count] == 2) {
            
            NSArray *twoTouch = [touches allObjects];
            
            UITouch *tOne = [twoTouch objectAtIndex:0];
            UITouch *tTwo = [twoTouch objectAtIndex:1];
            CGPoint firstTouch = [tOne locationInView:[tOne view]];
            CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
            CGFloat currentDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
            
            distance = currentDistance - _initialDistance;
        } else if ([touches count] == 1) {
            distance = _lastDistance;
        }

        NSArray *starPosArray = [[DataManager sharedInstance] starsInZ:_depth];
        if (distance <= MIN_TRANSITION_DISTANCE) {
            
            for (int i = 0; i < starPosArray.count; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
                
                NSDictionary *starInfo = [starPosArray objectAtIndex:i];
                CGPoint starPoint = CGPointMake([[starInfo objectForKey:@"star_x"]floatValue], [[starInfo objectForKey:@"star_y"]floatValue]);
                starPoint = [self pointResacle:starPoint];
                star.position = starPoint;
                
                CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:starPoint];
                CCRotateBy *roation = nil;//[CCRotateBy actionWithDuration:0.2 angle:20];
                CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.2];
                CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
//                [star runAction:[CCSpawn actions:roation, scale, fadeIn, move, nil]];

                CCSpawn *spawn = [CCSpawn actions:scale, fadeIn, move, roation, nil];
                
                id callback = [CCCallFuncN actionWithTarget:self selector:@selector(afterOut:)];
                [star runAction:[CCSequence actions:spawn, callback, nil]];

                star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
                [self removeChild:star cleanup:YES];
            }
#ifdef DEBUG           
            [statusLabel setString:@"Zoom out"];
#endif
            _depth--;
            [self drawSpaces:_depth];
            
        } else if (distance >= MAX_TRANSITION_DISTANCE ) {
            
            for (int i = 0; i < starPosArray.count; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
                CGPoint starPoint = star.position;
                float distance = 1280;
                
                starPoint.x = (starPoint.x - size.width/2) * (1+distance/250 ) + size.width/2;
                starPoint.y = (starPoint.y - size.height/2)* (1+distance/250 ) + size.height/2;
                
                ccTime time = 0.5;
                CCMoveTo *move = [CCMoveTo actionWithDuration:time position:starPoint];
                CCRotateBy *roation = [CCRotateBy actionWithDuration:time angle:180];
                CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:time];
                CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:time];
                
                CCSpawn *spawn = [CCSpawn actions:roation, scale, fadeOut, move, nil];
                
                id callback = [CCCallFuncN actionWithTarget:self selector:@selector(afterOut:)];
                [star runAction:[CCSequence actions:spawn, callback, nil]];

                star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
                [self removeChild:star cleanup:YES];
            }
#ifdef DEBUG        
            [statusLabel setString:@"Zoom in"];
#endif

            _depth++;
            [self drawSpaces:_depth];
        } else {
            for (int i = 0; i < starPosArray.count; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
                star.opacity = 255;
                NSDictionary *starInfo = [starPosArray objectAtIndex:i];
                CGPoint starPoint = CGPointMake([[starInfo objectForKey:@"star_x"]floatValue], [[starInfo objectForKey:@"star_y"]floatValue]);
                starPoint = [self pointResacle:starPoint];
                
                CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:starPoint];
                [star runAction:move];
            }
            
            starPosArray = [[DataManager sharedInstance] starsInZ:_depth+1];
            for (int i = 0; i < starPosArray.count; i++) {
                NSDictionary *starInfo = [starPosArray objectAtIndex:i];
                CGPoint starPoint = CGPointMake([[starInfo objectForKey:@"star_x"]floatValue], [[starInfo objectForKey:@"star_y"]floatValue]);
                starPoint = [self pointResacle:starPoint];
                
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth+1 * 100 + i];
                star.opacity = 255;
                starPoint = CGPointMake(starPoint.x/2 + 1024/4, starPoint.y/2 + 768/4);
                
                CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:starPoint];
                [star runAction:move];
            }
            
#ifdef DEBUG
            [statusLabel setString:@" "];
#endif
        }
   
#ifdef DEBUG
        [countLabel setString:[NSString stringWithFormat:@"%i _depth", _depth]];
        [distLabel setString:[NSString stringWithFormat:@"%f", distance]];
#endif
        
    }
    _initialDistance = _lastDistance = 0;
    
}

- (void)afterOut:(CCNode*)node{
//    NSLog(@"%@ : %i", NSStringFromSelector(_cmd), node.tag);
    [self removeChild:node cleanup:YES];
    
//    CCSprite *sprite =  (CCSprite *)[self.parent getChildByTag:node.tag +CCNodeTag_BACK_STAR];
//    if (sprite != nil)
//    [self removeChild:node cleanup:YES];

}

- (void)shiftX:(CGFloat)distance{
    
    CCLayer *bgLayer =  (CCLayer *)[self.parent getChildByTag:CCNodeTag_background];
    CGPoint bgLayerPoint = bgLayer.position;
    bgLayerPoint.x = distance;
    
    ccTime time = 0.5;
    CCMoveTo *move = [CCMoveTo actionWithDuration:time position:bgLayerPoint];
    CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:time];
    [bgLayer runAction:[CCSpawn actions:move, scale, nil]];
    
    if(distance == 0){
        
        UIView *view = [[[CCDirector sharedDirector]openGLView]viewWithTag:CCNodeTag_tableview];
        [view removeFromSuperview];

        for(CCNode *node in self.children){
            CGPoint point = node.position;
            point.x -= _touchDistance;
            
            CCMoveTo *move = [CCMoveTo actionWithDuration:time position:point];
            CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:time];
            [node runAction:[CCSpawn actions:move, scale, nil]];
        }
        _touchDistance = 0;
    } else {
        
        CCLayerColor *touchLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 150)];
        touchLayer.position = CGPointMake(0, 0);
        touchLayer.isTouchEnabled = YES;
        touchLayer.tag = CCNodeTag_touchLayer;
        [self addChild:touchLayer z:9999];
        
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 1024-250, 768, 250) style:UITableViewStylePlain];
        tableView.transform = CGAffineTransformMakeRotation(M_PI/2);
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tag = CCNodeTag_tableview;
        [[[CCDirector sharedDirector]openGLView]addSubview:tableView];
        tableView.frame = CGRectMake(0, 1024, 768, 250);
        [tableView release];
        
        [UIView animateWithDuration:distance animations:^(void){
            tableView.frame = CGRectMake(0, 1024-250, 768, 250);
        }];
        
        for(CCNode *node in self.children){
            CGPoint point = node.position;
            point.x += distance;
            
            CCMoveTo *move = [CCMoveTo actionWithDuration:time position:point];
            CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:time];
            [node runAction:[CCSpawn actions:move, scale, nil]];
        }
        
        _touchDistance = distance;
    }
    
    _isStarClicked = !_isStarClicked;
}

- (void)explorer:(CGFloat)distance {
    CGSize size = [[CCDirector sharedDirector] winSize];
    _lastDistance = distance;
    
    CCLabelTTF *distLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_distance];
    [distLabel setString:[NSString stringWithFormat:@"%f", distance]];
    
    NSArray *starPosArray = [[DataManager sharedInstance] starsInZ:_depth];
    for (int i = 0; i < starPosArray.count; i++) {
        CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
        if (star == nil) break;

        NSDictionary *starInfo = [starPosArray objectAtIndex:i];
        CGPoint starPoint = CGPointMake([[starInfo objectForKey:@"star_x"]floatValue], [[starInfo objectForKey:@"star_y"]floatValue]);
        starPoint = [self pointResacle:starPoint];
        
        starPoint.x = (starPoint.x - size.width/2) * (1+distance/250 ) + size.width/2;
        starPoint.y = (starPoint.y - size.height/2)* (1+distance/250 ) + size.height/2;
       
        star.position = starPoint;
        
        int radius = ccpDistance(star.position, CGPointMake(size.width/2, size.height/2));
        if (radius < 0) radius *= -1;
        if (radius > Opacity_DISTANCE) {
            //TODO 튜닝하자!!!
            star.opacity = 255/(radius/100);
        } else {
            star.opacity = 255;
        }
//        CCMoveTo *move = [CCMoveTo actionWithDuration:0.0001 position:starPoint];
        CCRotateBy *roation = [CCRotateBy actionWithDuration:1 angle:distance/4];
        
        if ([[starInfo objectForKey:@"is_tag"]isEqualToString:@"Y"]) {
            roation = nil;
        }
        
//        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:1];
        CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
//        NSLog(@"star.opacity : %i", star.opacity);
        [star runAction:[CCSpawn actions:scale, roation, nil]];
    }
    
    //NEXT
    int level = _depth + 1;
    starPosArray = [[DataManager sharedInstance] starsInZ:level];
    for (int i = 0; i < starPosArray.count; i++) {
        CCSprite *star =  (CCSprite *)[self getChildByTag:level * 100 + i + CCNodeTag_BACK_STAR];
        if (star == nil) break;
        
        NSDictionary *starInfo = [starPosArray objectAtIndex:i];
        CGPoint starPoint = CGPointMake([[starInfo objectForKey:@"star_x"]floatValue], [[starInfo objectForKey:@"star_y"]floatValue]);
        starPoint = [self pointResacle:starPoint];
        starPoint = CGPointMake(starPoint.x/2 + 1024/4, starPoint.y/2 + 768/4);
        
        starPoint.x = (starPoint.x - size.width/2) * (1+distance/250 ) + size.width/2;
        starPoint.y = (starPoint.y - size.height/2)* (1+distance/250 ) + size.height/2;
        
        //TODO 튜닝하자!!!
//        star.scale = distance/1000;
        star.position = starPoint;
        
        int radius = ccpDistance(star.position, CGPointMake(size.width/2, size.height/2));
        if (radius < 0) radius *= -1;
        if (radius > Opacity_DISTANCE) {
            //TODO 튜닝하자!!!
            star.opacity = 255/(radius/100);
        } else {
            star.opacity = 255;
        }
        
//        CCMoveTo *move = [CCMoveTo actionWithDuration:0.0001 position:starPoint];
        CCRotateBy *roation = [CCRotateBy actionWithDuration:0.1 angle:20];
//        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:1];
        CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
//        NSLog(@"star.opacity : %i", star.opacity);
        [star runAction:[CCSpawn actions:roation, scale, nil]];
    }
}

- (void)drawSpaces:(CGFloat)depth {

//    NSMutableArray *starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth]];
    NSArray *starPosArray = [[DataManager sharedInstance] starsInZ:_depth];

    for (int i = 0; i < starPosArray.count; i++) {
        NSDictionary *dic = [starPosArray objectAtIndex:i];
        
        CGPoint starPoint = CGPointMake([[dic objectForKey:@"star_x"]floatValue], [[dic objectForKey:@"star_y"]floatValue]);
        
        starPoint = [self pointResacle:starPoint];
        
        CCSprite *star = nil;
        if ([[dic objectForKey:@"is_tag"]isEqualToString:@"Y"]) {
            star = [CCSprite spriteWithFile:[dic objectForKey:@"image_name"]];

            NSString *fontName = @"BlairMdITC TT-Medium";
            BOOL isFont = [[FontManager sharedManager]loadFont:fontName];
            if (!isFont) {
                fontName = @"Marker Felt";
            }
            
            UILabel *slabel = [[UILabel alloc]initWithFrame:CGRectZero];
            slabel.text = [dic objectForKey:@"tag_name"];
            slabel.font = [UIFont fontWithName:fontName size:30];
            [slabel sizeToFit];
            NSLog(@"slabel.frame.size : %@", NSStringFromCGSize(slabel.frame.size));
            
            CCLabelTTF *label = [CCLabelTTF labelWithString:[dic objectForKey:@"tag_name"]
                                                 dimensions:slabel.frame.size
                                                  alignment:CCTextAlignmentCenter
                                                   fontName:fontName fontSize:30];
            label.anchorPoint = CGPointMake(0, 1);
            label.position = CGPointMake(star.position.x, star.position.y);
            [star addChild:label];
            
            star.scale = 0.7;
        }else{
            
            [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"star_ani.plist"];
            NSMutableArray *frames = [NSMutableArray array];
            for (int i = 1; i < 9; i++) {
                NSString *frameName = [NSString stringWithFormat:@"star_0%i.png",i];
                CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
                [frames addObject:frame];
            }
            
            star = [CCSprite spriteWithSpriteFrame:[frames objectAtIndex:0]];
            
            CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:0.1f];
            CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
            animate = [CCRepeatForever actionWithAction:animate];
            [star runAction:animate];
            
            CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.5];
            [star runAction:fadeIn];
            
            star.scale = 0.5;
        }
        
        star.position = starPoint;
        star.tag = _depth * 100 + i;
        [self addChild:star z:star.tag];

//        [self schedule:@selector(update:)interval:];
    }
    
//    starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth + 1]];
    starPosArray = [[DataManager sharedInstance] starsInZ:_depth+1];

    for (int i = 0; i < starPosArray.count; i++) {
        NSDictionary *starInfo = [starPosArray objectAtIndex:i];
        CGPoint starPoint = CGPointMake([[starInfo objectForKey:@"star_x"]floatValue], [[starInfo objectForKey:@"star_y"]floatValue]);
        starPoint = [self pointResacle:starPoint];
        
        CCSprite *star = nil;
        if ([[starInfo objectForKey:@"is_tag"]isEqualToString:@"Y"]) {            
            star = [CCSprite spriteWithFile:[starInfo objectForKey:@"image_name"]];
            star.scale = 0.3;
        } else {
            star = [CCSprite spriteWithFile:@"star.png"];
            star.scale = 0.5;
        }

        star.tag = (_depth + 1) * 100 + i + CCNodeTag_BACK_STAR;
        star.position = CGPointMake(starPoint.x/2 + 1024/4, starPoint.y/2 + 768/4);
        [self addChild:star z:star.tag];
    }
}

- (CGPoint)pointResacle:(CGPoint)point{
    CGSize size = [[CCDirector sharedDirector] winSize];
    return CGPointMake(point.x * size.width/320, point.y * size.height/200);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([startID isEqualToString:@"0"]) {
        return 1938;
    }
    return 1835;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aaa"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([startID isEqualToString:@"0"]) {
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tagline.png"]];
    }else{
        NSLog(@"startID : %@", [NSString stringWithFormat:@"t%@.png", startID]);
        cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"t%@.png", startID]]];
    }

    return cell;
}

@end
