//
//  Pipe.h
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Pipe : NSObject
-(id)initWithX:(CGFloat)x;
-(void)startMoving;
-(void)stopMoving;
@property (nonatomic, retain) UIImageView *upperPipe;
@property (nonatomic, retain) UIImageView *lowerPipe;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat speed;
@end
