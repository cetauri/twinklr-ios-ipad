//
//  HelloWorldLayer.m
//  twinklr-ios-ipad
//
//  Created by cetauri on 12. 11. 8..
//  Copyright __MyCompanyName__ 2012년. All rights reserved.
//
#define MAX_DEPTH 10
#define STAR_COUNT 7
#define MOVE_Penalty 2
#define TRANSITION_DISTANCE 200
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
	       
        _depth = 1;
        _historyPosDictionary = [[NSMutableDictionary alloc] init];
        _isPosDictionary = [[NSMutableDictionary alloc] init];
        
        for (int d = _depth; d < _depth + MAX_DEPTH; d++) {
            NSMutableArray *starPosArray = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < STAR_COUNT; i++) {
                int xR = (arc4random() % 1024/2)+1024/4;
                int yR = (arc4random() % 798/2)+798/4;
                
                NSValue* point =[NSValue valueWithCGPoint:CGPointMake(xR, yR)];
                [starPosArray addObject:point];
            }
            
            [_historyPosDictionary setObject:starPosArray forKey:[NSString stringWithFormat:@"%i", d]];
            [starPosArray release];
        }

        [self drawSpaces:_depth];
        

//        CCParticleSystem *particleTest = [CCParticleGalaxy node];
//        //    particleTest.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
//        particleTest.life = 2;
//        particleTest.lifeVar = 0.2f;
//
//        particleTest.duration = 2.5;
//        particleTest.startSize = 3.0f;
//
//        [self addChild:particleTest z:1000 tag:1000000];
//        
//        CCParticleSystem *emitter = [CCParticleGalaxy node];
////[[[CCParticleExplosion alloc] initWithTotalParticles:150] autorelease];
//        //입자 수명
//        emitter.life = 1.0f;
//        emitter.lifeVar = 0.2f;
//        //입자 속도
//        emitter.speedVar = 5.0f;
//        //입자의 픽셀 단위 크기
//        emitter.startSize = 30.0f;
//        //emitter.duration = 3.0f;
//        [self addChild:emitter z:1000 tag:1000000];
        
//        CCParticleSystem *particleTest2 = [CCParticleFire node];
//        particleTest2.life = 2;
//        particleTest2.duration = 2.5;
//
//        [self addChild:particleTest2 z:1001 tag:1000001];
        
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

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    [_isPosDictionary release];
    [_historyPosDictionary release];
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
            for (int i = 0; i < STAR_COUNT; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
                if (CGRectContainsPoint(star.boundingBox, convertedTouch)){
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

    CGSize size = [[CCDirector sharedDirector] winSize];
    if(_initialDistance != 0 && [touches count] == 2){
        NSArray *twoTouch = [touches allObjects];
        
		UITouch *tOne = [twoTouch objectAtIndex:0];
		UITouch *tTwo = [twoTouch objectAtIndex:1];
		CGPoint firstTouch = [tOne locationInView:[tOne view]];
		CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
		CGFloat currentDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
        
        CGFloat distance = currentDistance - _initialDistance;
        
        if (distance <= TRANSITION_DISTANCE) {
            
            for (int i = 0; i < STAR_COUNT; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
                
                NSMutableArray *starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth]];
                CGPoint starPoint = [[starPosArray objectAtIndex:i] CGPointValue];
                star.position = starPoint;
                
                CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:starPoint];
                CCRotateBy *roation = [CCRotateBy actionWithDuration:0.2 angle:20];
                CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.2];
                CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
//                [star runAction:[CCSpawn actions:roation, scale, fadeIn, move, nil]];

                CCSpawn *spawn = [CCSpawn actions:roation, scale, fadeIn, move, nil];
                
                id callback = [CCCallFuncN actionWithTarget:self selector:@selector(afterOut:)];
                [star runAction:[CCSequence actions:spawn, callback, nil]];

                star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
                [self removeChild:star cleanup:YES];
            }
            
        } else if (distance > TRANSITION_DISTANCE) {
            
            for (int i = 0; i < STAR_COUNT; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
                CGPoint starPoint = star.position;
                float distance = 1000;
                if (starPoint.x > size.width/2 && starPoint.y > size.height/2) {
                    starPoint.x += distance/10;
                    starPoint.y += distance/10;
                } else if (starPoint.x > size.width/2 && starPoint.y < size.height/2) {
                    starPoint.x += distance/10;
                    starPoint.y -= distance/10;
                } else if (starPoint.x < size.width/2 && starPoint.y > size.height/2) {
                    starPoint.x -= distance/10;
                    starPoint.y += distance/10;
                } else if (starPoint.x < size.width/2 && starPoint.y < size.height/2) {
                    starPoint.x -= distance/10;
                    starPoint.y -= distance/10;
                }
                
                ccTime time = 0.5;
                CCMoveTo *move = [CCMoveTo actionWithDuration:time position:starPoint];
                CCRotateBy *roation = [CCRotateBy actionWithDuration:time angle:20];
                CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:time];
                CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
                
                CCSpawn *spawn = [CCSpawn actions:roation, scale, fadeOut, move, nil];
                
                id callback = [CCCallFuncN actionWithTarget:self selector:@selector(afterOut:)];
                [star runAction:[CCSequence actions:spawn, callback, nil]];

                star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
                [self removeChild:star cleanup:YES];
            }
        }
        
        CCLabelTTF *distLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_distance];
        CCLabelTTF *statusLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_status];
        CCLabelTTF *countLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_count];

        if (distance > TRANSITION_DISTANCE) {
            if (_depth <= MAX_DEPTH) {
                [statusLabel setString:@"Zoom in"];
                _depth++;
                [self drawSpaces:_depth];
            }
        } else if (distance <= -TRANSITION_DISTANCE) {
            if (_depth > 1) {
                [statusLabel setString:@"Zoom out"];
                _depth--;
                [self drawSpaces:_depth];
            }
        }else{
            [statusLabel setString:@" "];
        }
        
