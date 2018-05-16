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
#import "FilterManager.h"
#import "MNImagePickerViewController.h"
#import "MNGetPhotoAlbums.h"

@interface BottomBarView ()<CameraFilterViewDelegate>
@property (nonatomic, strong) UIView *moView;
@property (nonatomic, strong) DrawCyclesButton *camera;
@property (nonatomic, strong) CameraFilterView *cameraFilterView;//自定义滤镜视图
@property (nonatomic, strong) FilterManager *filterManager;
@property (nonatomic, strong) NSMutableArray *filtersArray;
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
    
    [cyclesView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerVc:)]];
    
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
    
    [self setUpFsModels];
}

- (void)setUpFsModels
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger cameraFilterCount = self.filterManager.filterArray.count;
        NSMutableArray *filterArray = [[NSMutableArray alloc] initWithCapacity:cameraFilterCount];
        for (NSInteger index = 0; index < cameraFilterCount; index++) {
            UIImage *image = [UIImage imageNamed:@"filter"];
            FilterSampleModel *fSModel = [[FilterSampleModel alloc] init];
            fSModel.index = index;
            fSModel.filter = [self.filterManager filterTheImage:index];
            fSModel.image = [self setTheSampleImageFilter:[self.filterManager filterTheImage:index] SampleImg:image];
            fSModel.isSel = NO;
            fSModel.desc = self.filterManager.filterArray[index][@"desc"];
            [filterArray addObject:fSModel];
        }
        
        self.filtersArray = filterArray;
    });
}

- (FilterManager *)filterManager{
    if(_filterManager == nil){
        _filterManager = [[FilterManager alloc] init];
    }
    
    return _filterManager;
}

- (CameraFilterView *)cameraFilterView{
    if (_cameraFilterView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _cameraFilterView = [[CameraFilterView alloc] initWithFrame:CGRectMake(0, -63, self.frame.size.width, 63) collectionViewLayout:layout];
        _cameraFilterView.cameraFilterDelegate = self;
        _cameraFilterView.picArray = self.filtersArray;
        _cameraFilterView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_cameraFilterView];
    }
    
    return _cameraFilterView;
}

- (UIImage *)setTheSampleImageFilter:(id)filter SampleImg:(UIImage *)inputImage
{
    [filter forceProcessingAtSize:CGSizeMake(120, 120)];
    [filter useNextFrameForImageCapture];
    
    GPUImagePicture *imageSorce = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    [imageSorce addTarget:filter];
    [imageSorce processImage];
    
    return [[filter imageFromCurrentFramebuffer] imageWithRect:CGSizeMake(42, 42)];
}

- (void)switchCameraFilter:(NSInteger)index {
    FilterSampleModel *fsModel = self.filtersArray[index];
    if (self.filterBlock) {
        self.filterBlock(fsModel.filter,fsModel.desc);
    }
}

- (void)filtersAction:(UIButton *)sender
{
    [sender setSelected:!sender.isSelected];
    if (sender.isSelected) {
        self.cameraFilterView.hidden = NO;
        [UIView animateWithDuration:0.1 delay:0.2 options:0 animations:^{
            self.cameraFilterView.transform = CGAffineTransformMakeTranslation(0, 70);
            self.moView.transform = CGAffineTransformMakeTranslation(0, 28);
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

- (void)showPickerVc:(id)recognizer{
    if ([MNGetPhotoAlbums authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if ([MNGetPhotoAlbums authorizationStatus] == 0) { // 未请求过相册权限
        [[MNGetPhotoAlbums shareManager] requestAuthorizationWithCompletion:^{
            [self showPickerVc:nil];
        }];
    }else{
        MNImagePickerViewController *imagePickerVc = [[MNImagePickerViewController alloc] init];
        [self.parentVC presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

@end
