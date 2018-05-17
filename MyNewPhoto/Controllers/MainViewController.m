//
//  MainViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/3.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MainViewController.h"
#import "GPUImage.h"
#import "ToolBarView.h"
#import "BottomBarView.h"
#import "UIImage+RoundCorner.h"
#import "GPUImageBeautifyFilter.h"

//闪光灯状态
typedef NS_ENUM(NSInteger, CameraManagerFlashMode) {
    CameraManagerFlashModeAuto, /**<自动*/
    CameraManagerFlashModeOff, /**<关闭*/
    CameraManagerFlashModeOn /**<打开*/
};

@interface MainViewController ()<UIGestureRecognizerDelegate,CAAnimationDelegate>
{
    CALayer *_focusLayer; //聚焦层
}

@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageStillCamera *gpuStillCamera;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong) BottomBarView *bottomView;
@property (nonatomic, strong) UISlider *brightnessSilder;
@property (nonatomic, assign) CGFloat beginGestureScale;//开始的缩放比例
@property (nonatomic, assign) CGFloat effectiveScale;//最后的缩放比例
@property (nonatomic, assign) CameraManagerFlashMode flashMode;
@property (nonatomic, strong) UILabel *lblDesc;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpUI];
    [self setUpCamera];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setUpUI{
    self.gpuImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-150)];
//    [self.view addSubview:self.gpuImageView];
    
    ToolBarView *toolView = [[ToolBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
    [self.view addSubview:toolView];
    WEAKSELF
    toolView.cameraBlock = ^(NSInteger cameraType) {
        [weakSelf changeCamera];
    };
    
    _bottomView = [[BottomBarView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-150, self.view.frame.size.width, 150)];
    [self.view addSubview:_bottomView];
    _bottomView.picBlock = ^{
        [weakSelf takePicture];
    };
    _bottomView.filterBlock = ^(id filter, NSString *desc){
        [weakSelf showFilters:filter Desc:desc];
    };
    _bottomView.parentVC = self;
    
    self.lblDesc = [UILabel new];
    self.lblDesc.font = mnFont(26);
    self.lblDesc.textColor = [UIColor whiteColor];
    [self.view addSubview:self.lblDesc];
    self.lblDesc.hidden = YES;
    
    [self setfocusImage:[UIImage createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(60, 60)]];
    
    //初始化闪光灯模式为Auto
    [self setFlashMode:CameraManagerFlashModeAuto];
    //初始化开始及结束的缩放比例都为1.0
    [self setBeginGestureScale:1.0f];
    [self setEffectiveScale:1.0f];
    
    _brightnessSilder = [[UISlider alloc] initWithFrame:CGRectMake(self.view.frame.size.width-130, 260, 214, 18)];
    //设置旋转90度
    _brightnessSilder.transform = CGAffineTransformMakeRotation(-1.57079633);
    _brightnessSilder.value=0;
    _brightnessSilder.minimumValue=-1.0;
    _brightnessSilder.maximumValue=1.0;
    _brightnessSilder.minimumTrackTintColor = [UIColor whiteColor];
    _brightnessSilder.maximumTrackTintColor = [UIColor whiteColor];
    _brightnessSilder.alpha = 0.5;
    [self.view addSubview:_brightnessSilder];
    
    [_brightnessSilder addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

}

- (void)sliderValueChanged:(UISlider *)slider
{
    _brightnessFilter.brightness = slider.value;
}

- (void)setUpCamera{
    self.gpuStillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.gpuStillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.gpuStillCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.gpuStillCamera.horizontallyMirrorRearFacingCamera  = NO;
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    // 美白滤镜-- 亮度 亮度：调整亮度（-1.0 - 1.0，默认为0.0）
    _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
//    GPUImageSmoothToonFilter *smoothToonFilter = [[GPUImageSmoothToonFilter alloc] init];
    [self.gpuStillCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:_brightnessFilter];
    [_brightnessFilter addTarget:self.gpuImageView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.gpuStillCamera startCameraCapture];
    });
}

- (void)changeCamera{
    [self.gpuStillCamera rotateCamera];
}

//设置聚焦图片
- (void)setfocusImage:(UIImage *)focusImage {
    if (!focusImage) return;
    
    if (!_focusLayer) {
        //增加tap手势，用于聚焦及曝光
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus:)];
        [self.gpuImageView addGestureRecognizer:tap];
        //增加pinch手势，用于调整焦距
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(focusDisdance:)];
        [self.gpuImageView addGestureRecognizer:pinch];
        pinch.delegate = self;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
    imageView.image = focusImage;
    CALayer *layer = imageView.layer;
    layer.hidden = YES;
    [self.gpuImageView.layer addSublayer:layer];
    _focusLayer = layer;
    
}

//调整焦距方法
-(void)focusDisdance:(UIPinchGestureRecognizer*)pinch {
    self.effectiveScale = self.beginGestureScale * pinch.scale;
    if (self.effectiveScale < 1.0f) {
        self.effectiveScale = 1.0f;
    }
    CGFloat maxScaleAndCropFactor = 3.0f;//设置最大放大倍数为3倍
    if (self.effectiveScale > maxScaleAndCropFactor)
        self.effectiveScale = maxScaleAndCropFactor;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    NSError *error;
    if([self.gpuStillCamera.inputCamera lockForConfiguration:&error]){
        [self.gpuStillCamera.inputCamera setVideoZoomFactor:self.effectiveScale];
        [self.gpuStillCamera.inputCamera unlockForConfiguration];
    }
    else {
        NSLog(@"ERROR = %@", error);
    }
    
    [CATransaction commit];
}

//手势代理方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

