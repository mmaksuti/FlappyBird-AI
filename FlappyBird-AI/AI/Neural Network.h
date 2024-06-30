//
//  Neural Network.h
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef double (*actf_t)(double);
@interface Node : NSObject
@property (nonatomic, assign) double value;
@property (nonatomic, assign) actf_t activationFunc;
@property (nonatomic, assign) bool isBias;
-(id)initWithActivationFunc:(actf_t)func;
@end

@interface Connection : NSObject
@property (nonatomic, assign) double weight;
@property (nonatomic, retain) Node* node;
-(id)initWithWeight:(double)weight connectTo:(Node *)node;
@end

@interface OutputLayer : NSObject
@property (nonatomic, retain) NSMutableArray<Node *> *nodes;
-(id)initWithNumberOfNodes:(int)nNodes;
-(void)setActivationFuncInAllNodes:(actf_t)func;
@end

@interface HiddenLayer : NSObject
@property (nonatomic, retain) NSMutableArray<Node *> *nodes;
@property (nonatomic, retain) NSMutableArray<NSMutableArray<NSNumber *> *> *weights;
@property (nonatomic, retain) OutputLayer *outputLayer;
-(id)initWithNumberOfNodes:(int)nNodes outputLayer:(OutputLayer *)output;
-(void)setActivationFuncInAllNodes:(actf_t)func;
-(void)addBias:(double)bias;
@end

@interface InputLayer : NSObject
@property (nonatomic, retain) NSMutableArray<Node *> *nodes;
@property (nonatomic, retain) NSMutableArray<NSMutableArray<NSNumber *> *> *weights;
@property (nonatomic, retain) HiddenLayer *hiddenLayer;
-(id)initWithNumberOfNodes:(int)nNodes hiddenLayer:(HiddenLayer *)hidden;
-(void)setActivationFuncInAllNodes:(actf_t)func;
-(void)addBias:(double)bias;
@end

@interface Network : NSObject
@property (nonatomic, assign) int fitness;
@property (nonatomic, retain) InputLayer *inputLayer;
@property (nonatomic, retain) HiddenLayer *hiddenLayer;
@property (nonatomic, retain) OutputLayer *outputLayer;
-(id)initWithNumberOfInputNodes:(int)nInput hiddenNodes:(int)nHidden outputNodes:(int)nOutput;
-(NSMutableArray <NSNumber *>*)getOuputForInput:(NSMutableArray <NSNumber *>*)input;
@end

#define RANDOM(min, max) (((float)(arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (max - min)) + min
#define RANDOM_INT(min, max) arc4random() % (((max) + 1) - (min)) + (min)
#define PROBABLE(probability) (RANDOM_INT(1, probability) == 1)
