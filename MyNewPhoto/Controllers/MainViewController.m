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
#import "MNGetPhotoAlbums.h"
#import "CameraButtonView.h"
#import "MNImagePickerViewController.h"
#import "ShowPicView.h"

//闪光灯状态
typedef NS_ENUM(NSInteger, CameraManagerFlashMode) {
    CameraManagerFlashModeAuto, /**<自动*/
    CameraManagerFlashModeOff, /**<关闭*/
    CameraManagerFlashModeOn /**<打开*/
};

@interface MainViewController ()<UIGestureRecognizerDelegate,CAAnimationDelegate,UIAlertViewDelegate>
{
    CALayer *_focusLayer; //聚焦层
    NSString *pathToMovie;
    GPUImageMovieWriter *movieWriter;
}

@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageStillCamera *gpuStillCamera;
@property (nonatomic, strong) GPUImageVideoCamera *gpuVideoCamera;
@property (nonatomic, strong) GPUImageBeautifyFilter *beautifyFilter;
@property (nonatomic, strong) id selFilter;
@property (nonatomic, strong) CameraButtonView *cameraBtn;
@property (nonatomic, strong) BottomBarView *bottomView;
@property (nonatomic, assign) CGFloat beginGestureScale;//开始的缩放比例
@property (nonatomic, assign) CGFloat effectiveScale;//最后的缩放比例
@property (nonatomic, assign) CameraManagerFlashMode flashMode;
@property (nonatomic, strong) UILabel *lblDesc;
@property (nonatomic, assign) BOOL isTakeVideo;
@property (nonatomic, assign) BOOL isHadStopCamera;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;//前置或者后置摄像头
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, assign) BOOL isRefuseAccessAudio;
@property (nonatomic, strong) ShowPicView *showPicView;
@property (nonatomic, strong) GPUImageUIElement *uiElement;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkoutCameraAuthority];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    if (self.isHadStopCamera) {
        [self.gpuStillCamera startCameraCapture];
        self.isHadStopCamera = NO;
    }
}

- (void)checkoutCameraAuthority{
    AVAuthorizationStatus authStatus = [MNGetPhotoAlbums mediaAuthorizationStatus:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied) {
        NSString *app_Name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"%@需要访问您的相机,请在设置/隐私/相机中允许访问相机",app_Name];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"无法访问相机" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1001;
        [alert show];
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [[MNGetPhotoAlbums shareManager] requestAuthorizationWithType:AVMediaTypeVideo Completion:^{
            [self checkoutCameraAuthority];
        }];
    }else{
        [self setUpUI];
        [self preFilter];
        
        [self.gpuStillCamera addTarget:self.selFilter];
        [self.selFilter addTarget:self.gpuImageView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [self.gpuStillCamera startCameraCapture];
            dispatch_async(dispatch_get_main_queue(), ^{
               self.cameraBtn.hidden = NO;
            });
        });
        
        [self setupCameraFlash];
    }
}

