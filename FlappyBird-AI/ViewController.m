//
//  ViewController.m
//  FlappyBird-AI
//
//  Created by Marko Maksuti on 11/5/19.
//  Copyright © 2019 Marko Maksuti. All rights reserved.
//

#import "ViewController.h"
#import "Game/Bird.h"
#import "Game/Pipe.h"
#import "AI/Brain.h"
#import <objc/runtime.h>

#define HEX_COLOR(color) [UIColor colorWithRed: ((double)((color & 0xff0000) >> 16))/0xff green:((double)((color & 0xff00) >> 8))/0xff blue:((double)(color & 0xff))/0xff alpha:1];
#define SCREEN UIScreen.mainScreen.bounds

@interface ViewController () <UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UITextView *generationLabel;
@property (nonatomic, assign) BOOL isPopulation;
@property (nonatomic, assign) BOOL populateWithSaved;
@end

Bird *bird = nil;
Pipe *pp = nil;

NSMutableArray <Bird *> *birds = nil;
NSMutableArray <Pipe *> *pipes = nil;

NSMutableArray <Bird *> *deadBirds = nil;

CADisplayLink *calink = nil;

NSUserDefaults *userDefaults;
NSMutableArray *savedInputWeights = nil;
NSMutableArray *savedHiddenWeights = nil;

bool createPipes = YES;
int score = 0;
int highscore = 0;
int generation = 1;

@implementation ViewController

