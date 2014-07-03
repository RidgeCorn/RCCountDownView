//
//  RCCountDownView.m
//  RCCountDownView
//
//  Created by Looping on 14-5-26.
//  Copyright (c) 2014  RidgeCorn. All rights reserved.
//

/**
 The MIT License (MIT)
 
 Copyright (c) 2014 RidgeCorn
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "RCCountDownView.h"

#define RCCountDownTimeInterval 1.f

@interface RCCountDownView () {
    NSTimeInterval _countDownTimeTotal;
    NSTimeInterval _countDownTimeLeft;
    NSTimer *_countDownTimer;
    UILabel *_timeLabel;
    UIColor *_defaultColor;
    UIColor *_startedColor;
    UIColor *_pausedColor;
    UIColor *_stoppedColor;
    UILabel *_progressLabel;
    UIView *_progressView;
}

@property (nonatomic) UIFont *displayTextFont;
@property (nonatomic, copy) void(^countDownCompletionBlock)(RCCountDownView *view);
@property (nonatomic) NSDate *pauseDate;
@property (nonatomic) NSDate *fireDate;

@property (nonatomic) BOOL progressViewEnabled;
@property (nonatomic) UIColor *progressColor;
@property (nonatomic) UIColor *progressBackgroundColor;

@property (nonatomic) CGFloat fontSize;
@end

static NSBundle *_localizationBundle = nil;

@implementation RCCountDownView

#pragma mark - Localization

+ (void)setLocalizationBundle:(NSBundle *)localizationBundle {
    _localizationBundle = localizationBundle ?: [NSBundle mainBundle];
}

#pragma mark - Initialization

+ (void)initialize {
    if (self == [RCCountDownView class]) {
        _localizationBundle = [NSBundle mainBundle];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commInit];
    }
    return self;
}

- (void)commInit {
    _progressViewEnabled = YES;
    
    [self setupTimeLabel];
    
    if (self.frame.size.height >= 60) {
        [self setupProgressView];
    } else {
        _progressViewEnabled = NO;
    }
}

- (void)setupTimeLabel {
    CGRect frame = self.frame;
    frame.origin = CGPointMake(0, 0);
    
    if (_timeLabel) {
        [_timeLabel removeFromSuperview];
        [_timeLabel setFrame:frame];
    } else {
        _timeLabel = [[UILabel alloc] initWithFrame:frame];
    }
    
    _fontSize = self.frame.size.height >= 60 ? 32 : (self.frame.size.height >= 30.f ? 26.f : (self.frame.size.height - 12.f >= 0 ? self.frame.size.height - 4.f : 0.f));
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:_fontSize];
    font = font ?: [UIFont systemFontOfSize:_fontSize];
    _displayTextFont = font;
    
    [_timeLabel setFont:_displayTextFont];
    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    
    if ( !_defaultColor) {
        _defaultColor = [UIColor blackColor];
    }
    
    if ( !_startedColor) {
        _startedColor = [UIColor greenColor];
    }
    
    if ( !_pausedColor) {
        _pausedColor = [UIColor orangeColor];
    }
    
    if ( !_stoppedColor) {
        _stoppedColor = [UIColor redColor];
    }
    
    
    [_timeLabel setAttributedText:[self _displayStringWithTime:0]];
    
    [self addSubview:_timeLabel];
}

- (void)setupProgressView {
    CGRect frame = CGRectMake(0, _timeLabel.frame.size.height * 4 / 5.f, self.frame.size.width, 2.f);
    if (_progressView) {
        [_progressView removeFromSuperview];
        [_progressView setFrame:frame];
    } else {
        _progressView = [[UIView alloc] initWithFrame:frame];
    }
    
    [_progressView setBackgroundColor:_progressBackgroundColor ?: (_progressBackgroundColor = [UIColor lightGrayColor])];
    
    frame.origin = CGPointZero;
    if (_progressLabel) {
        [_progressLabel removeFromSuperview];
        [_progressLabel setFrame:frame];
    } else {
        _progressLabel = [[UILabel alloc] initWithFrame:frame];
    }
    [_progressLabel setBackgroundColor:_progressColor ?: (_progressColor = [UIColor darkGrayColor])];
    
    [_progressView addSubview:_progressLabel];
    [self addSubview:_progressView];
}

#pragma mark - Control

- (void)startCountDownWithTime:(NSTimeInterval)time remainTime:(NSTimeInterval)remainTime completion:(void (^)(RCCountDownView *))completion {
    time = time > 0 ? time : 0;
    remainTime = remainTime > 0 ? (remainTime > time ? time : remainTime) : 0;
    
    if ( !(_timeLabel && _timeLabel.superview)) {
        [self commInit];
    }
    
    if (completion) {
        _countDownCompletionBlock = completion;
    }
    
    if (time) {
        _countDownTimeTotal = time;
        _countDownTimeLeft = remainTime;
        
        [self _startTimer];
    } else {
        [self stop];
    }
    
    [self _changeDisplayColorWithStatus:RCCountDownViewStatusStarted];
}

- (void)startCountDownWithTime:(NSTimeInterval)time completion:(void (^)(RCCountDownView *))completion {
    [self startCountDownWithTime:time remainTime:time completion:completion];
}

- (void)pause {
    _pauseDate = [NSDate date];
    _fireDate = _countDownTimer.fireDate;
    
    [self _stopTimer];
    
    [self _changeDisplayColorWithStatus:RCCountDownViewStatusPaused];
}

- (void)resume {
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:[_fireDate timeIntervalSince1970] - [_pauseDate timeIntervalSince1970] target:self selector:@selector(_resumeCountDown) userInfo:nil repeats:NO];
    
    [self _changeDisplayColorWithStatus:RCCountDownViewStatusStarted];
}

- (void)stop {
    [self pause];
    
    _countDownTimeLeft = 0;
    
    [self _refreshProgress];
    
    [self _changeDisplayColorWithStatus:RCCountDownViewStatusStopped];
}

- (BOOL)isProgressViewEnabled {
    return _progressViewEnabled;
}

- (void)setDisplayTextFont:(UIFont *)displayTextFont {
    _displayTextFont = displayTextFont;
    [_timeLabel setFont:_displayTextFont];
    [_timeLabel setAttributedText:[self _displayStringWithTime:_countDownTimeLeft]];
}

- (void)progressViewEnabled:(BOOL)enabled {
    _progressViewEnabled = enabled;
    
    if ( !_progressView) {
        [self setupProgressView];
    }
}

- (void)setDisplayColor:(UIColor *)color withStatus:(RCCountDownViewStatus)status {
    switch (status) {
        case RCCountDownViewStatusDefault: {
            _defaultColor = color;
            _startedColor = color;
            _pausedColor = color;
            _stoppedColor = color;
        }
            break;
            
        case RCCountDownViewStatusStarted: {
            _startedColor = color;
        }
            break;
            
        case RCCountDownViewStatusPaused: {
            _pausedColor = color;
        }
            break;
            
        case RCCountDownViewStatusStopped: {
            _stoppedColor = color;
        }
            break;
            
        default:
            break;
    }
    
    [self _changeDisplayColorWithStatus:status];
}

- (void)setProgressColor:(UIColor *)color withBackgroundColor:(UIColor *)bgColor {
    if (color) {
        _progressColor = color;
    }
    
    if (bgColor) {
        _progressBackgroundColor = bgColor;
    }
    
    [self _refreshProgress];
}

- (BOOL)isCompleted {
    return !_countDownTimeLeft;
}

- (NSTimeInterval)timeLeft {
    return _countDownTimeLeft;
}


#pragma mark - Internal

- (void)_changeDisplayColorWithStatus:(RCCountDownViewStatus)status {
    _status = status;
    
    switch (status) {
        case RCCountDownViewStatusDefault: {
            [_timeLabel setTextColor:_defaultColor];
        }
            break;
            
        case RCCountDownViewStatusStarted: {
            [_timeLabel setTextColor:_startedColor];
        }
            break;
            
        case RCCountDownViewStatusPaused: {
            [_timeLabel setTextColor:_pausedColor];
        }
            break;
            
        case RCCountDownViewStatusStopped: {
            [_timeLabel setTextColor:_stoppedColor];
        }
            break;
            
        default:
            break;
    }
}

- (NSAttributedString *)_displayStringWithTime:(NSTimeInterval)time {
    NSUInteger hours = _countDownTimeLeft / 3600;
    NSUInteger minutes = ((int)(_countDownTimeLeft) % 3600) / 60;
    NSUInteger seconds = ((int)(_countDownTimeLeft) % 60);
    NSString *hoursName = NSLocalizedStringFromTableInBundle(@"h", @"RCCountDownView", _localizationBundle,);
    NSString *minutesName = NSLocalizedStringFromTableInBundle(@"m", @"RCCountDownView", _localizationBundle,);
    NSString *secondsName = NSLocalizedStringFromTableInBundle(@"s", @"RCCountDownView", _localizationBundle,);
    
    NSMutableAttributedString *timeDisplayString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02lu%@  %02lu%@  %02lu%@", (unsigned long)hours, hoursName, (unsigned long)minutes, minutesName, (unsigned long)seconds, secondsName]];
    
    UIFont *font = [_displayTextFont fontWithSize:_fontSize / 2 - 2];
    
    [timeDisplayString addAttribute:NSFontAttributeName value:font range:NSMakeRange(2, hoursName.length)];
    [timeDisplayString addAttribute:NSFontAttributeName value:font range:NSMakeRange(6 + hoursName.length, minutesName.length)];
    [timeDisplayString addAttribute:NSFontAttributeName value:font range:NSMakeRange(timeDisplayString.length - secondsName.length, secondsName.length)];
    
    return timeDisplayString;
}

- (void)_countDown {
    if (_countDownTimeLeft > 0) {
        _countDownTimeLeft --;
        [_timeLabel setAttributedText:[self _displayStringWithTime:_countDownTimeLeft]];
        [self _refreshProgress];
    } else {
        [self stop];

        if (_countDownCompletionBlock) {
            _countDownCompletionBlock(self);
        }
    }
}

- (void)_refreshProgress {
    if (_progressViewEnabled) {
        CGRect frame = _progressLabel.frame;
        CGFloat leftTime = (_countDownTimeLeft > 0.9) ? _countDownTimeLeft : 0;
        CGFloat totalTime = (_countDownTimeTotal > 0.9 ? _countDownTimeTotal : 1);
        frame.size.width = (leftTime / totalTime) *_progressView.frame.size.width;
        [_progressLabel setFrame:frame];
        
        [_progressLabel setBackgroundColor:_progressColor];
        [_progressView setBackgroundColor:_progressBackgroundColor];
    }
}

- (void)_resumeCountDown {
    [self _countDown];
    
    if (_countDownTimeLeft) {
        [self _startTimer];
    }
}

- (void)_startTimer {
    [self _stopTimer];
    
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:RCCountDownTimeInterval target:self selector:@selector(_countDown) userInfo:nil repeats:YES];
}

- (void)_stopTimer {
    [_countDownTimer invalidate];
    _countDownTimer = nil;
}

@end
