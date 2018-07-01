//
//  VideoFilterViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/6/25.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "VideoFilterViewController.h"
#import "BottomBarView.h"

@interface VideoFilterViewController ()
@property (nonatomic, strong) GPUImageMovie * gpuMovie;//接管视频数据
@property (nonatomic, strong) GPUImageView * gpuView;//预览视频内容
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *selFilter;//视频滤镜
@property (nonatomic, strong) GPUImageMovieWriter * movieWriter;//视频处理输出
@property (nonatomic, strong) GPUImagePicture *imageSource;
@property (nonatomic, strong) NSMutableDictionary *filterImageDictionary;
@property (nonatomic, copy)   NSString *fileSavePath;//视频合成后存储路径
@property (nonatomic, strong) UIImageView *pictureImageView;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *bottomView;
@property (strong, nonatomic) AVPlayer *myPlayer;//播放器
@property (strong, nonatomic) AVPlayerItem *playItem;//播放单元
@property (nonatomic, strong) AVAsset *asset;
@end

@implementation VideoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.pictureImageView = [[UIImageView alloc] initWithImage:self.picture];
    self.pictureImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.pictureImageView.frame = self.view.frame;
    self.pictureImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.pictureImageView];
    
    _gpuView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    _gpuView.fillMode = kGPUImageFillModePreserveAspectRatio;
    _gpuView.hidden = YES;
    [self.view addSubview:_gpuView];
    _playItem = [[AVPlayerItem alloc] initWithURL:self.videoURL];
    _myPlayer = [AVPlayer playerWithPlayerItem:_playItem];
    
    _gpuMovie = [[GPUImageMovie alloc] initWithPlayerItem:self.playItem];
    [_gpuMovie addTarget:_gpuView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 68)];
    [self.view addSubview:headerView];
    headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(10, 0, 40, 40);
    [headerView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.center = CGPointMake(backBtn.center.x, headerView.center.y);
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    shareBtn.frame = CGRectMake(screenSize.width-50, 0, 40, 40);
    [headerView addSubview:shareBtn];
    [shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.center = CGPointMake(shareBtn.center.x, headerView.center.y);
    self.headerView = headerView;
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.tag = 1001;
    [playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [playBtn sizeToFit];
    [self.view addSubview:playBtn];
    playBtn.center = self.view.center;
    [playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, screenSize.height-63, screenSize.width, 68)];
    _bottomView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.view addSubview:_bottomView];
    
    WEAKSELF
    BottomBarView *bottomFilterView = [[BottomBarView alloc] initWithFrame:CGRectMake(0, 5, _bottomView.frame.size.width-_bottomView.frame.size.height, _bottomView.frame.size.height-5) IsFilterPic:YES];
    bottomFilterView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    [_bottomView addSubview:bottomFilterView];
    bottomFilterView.filterBlock = ^(id filter, NSString *desc) {
        [weakSelf showFilters:filter Desc:desc];
    };
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    saveBtn.frame = CGRectMake(_bottomView.frame.size.width-_bottomView.frame.size.height, 0, _bottomView.frame.size.height, _bottomView.frame.size.height);
    saveBtn.backgroundColor = [UIColor yellowColor];
    [_bottomView addSubview:saveBtn];
    [saveBtn addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.enabled = NO;
    self.saveBtn = saveBtn;
    
    self.imageSource = [[GPUImagePicture alloc] initWithImage:self.picture];
    self.filterImageDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [self addNotification];
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.videoAsset options:[PHVideoRequestOptions new] resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.asset = avasset;
        });
    }];
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction:(id)sender{
    NSString *info = @"来自情迷相机的分享";
    NSMutableArray *possItems = [NSMutableArray arrayWithCapacity:3];
    [possItems addObject:info];
    [possItems addObject:self.pictureImageView.image];
    [possItems addObject:self.videoURL];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:possItems applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
}