//#ifdef DEBUG
        [countLabel setString:[NSString stringWithFormat:@"%i _depth", _depth]];
        [distLabel setString:[NSString stringWithFormat:@"%f", distance]];
//#endif
        
    }
    _initialDistance = 0;
    
}

- (void)afterOut:(CCNode*)node{
    NSLog(@"%@ : %i", NSStringFromSelector(_cmd), node.tag);
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

    for (int i = 0; i < STAR_COUNT; i++) {
        CCSprite *star =  (CCSprite *)[self getChildByTag:_depth * 100 + i];
        if (star == nil) break;
        
        NSMutableArray *starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth]];
        CGPoint starPoint = [[starPosArray objectAtIndex:i] CGPointValue];
        if (starPoint.x > size.width/2 && starPoint.y > size.height/2) {
            starPoint.x += distance / MOVE_Penalty;
            starPoint.y += distance / MOVE_Penalty;
        } else if (starPoint.x > size.width/2 && starPoint.y < size.height/2) {
            starPoint.x += distance / MOVE_Penalty;
            starPoint.y -= distance / MOVE_Penalty;
        } else if (starPoint.x < size.width/2 && starPoint.y > size.height/2) {
            starPoint.x -= distance / MOVE_Penalty;
            starPoint.y += distance / MOVE_Penalty;
        } else if (starPoint.x < size.width/2 && starPoint.y < size.height/2) {
            starPoint.x -= distance / MOVE_Penalty;
            starPoint.y -= distance / MOVE_Penalty;
        }
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
    
    //NEXT
    int level = _depth + 1;
    for (int i = 0; i < STAR_COUNT; i++) {
        CCSprite *star =  (CCSprite *)[self getChildByTag:level * 100 + i + CCNodeTag_BACK_STAR];
        if (star == nil) break;
        
        int scaleSize = 8;
        NSMutableArray *starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", level]];
        CGPoint starPoint = [[starPosArray objectAtIndex:i] CGPointValue];
        starPoint = CGPointMake(starPoint.x/2 + 1024/4, starPoint.y/2 + 768/4);

        if (starPoint.x > size.width/2 && starPoint.y > size.height/2) {
            starPoint.x += distance / MOVE_Penalty /scaleSize;
            starPoint.y += distance / MOVE_Penalty /scaleSize;
        } else if (starPoint.x > size.width/2 && starPoint.y < size.height/2) {
            starPoint.x += distance / MOVE_Penalty /scaleSize;
            starPoint.y -= distance / MOVE_Penalty /scaleSize;
        } else if (starPoint.x < size.width/2 && starPoint.y > size.height/2) {
            starPoint.x -= distance / MOVE_Penalty /scaleSize;
            starPoint.y += distance / MOVE_Penalty /scaleSize;
        } else if (starPoint.x < size.width/2 && starPoint.y < size.height/2) {
            starPoint.x -= distance / MOVE_Penalty /scaleSize;
            starPoint.y -= distance / MOVE_Penalty /scaleSize;
        }
        
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

    NSMutableArray *starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth]];
    for (int i = 0; i < starPosArray.count; i++) {
        CGPoint starPoint = [[starPosArray objectAtIndex:i] CGPointValue];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"star_ani.plist"];
        NSMutableArray *frames = [NSMutableArray array];
        for (int i = 1; i < 9; i++) {
            NSString *frameName = [NSString stringWithFormat:@"star_0%i.png",i];
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
            [frames addObject:frame];
        }
        
        CCSprite *star = [CCSprite spriteWithSpriteFrame:[frames objectAtIndex:0]];
        [star setPosition:starPoint];
        star.tag = _depth * 100 + i;
        star.scale = 0.5;
        [self addChild:star z:star.tag];

        CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:0.1f];
        CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
        animate = [CCRepeatForever actionWithAction:animate];
        [star runAction:animate];
        
