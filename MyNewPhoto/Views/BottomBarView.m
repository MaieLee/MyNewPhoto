//
//  BottomBarView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "BottomBarView.h"
#import "DrawCyclesButton.h"
#import "CyclesView.h"
#import "UIImage+RoundCorner.h"
#import "CameraFilterView.h"
#import "GPUImage.h"
#import "FilterSampleModel.h"

static int CameraFilterCount = 10;//滤镜的数量

@interface BottomBarView ()<CameraFilterViewDelegate>
@property (nonatomic, strong) UIView *moView;
@property (nonatomic, strong) DrawCyclesButton *camera;
@property (nonatomic, strong) CameraFilterView *cameraFilterView;//自定义滤镜视图
@end

@implementation BottomBarView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)setUpUI{
    UIView *moView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:moView];
    self.moView = moView;
    
    _camera = [[DrawCyclesButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 110, 76, 76)];
    [moView addSubview:_camera];
    _camera.center = CGPointMake(moView.center.x, _camera.center.y);
    [_camera addTarget:self action:@selector(drawColor) forControlEvents:UIControlEventTouchUpInside];
    
    CyclesView *cyclesView = [[CyclesView alloc] initWithFrame:CGRectMake(20, 0, 36, 36)];
    [moView addSubview:cyclesView];
    cyclesView.center = CGPointMake(cyclesView.center.x, _camera.center.y);
    cyclesView.backgroundColor = mnColor(0, 0, 0, 0);
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    [moView insertSubview:_imgView belowSubview:cyclesView];
    _imgView.center = cyclesView.center;
    
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [cyclesView addSubview:_activityIndicator];
    _activityIndicator.frame = (CGRect){0,0,cyclesView.frame.size};
    _activityIndicator.hidesWhenStopped = YES;
    
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn setBackgroundImage:[UIImage createFilterImage] forState:UIControlStateNormal];
    [moView addSubview:filterBtn];
    filterBtn.frame = CGRectMake(self.frame.size.width-60, 0, 40, 20);
    filterBtn.center = CGPointMake(filterBtn.center.x, _camera.center.y);
    
    [filterBtn addTarget:self action:@selector(filtersAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (CameraFilterView *)cameraFilterView{
    if (_cameraFilterView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _cameraFilterView = [[CameraFilterView alloc] initWithFrame:CGRectMake(0, -55, self.frame.size.width, 40) collectionViewLayout:layout];
        NSMutableArray *filterNameArray = [[NSMutableArray alloc] initWithCapacity:CameraFilterCount];
        for (NSInteger index = 0; index < CameraFilterCount; index++) {
            UIImage *image = [[UIImage imageNamed:@"filter"] imageWithRect:CGSizeMake(42, 42)];
            
            FilterSampleModel *fSModel = [[FilterSampleModel alloc] init];
            fSModel.index = index;
            fSModel.image = [self setTheSampleImageFilter:index SampleImg:image];
            fSModel.isSel = NO;
            [filterNameArray addObject:fSModel];
        }
        _cameraFilterView.cameraFilterDelegate = self;
        _cameraFilterView.picArray = filterNameArray;
        _cameraFilterView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_cameraFilterView];
    }
    
    return _cameraFilterView;
}

- (UIImage *)setTheSampleImageFilter:(NSInteger)index SampleImg:(UIImage *)inputImage
{
    GPUImageFilter *filter = [self filterTheImage:index];
    
    [filter forceProcessingAtSize:CGSizeMake(120, 120)];
    [filter useNextFrameForImageCapture];
    
    GPUImagePicture *imageSorce = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    [imageSorce addTarget:filter];
    [imageSorce processImage];
    
    return [filter imageFromCurrentFramebuffer];
}

- (void)switchCameraFilter:(NSInteger)index {
    GPUImageFilter *filter = [self filterTheImage:index];
    if (self.filterBlock) {
        self.filterBlock(filter);
    }
}

- (GPUImageFilter *)filterTheImage:(NSInteger)index{
    GPUImageFilter *_filter;
    switch (index) {
        case 0:
            _filter = [[GPUImageFilter alloc] init];//原图
            break;
        case 1:
            _filter = [[GPUImageHueFilter alloc] init];//绿巨人
            break;
        case 2:
            _filter = [[GPUImageColorInvertFilter alloc] init];//负片
            break;
        case 3:
            _filter = [[GPUImageSepiaFilter alloc] init];//老照片
            break;
        case 4: {
            _filter = [[GPUImageGaussianBlurPositionFilter alloc] init];
            [(GPUImageGaussianBlurPositionFilter*)_filter setBlurRadius:40.0/320.0];
        }
            break;
        case 5:
            _filter = [[GPUImageToonFilter alloc] init];//素描
            break;
        case 6:
            _filter = [[GPUImageVignetteFilter alloc] init];//黑晕
            break;
        case 7:
            _filter = [[GPUImageGrayscaleFilter alloc] init];//灰度
            break;
        case 8:
        {
            _filter = [[GPUImageGammaFilter alloc] init];//卡通效果 黑色粗线描边
            [(GPUImageGammaFilter *)_filter setGamma:2];
        }
            break;
        case 9:
        {
            _filter = [[GPUImageLuminanceThresholdFilter alloc] init];
        }
            break;
        default:
            _filter = [[GPUImageFilter alloc] init];
            break;
    }
    
    return _filter;
}

- (void)filtersAction:(UIButton *)sender
{
    [sender setSelected:!sender.isSelected];
    if (sender.isSelected) {
        self.cameraFilterView.hidden = NO;
        [UIView animateWithDuration:0.1 delay:0.2 options:0 animations:^{
            self.cameraFilterView.transform = CGAffineTransformMakeTranslation(0, 70);
            self.moView.transform = CGAffineTransformMakeTranslation(0, 25);
            self.camera.transform = CGAffineTransformMakeScale(0.85, 0.85);
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.1 delay:0.2 options:0 animations:^{
            self.cameraFilterView.transform = CGAffineTransformMakeTranslation(0, -70);
            self.moView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.camera.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.cameraFilterView.hidden = YES;
        }];
    }
}

- (void)drawColor{
    if (self.picBlock) {
        self.picBlock();
    }
}

@end
