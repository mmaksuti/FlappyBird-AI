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

@implementation Bird : UIImageView

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setImage:[UIImage imageNamed:@"bird"]];
        self.isJumping = false;
        self.speed = 0;
        self.numberOfJumps = 0;
    }
    return self;
}

-(void)startMoving {
    self.speed = 7;
    self.numberOfJumps = 0;
}

-(void)stopMoving {
    self.speed = 0;
}

-(void)jump {
    self.isJumping = true;
    self.speed = -7;
    self.numberOfJumps += 10;
}
        
@end