- (void)setUpUI{
    CGRect viewFrame = self.view.frame;
    self.gpuImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height)];
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
    [self.view addSubview:self.gpuImageView];
    
    [self addSwipeGesture];
    
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"flash_0"] forState:UIControlStateNormal];
    flashBtn.frame = CGRectMake(10, 15, 60, 40);
    [self.view addSubview:flashBtn];
    [flashBtn addTarget:self action:@selector(changeFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    self.flashBtn = flashBtn;
    
    UIButton *switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchCameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [switchCameraBtn setImage:[UIImage imageNamed:@"switchcamera"] forState:UIControlStateNormal];
    switchCameraBtn.titleLabel.font = mnFont(14);
    switchCameraBtn.frame = CGRectMake(viewFrame.size.width-70, 15, 60, 40);
    [self.view addSubview:switchCameraBtn];
    [switchCameraBtn addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    WEAKSELF
    _cameraBtn = [[CameraButtonView alloc] initWithFrame:CGRectMake(0, viewFrame.size.height - 140, 87, 87)];
    [self.view addSubview:_cameraBtn];
    _cameraBtn.hidden = YES;
    _cameraBtn.center = CGPointMake(self.view.center.x, _cameraBtn.center.y);
    _cameraBtn.takePicture = ^{
        [weakSelf takePicture];
    };
    _cameraBtn.takeVideo = ^(NSInteger cameraStatus) {
        if (cameraStatus == 0) {
            [weakSelf preVideoRecording];
        }else if (cameraStatus == 1) {
            [weakSelf startVideoRecording];
        }else if (cameraStatus == 2) {
            [weakSelf stopVideoRecording];
        }else if (cameraStatus == 3){
            //还没开始录制长按手势已经结束
            [weakSelf.gpuVideoCamera stopCameraCapture];
            [weakSelf setUpStillCamera];
        }
    };
    
    _bottomView = [[BottomBarView alloc] initWithFrame:CGRectMake(0, viewFrame.size.height-63, viewFrame.size.width, 63)];
    [self.view addSubview:_bottomView];
    _bottomView.transform = CGAffineTransformMakeTranslation(0, 63);
    _bottomView.filterBlock = ^(id filter, NSString *desc) {
        [weakSelf showFilters:filter Desc:desc];
    };
    
    self.lblDesc = [UILabel new];
    self.lblDesc.font = mnFont(26);
    self.lblDesc.textColor = [UIColor whiteColor];
    [self.view addSubview:self.lblDesc];
    self.lblDesc.hidden = YES;
    
    CGFloat showviewWidth = screenSize.width*0.15;
    CGFloat showviewHeight = screenSize.height*0.15;
    _showPicView = [[ShowPicView alloc] initWithFrame:CGRectMake(screenSize.width-showviewWidth-10, screenSize.height-showviewHeight-10, showviewWidth, showviewHeight)];
    [self.view addSubview:_showPicView];
    _showPicView.complete = ^(BOOL isSavePic, UIImage *saveImage) {
        if (isSavePic) {
            [weakSelf savedPhotosAlbum:saveImage];
        }else{
            [weakSelf saveVideoAlbum];
        }
    };
    _showPicView.detailComplete = ^(BOOL isShow) {
        if (isShow) {
            [weakSelf.gpuStillCamera stopCameraCapture];
        }else{
            [weakSelf.gpuStillCamera startCameraCapture];
        }
    };
    
    [self setfocusImage:[UIImage createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(60, 60)]];
    self.cameraPosition = AVCaptureDevicePositionBack;
}

- (void)setupCameraFlash{
    //初始化闪光灯模式为Auto
    [self setFlashMode:CameraManagerFlashModeAuto];
    //初始化开始及结束的缩放比例都为1.0
    [self setBeginGestureScale:1.0f];
    [self setEffectiveScale:1.0f];
}

- (void)addSwipeGesture{
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.gpuImageView addGestureRecognizer:leftRecognizer];
    
    UISwipeGestureRecognizer *upRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [upRecognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [self.gpuImageView addGestureRecognizer:upRecognizer];
    
    UISwipeGestureRecognizer *downRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [downRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.gpuImageView addGestureRecognizer:downRecognizer];
}

- (void)preFilter{
    self.beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    self.selFilter = self.beautifyFilter;
}

- (void)setUpStillCamera{
    self.isTakeVideo = NO;
    [self.gpuStillCamera removeAllTargets];
    [self.selFilter removeAllTargets];
    
    [self.gpuStillCamera addTarget:self.selFilter];
    [self.selFilter addTarget:self.gpuImageView];
    
    self.flashBtn.hidden = self.cameraPosition == AVCaptureDevicePositionBack?NO:YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.gpuStillCamera.cameraPosition != self.cameraPosition) {
            [self.gpuStillCamera rotateCamera];
        }
        [self.gpuStillCamera startCameraCapture];
    });
}

- (GPUImageStillCamera *)gpuStillCamera{
    if (_gpuStillCamera == nil) {
        _gpuStillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
        _gpuStillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _gpuStillCamera.horizontallyMirrorFrontFacingCamera = YES;
        _gpuStillCamera.horizontallyMirrorRearFacingCamera  = NO;
    }
    
    return _gpuStillCamera;
}

- (void)setUpVideoCamera{
    [self.gpuVideoCamera removeAllTargets];
    [self.selFilter removeAllTargets];
    
    [self.gpuVideoCamera addTarget:self.selFilter];
    [self.uiElement addTarget:self.selFilter];
    [self.selFilter addTarget:self.gpuImageView];
    
    if (self.gpuVideoCamera.cameraPosition != self.cameraPosition) {
        [self.gpuVideoCamera rotateCamera];
    }
    
    __unsafe_unretained GPUImageUIElement *weakOverlay = self.uiElement;
    [self.selFilter disableSecondFrameCheck];//这样只是在需要更新水印的时候检查更新就不会调用很多次
    runAsynchronouslyOnVideoProcessingQueue(^{
        [weakOverlay update];
    });
    
    self.flashBtn.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.gpuVideoCamera startCameraCapture];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.cameraBtn startRecord];
        });
    });
}

