//
//  SpaceLayer.m
//  twinklr-ios-ipad
//
//  Created by cetauri on 12. 11. 16..
//  Copyright 2012년 __MyCompanyName__. All rights reserved.
//

#import "SpaceLayer.h"


@implementation SpaceLayer
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SpaceLayer *layer = [SpaceLayer node];
	
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
        CCNode *backgroundNode = [CCSprite spriteWithFile:@"universe_bg.jpg"];
        backgroundNode.position =  ccp( size.width /2 , size.height/2);
        [self addChild:backgroundNode];
//        CCLabelTTF *countlabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
//		countlabel.position =  ccp( size.width /2 , size.height/2 - 100);
//		[self addChild:countlabel z:1 tag:CCNodeTag_count];
//        
//        CCLabelTTF *statuslabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
//		statuslabel.position =  ccp( size.width /2 - 200, 20);
//		[self addChild:statuslabel z:1 tag:CCNodeTag_status];
//        
//        CCLabelTTF *scalelabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
//		scalelabel.position =  ccp( size.width /2 + 200 , 20);
//        [self addChild:scalelabel z:1 tag:CCNodeTag_distance];
//        
////        self.isTouchEnabled = YES;
////        [CCDirector sharedDirector].openGLView.multipleTouchEnabled = true;
//        
//        
//        starPosArray = [[NSMutableArray alloc]init];
//        for (int i = 0; i < 5; i++) {
//            int starR = arc4random() % 25;
//            int xR = (arc4random() % 1024/2)+1024/4;
//            int yR = (arc4random() % 798/2)+798/4;
//            
//            CCSprite *star = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%i.jpg", starR]];
//            [star setScale:0.5];
//            [star setPosition:CGPointMake(xR, yR)];
//            star.tag = (depth + 1) * 100 + i;
//            [self addChild:star z:star.tag];
//            
//            NSValue* point =[NSValue valueWithCGPoint:star.position];
//            [starPosArray addObject:point];
//        }
//        
//        depth = 0;
//        
//        CCParticleSystem *particleTest = [CCParticleGalaxy node];
//        //    particleTest.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
//        particleTest.life = 2;
//        particleTest.lifeVar = 0.2f;
//        
//        particleTest.duration = 2.5;
//        particleTest.startSize = 3.0f;
//        
//        [self addChild:particleTest z:1000 tag:1000000];
        
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

@end
