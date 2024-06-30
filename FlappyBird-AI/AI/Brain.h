//
//  Brain.h
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Neural Network.h"

@interface Brain : NSObject

@property (nonatomic, retain) Network *network;
@property (nonatomic, assign) int fitness;
-(bool)decideWithDistanceFromPipe:(double)distance height:(double)height pipeHeight1:(double)p1 pipeHeight2:(double)p2;
-(bool)decideWithBirdPositin:(double)y holeX:(double)hx holeY:(double)hy;
-(Brain *)mutatedCopy;
-(Brain*)crossoverWith:(Brain*)b;

@end
