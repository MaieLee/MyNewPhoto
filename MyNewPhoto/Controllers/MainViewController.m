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

@interface MainViewController ()

@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageStillCamera *gpuStillCamera;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong) BottomBarView *bottomView;
@property (nonatomic, strong) UISlider *brightnessSilder;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpUI];
    [self setUpCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)setUpUI{
    self.gpuImageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-150)];
    [self.view addSubview:self.gpuImageView];
    
    ToolBarView *toolView = [[ToolBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
    [self.view addSubview:toolView];
    WEAKSELF
    toolView.cameraBlock = ^(NSInteger cameraType) {
        [weakSelf changeCamera];
    };
    
    _bottomView = [[BottomBarView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-130, self.view.frame.size.width, 130)];
    [self.view addSubview:_bottomView];
    _bottomView.picBlock = ^{
        [weakSelf takePicture];
    };
    
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
    self.gpuStillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
    self.gpuStillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.gpuStillCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.gpuStillCamera.horizontallyMirrorRearFacingCamera  = NO;
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    // 美白滤镜-- 亮度 亮度：调整亮度（-1.0 - 1.0，默认为0.0）
    _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    _brightnessFilter.brightness = 0.1;
    
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    
    [self.gpuStillCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:_brightnessFilter];
    [_brightnessFilter addTarget:self.gpuImageView];
    
//    [self.gpuStillCamera addTarget:self.gpuImageView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.gpuStillCamera startCameraCapture];
    });
}

- (void)changeCamera{
    [self.gpuStillCamera rotateCamera];
}

- (void)takePicture{
    [self.bottomView.activityIndicator startAnimating];
    
    [self.gpuStillCamera capturePhotoAsImageProcessedUpToFilter:_brightnessFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        void* contextInfo;
        UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(saveImage:didFinishSavingWithError:contextInfo:), contextInfo);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
