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
#define RANDOM(min, max) arc4random() % (((max) + 1) - (min)) + (min)

@interface ViewController () <UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UIButton *AIBtn;
@property (weak, nonatomic) IBOutlet UIButton *manualBtn;
@end

Bird *bird;
Pipe *pp;
NSMutableArray *birds;

CADisplayLink *calink = nil;

bool createPipes = true;
bool isAI = false;

Brain *brain;

extern int score;

@implementation ViewController

- (IBAction)start:(id)sender {
    [sender setHidden:YES];
    [self.AIBtn setHidden:YES];
    
    [self addPipes];
    [self addBird];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressed)];
    [self.view addGestureRecognizer:tapGesture];
}

- (IBAction)startAI:(id)sender {
    isAI = YES;
    
    [sender setHidden:YES];
    [self.manualBtn setHidden:YES];
    
    [self addPipes];
    
    birds = [NSMutableArray new];
    for (int i = 0; i < 100; i++) {
        [self addBird];
        [birds addObject:bird];
        [self.view addSubview:bird];
        [bird startMoving];
    }
}

-(void)addBird {
    bird = [[Bird alloc] initWithFrame:CGRectMake(50, RANDOM(0, ((int)SCREEN.size.height - 50)), 50, 50)];
    bird.backgroundColor = HEX_COLOR(RANDOM(0, 0xffffff));
    
    if (isAI) {
        brain = [[Brain alloc] init];
        [bird setBrain:brain];
    }
    
    [self.view addSubview:bird];
    [bird startMoving];
    
    if (!calink) {
        calink = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkIfLost)];
        [calink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

-(void)addPipes {
    if (createPipes) {
        pp = [[Pipe alloc] initWithX:SCREEN.size.width];
        [self.view addSubview:pp.upperPipe];
        [self.view addSubview:pp.lowerPipe];
        [pp startMoving];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addPipes];
        });
    }
    else {
        createPipes = true;
    }
}

-(void)pressed {
    [bird jump];
}

bool keep = true;
bool lose = true;

-(void)checkIfLost {
    if (!bird || !pp) {
        return;
    }
    
#define BIRD b.layer.presentationLayer.frame
#define UP pp.upperPipe.layer.presentationLayer.frame
#define LP pp.lowerPipe.layer.presentationLayer.frame
    
    if (isAI) {
        unsigned long count = birds.count;
        for (int i = 0; i < count; i++) {
            Bird *b = birds[i];
            if ([b.brain decideWithDistanceFromPipe:(pp.lowerPipe.layer.presentationLayer.frame.origin.x - b.frame.origin.x - b.frame.size.width)/SCREEN.size.width height:(b.layer.presentationLayer.frame.origin.y + b.layer.presentationLayer.frame.size.height/2)/SCREEN.size.height pipeHeight1:pp.lowerPipe.layer.presentationLayer.frame.size.height/SCREEN.size.height pipeHeight2:pp.upperPipe.layer.presentationLayer.frame.size.height/SCREEN.size.height]) {
                [b jump];
            }
            
            if (!BIRD.size.width) {
                continue;
            }
            
            if (LP.origin.x > b.frame.origin.x + b.frame.size.width) {
                continue;
            }
            
            if (!lose) {
                continue;
            }
            
            if ((BIRD.origin.y <= UP.origin.y + UP.size.height) || (BIRD.origin.y + BIRD.size.height >= LP.origin.y)) {
                [b stopMoving];
                [b removeFromSuperview];
                [birds removeObject:b];
                i--;
                count--;
                if (count == 1) {
                    //lose = false;
                }
                if (count == 0) {
                    [self lost];
                    return;
                }
            }
        }
    }
    else {
        if (!bird.layer.presentationLayer.frame.size.width) {
            return;
        }
        
        if (LP.origin.x > bird.layer.presentationLayer.frame.origin.x + bird.layer.presentationLayer.frame.size.width) {
            return;
        }
        
        if ((bird.layer.presentationLayer.frame.origin.y <= UP.origin.y + UP.size.height) ||  (bird.layer.presentationLayer.frame.origin.y + bird.layer.presentationLayer.frame.size.height >= LP.origin.y)) {
            [self lost];
        }
    }
}

-(void)lost { 
    createPipes = false;
    [calink invalidate];
    
    [self.manualBtn setHidden:NO];
    [self.AIBtn setHidden:NO];
    
    [pp stopMoving];
    [bird stopMoving];
    
    [bird removeFromSuperview];
    [pp.upperPipe removeFromSuperview];
    [pp.lowerPipe removeFromSuperview];
    
    bird = nil;
    pp = nil;
    
    score = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
