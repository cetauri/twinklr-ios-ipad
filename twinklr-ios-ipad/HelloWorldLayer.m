//
//  HelloWorldLayer.m
//  twinklr-ios-ipad
//
//  Created by cetauri on 12. 11. 8..
//  Copyright __MyCompanyName__ 2012년. All rights reserved.
//

enum CCNodeTag {
    CCNodeTag_status = 10,
    CCNodeTag_distance,
    CCNodeTag_count,
    CCNodeTag_background
};

// Import the interfaces
#import "HelloWorldLayer.h"
#import "SpaceLayer.h"
// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    SpaceLayer *backlayer = [SpaceLayer node];
    backlayer.tag = CCNodeTag_background;
    [scene addChild:backlayer];
    
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	
    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	        
        CCLabelTTF *countlabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		countlabel.position =  ccp( size.width /2 , size.height/2 - 100);
		[self addChild:countlabel z:1 tag:CCNodeTag_count];
        
        CCLabelTTF *statuslabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		statuslabel.position =  ccp( size.width /2 - 200, 20);
		[self addChild:statuslabel z:1 tag:CCNodeTag_status];

        CCLabelTTF *scalelabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		scalelabel.position =  ccp( size.width /2 + 200 , 20);
        [self addChild:scalelabel z:1 tag:CCNodeTag_distance];
        
        self.isTouchEnabled = YES;
        [CCDirector sharedDirector].openGLView.multipleTouchEnabled = true;

        
        starPosArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < 5; i++) {
            int xR = (arc4random() % 1024/2)+1024/4;
            int yR = (arc4random() % 798/2)+798/4;

            CCSprite *star = [CCSprite spriteWithFile:@"star_on.png"];
            [star setPosition:CGPointMake(xR, yR)];
            star.tag = (depth + 1) * 100 + i;
            [self addChild:star z:star.tag];
            
            NSValue* point =[NSValue valueWithCGPoint:star.position];
            [starPosArray addObject:point];
        }
        
        depth = 0;

        CCParticleSystem *particleTest = [CCParticleGalaxy node];
        //    particleTest.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
        particleTest.life = 2;
        particleTest.lifeVar = 0.2f;

        particleTest.duration = 2.5;
        particleTest.startSize = 3.0f;

        [self addChild:particleTest z:1000 tag:1000000];
        
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
    [starPosArray release];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
    
    if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint convertedTouch = [self convertTouchToNodeSpace: touch];
		// single touch dragging needs to go here
        
        for (int i = 0; i < 5; i++) {
            CCSprite *star =  (CCSprite *)[self getChildByTag:(/*depth +*/ 1) * 100 + i];
            
            if (CGRectContainsPoint(star.boundingBox, convertedTouch)){
                [self shiftX:-500];
                break;
            }
        }
        
//        [self schedule:@selector(update:)];

	} else if ([touches count] == 2) {
		// Get points of both touches
		NSArray *twoTouch = [touches allObjects];
		UITouch *tOne = [twoTouch objectAtIndex:0];
		UITouch *tTwo = [twoTouch objectAtIndex:1];
		CGPoint firstTouch = [tOne locationInView:[tOne view]];
		CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
        
		// Find the distance between those two points
		initialDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
	}
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
	if ([touches count] == 1) {
		// drag methods
//		UITouch* touch = [touches anyObject];
//		CGPoint convertedTouch = [self convertTouchToNodeSpace: touch];
		// single drag method needs to go here
        
	}else if ([touches count] == 2) {
		NSArray *twoTouch = [touches allObjects];
        
		UITouch *tOne = [twoTouch objectAtIndex:0];
		UITouch *tTwo = [twoTouch objectAtIndex:1];
		CGPoint firstTouch = [tOne locationInView:[tOne view]];
		CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
		CGFloat currentDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
        
		if (initialDistance == 0) {
			initialDistance = currentDistance;
            // set to 0 in case the two touches weren't at the same time
		} else{
            [self explorer:(currentDistance - initialDistance)];
        }
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
//
    CGSize size = [[CCDirector sharedDirector] winSize];
//    if(point.x != size.width/2){
//        float angle = 90;
//        if (size.width/2 < point.x ) angle *= -1;
//
//        //animation
//        CGSize size = [[CCDirector sharedDirector] winSize];
//        CCMoveTo *move = [CCMoveTo actionWithDuration:0.3 position:CGPointMake(size.width/2, point.y)];
//        CCRotateBy *roation = [CCRotateBy actionWithDuration:0.3 angle:angle];
//        [ballSprite runAction:[CCSpawn actions:move, roation, nil]];
//    }
    if(initialDistance != 0 && [touches count] == 2){
        NSArray *twoTouch = [touches allObjects];
        
		UITouch *tOne = [twoTouch objectAtIndex:0];
		UITouch *tTwo = [twoTouch objectAtIndex:1];
		CGPoint firstTouch = [tOne locationInView:[tOne view]];
		CGPoint secondTouch = [tTwo locationInView:[tTwo view]];
		CGFloat currentDistance = sqrt(pow(firstTouch.x - secondTouch.x, 2.0f) + pow(firstTouch.y - secondTouch.y, 2.0f));
        
        CGFloat distance = currentDistance - initialDistance;
        
        if (distance <= 200) {
            for (int i = 0; i < 5; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:(/*depth +*/ 1) * 100 + i];
                
                CGPoint starPoint = [[starPosArray objectAtIndex:i] CGPointValue];
                star.position = starPoint;
                
                CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:starPoint];
                CCRotateBy *roation = [CCRotateBy actionWithDuration:0.2 angle:20];
                CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.2];
                CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
                
                [star runAction:[CCSpawn actions:roation, scale, move, fadeIn, nil]];
            }
        } else if (distance > 200) {
            
            for (int i = 0; i < 5; i++) {
                CCSprite *star =  (CCSprite *)[self getChildByTag:(/*depth +*/ 1) * 100 + i];
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
                
                CCMoveTo *move = [CCMoveTo actionWithDuration:0.2 position:starPoint];
                CCRotateBy *roation = [CCRotateBy actionWithDuration:0.2 angle:20];
                CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:0.2];
                CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
                
                [star runAction:[CCSpawn actions:roation, scale, fadeOut, move, nil]];
            }
        }
    }
    initialDistance = 0;
}

