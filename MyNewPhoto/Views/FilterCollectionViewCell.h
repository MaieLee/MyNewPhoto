//
//  FilterCollectionViewCell.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/10.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilterSampleModel;

@interface FilterCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *selImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *descLabel;
@end