- (GPUImageVideoCamera *)gpuVideoCamera{
    if (_gpuVideoCamera == nil) {
        _gpuVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
        _gpuVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _gpuVideoCamera.horizontallyMirrorFrontFacingCamera = YES;
        _gpuVideoCamera.horizontallyMirrorRearFacingCamera  = NO;
        if (!self.isRefuseAccessAudio) {
            [_gpuVideoCamera addAudioInputsAndOutputs];
        }
        
        UIImage *waterImage = [UIImage imageNamed:@"watermark"];
        UIImageView *waterImageView = [[UIImageView alloc] initWithImage:waterImage];
        
        _uiElement = [[GPUImageUIElement alloc] initWithView:waterImageView];
    }
    
    return _gpuVideoCamera;
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    if (self.isTakeVideo) {
        return;
    }
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        [self.bottomView show];
        [UIView animateWithDuration:0.2 animations:^{
            self.cameraBtn.transform = CGAffineTransformMakeTranslation(0,-30);
        } completion:^(BOOL finished) {
            
        }];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
        [self.bottomView hide];
        [UIView animateWithDuration:0.2 animations:^{
            self.cameraBtn.transform = CGAffineTransformMakeTranslation(0,0);
        } completion:^(BOOL finished) {
            
        }];
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.gpuStillCamera stopCameraCapture];
        self.isHadStopCamera = YES;
        [self showPickerVc];
    }
}

- (void)showPickerVc{
    NSInteger AuthorizationStatus = [MNGetPhotoAlbums photoAuthorizationStatus];
    if (AuthorizationStatus == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        NSString *app_Name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"%@需要访问您的相册,请在设置/隐私/相册中允许访问相册",app_Name];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (AuthorizationStatus == 0) { // 未请求过相册权限
        [[MNGetPhotoAlbums shareManager] requestAuthorizationWithType:@"photo" Completion:^{
            [self showPickerVc];
        }];
    }else{
        MNImagePickerViewController *imagePickerVc = [[MNImagePickerViewController alloc] init];
        [self.navigationController pushViewController:imagePickerVc animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (alertView.tag == 1002) {
            self.isRefuseAccessAudio = YES;
            return;
        }
    }
    
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([ [UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)switchCamera:(UIButton *)button{
    button.selected = !button.isSelected;
    self.cameraPosition = button.selected?AVCaptureDevicePositionFront:AVCaptureDevicePositionBack;
    
    if (self.isTakeVideo) {
        [self.gpuVideoCamera rotateCamera];
    }else{
        self.flashBtn.hidden = button.selected;
        [self.gpuStillCamera rotateCamera];
    }
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
    }else {
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
    if (self.isTakeVideo) {
        return;
    }
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
        case CameraManagerFlashModeOff:
            self.flashMode = CameraManagerFlashModeAuto;
            [button setImage:[UIImage imageNamed:@"flash_0"] forState:UIControlStateNormal];
            break;
        case CameraManagerFlashModeAuto:
            self.flashMode = CameraManagerFlashModeOn;
            [button setImage:[UIImage imageNamed:@"flash_1"] forState:UIControlStateNormal];
            break;
        case CameraManagerFlashModeOn:
            self.flashMode = CameraManagerFlashModeOff;
            [button setImage:[UIImage imageNamed:@"flash_2"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)takePicture{
    [self.gpuStillCamera capturePhotoAsImageProcessedUpToFilter:self.selFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        [self.gpuStillCamera stopCameraCapture];
        
        [self.showPicView showCameraImage:processedImage IsSavePic:YES Complete:^{
            [self.gpuStillCamera startCameraCapture];
        }];
    }];
}

- (void)savedPhotosAlbum:(UIImage *)processedImage{
    UIImage *waterImage = [UIImage imageNamed:@"watermark"];
    UIImage *saveImage = [UIImage waterImageWithImage:processedImage waterImage:waterImage waterImageRect:CGRectMake(40, processedImage.size.height-waterImage.size.height-40, waterImage.size.width, waterImage.size.height)];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (@available(iOS 9.0, *)) {
            [[MNGetPhotoAlbums shareManager] insertObject:saveImage isImage:YES intoAlbumNamed:@"情迷相册" completionHandler:nil];
        }else{
            UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(saveImage:didFinishSavingWithError:contextInfo:), nil);
        }
    });
}

- (void)saveImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(!error) {
//        NSLog(@"保存成功！");
    }else{
//        NSLog(@"保存失败！");
    }
}

- (void)preVideoRecording{
    AVAuthorizationStatus authStatus = [MNGetPhotoAlbums mediaAuthorizationStatus:AVMediaTypeAudio];
    
    if (authStatus == AVAuthorizationStatusDenied) {
        NSString *app_Name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"%@需要访问您的麦克风,请在设置/隐私/麦克风中启用麦克风",app_Name];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"无法访问麦克风" message:message delegate:self cancelButtonTitle:@"不需要" otherButtonTitles:@"设置", nil];
        alert.tag = 1002;
        [alert show];
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [[MNGetPhotoAlbums shareManager] requestAuthorizationWithType:AVMediaTypeAudio Completion:nil];
    }else{
        [self.gpuStillCamera removeAllTargets];
        [self setUpVideoCamera];
        
        [self.bottomView hide];
    }
}