- (void)start {
    [self addPipes];
    
    birds = [NSMutableArray new];
    deadBirds = [NSMutableArray new];
    
   // bool addedOrig = false;
    
    for (int i = 0; i < (self.isPopulation ? 200 : 1); i++) {
        [self addBird];
        
        Brain *brain = [[Brain alloc] init];
        bird.brain = brain;
    
        if (!self.isPopulation || self.populateWithSaved) {
            bird.brain.network.inputLayer.weights = [savedInputWeights mutableCopy];
            bird.brain.network.hiddenLayer.weights = [savedHiddenWeights mutableCopy];
            if (self.populateWithSaved) {//} && addedOrig) {
                bird.brain.fitness = highscore;
                bird.brain = [bird.brain mutatedCopy];
                
            }
            /*else if (self.populateWithSaved) {
                bird.brain.fitness = highscore;
                addedOrig = true;
            }*/
        }
        
        [birds addObject:bird];
        [self.view bringSubviewToFront:self.generationLabel];
        [bird startMoving];
    }
    
    if (!calink) {
        calink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateGame)];
        [calink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

-(NSMutableArray <Bird *> *)doSelection:(NSMutableArray <Bird *> *)population {
    NSMutableArray *newPopulation = [NSMutableArray new];

    int fitnessSum = 0;
    for (Bird *b in population) {
        fitnessSum += b.brain.fitness;
    }
    
    for (Bird *b in population) {
        // probability to crossover = fitness of bird/total fitness
        if (!b.brain.fitness) {
            continue; // fitness 0 = no crossover
        }
        if (PROBABLE(fitnessSum/b.brain.fitness)) {
            b.brain.fitness = 0;
            [newPopulation addObject:b];
        }
    }
    
    printf("Chose %ld birds for crossover\n", newPopulation.count);
    return newPopulation;
}

- (void)startNewGenerationWithFittiest:(Brain *)b population:(NSMutableArray <Bird *> *)population {
    [self addPipes];
    
    if (!self.isPopulation) {
        [self addBird];
        bird.brain = b;

        [birds addObject:bird];
        [self.view bringSubviewToFront:self.generationLabel];
        [bird startMoving];
    }
    else {
        population = [self doSelection:population];
        
        for (Bird *b in population) {
            [birds addObject:b];
            [self.view bringSubviewToFront:self.generationLabel];
            [bird startMoving];
        }
        
        for (int i = 0; i < 200; i++) {
            [self addBird];
            bird.brain = b;
            if (population.count > 0) {
                bird.brain = [bird.brain crossoverWith:population[RANDOM_INT(0, population.count - 1)].brain];
            }
            bird.brain = [bird.brain mutatedCopy];
            
            [birds addObject:bird];
            [self.view bringSubviewToFront:self.generationLabel];
            [bird startMoving];
        }
    }
    
    /*for (int i = 0; i < (self.isPopulation ? 200 : 1); i++) {
        [self addBird];
        
        if (b2 != nil) {
            bird.brain = [b crossoverWith:b2];
        }
        bird.brain = [b mutatedCopy];
        
        [birds addObject:bird];
        [self.view bringSubviewToFront:self.generationLabel];
        [bird startMoving];
    }
    */
    [calink setPaused:NO];
}

-(void)addBird {
    bird = [[Bird alloc] initWithFrame:CGRectMake(50, RANDOM(0, SCREEN.size.height - 64 * 3/4), 90 * 3/4, 64 * 3/4)];
    
    //bird = [[Bird alloc] initWithFrame:CGRectMake(50, SCREEN.size.height/2 - 64 * 3/4, /*RANDOM(0, ((int)SCREEN.size.height - 50))*/ 90 * 3/4, 64 * 3/4)];
    [self.view addSubview:bird];
    [self.view bringSubviewToFront:self.generationLabel];
}

-(void)addPipes {
    if (!pipes) {
        pipes = [NSMutableArray array];
    }
    
    Pipe *p = [[Pipe alloc] initWithX:SCREEN.size.width];
    [pipes addObject:p];
    [self.view addSubview:p.upperPipe];
    [self.view addSubview:p.lowerPipe];
    [self.view bringSubviewToFront:self.generationLabel];
    [p startMoving];
}

-(void)updateGame {
    if ([self presentedViewController]) {
        return;
    }
    
    unsigned long count = [pipes count];
    for (int i = 0; i < count; i++) {
        Pipe *p = pipes[i];
        
        CGRect upipe = p.upperPipe.frame;
        upipe.origin.x -= p.speed;
        p.upperPipe.frame = upipe;
        
        CGRect lpipe = p.lowerPipe.frame;
        lpipe.origin.x -= p.speed;
        p.lowerPipe.frame = lpipe;

        if (lpipe.origin.x == SCREEN.size.width - 450) {
            [self addPipes];
        }
        
        if (lpipe.origin.x + lpipe.size.width < 0) {
            [pipes[i].lowerPipe removeFromSuperview];
            [pipes[i].upperPipe removeFromSuperview];
            [pipes removeObjectAtIndex:i];
            count--;
            if (i) {
                i--;
            }
        }
        
        if (pipes.count) {
            if (lpipe.origin.x + lpipe.size.width < bird.frame.origin.x && lpipe.origin.x + lpipe.size.width > 0 && pipes.count >= 2) {
                if (pp != pipes[1]) {
                    pp = pipes[1];
                    score++;
                    printf("%lu birds left\n", (unsigned long)birds.count);
                }
            }
            else {
                pp = pipes[i];
            }
        }
    }
    
    if (self.isPopulation) {
        unsigned long count = (unsigned long)birds.count ? (unsigned long)birds.count : 200;
        self.generationLabel.text = [NSString stringWithFormat:@"Generation: %d     \nScore: %d     \nHighscore: %d     \nBirds left: %lu     \n", generation, score, highscore, count];
    }
    else {
        self.generationLabel.text = [NSString stringWithFormat:@"Score: %d     \nHighscore: %d     \n", score, highscore];
    }
    
    count = birds.count;
    for (int i = 0; i < count; i++) {
        Bird *b = birds[i];
        
        if (!b.frame.size.width) {
            continue;
        }
        
        if (b.sleep != 0) {
            if (b.speed < 0) {
                b.sleep = 0;
                goto cont;
            }
            
            if (b.sleep == 1) {
                b.isJumping = NO;
            }
            b.sleep--;
            continue;
        }
    
    cont:;
        b.brain.fitness = score;
        if (score > highscore && self.isPopulation) {
            highscore = score;
            [userDefaults setObject:[NSNumber numberWithInt:highscore] forKey:@"highscore"];
            [userDefaults setObject:[NSNumber numberWithInt:generation] forKey:@"generation"];
            [userDefaults setObject:b.brain.network.inputLayer.weights forKey:@"inputWeights"];
            [userDefaults setObject:b.brain.network.hiddenLayer.weights forKey:@"hiddenWeights"];
            [userDefaults synchronize];
        }
        
        CGRect bframe = b.frame;
        bframe.origin.y += b.speed;
        
        if (bframe.origin.y >= SCREEN.size.height - bframe.size.height) {
            bframe.origin.y = SCREEN.size.height - bframe.size.height;
            b.speed = 0;
        }
        if (bframe.origin.y <= 0) {
            bframe.origin.y = 0;
            [b startMoving];
        }
        
        b.frame = bframe;
        
        if (CGRectIntersectsRect(bframe, pp.lowerPipe.frame) || CGRectIntersectsRect(bframe, pp.upperPipe.frame)) {
            bird = b;
            [b stopMoving];
            [b removeFromSuperview];
            [deadBirds addObject:b];
            [birds removeObject:b];
            
            count--;
            if (count == 0) {
                [self lost];
                return;
            }
            i--;
        }
        
        if (b.isJumping) {
            b.numberOfJumps--;
            if (b.numberOfJumps <= 0) {
                b.isJumping = NO;
                b.sleep = 3;
                [b startMoving];
            }
        }
        
        if ([b.brain decideWithBirdPositin:b.frame.origin.y holeX:(pp.lowerPipe.frame.origin.x + pp.lowerPipe.frame.size.width)/2 holeY:(pp.lowerPipe.frame.origin.y + pp.upperPipe.frame.size.height)/2]) {
            [b jump];
        }
        
        /*if ([b.brain decideWithDistanceFromPipe:(pp.lowerPipe.frame.origin.x - b.frame.origin.x - b.frame.size.width)/SCREEN.size.width height:(b.frame.origin.y + b.frame.size.height/2)/SCREEN.size.height pipeHeight1:pp.lowerPipe.frame.size.height/SCREEN.size.height pipeHeight2:pp.upperPipe.frame.size.height/SCREEN.size.height]) {
            [b jump];
        }*/
        /*else {
            b.sleep = 0;
            [b startMoving];
        }*/
    }
}

-(void)lost {
    [calink setPaused:YES];
    
    generation++;
    if (self.isPopulation) {
        self.generationLabel.text = [NSString stringWithFormat:@"Generation: %d     \nScore: %d     \nHighscore: %d     \n", generation, score, highscore];
    }
    else {
        self.generationLabel.text = [NSString stringWithFormat:@"Score: %d     \nHighscore: %d     \n", score, highscore];
    }
    
    unsigned long count = pipes.count;
    while (count > 0) {
        Pipe *p = pipes[0];
        [p.upperPipe removeFromSuperview];
        [p.lowerPipe removeFromSuperview];
        [pipes removeObjectAtIndex:0];
        count--;
    }
    
    score = 0;
    
    [self startNewGenerationWithFittiest:bird.brain population:deadBirds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

bool started = NO;
-(void)viewDidAppear:(BOOL)animated {
    if (!started) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        
        CGRect imgFrame = image.frame;
        imgFrame.size.height = SCREEN.size.height;
        imgFrame.size.width *= imgFrame.size.height / image.frame.size.height;
        image.frame = imgFrame;
        image.contentMode = UIViewContentModeScaleToFill;
        [self.view addSubview:image];

        self.isPopulation = YES;
        self.populateWithSaved = NO;
        
        if (self.isPopulation) {
            self.generationLabel.text = [NSString stringWithFormat:@"Generation: %d     \nScore: %d     \nHighscore: %d     \n", generation, score, highscore];
        }
        else {
            self.generationLabel.text = [NSString stringWithFormat:@"Score: %d     \nHighscore: %d     \n", score, highscore];
        }
        self.generationLabel.translatesAutoresizingMaskIntoConstraints = YES;
        [self.generationLabel sizeToFit];
        self.generationLabel.scrollEnabled = NO;
        [self.view bringSubviewToFront:self.generationLabel];
    
        userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([userDefaults objectForKey:@"highscore"] != nil) {
            highscore = [[userDefaults objectForKey:@"highscore"] intValue];
        }
        
        if ([userDefaults objectForKey:@"hiddenWeights"] != nil && [userDefaults objectForKey:@"inputWeights"] != nil) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Load?" message:@"Do you want to load the previous best bird?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                savedInputWeights = [userDefaults objectForKey:@"inputWeights"];
                savedHiddenWeights = [userDefaults objectForKey:@"hiddenWeights"];
                
                self.isPopulation = NO;
                self.populateWithSaved = NO;
                started = YES;
                [self start];
            }];
            
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Start a population with it" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                savedInputWeights = [userDefaults objectForKey:@"inputWeights"];
                savedHiddenWeights = [userDefaults objectForKey:@"hiddenWeights"];
                
                self.isPopulation = YES;
                self.populateWithSaved = YES;
                
                generation = [[userDefaults objectForKey:@"generation"] intValue];
                
                started = YES;
                [self start];
            }];
            
            UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                started = YES;
                [self start];
            }];
            
            [alertController addAction:action1];
            [alertController addAction:action2];
            [alertController addAction:action3];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        if ([self presentedViewController]) {
            return;
        }
        
        started = YES;
        [self start];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