//        [self schedule:@selector(update:)interval:];
    }
    
    starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth + 1]];
    for (int i = 0; i < starPosArray.count; i++) {
        CGPoint starPoint = [[starPosArray objectAtIndex:i] CGPointValue];
        
//        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"star_ani.plist"];
//        NSMutableArray *frames = [NSMutableArray array];
//        for (int i = 1; i < 9; i++) {
//            NSString *frameName = [NSString stringWithFormat:@"star_0%i.png",i];
//            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
//            [frames addObject:frame];
//        }
//        
        CCSprite *star = [CCSprite spriteWithFile:@"star.png"];
        [star setPosition:starPoint];
        star.tag = (_depth + 1) * 100 + i + CCNodeTag_BACK_STAR;
        star.scale = 0.5;
        star.position = CGPointMake(star.position.x/2 + 1024/4, star.position.y/2 + 768/4);
        [self addChild:star z:star.tag];
        
//        CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:0.1f];
//        CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
//        animate = [CCRepeatForever actionWithAction:animate];
//        [star runAction:animate];
//        
//        [self schedule:@selector(update:)interval:￼];
    }
    
    
//    starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth - 1]];
//    for (int i = 0; i < starPosArray.count; i++) {
//        CCSprite *star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
//        if(star == nil)
//            [self addChild:star z:star.tag];
//    }
//    starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth - 1 + CCNodeTag_BACK_STAR]];
//    for (int i = 0; i < starPosArray.count; i++) {
//        CCSprite *star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
//        if(star == nil)
//            [self addChild:star z:star.tag];
//    }
    
    
//    
//    starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth + 1]];
//    for (int i = 0; i < starPosArray.count; i++) {
//        CCSprite *star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
//        if(star == nil)
//            [self addChild:star z:star.tag];
//    }
//    starPosArray = [_historyPosDictionary objectForKey:[NSString stringWithFormat:@"%i", _depth + 1 + CCNodeTag_BACK_STAR]];
//    for (int i = 0; i < starPosArray.count; i++) {
//        CCSprite *star =  (CCSprite *)[self getChildByTag:(_depth+1) * 100 + i + CCNodeTag_BACK_STAR];
//        if(star == nil)
//            [self addChild:star z:star.tag];
//    }
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 769;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aaa"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tagline.png"]];
    cell.backgroundColor = [UIColor grayColor];
    return cell;
}

@end
