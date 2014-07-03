//
//  RCViewController.m
//  RCCountDownViewExample
//
//  Created by Looping on 14/6/29.
//  Copyright (c) 2014年 RidgeCorn. All rights reserved.
//

#import "RCViewController.h"
#import <RCCountDownView.h>

@interface RCViewController ()

@property (weak, nonatomic) IBOutlet RCCountDownView *countDownView;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

@implementation RCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startCountDown];
    
    [self updateState];
}

- (void)startCountDown {
    [_countDownView startCountDownWithTime:60 completion:^(RCCountDownView *view) {
        NSLog(@"Count down completed!");
        
        [self updateState];
    }];
    
    [_countDownView setDisplayColor:[UIColor darkGrayColor] withStatus:RCCountDownViewStatusStarted];
}

- (IBAction)startLighting:(UIButton *)sender {
    RCCountDownViewStatus status = _countDownView.status;
    
    if (status == RCCountDownViewStatusStopped) {
        [self startCountDown];
        
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [_countDownView stop];
        [sender setTitle:@"Start" forState:UIControlStateNormal];
    }
    
    [self updateState];
}

- (IBAction)pauseLighting:(UIButton *)sender {
    RCCountDownViewStatus status = _countDownView.status;
    
    [sender setTitle:@"Pause" forState:UIControlStateNormal];
    
    if (status != RCCountDownViewStatusStopped) {
        if (status == RCCountDownViewStatusPaused) {
            [_countDownView resume];
        } else {
            [_countDownView pause];
            [sender setTitle:@"Resume" forState:UIControlStateNormal];
        }
    }
    
    [self updateState];
}

- (void)updateState {
    switch (_countDownView.status) {
        case RCCountDownViewStatusDefault: {
            [_stateLabel setText:@"Stopped"];
        }
            break;
        case RCCountDownViewStatusStarted: {
            [_stateLabel setText:@"Counting ..."];
        }
            break;
        case RCCountDownViewStatusPaused: {
            [_stateLabel setText:@"Pausing ..."];
        }
            break;
        case RCCountDownViewStatusStopped: {
            [_stateLabel setText:@"Stopped"];
        }
            break;
            
        default: {
            [_stateLabel setText:@"Unknown status"];
        }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