//对焦方法
- (void)focus:(UITapGestureRecognizer *)tap {
    self.gpuImageView.userInteractionEnabled = NO;
    CGPoint touchPoint = [tap locationInView:tap.view];
    [self layerAnimationWithPoint:touchPoint];
    /**
     *下面是照相机焦点坐标轴和屏幕坐标轴的映射问题，这个坑困惑了我好久，花了各种方案来解决这个问题，以下是最简单的解决方案也是最准确的坐标转换方式
     */
    if(_gpuStillCamera.cameraPosition == AVCaptureDevicePositionBack){
        touchPoint = CGPointMake( touchPoint.y /tap.view.bounds.size.height ,1-touchPoint.x/tap.view.bounds.size.width);
    }
    else
        touchPoint = CGPointMake(touchPoint.y /tap.view.bounds.size.height ,touchPoint.x/tap.view.bounds.size.width);
    /*以下是相机的聚焦和曝光设置，前置不支持聚焦但是可以曝光处理，后置相机两者都支持，下面的方法是通过点击一个点同时设置聚焦和曝光，当然根据需要也可以分开进行处理
     */
    if([self.gpuStillCamera.inputCamera isExposurePointOfInterestSupported] && [self.gpuStillCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    {
        NSError *error;
        if ([self.gpuStillCamera.inputCamera lockForConfiguration:&error]) {
            [self.gpuStillCamera.inputCamera setExposurePointOfInterest:touchPoint];
            [self.gpuStillCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            if ([self.gpuStillCamera.inputCamera isFocusPointOfInterestSupported] && [self.gpuStillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [self.gpuStillCamera.inputCamera setFocusPointOfInterest:touchPoint];
                [self.gpuStillCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            }
            [self.gpuStillCamera.inputCamera unlockForConfiguration];
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
}

//对焦动画
- (void)layerAnimationWithPoint:(CGPoint)point {
    if (_focusLayer) {
        //聚焦点聚焦动画设置
        CALayer *focusLayer = _focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.delegate = self;
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
    }
}

//动画的delegate方法
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // 1秒钟延时
    [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:0.5f];
}

//focusLayer回到初始化状态
- (void)focusLayerNormal {
    self.gpuImageView.userInteractionEnabled = YES;
    _focusLayer.hidden = YES;
}

//设置闪光灯模式
- (void)setFlashMode:(CameraManagerFlashMode)flashMode {
    _flashMode = flashMode;
    
    switch (flashMode) {
        case CameraManagerFlashModeAuto: {
            [self.gpuStillCamera.inputCamera lockForConfiguration:nil];
            if ([self.gpuStillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [self.gpuStillCamera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
            }
            [self.gpuStillCamera.inputCamera unlockForConfiguration];
        }
            break;
        case CameraManagerFlashModeOff: {
            [self.gpuStillCamera.inputCamera lockForConfiguration:nil];
            [self.gpuStillCamera.inputCamera setFlashMode:AVCaptureFlashModeOff];
            [self.gpuStillCamera.inputCamera unlockForConfiguration];
        }
            
            break;
        case CameraManagerFlashModeOn: {
            [self.gpuStillCamera.inputCamera lockForConfiguration:nil];
            [self.gpuStillCamera.inputCamera setFlashMode:AVCaptureFlashModeOn];
            [self.gpuStillCamera.inputCamera unlockForConfiguration];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 改变闪光灯状态
- (void)changeFlashMode:(UIButton *)button {
    switch (self.flashMode) {
        case CameraManagerFlashModeAuto:
            self.flashMode = CameraManagerFlashModeOn;
            [button setImage:[UIImage imageNamed:@"flashing_on"] forState:UIControlStateNormal];
            break;
        case CameraManagerFlashModeOff:
            self.flashMode = CameraManagerFlashModeAuto;
            [button setImage:[UIImage imageNamed:@"flashing_auto"] forState:UIControlStateNormal];
            break;
        case CameraManagerFlashModeOn:
            self.flashMode = CameraManagerFlashModeOff;
            [button setImage:[UIImage imageNamed:@"flashing_off"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)takePicture{
    [self.bottomView.activityIndicator startAnimating];
    
    [self.gpuStillCamera capturePhotoAsImageProcessedUpToFilter:_brightnessFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(saveImage:didFinishSavingWithError:contextInfo:), nil);
    }];
}

- (void)saveImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    CGSize imgSize = self.bottomView.imgView.frame.size;
    UIImage *thumImg = [UIImage thumbnailWithImage:image size:imgSize];
    self.bottomView.imgView.image = [thumImg imageWithRect:imgSize];
    [self.bottomView.activityIndicator stopAnimating];
    if(!error) {
        NSLog(@"保存成功！");
    }else{
        NSLog(@"保存失败！");
    }
}

- (void)showFilters:(id)filter Desc:(NSString *)desc
{
    [self.gpuStillCamera removeAllTargets];
    GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    bilateralFilter.distanceNormalizationFactor = 9.0;
    
    [self.gpuStillCamera addTarget:filter];
    [filter addTarget:bilateralFilter];
    [bilateralFilter addTarget:_brightnessFilter];
    [_brightnessFilter addTarget:self.gpuImageView];
    
    self.lblDesc.hidden = NO;
    self.lblDesc.text = desc;
    [self.lblDesc sizeToFit];
    self.lblDesc.center = self.gpuImageView.center;
    [UIView animateWithDuration:0.6 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.lblDesc.transform = CGAffineTransformMakeScale(1.6, 1.6);
        self.lblDesc.alpha = 0.1;
    } completion:^(BOOL finished) {
        self.lblDesc.transform = CGAffineTransformMakeScale(1, 1);
        self.lblDesc.hidden = YES;
        self.lblDesc.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
