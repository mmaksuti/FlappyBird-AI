//
//  Bird.m
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bird.h"
#import "Pipe.h"

#define HEX_COLOR(color) [UIColor colorWithRed: ((double)((color & 0xff0000) >> 16))/0xff green:((double)((color & 0xff00) >> 8))/0xff blue:((double)(color & 0xff))/0xff alpha:1];
#define SCREEN UIScreen.mainScreen.bounds

@implementation Bird : UIView

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = HEX_COLOR(0xffff00);
    }
    return self;
}

bool stop = false;

-(void)startMoving {
    self.prop = [[UIViewPropertyAnimator alloc] initWithDuration:(2.5 * (SCREEN.size.height - self.frame.origin.y - self.frame.size.height)/(SCREEN.size.height - self.frame.size.height)) curve:UIViewAnimationCurveLinear animations:^(void) {
        CGRect frame = self.frame;
        frame.origin.y += SCREEN.size.height - frame.origin.y - frame.size.height;
        self.frame = frame;
    }];
    [self.prop startAnimation];
}

-(void)stopMoving {
    [self.prop stopAnimation:true];
}

-(void)jump {
    [self stopMoving];
    self.prop = [[UIViewPropertyAnimator alloc] initWithDuration:0.2 curve:UIViewAnimationCurveEaseOut animations:^(void) {
        CGRect frame = self.frame;
        frame.origin.y -= 85;
        if (frame.origin.y < 0) frame.origin.y = 0;
        self.frame = frame;
    }];
    [self.prop startAnimation];
    
    __weak Bird* _self = self;
    [self.prop addCompletion:^(UIViewAnimatingPosition pos) {
        [_self stopMoving];
        usleep(70000);
        [_self startMoving];
    }];
}
        
@end
