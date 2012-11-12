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
    CCNodeTag_ball
};

// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
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
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello Universe" fontName:@"Marker Felt" fontSize:64];
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
        
        
        CCLabelTTF *countlabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		countlabel.position =  ccp( size.width /2 , size.height/2 - 100);
		[self addChild:countlabel z:1 tag:CCNodeTag_count];
        
        CCLabelTTF *statuslabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		statuslabel.position =  ccp( size.width /2 - 200, 20);
		[self addChild:statuslabel z:1 tag:CCNodeTag_status];

        CCLabelTTF *scalelabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
		scalelabel.position =  ccp( size.width /2 + 200 , 20);
        [self addChild:scalelabel z:1 tag:CCNodeTag_distance];
        
        CCSprite * bg = [CCSprite spriteWithFile:@"star1.png"];
        [bg setPosition:ccp(0, 0)];
//        [bg setScaleY:1.2];
//        [bg setAnchorPoint:ccp(0,0)];
        [self addChild:bg z:-1];
        
        self.isTouchEnabled = YES;
        [CCDirector sharedDirector].openGLView.multipleTouchEnabled = true;
        
        depth = 0;
                
        CCSprite *ball = [CCSprite spriteWithFile:@"earth3am.jpg"];
        ball.position =  ccp( size.width /2 , size.height/2 + 100);
        ball.scaleX = 0.05;
        ball.scaleY = 0.05;
        ball.tag = CCNodeTag_ball;
        [self addChild:ball z:1];
        
        for (int i = 0; i < 5; i++) {
            int starR = arc4random() % 25;
            int xR = (arc4random() % 1024/2)+1024/4;
            int yR = (arc4random() % 798/2)+798/4;

            CCSprite *star = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i.jpg", starR]];
            [star setPosition:CGPointMake(xR, yR)];
            star.tag = (depth + 1) * 100 + i;
            
            if (xR > size.width/2 && yR > size.height/2) {
                star.anchorPoint = CGPointMake(0, 0);
            } else if (xR > size.width/2 && yR < size.height/2) {
                star.anchorPoint = CGPointMake(1, 0);
            } else if (xR < size.width/2 && yR > size.height/2) {
                star.anchorPoint = CGPointMake(0, 1);
            } else if (xR < size.width/2 && yR < size.height/2) {
                star.anchorPoint = CGPointMake(1, 1);
            }
        
            
            [self addChild:star z:star.tag];
            
            
        }
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
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
    
    CCSprite *ballSprite =  (CCSprite *)[self getChildByTag:CCNodeTag_ball];
    CGPoint point = ballSprite.position;
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    if(point.x != size.width/2){
        float angle = 90;
        if (size.width/2 < point.x ) angle *= -1;
    
        //animation
        CGSize size = [[CCDirector sharedDirector] winSize];
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.3 position:CGPointMake(size.width/2, point.y)];
        CCRotateBy *roation = [CCRotateBy actionWithDuration:0.3 angle:angle];
        [ballSprite runAction:[CCSpawn actions:move, roation, nil]];
    }
    initialDistance = 0;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%@ - %i", NSStringFromSelector(_cmd), [touches count]);
    
    if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint convertedTouch = [self convertTouchToNodeSpace: touch];
		// single touch dragging needs to go here
        
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
		UITouch* touch = [touches anyObject];
		CGPoint convertedTouch = [self convertTouchToNodeSpace: touch];
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
- (void)explorer:(CGFloat)distance{

    CCLabelTTF *distLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_distance];
    CCLabelTTF *statusLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_status];
    CCLabelTTF *countLabel =  (CCLabelTTF *)[self getChildByTag:CCNodeTag_count];
    CCSprite *ballSprite =  (CCSprite *)[self getChildByTag:CCNodeTag_ball];

    CGPoint point = ballSprite.position;
    
    if (distance > 200) {
        [statusLabel setString:@"Zoom in"];
        depth++;
    } else if (distance < -200) {
        [statusLabel setString:@"Zoom out"];
        depth--;
    }else{
        CGSize size = [[CCDirector sharedDirector] winSize];

        point.x = size.width/2 + distance*1.5;
        ballSprite.position = point;
        [statusLabel setString:@" "];
        
        for (int i = 0; i < 5; i++) {
            CCSprite *star =  (CCSprite *)[self getChildByTag:(/*depth +*/ 1) * 100 + i];
            
            NSLog(@"%i : %@", (depth + 1) * 100 + i, star.description);
            if (star == nil) break;
            
            
            CGPoint starPoint = star.position;
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
        }
    }
    
//#ifdef DEBUG
    [countLabel setString:[NSString stringWithFormat:@"%i depth", depth]];
    [distLabel setString:[NSString stringWithFormat:@"%f", distance]];
//#endif
    
}

@end
