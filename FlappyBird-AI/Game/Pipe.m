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

@implementation Pipe

bool low = false;

-(id)initWithX:(CGFloat)x {
    self.x = x;
    if (self = [super init]) {
        int height = (int)SCREEN.size.height;
        
        int upperPoint, lowerPoint;
       // int point;
       /* if (low) {
            point = height/8;
            low = false;
        }
        else {
            point = height * 7/8;
            low = true;
        }*/
        
        int point = RANDOM(height/8, (height * 7)/8);
        if (point > height/2) {
            lowerPoint = point;
            upperPoint = lowerPoint - 210;
        }
        else {
            upperPoint = point;
            lowerPoint = upperPoint + 210;
        }
        
        self.upperPipe = [[UIImageView alloc] initWithFrame:CGRectMake(self.x, 0, 60, upperPoint)];
        self.lowerPipe = [[UIImageView alloc] initWithFrame:CGRectMake(self.x, lowerPoint, 60, height-lowerPoint)];
        self.upperPipe.contentMode = UIViewContentModeBottom;
        self.lowerPipe.contentMode = UIViewContentModeTop;
        [self.upperPipe setImage:[UIImage imageNamed:@"upperPipe"]];
        [self.lowerPipe setImage:[UIImage imageNamed:@"lowerPipe"]];
    }
    return self;
}

-(void)startMoving {
    self.speed = 5;
}

-(void)stopMoving {
    self.speed = 0;
}

@end
