//
//  CameraFilterView.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/9.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "CameraFilterView.h"
#import "FilterCollectionViewCell.h"
#import "UIImage+RoundCorner.h"
#import "FilterSampleModel.h"

static const float CELL_HEIGHT = 63.0f;
static const float CELL_WIDTH = 50.0f;
@interface CameraFilterView ()
@property (nonatomic, assign) NSInteger selIndex;
@property (nonatomic, strong) FilterCollectionViewCell *selCell;
@end

static NSString *identifier = @"cameraFilterCellID";

@implementation CameraFilterView

#pragma mark 初始化方法

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        [self registerClass:[FilterCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        
        _selIndex = -1;
    }
    return self;
}

#pragma mark collection 方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_picArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    FilterSampleModel *fSModel = [self.picArray objectAtIndex:indexPath.row];
    cell.imageView.image = fSModel.image;
    cell.selImageView.image = [UIImage createTickImage];
    cell.selImageView.hidden = !fSModel.isSel;
    cell.descLabel.text = fSModel.desc;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.selIndex) {
        return;
    }
    FilterSampleModel *fSModel = [self.picArray objectAtIndex:indexPath.row];
    fSModel.isSel = YES;
    FilterCollectionViewCell *cell = (FilterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selImageView.hidden = NO;
    
    if (self.selIndex != -1) {
        FilterSampleModel *lastFSModel = [self.picArray objectAtIndex:self.selIndex];
        lastFSModel.isSel = NO;
        self.selCell.selImageView.hidden = YES;
    }
    self.selCell = cell;
    self.selIndex = indexPath.row;
    
    [_cameraFilterDelegate switchCameraFilter:indexPath.row];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
@end