- (void)startVideoRecording{
{
    self.isTakeVideo = YES;
    pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Movie.m4v"];
    // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];

    movieWriter.encodingLiveVideo = YES;
    movieWriter.shouldPassthroughAudio = YES;
    [self.selFilter addTarget:movieWriter];
    self.gpuVideoCamera.audioEncodingTarget = movieWriter;
    [movieWriter startRecording];
}}

- (void)stopVideoRecording{
    if (!self.isTakeVideo) {
        return;
    }
    self.gpuVideoCamera.audioEncodingTarget = nil;
    
    CGSize showPicViewFrameSize = CGSizeMake(self.showPicView.frame.size.width, self.showPicView.frame.size.height);

    [movieWriter finishRecordingWithCompletionHandler:^{
        UIImage *image = [[MNGetPhotoAlbums shareManager] firstFrameWithVideoURL:self->pathToMovie size:showPicViewFrameSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraBtn.transform = CGAffineTransformMakeTranslation(0,0);
            self.showPicView.vedioURL = [NSURL fileURLWithPath:self->pathToMovie];
            [self.showPicView showCameraImage:image IsSavePic:NO Complete:^{
                [self.gpuVideoCamera stopCameraCapture];
                [self.gpuVideoCamera removeAllTargets];
                [self setUpStillCamera];
                
                [self.cameraBtn finishSaveVideo];
            }];
        });
    }];
    
    [self.selFilter removeTarget:movieWriter];
}

- (void)saveVideoAlbum{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (@available(iOS 9.0, *)) {
            [[MNGetPhotoAlbums shareManager] insertObject:[NSURL fileURLWithPath:self->pathToMovie] isImage:NO intoAlbumNamed:@"情迷相册" completionHandler:nil];
        }else{
            UISaveVideoAtPathToSavedPhotosAlbum(self->pathToMovie, self, @selector(saveVideo:didFinishSavingWithError:contextInfo:), nil);
        }
    });
}

- (void)saveVideo:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    if(!error) {
//        NSLog(@"保存成功！");
    }else{
//        NSLog(@"保存失败！");
    }
}

- (void)showFilters:(id)filter Desc:(NSString *)desc
{
    if (!self.isTakeVideo) {
        [self.gpuStillCamera removeAllTargets];
    }else{
        [self.gpuVideoCamera removeAllTargets];
    }
    [self.selFilter removeAllTargets];
    
    id filterGroup = nil;
    if ([desc isEqualToString:@"原图"]) {
        filterGroup = filter;
    }else{
        GPUImageBilateralFilter *bilateralFilter = [[GPUImageBilateralFilter alloc] init];
        bilateralFilter.distanceNormalizationFactor = 9.0;
        if ([filter isKindOfClass:[GPUImageFilterGroup class]]) {
            [self addGPUImageFilter:bilateralFilter InFilterGroup:(GPUImageFilterGroup *)filter];
            filterGroup = filter;
        }else{
            GPUImageFilterGroup *fGroup = [[GPUImageFilterGroup alloc] init];
            [fGroup addFilter:bilateralFilter];
            [fGroup addFilter:filter];
            
            fGroup.initialFilters = @[bilateralFilter,filter];
            fGroup.terminalFilter = filter;
            
            filterGroup = fGroup;
        }
    }
    
    if (!self.isTakeVideo) {
        [self.gpuStillCamera addTarget:filterGroup];
    }else{
        [self.gpuVideoCamera addTarget:filterGroup];
        [self.uiElement addTarget:filterGroup];
        
        __unsafe_unretained GPUImageUIElement *weakOverlay = self.uiElement;
        [filterGroup disableSecondFrameCheck];//这样只是在需要更新水印的时候检查更新就不会调用很多次
        runAsynchronouslyOnVideoProcessingQueue(^{
            [weakOverlay update];
        });
    }
    [filterGroup addTarget:self.gpuImageView];
    
    self.selFilter = filterGroup;
    
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

- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter InFilterGroup:(GPUImageFilterGroup *)filterGroup
{
    [filterGroup addFilter:filter];
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    GPUImageOutput<GPUImageInput> *terminalFilter    = filterGroup.terminalFilter;
    NSArray *initialFilters                          = filterGroup.initialFilters;
    [terminalFilter addTarget:newTerminalFilter];
    
    filterGroup.initialFilters = @[initialFilters[0]];
    filterGroup.terminalFilter = newTerminalFilter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
