//
//  PictureFilterViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/15.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "PictureFilterViewController.h"
#import "BottomBarView.h"
#import "GPUImage.h"

@interface PictureFilterViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *pictureImageView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) BottomBarView *bottomView;
@property (nonatomic, assign) BOOL isHiddenView;
@property (nonatomic, assign) BOOL isLessthen;
@property (nonatomic, strong) UILabel *lblDesc;
@property (strong, nonatomic) AVPlayer *myPlayer;//播放器
@property (strong, nonatomic) AVPlayerItem *item;//播放单元
@property (strong, nonatomic) AVPlayerLayer *playerLayer;//播放界面（layer）
@end

@implementation PictureFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.pictureImageView = [[UIImageView alloc] initWithImage:self.picture];
    self.pictureImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.pictureImageView.frame = self.view.frame;
    self.pictureImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.pictureImageView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 68)];
    [self.view addSubview:headerView];
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10, 0, 40, 40);
    [headerView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.center = CGPointMake(backBtn.center.x, headerView.center.y);
    self.headerView = headerView;
    
    if (self.isVideo) {
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.tag = 1001;
        [playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [playBtn sizeToFit];
        [self.view addSubview:playBtn];
        playBtn.center = self.view.center;
        [playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        
        self.item = [AVPlayerItem playerItemWithURL:self.videoURL];
        self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
        self.playerLayer.frame = CGRectMake(0, 0, self.pictureImageView.bounds.size.width, self.pictureImageView.bounds.size.height);
        [self.pictureImageView.layer addSublayer:self.playerLayer];
        
        [self addNotification];
    }else{
        WEAKSELF
        _bottomView = [[BottomBarView alloc] initWithFrame:CGRectMake(0, screenSize.height-63, screenSize.width, 63)];
        _bottomView.isFilterPicture = YES;
        _bottomView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        [self.view addSubview:_bottomView];
        
        _bottomView.filterBlock = ^(id filter, NSString *desc) {
            [weakSelf showFilters:filter Desc:desc];
        };
        
        self.lblDesc = [UILabel new];
        self.lblDesc.font = mnFont(26);
        self.lblDesc.textColor = [UIColor whiteColor];
        [self.view addSubview:self.lblDesc];
        self.lblDesc.hidden = YES;
        
        [self addGestureRecognizer];
    }
}

// 添加所有的手势
- (void)addGestureRecognizer
{
    //点击
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.pictureImageView addGestureRecognizer:tapGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    pinchGestureRecognizer.delegate = self;
    [self.pictureImageView addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.pictureImageView addGestureRecognizer:panGestureRecognizer];
}

#pragma mark 手势处理
- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat width = self.pictureImageView.frame.size.width*pinchGestureRecognizer.scale;
        if (width < screenSize.width*2) {
            self.pictureImageView.transform = CGAffineTransformScale(self.pictureImageView.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        }
        pinchGestureRecognizer.scale = 1;
    }
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.isLessthen = self.pictureImageView.frame.size.width > screenSize.width?NO:YES;
        if (self.isLessthen) {
            [UIView animateWithDuration:0.2 animations:^{
                self.pictureImageView.frame = self.view.frame;
            }];
        }
    }
}

- (void)tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    self.isHiddenView = !self.isHiddenView;
    if (self.isHiddenView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.transform = CGAffineTransformMakeTranslation(0, -68);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 63);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }
}

- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (!self.isLessthen) {
            CGPoint translation = [panGestureRecognizer translationInView:self.pictureImageView.superview];
            CGFloat pointX = self.pictureImageView.center.x + translation.x;
            CGFloat pointY = self.pictureImageView.center.y + translation.y;
            
            CGFloat gapX = (self.pictureImageView.frame.size.width-self.view.frame.size.width)/2;
            CGFloat gapY = (self.pictureImageView.frame.size.height-self.view.frame.size.height)/2;
            CGFloat translationMinX = self.view.center.x-gapX;
            CGFloat translationMaxX = self.view.center.x+gapX;
            CGFloat translationMinY = self.view.center.y-gapY;
            CGFloat translationMaxY = self.view.center.y+gapY;
            
            if (pointX>translationMinX && pointX<translationMaxX && pointY>translationMinY && pointY<translationMaxY) {
                CGPoint translationCenter = (CGPoint){pointX, pointY};
                [self.pictureImageView setCenter:translationCenter];
            }
            
            [panGestureRecognizer setTranslation:CGPointZero inView:self.pictureImageView.superview];
        }
    }
    
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)play:(UIButton *)btn{
    btn.selected = !btn.isSelected;
    if (btn.isSelected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.transform = CGAffineTransformMakeTranslation(0, -68);
            btn.alpha = 0;
        } completion:^(BOOL finished) {
            btn.center = CGPointMake(self.view.frame.size.width-btn.frame.size.width/2-10, self.view.frame.size.height-btn.frame.size.height/2-10);
            [btn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.2 animations:^{
                btn.alpha = 1;
            }];
        }];
        [self.myPlayer play];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            btn.alpha = 0;
        } completion:^(BOOL finished) {
            btn.center = self.view.center;
            [btn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.2 animations:^{
                self.headerView.transform = CGAffineTransformMakeTranslation(0, 0);
                btn.alpha = 1;
            }];
        }];
        
        [self.myPlayer pause];
    }
}

- (void)showFilters:(id)filter Desc:(NSString *)desc
{
    GPUImagePicture *imageSorce = [[GPUImagePicture alloc] initWithImage:self.picture smoothlyScaleOutput:YES];
    [imageSorce addTarget:filter];
    [imageSorce processImage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *filterImage = [filter imageFromCurrentFramebuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pictureImageView.image = filterImage;
        });
    });
 
    self.lblDesc.hidden = NO;
    self.lblDesc.text = desc;
    [self.lblDesc sizeToFit];
    self.lblDesc.center = self.view.center;
    [UIView animateWithDuration:0.6 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.lblDesc.transform = CGAffineTransformMakeScale(1.6, 1.6);
        self.lblDesc.alpha = 0.1;
    } completion:^(BOOL finished) {
        self.lblDesc.transform = CGAffineTransformMakeScale(1, 1);
        self.lblDesc.hidden = YES;
        self.lblDesc.alpha = 1;
    }];
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
    [self.myPlayer seekToTime:CMTimeMake(0, 1)];
    [self.myPlayer pause];
    
    UIButton *playBtn = (UIButton *)[self.view viewWithTag:1001];
    playBtn.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        playBtn.alpha = 0;
    } completion:^(BOOL finished) {
        playBtn.center = self.view.center;
        [playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.transform = CGAffineTransformMakeTranslation(0, 0);
            playBtn.alpha = 1;
        }];
    }];
}

- (void)dealloc{
    [self.myPlayer pause];
    [self.playerLayer removeFromSuperlayer];
    self.myPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
