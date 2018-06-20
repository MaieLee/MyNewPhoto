//
//  ShowPicView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/31.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "ShowPicView.h"
#import <pthread.h>

@interface ShowPicView ()
{
    pthread_mutex_t lock;
}

@property (strong, nonatomic) AVPlayer *myPlayer;//播放器
@property (strong, nonatomic) AVPlayerItem *item;//播放单元
@property (strong, nonatomic) AVPlayerLayer *playerLayer;//播放界面（layer）
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *playIco;
@property (nonatomic, strong) UIImageView *endGifImage;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) BOOL isHold;
@property (nonatomic, assign) BOOL isSavePic;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIButton *delButton;
@end

@implementation ShowPicView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2;
    _oldFrame = self.frame;
    _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4)];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_bgImageView];
    
    _playIco = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_ico"]];
    _playIco.frame = CGRectMake(0, 0, 16, 16);
    [self addSubview:_playIco];
    _playIco.center = _bgImageView.center;
    _playIco.hidden = YES;
    
    _delButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_delButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    _delButton.frame = CGRectMake(self.frame.size.width-50, self.frame.size.height-50, 48, 48);
    [self addSubview:_delButton];
    [_delButton addTarget:self action:@selector(delAction:) forControlEvents:UIControlEventTouchUpInside];
    _delButton.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(holdPicture)];
    [self addGestureRecognizer:tap];
    self.hidden = YES;
    self.alpha = 0.2;
}

- (void)showCameraImage:(UIImage *)image IsSavePic:(BOOL)isSavePic Complete:(void (^)(void))complete{
    self.hidden = NO;
    _isSavePic = isSavePic;
    if (isSavePic) {
        self.playIco.hidden = YES;
    }else{
        self.playIco.hidden = NO;
        [self addNotification];
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.bgImageView.image = image;
    self.alpha = 0.2;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
        self.timer = [NSTimer timerWithTimeInterval:3.f target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }];
}

- (void)holdPicture{
    pthread_mutex_lock(&lock);
    self.isHold = !self.isHold;
    pthread_mutex_unlock(&lock);
    
    if (self.isHold) {
        [self.timer invalidate];
        self.timer = nil;
        
        if (self.detailComplete) {
            self.detailComplete(YES);
        }
        
        self.playIco.hidden = YES;
        
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0].CGColor;
        self.backgroundColor = [UIColor clearColor];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(-2, -2, screenSize.width+4, screenSize.height+4);
            self.bgImageView.frame = CGRectMake(2,2,screenSize.width,screenSize.height);
        } completion:^(BOOL finished) {
            [self playTheVedio];
            self.delButton.hidden = NO;
            self.delButton.frame = CGRectMake(self.frame.size.width-62, self.frame.size.height-62, 60, 60);
        }];
    }else{
        if (!self.isSavePic) {
            [self.myPlayer pause];
            [self.playerLayer removeFromSuperlayer];
        }
        
        if (self.detailComplete) {
            self.detailComplete(NO);
        }
        
        self.delButton.hidden = YES;
        CGRect lastFrame = CGRectMake(self.oldFrame.origin.x, self.oldFrame.origin.y, self.oldFrame.size.width, self.oldFrame.size.height);
        if (self.isDelete) {
            CGFloat lastX = self.oldFrame.origin.x+self.oldFrame.size.width;
            CGFloat lastY = self.oldFrame.origin.y+self.oldFrame.size.height;
            lastFrame = CGRectMake(lastX, lastY, 4, 4);
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = lastFrame;
            self.bgImageView.frame = CGRectMake(2,2,lastFrame.size.width-4,lastFrame.size.height-4);
        } completion:^(BOOL finished) {
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.backgroundColor = [UIColor whiteColor];
            if (!self.isSavePic) {
                self.playIco.hidden = NO;
            }
            if (!self.isDelete) {
                self.timer = [NSTimer timerWithTimeInterval:3.f target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
            }else{
                self.isDelete = NO;
                self.hidden = YES;
                self.frame = self.oldFrame;
                self.bgImageView.frame = CGRectMake(2,2,self.oldFrame.size.width-4,self.oldFrame.size.height-4);

                self.endGifImage.hidden = NO;
                [self.endGifImage startAnimating];
            }
        }];
    }
}

- (void)playTheVedio{
    self.item = [AVPlayerItem playerItemWithURL:self.vedioURL];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = CGRectMake(0, 0, self.bgImageView.bounds.size.width, self.bgImageView.bounds.size.height);
    [self.bgImageView.layer addSublayer:self.playerLayer];
    
    [self.myPlayer play];
}

- (void)delAction:(UIButton *)btn{
    self.isDelete = YES;
    self.endGifImage.hidden = YES;
    [self holdPicture];
}

- (UIImageView *)endGifImage{
    if (_endGifImage == nil) {
        _endGifImage = [[UIImageView alloc] initWithFrame:CGRectMake(screenSize.width-35, screenSize.height-35, 35, 35)];
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:5];
        for (int i=1; i<6; i++) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"wrategit_%d",i]];
            [images addObject:img];
        }
        _endGifImage.animationImages = images;
        _endGifImage.animationDuration = 0.25;
        _endGifImage.animationRepeatCount = 1;
        
        [self.window addSubview:_endGifImage];
    }
    
    return _endGifImage;
}

- (void)timerAction
{
    if (self.isHold) {
        return;
    }
    
    pthread_mutex_lock(&lock);
    self.isHold = NO;
    pthread_mutex_unlock(&lock);
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.complete) {
        self.complete(self.isSavePic,self.bgImageView.image);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(self.frame.size.width+10, 0);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 0.2;
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    
    if (!self.isSavePic) {
        [self removeNotification];
    }
}

/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.myPlayer.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    // 播放完成后重复播放
    // 跳到最新的时间点开始播放
    [self.myPlayer seekToTime:CMTimeMake(0, 1)];
    [self.myPlayer play];
}

@end
