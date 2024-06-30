//
//  Bird.h
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../AI/Brain.h"

@interface Bird : UIImageView

@property (nonatomic, assign) BOOL isJumping;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) int numberOfJumps;
@property (nonatomic, assign) int sleep;

@property (nonatomic, retain) Brain *brain;

-(id)initWithFrame:(CGRect)frame;
-(void)startMoving;
-(void)stopMoving;
-(void)jump;

@end
