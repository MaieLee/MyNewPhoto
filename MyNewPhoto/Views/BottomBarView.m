//
//  BottomBarView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "BottomBarView.h"
#import "UIImage+RoundCorner.h"
#import "CameraFilterView.h"
#import "GPUImage.h"
#import "FilterSampleModel.h"
#import "FilterManager.h"
#import "MNAppDataHelper.h"

@interface BottomBarView ()<CameraFilterViewDelegate>
@property (nonatomic, strong) CameraFilterView *cameraFilterView;//自定义滤镜视图
@property (nonatomic, strong) FilterManager *filterManager;
@property (nonatomic, strong) NSMutableArray *filtersArray;
@property (nonatomic, assign) BOOL isHadLoadCameraView;
@property (nonatomic, assign) BOOL isHadHide;
@property (nonatomic, assign) BOOL isFilterPicture;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation BottomBarView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame IsFilterPic:(BOOL)isFilter{
    _isFilterPicture = isFilter;
    
    return [self initWithFrame:frame];
}

- (void)setUpUI{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [self setUpFsModels];
}

- (void)setUpFsModels
{
    if ([MNAppDataHelper shareManager].filtersArray) {
        self.filtersArray = [MNAppDataHelper shareManager].filtersArray;
        for (FilterSampleModel *fsModel in self.filtersArray) {
            fsModel.isSel = NO;
        }

        [self addSubview:self.cameraFilterView];
    }else{
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [self addSubview:self.activityIndicator];
        self.activityIndicator.frame = CGRectMake((self.frame.size.width-60)/2, (self.frame.size.height-60)/2, 60, 60);
        self.activityIndicator.color = [UIColor whiteColor];
        self.activityIndicator.hidesWhenStopped = YES;
        [self.activityIndicator startAnimating];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSInteger cameraFilterCount = self.filterManager.filterArray.count;
            NSMutableArray *filterArray = [[NSMutableArray alloc] initWithCapacity:cameraFilterCount];
            for (NSInteger index = 0; index < cameraFilterCount; index++) {
                UIImage *image = [UIImage imageNamed:@"filter"];
                FilterSampleModel *fSModel = [[FilterSampleModel alloc] init];
                fSModel.index = index;
                fSModel.filterClassName = self.filterManager.filterArray[index][@"name"];
                fSModel.desc = self.filterManager.filterArray[index][@"desc"];
                fSModel.image = [self setTheSampleImageFilter:[self.filterManager filterTheName:fSModel.filterClassName] SampleImg:image];
                fSModel.isSel = NO;
                [filterArray addObject:fSModel];
            }
            
            self.filtersArray = filterArray;
            [MNAppDataHelper shareManager].filtersArray = filterArray;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addSubview:self.cameraFilterView];
                [self.activityIndicator stopAnimating];
            });
        });
    }
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
        
        _cameraFilterView = [[CameraFilterView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 63) collectionViewLayout:layout];
        _cameraFilterView.cameraFilterDelegate = self;
        _cameraFilterView.picArray = self.filtersArray;
        if (self.isFilterPicture) {
            _cameraFilterView.textColor = [UIColor blackColor];
        }
        _cameraFilterView.backgroundColor = [UIColor clearColor];
    }
    
    return _cameraFilterView;
}

- (UIImage *)setTheSampleImageFilter:(id)filter SampleImg:(UIImage *)inputImage
{
    [filter forceProcessingAtSize:inputImage.size];
    [filter useNextFrameForImageCapture];
    
    GPUImagePicture *imageSorce = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    [imageSorce addTarget:filter];
    [imageSorce processImage];
    
    return [[filter imageFromCurrentFramebuffer] imageWithRect:CGSizeMake(42, 42)];
}

- (void)switchCameraFilter:(NSInteger)index {
    FilterSampleModel *fsModel = self.filtersArray[index];
    if (self.filterBlock) {
        self.filterBlock([self.filterManager filterTheName:fsModel.filterClassName],fsModel.desc);
    }
}

- (void)show
{
    self.isHadHide = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
    }];
}

- (void)hide
{
    if (self.isHadHide) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    } completion:^(BOOL finished) {
        self.isHadHide = YES;
    }];
}

@end
