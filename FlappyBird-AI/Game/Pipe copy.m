//
//  Pipe.m
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pipe.h"

#define HEX_COLOR(color) [UIColor colorWithRed: ((double)((color & 0xff0000) >> 16))/0xff green:((double)((color & 0xff00) >> 8))/0xff blue:((double)(color & 0xff))/0xff alpha:1];
#define SCREEN UIScreen.mainScreen.bounds
#define RANDOM(min, max) arc4random() % (((max) + 1) - (min)) + (min)

int score = 0;

@implementation Pipe

-(id)initWithX:(CGFloat)x {
    self.x = x;
    if (self = [super init]) {
        int height = (int)SCREEN.size.height;
        
        int upperPoint, lowerPoint;
        int point = RANDOM(height/8, (height * 7)/8);
        if (point > height/2) {
            lowerPoint = point;
            upperPoint = lowerPoint - 200;
        }
        else {
            upperPoint = point;
            lowerPoint = upperPoint + 200;
        }
        
        self.upperPipe = [[UIView alloc] initWithFrame:CGRectMake(self.x, 0, 60, upperPoint)];
        self.lowerPipe = [[UIView alloc] initWithFrame:CGRectMake(self.x, lowerPoint, 60, height-lowerPoint)];
        
        self.upperPipe.backgroundColor = HEX_COLOR(0xff00);
        self.lowerPipe.backgroundColor = HEX_COLOR(0xff00);
    }
    return self;
}

UIViewPropertyAnimator *pProp;

-(void)startMoving {
    pProp = [[UIViewPropertyAnimator alloc] initWithDuration:(2.5 * (self.x + 100)/(SCREEN.size.width + 100)) curve:UIViewAnimationCurveLinear animations:^(void) {
        CGRect uFrame = self.upperPipe.frame;
        CGRect lFrame = self.lowerPipe.frame;
        uFrame.origin.x -= self.x + 100;
        lFrame.origin.x -= self.x + 100;
        self.upperPipe.frame = uFrame;
        self.lowerPipe.frame = lFrame;
    }];
    
    [pProp startAnimation];
    [pProp addCompletion:^(UIViewAnimatingPosition pos) {
        [self.upperPipe removeFromSuperview];
        [self.lowerPipe removeFromSuperview];
        self.upperPipe = nil;
        self.lowerPipe = nil;
        
        score++;
        printf("SCORE: %d\n", score);
    }];
}

-(void)stopMoving {
    [pProp stopAnimation:true];
}
@end
