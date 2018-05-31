//
//  CameraButtonView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/25.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "CameraButtonView.h"
#import "MNCircleView.h"
#import "MNSolidCircleView.h"

@interface CameraButtonView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) MNSolidCircleView *bgSolidCircleView;
@property (nonatomic, strong) MNCircleView *circleView;
@property (nonatomic, strong) MNSolidCircleView *upSolidCircleView;
@property (nonatomic, strong) NSTimer *recordTimer;
//@property (nonatomic, strong) NSDate *recordStartTime;
@property (nonatomic, assign) BOOL isEndRecord;
@property (nonatomic, assign) BOOL isHadStartRecord;//已经开始录制
@property (nonatomic, assign) BOOL isLongPressEnd;//长按已经结束

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;
@end

@implementation CameraButtonView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUpUI];
        [self addTapEvent];
    }
    
    return self;
}

- (void)setUpUI{
    _bgSolidCircleView = [[MNSolidCircleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) BgColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
    [self addSubview:_bgSolidCircleView];
    
    _circleView = [[MNCircleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_circleView];
    
    CGSize selfSize = self.frame.size;
    CGFloat upSolidW = selfSize.width - 24;
    _upSolidCircleView = [[MNSolidCircleView alloc] initWithFrame:CGRectMake((selfSize.width-upSolidW)/2, (selfSize.width-upSolidW)/2, upSolidW, upSolidW) BgColor:[UIColor whiteColor]];
    [self addSubview:_upSolidCircleView];
}

- (void)addTapEvent
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePicture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    self.tapGesture = tapGesture;
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(takeVideo:)];
    longGesture.minimumPressDuration = 0.4;
    longGesture.allowableMovement = 100;
    longGesture.delegate = self;
    [self addGestureRecognizer:longGesture];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    self.circleView.progress = progress;
}

#pragma mark -- 手势识别
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if ([_longGesture isEqual:gestureRecognizer]) {
        return [_tapGesture isEqual:otherGestureRecognizer];
    }
    
    if ([_tapGesture isEqual:gestureRecognizer]) {
        return [_longGesture isEqual:otherGestureRecognizer];
    }
    
    return NO;
}

- (void)takePicture:(UITapGestureRecognizer *)renderer{
    NSLog(@"takePicture");
    
    [UIView animateWithDuration:0.2 animations:^{
        self.upSolidCircleView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    } completion:^(BOOL finished) {
        self.upSolidCircleView.transform = CGAffineTransformMakeScale(1, 1);
        if (self.takePicture) {
            self.takePicture();
        }
    }];
}

- (void)finishSavePic{
//    self.upSolidCircleView.transform = CGAffineTransformMakeScale(1, 1);
}

- (void)takeVideo:(UILongPressGestureRecognizer *)renderer{
    if (renderer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按手势开启");
        self.isEndRecord = NO;
        self.isLongPressEnd = NO;
        if (self.takeVideo) {
            self.takeVideo(0);
        }
    } else if (renderer.state == UIGestureRecognizerStateEnded){
        NSLog(@"长按手势结束");
        self.isLongPressEnd = YES;
        [self stopRecord];
    }
}

- (void)startRecord{
    self.isHadStartRecord = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.bgSolidCircleView.transform = CGAffineTransformMakeScale(1.6, 1.6);
        self.upSolidCircleView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        self.circleView.transform = CGAffineTransformMakeScale(1.6, 1.6);
    } completion:^(BOOL finished) {
        if (self.isLongPressEnd) {
            if (self.takeVideo) {
                self.takeVideo(3);
            }
            [self finishSaveVideo];
        }else{
            if (self.takeVideo) {
                self.takeVideo(1);
            }
            
            NSTimeInterval timeInterval = 0.1f;
            self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                                target:self
                                                              selector:@selector(updateProgress)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    }];
}

- (void)updateProgress
{
    self.circleView.progress += 0.01;
    
    if (self.circleView.progress >= 1) {
        [self stopRecord];
    }
}

- (void)stopRecord
{
    if (!self.isHadStartRecord) {
        return;
    }
    self.isHadStartRecord = NO;
    
    if (self.isEndRecord) {
        return;
    }
    self.isEndRecord = YES;
    
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    
    if (self.takeVideo) {
        self.takeVideo(2);
    }
}

- (void)finishSaveVideo
{
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    
    self.bgSolidCircleView.transform = CGAffineTransformMakeScale(1, 1);
    self.upSolidCircleView.transform = CGAffineTransformMakeScale(1, 1);
    self.circleView.transform = CGAffineTransformMakeScale(1, 1);
    self.circleView.progress = 0;
}

@end
