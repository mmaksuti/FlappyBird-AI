//
//  Neural Network.m
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import "Neural Network.h"

@implementation Node
-(id)initWithActivationFunc:(actf_t)func {
    if ((self = [super init])) {
        self.activationFunc = func;
        self.value = 0;
        self.isBias = NO;
    }
    return self;
}
@end

@implementation OutputLayer
-(id)initWithNumberOfNodes:(int)nNodes {
    if ((self = [super init])) {
        self.nodes = [NSMutableArray new];
        for (int i = 0; i < nNodes; i++) {
            [self.nodes addObject:[[Node alloc] initWithActivationFunc:NULL]];
        }
    }
    return self;
}

-(void)setActivationFuncInAllNodes:(actf_t)func {
    for (Node *node in self.nodes) {
        node.activationFunc = func;
    }
}
@end

@implementation HiddenLayer
-(id)initWithNumberOfNodes:(int)nNodes outputLayer:(OutputLayer *)output {
    if ((self = [super init])) {
        self.nodes = [NSMutableArray new];
        self.weights = [NSMutableArray new];
        self.outputLayer = output;
        for (int i = 0; i < nNodes; i++) {
            [self.nodes addObject:[[Node alloc] initWithActivationFunc:NULL]];
            [self.weights addObject:[NSMutableArray new]];
            for (int i = 0; i < output.nodes.count; i++) {
                [[self.weights lastObject] addObject:[NSNumber numberWithDouble:RANDOM(-1, 1)]];
            }
        }
    }
    return self;
}

-(void)setActivationFuncInAllNodes:(actf_t)func {
    for (Node *node in self.nodes) {
        node.activationFunc = func;
    }
}

-(void)addBias:(double)bias {
    Node *biasNode = [[Node alloc] initWithActivationFunc:NULL];
    biasNode.value = bias;
    biasNode.isBias = YES;
    [self.nodes addObject:biasNode];
    [self.weights addObject:[NSMutableArray new]];
    for (int i = 0; i < self.outputLayer.nodes.count; i++) {
        if ([self.outputLayer.nodes objectAtIndex:i].isBias) break;
        [[self.weights lastObject] addObject:[NSNumber numberWithDouble:1]];
    }
}
@end

@implementation InputLayer
-(id)initWithNumberOfNodes:(int)nNodes hiddenLayer:(HiddenLayer *)hidden {
    if ((self = [super init])) {
        self.nodes = [NSMutableArray new];
        self.weights = [NSMutableArray new];
        self.hiddenLayer = hidden;
        for (int i = 0; i < nNodes; i++) {
            [self.nodes addObject:[[Node alloc] initWithActivationFunc:NULL]];
            [self.weights addObject:[NSMutableArray new]];
            for (int i = 0; i < hidden.nodes.count; i++) {
                [[self.weights lastObject] addObject:[NSNumber numberWithDouble:RANDOM(-1, 1)]];
            }
        }
    }
    return self;
}

-(void)setActivationFuncInAllNodes:(actf_t)func {
    for (Node *node in self.nodes) {
        node.activationFunc = func;
    }
}

-(void)addBias:(double)bias {
    Node *biasNode = [[Node alloc] initWithActivationFunc:NULL];
    biasNode.value = bias;
    biasNode.isBias = YES;
    [self.nodes addObject:biasNode];
    [self.weights addObject:[NSMutableArray new]];
    for (int i = 0; i < self.hiddenLayer.nodes.count; i++) {
        if (self.hiddenLayer.nodes[i].isBias) break;
        [[self.weights lastObject] addObject:[NSNumber numberWithDouble:1]];
    }
}
@end

@implementation Network
-(id)initWithNumberOfInputNodes:(int)nInput hiddenNodes:(int)nHidden outputNodes:(int)nOutput {
    if ((self = [super init])) {
        self.outputLayer = [[OutputLayer alloc] initWithNumberOfNodes:nOutput];
        self.hiddenLayer = [[HiddenLayer alloc] initWithNumberOfNodes:nHidden outputLayer:self.outputLayer];
        self.inputLayer = [[InputLayer alloc] initWithNumberOfNodes:nInput hiddenLayer:self.hiddenLayer];
    }
    return self;
}

-(NSMutableArray <NSNumber *>*)getOuputForInput:(NSMutableArray <NSNumber *>*)input {
    for (int i = 0; i < [input count]; i++) {
        if (self.inputLayer.nodes[i].activationFunc) {
            self.inputLayer.nodes[i].value = self.inputLayer.nodes[i].activationFunc([input[i] doubleValue]);
        }
        else {
            self.inputLayer.nodes[i].value = [input[i] doubleValue];
        }
    }

    for (int i = 0; i < self.inputLayer.weights.count; i++) {
        for (int j = 0; j < self.inputLayer.weights[i].count; j++) {
            if (i == 0) {
                self.hiddenLayer.nodes[j].value = self.inputLayer.nodes[i].value * [self.inputLayer.weights[i][j] doubleValue];
            }
            else {
                self.hiddenLayer.nodes[j].value += self.inputLayer.nodes[i].value * [self.inputLayer.weights[i][j] doubleValue];
            }
            
            if (self.hiddenLayer.nodes[j].activationFunc) {
                self.hiddenLayer.nodes[j].value = self.hiddenLayer.nodes[j].activationFunc(self.hiddenLayer.nodes[j].value);
            }
        }
    }
    
    for (int i = 0; i < self.hiddenLayer.weights.count; i++) {
        for (int j = 0; j < self.hiddenLayer.weights[i].count; j++) {
            
            if (i == 0) {
                self.outputLayer.nodes[j].value = self.hiddenLayer.nodes[i].value * [self.hiddenLayer.weights[i][j] doubleValue];
            }
            else {
                self.outputLayer.nodes[j].value += self.hiddenLayer.nodes[i].value * [self.hiddenLayer.weights[i][j] doubleValue];
            }
            
            if (self.outputLayer.nodes[j].activationFunc) {
                self.outputLayer.nodes[j].value = self.outputLayer.nodes[j].activationFunc(self.outputLayer.nodes[j].value);
            }
        }
    }
    
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:self.outputLayer.nodes.count];
    for (int i = 0; i < self.outputLayer.nodes.count; i++) {
        output[i] = [NSNumber numberWithDouble:self.outputLayer.nodes[i].value];
    }
    return output;
}
@end
