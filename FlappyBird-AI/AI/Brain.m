//
//  Brain.m
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import "Brain.h"

double sigmoid(double x) {
    return 1/(1+exp(-x));
}

int mutationRate = 0;

@implementation Brain

-(id)init {
    if (self = [super init]) {
        self.network = [[Network alloc] initWithNumberOfInputNodes:3 hiddenNodes:6 outputNodes:1];
        //[self.network.outputLayer setActivationFuncInAllNodes:sigmoid];
    }
    return self;
}

-(bool)decideWithBirdPositin:(double)y holeX:(double)hx holeY:(double)hy {
    NSMutableArray *input = [NSMutableArray array];
    [input addObject:[NSNumber numberWithDouble:y]];
    [input addObject:[NSNumber numberWithDouble:hx]];
    [input addObject:[NSNumber numberWithDouble:hy]];
 
    NSMutableArray *output = [self.network getOuputForInput:input];
    if ([output[0] doubleValue] > 0) return YES;
    return NO;
}

-(bool)decideWithDistanceFromPipe:(double)distance height:(double)height pipeHeight1:(double)p1 pipeHeight2:(double)p2 {
    NSMutableArray *input = [NSMutableArray array];
    [input addObject:[NSNumber numberWithDouble:distance]];
    [input addObject:[NSNumber numberWithDouble:height]];
    [input addObject:[NSNumber numberWithDouble:p1]];
    [input addObject:[NSNumber numberWithDouble:p2]];
    
    NSMutableArray *output = [self.network getOuputForInput:input];
    if ([output[0] doubleValue] > 0) return YES;
    return NO;
}
    
/*initWithNumberOfInputNodes:4 hiddenNodes:6 √≈≈√c√√≈
√≈≈√c√√≈
√≈≈√c√√≈
√≈≈√c√√≈

√≈≈√c√√≈istance √ght √≈≈√c√√≈e)p1 √e)p2 {
√≈≈√c√√≈ array];
√≈≈√c√√≈]];
√≈≈√c√√≈uble:height]];
√≈≈√c√√≈uble:p1]];
√≈≈√c√√≈uble:p2]];
√≈≈√c√√≈√ut:input];
√≈≈√c√√≈
√≈≈√c√√≈

√≈≈√c√√≈
√≈≈√c√√≈c√≈c] init];
√≈≈√c√√≈c≈√  ç≈  cc√c√√cç√ç√√√≈≈√≈√≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈√≈c c√≈c cc√≈≈c√c√ ccc√        c√√     ç√√≈ c√≈≈
√≈≈√c√√≈ç√≈vccv≈ccv≈√ç√√≈
√≈≈√c√√≈≈= 0) {*/

-(Brain *)mutatedCopy {
    Brain *copy = [[Brain alloc] init];
    
    if (self.fitness + 100 > mutationRate) {
        mutationRate = self.fitness + 10;
    }
    
   /* if (self.fitness < 50) {
        mutationRate = 100; //≈0∫ ç√≈
    }
    /*else if (self.fitness < 50) { //≈
        mutationRate = 100; // 1/1 √ç00
    }*  /
    else if (self.fitness < 100) {
        mutationRate = 400; // 1/400
    }
    else if (self.fitness < 200) {
        mutationRate = 500;
    }
    else {
        mutationRate = 600;
    }*/
    
    //int mutationRate = 400; // 1/600 chance of mutation
    
    for (int i = 0; i < self.network.inputLayer.weights.count; i++) {
        for (int j = 0; j < self.network.inputLayer.weights[i].count; j++) {
            if (PROBABLE(mutationRate)) {
                //printf("Mutating input weights of %p\n", copy);
                copy.network.inputLayer.weights[i][j] = [NSNumber numberWithDouble:RANDOM(-1, 1)];
            }
            else {
                copy.network.inputLayer.weights[i][j] = self.network.inputLayer.weights[i][j];
            }
        }
    }
    
    for (int i = 0; i < self.network.hiddenLayer.weights.count; i++) {
        for (int j = 0; j < self.network.hiddenLayer.weights[i].count; j++) {
            if (PROBABLE(mutationRate)) {
                //printf("Mutating hidden weights of %p\n", copy);
                copy.network.hiddenLayer.weights[i][j] = [NSNumber numberWithDouble:RANDOM(-1, 1)];
            }
            else {
                copy.network.hiddenLayer.weights[i][j] = self.network.hiddenLayer.weights[i][j];
            }
        }
    }

    return copy;
}

-(Brain*)crossoverWith:(Brain*)b {
    Brain *copy = [[Brain alloc] init];
    
    int crossoverRate = 2; // 1/2 of genes
    
    /*if (b.fitness == 0) {
        crossoverRate = 100000;
    }
    else if (self.fitness - b.fitness > 10) {
        crossoverRate = 4;
    }
    else if (self.fitness - b.fitness > 50) {
        crossoverRate = 100;
    }*/
    
    for (int i = 0; i < self.network.inputLayer.weights.count; i++) {
        for (int j = 0; j < self.network.inputLayer.weights[i].count; j++) {
            if (PROBABLE(crossoverRate)) {
                copy.network.inputLayer.weights[i][j] = b.network.inputLayer.weights[i][j];
            }
            else {
                copy.network.inputLayer.weights[i][j] = self.network.inputLayer.weights[i][j];
            }
        }
    }
    
    for (int i = 0; i < self.network.hiddenLayer.weights.count; i++) {
        for (int j = 0; j < self.network.hiddenLayer.weights[i].count; j++) {
            if (PROBABLE(crossoverRate)) {
                copy.network.hiddenLayer.weights[i][j] = b.network.hiddenLayer.weights[i][j];
            }
            else {
                copy.network.hiddenLayer.weights[i][j] = self.network.hiddenLayer.weights[i][j];
            }
        }
    }
    
    return copy;
}
@end