//- (void)update:(ccTime)dt
//{
//    CGSize size = [[CCDirector sharedDirector] winSize];
//
//    if (selectedWidth == 0){
//        self.position=ccp(size.width, size.height);
//    } else {
//        self.position=ccp(selectedWidth, size.height);
//    }
//
//}

- (void)shiftX:(CGFloat)distance{
    distance = -250;
    CCLayer *bgLayer =  (CCLayer *)[self.parent getChildByTag:CCNodeTag_background];
    CGPoint bgLayerPoint = bgLayer.position;
    bgLayerPoint.x = distance;
    
    ccTime time = 0.5;
    CCMoveTo *move = [CCMoveTo actionWithDuration:time position:bgLayerPoint];
    CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:time];
    [bgLayer runAction:[CCSpawn actions:move, scale, nil]];
    
    for(CCNode *node in self.children){
        CGPoint point = node.position;
        point.x += distance;
        
        CCMoveTo *move = [CCMoveTo actionWithDuration:time position:point];
        CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:time];
        [node runAction:[CCSpawn actions:move, scale, nil]];
    }
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 1024-250, 768, 250) style:UITableViewStylePlain];
    tableView.transform = CGAffineTransformMakeRotation(M_PI/2);
    tableView.dataSource = self;
    tableView.delegate = self;
    [[[CCDirector sharedDirector]openGLView]addSubview:tableView];
    tableView.frame = CGRectMake(0, 1024, 768, 250);
    [tableView release];

    [UIView animateWithDuration:distance animations:^(void){
        tableView.frame = CGRectMake(0, 1024-250, 768, 250);
        
        
    }];
}

- (void)explorer:(CGFloat)distance{
    CGSize size = [[CCDirector sharedDirector] winSize];

    CCLabelTTF *distLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_distance];
    CCLabelTTF *statusLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_status];
    CCLabelTTF *countLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_count];
    
//    if (distance > 200) {
//        [statusLabel setString:@"Zoom in"];
//        depth++;
//    } else if (distance < -200) {
//        [statusLabel setString:@"Zoom out"];
//        depth--;
//    }else{

        [statusLabel setString:@" "];
        
        for (int i = 0; i < 5; i++) {
            CCSprite *star =  (CCSprite *)[self getChildByTag:(/*depth +*/ 1) * 100 + i];
            if (star == nil) break;
                      
            CGPoint starPoint = [[starPosArray objectAtIndex:i] CGPointValue];
            
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
        
            star.position = starPoint;
//            star.opacity = 255/(distance/10);

//            CCMoveTo *move = [CCMoveTo actionWithDuration:0.0001 position:starPoint];
            CCRotateBy *roation = [CCRotateBy actionWithDuration:0.1 angle:20];
//            CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:1];
            CCEaseExponentialIn  *scale = [CCEaseExponentialIn actionWithDuration:0.1];
            NSLog(@"star.opacity : %i", star.opacity);
            [star runAction:[CCSpawn actions:roation, scale, nil]];
        }
//    }
    
//#ifdef DEBUG
    [countLabel setString:[NSString stringWithFormat:@"%i depth", depth]];
    [distLabel setString:[NSString stringWithFormat:@"%f", distance]];
//#endif
    
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