- (void)play:(UIButton *)btn{
    btn.selected = !btn.isSelected;
    if (btn.isSelected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.headerView.transform = CGAffineTransformMakeTranslation(0, -68);
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 68);
            btn.alpha = 0;
        } completion:^(BOOL finished) {
            btn.center = CGPointMake(self.view.frame.size.width-btn.frame.size.width/2-10, self.view.frame.size.height-btn.frame.size.height/2-10);
            [btn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.2 animations:^{
                btn.alpha = 1;
            }];
        }];
        
        [self.gpuMovie startProcessing];
        [self.myPlayer play];
        self.pictureImageView.hidden = YES;
        self.gpuView.hidden = NO;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            btn.alpha = 0;
        } completion:^(BOOL finished) {
            btn.center = self.view.center;
            [btn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.2 animations:^{
                self.headerView.transform = CGAffineTransformMakeTranslation(0, 0);
                self.bottomView.transform = CGAffineTransformMakeTranslation(0, 0);
                btn.alpha = 1;
            }];
        }];
        
        [self.myPlayer pause];
    }
}

- (void)showFilters:(id)filter Desc:(NSString *)desc
{
    self.selFilter = filter;
    [_gpuMovie cancelProcessing];
    [_gpuMovie removeAllTargets];
    [_gpuMovie addTarget:self.selFilter];
    [self.selFilter addTarget:_gpuView];
    
    if ([desc isEqualToString:@"原图"]) {
        self.saveBtn.enabled = NO;
        self.pictureImageView.image = self.picture;
    }else{
        self.saveBtn.enabled = YES;
        UIImage *filterImage = nil;
        if ([self.filterImageDictionary.allKeys containsObject:desc]) {
            filterImage = [self.filterImageDictionary objectForKey:desc];
            self.pictureImageView.image = filterImage;
        }else{
            [self.imageSource removeAllTargets];
            [filter forceProcessingAtSize:self.picture.size];
            [self.imageSource addTarget:filter];
            [filter useNextFrameForImageCapture];
            [self.imageSource processImage];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage *filterImage = [filter imageFromCurrentFramebuffer];
                UIImage *resultImage = [UIImage imageWithData:UIImageJPEGRepresentation(filterImage, 0.3)];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (resultImage) {
                        [self.filterImageDictionary setObject:resultImage forKey:desc];
                        self.pictureImageView.image = resultImage;
                    }
                });
            });
        }
    }
}

#pragma mark -----------------------------视频存放位置------------------------
- (NSString *)fileSavePath{
    _fileSavePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"FilterMovie.m4v"];
    // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    unlink([_fileSavePath UTF8String]);
    NSLog(@"视频输出地址 fileSavePath = %@",_fileSavePath);
    
    return _fileSavePath;
}

#pragma mark ----------------------------合成视频点击事件-------------------------
- (void)saveAction:(id)sender{
    [self showLoadingHUD:nil];
    NSURL *movieURL = [NSURL fileURLWithPath:self.fileSavePath];
    
    GPUImageMovie *movieFile = [[GPUImageMovie alloc] initWithAsset:self.asset];
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(self.picture.size.width, self.picture.size.height)];//视频存放路径及输出视频宽高
    [movieFile addTarget:self.selFilter];
    
    self.movieWriter.shouldPassthroughAudio = YES;
    if ([[self.asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
        movieFile.audioEncodingTarget = self.movieWriter;
    } else {//no audio
        movieFile.audioEncodingTarget = nil;
    }
    
    [movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];
    [self.selFilter addTarget:self.movieWriter];
    [self.movieWriter startRecording];
    [movieFile startProcessing];
    
    WEAKSELF
    [self.movieWriter setFailureBlock:^(NSError *error) {
        NSLog(@"合成失败 173：error = %@",error.description);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoadingHUD:@"保存失败"];
            [weakSelf.selFilter removeTarget:weakSelf.movieWriter];
            [weakSelf.movieWriter finishRecording];
        });
    }];
    
    [self.movieWriter setCompletionBlock:^{
        NSLog(@"视频合成结束: 188 ");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoadingHUD:@"保存成功"];
            [weakSelf.selFilter removeTarget:weakSelf.movieWriter];
            [weakSelf.movieWriter finishRecording];
        });
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
            self.bottomView.transform = CGAffineTransformMakeTranslation(0, 0);
            playBtn.alpha = 1;
        }];
    }];
    
    self.pictureImageView.hidden = NO;
    self.gpuView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
