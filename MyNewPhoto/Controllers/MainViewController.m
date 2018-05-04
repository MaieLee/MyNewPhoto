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

@interface MainViewController ()

@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageStillCamera *gpuStillCamera;
@property (nonatomic, strong) GPUImageHighlightShadowFilter *filter;
@property (nonatomic, strong) BottomBarView *bottomView;
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
}

- (void)setUpCamera{
    self.gpuStillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    self.gpuStillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    _filter = [[GPUImageHighlightShadowFilter alloc] init];
    _filter.shadows = 0.5;
    _filter.highlights = 0.5;
    [self.gpuStillCamera addTarget:_filter];
    [_filter addTarget:self.gpuImageView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.gpuStillCamera startCameraCapture];
    });
}

- (void)changeCamera{
    [self.gpuStillCamera rotateCamera];
}

- (void)takePicture{
    [self.bottomView.activityIndicator startAnimating];
    
    [self.gpuStillCamera capturePhotoAsImageProcessedUpToFilter:_filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        void* contextInfo;
        UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(saveImage:didFinishSavingWithError:contextInfo:), contextInfo);
    }];
}

- (void)saveImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    self.bottomView.imgView.image = [image imageWithRect:self.bottomView.imgView.frame.size];
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
