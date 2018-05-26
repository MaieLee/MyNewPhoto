//
//  MNImagePickerViewController.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNImagePickerViewController.h"
#import "MNGetPhotoAlbums.h"
#import "ImgHeaderView.h"
#import "MNPictrueCollectionViewCell.h"
#import "PicCollectTableViewCell.h"
#import "SysPictureModel.h"

static NSString *const cellIdentf = @"showPictureCell";
static NSString *const collectCellIdentf = @"collectionCell";

@interface MNImagePickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) ImgHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *picCollectArray;
@property (nonatomic, strong) NSMutableArray *picArray;
@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) UITableView *picCollectionTableView;
@property (nonatomic, assign) CGFloat transformY;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL isCloseing;
@end

@implementation MNImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _headerView = [[ImgHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 68)];
    WEAKSELF
    _headerView.backBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    _headerView.titleBlock = ^(BOOL isShowTitle){
        [weakSelf showPicCollectView:isShowTitle];
    };
    
    MNGetPhotoAlbums *getAlbumsManager = [MNGetPhotoAlbums shareManager];
    _picCollectArray = [getAlbumsManager getPhtotAlbums];
    PHAssetCollection *collection = _picCollectArray[0];
    
    _picArray = [NSMutableArray arrayWithArray:[getAlbumsManager getAssetsInAssetCollection:collection]];
    
    self.itemSize = CGSizeMake((kScreenWidth-2)/3,(kScreenWidth-2)/3);
    [self.view addSubview:self.mainCollectionView];
    [self.view addSubview:self.picCollectionTableView];
    
    [_headerView.titleBtn setTitle:collection.localizedTitle forState:UIControlStateNormal];
    [_headerView.titleBtn setImageToRight];
    
    [self.view addSubview:_headerView];
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerView.frame.size.height, self.view.frame.size.width, self.mainCollectionView.frame.size.height)];
    _bgView.backgroundColor = mnColor(0, 0, 0, 0);
    _bgView.hidden = YES;
    [self.view insertSubview:_bgView belowSubview:self.picCollectionTableView];
    [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePicCollect)]];
}

- (UICollectionView *)mainCollectionView{
    if(!_mainCollectionView){
        CGFloat maxY = CGRectGetMaxY(self.headerView.frame);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        CGFloat spacing = 1;
        flowLayout.minimumLineSpacing = spacing;
        flowLayout.minimumInteritemSpacing = spacing;
        flowLayout.itemSize = self.itemSize;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 1, 0);
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, maxY, kScreenWidth, kScreenHeight-maxY) collectionViewLayout:flowLayout];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        [_mainCollectionView registerClass:[MNPictrueCollectionViewCell class] forCellWithReuseIdentifier:cellIdentf];
    }
    return  _mainCollectionView;
}

- (UITableView *)picCollectionTableView{
    if (_picCollectionTableView == nil) {
        CGFloat maxY = CGRectGetMaxY(self.headerView.frame);
        _transformY = _picCollectArray.count*50<(kScreenHeight-maxY)?_picCollectArray.count*50:kScreenHeight-maxY;
        _picCollectionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, maxY, kScreenWidth, _transformY) style:UITableViewStylePlain];
        _picCollectionTableView.delegate = self;
        _picCollectionTableView.dataSource = self;
        _picCollectionTableView.backgroundColor = mnColor(0, 0, 0, 0);
        _picCollectionTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _picCollectionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _picCollectionTableView.bounces = NO;
        _picCollectionTableView.hidden = YES;
        _picCollectionTableView.transform = CGAffineTransformMakeTranslation(0,-_transformY);
    }
    
    return _picCollectionTableView;
}

- (void)showPicCollectView:(BOOL)isShowTitle{
    if (isShowTitle) {
        self.picCollectionTableView.hidden = NO;
        self.bgView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.picCollectionTableView.transform = CGAffineTransformMakeTranslation(0,0);
            self.bgView.backgroundColor = mnColor(0, 0, 0, 0.3);
        } completion:^(BOOL finished) {

        }];
    }else{
        [self closePicCollect];
    }
}

- (void)closePicCollect
{
    if (self.isCloseing) {
        return;
    }
    
    self.isCloseing = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.picCollectionTableView.transform = CGAffineTransformMakeTranslation(0,-self.transformY);
        self.bgView.backgroundColor = mnColor(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        self.picCollectionTableView.hidden = YES;
        self.bgView.hidden = YES;
        self.isCloseing = NO;
        [self.headerView closeTitle];
    }];
}

#pragma mark -- UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _picArray.count;
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MNPictrueCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentf forIndexPath:indexPath];
    if (indexPath.item < _picArray.count) {
        __block SysPictureModel *sysPicModel = _picArray[indexPath.row];
        
        if (sysPicModel.assetImage == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MNGetPhotoAlbums shareManager] getAlbumImageWithAsset:sysPicModel.asset andParamSize:CGSizeMake(self.itemSize.width, self.itemSize.height) resultImage:^(UIImage *image) {
                    cell.picView.image = image;
                    sysPicModel.assetImage = image;
                }];
            });
        }else{
            cell.picView.image = sysPicModel.assetImage;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SysPictureModel *sysPicModel = _picArray[indexPath.row];
    [[MNGetPhotoAlbums shareManager] getAlbumImageWithAsset:sysPicModel.asset resultImage:^(UIImage *image) {
        
    }];
}

#pragma mark -- UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _picCollectArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PicCollectTableViewCell *cell =(PicCollectTableViewCell *)[tableView dequeueReusableCellWithIdentifier:collectCellIdentf];
    if (cell == nil) {
        cell = [[PicCollectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:collectCellIdentf];
    }
    
    PHAssetCollection *collection = _picCollectArray[indexPath.row];
    cell.titleLbl.text = collection.localizedTitle;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    cell.countLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)fetchResult.count];
    [cell.countLbl sizeToFit];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PHAssetCollection *collection = _picCollectArray[indexPath.row];
    [self.headerView.titleBtn setTitle:collection.localizedTitle forState:UIControlStateNormal];
    [self.headerView.titleBtn setImageToRight];
    
    [self.picArray removeAllObjects];
    [self.picArray addObjectsFromArray:[[MNGetPhotoAlbums shareManager] getAssetsInAssetCollection:collection]];
    
    [self.mainCollectionView reloadData];
    [self closePicCollect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
