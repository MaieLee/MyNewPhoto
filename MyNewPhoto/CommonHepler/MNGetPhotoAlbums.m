//
//  MNGetPhotoAlbums.m
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import "MNGetPhotoAlbums.h"

@interface MNGetPhotoAlbums()
{
    UIImage *picture;
}
@end

@implementation MNGetPhotoAlbums

+(MNGetPhotoAlbums *)shareManager
{
    static MNGetPhotoAlbums *shareGetPhotoAlbumsManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareGetPhotoAlbumsManagerInstance = [[self alloc] init];
    });
    
    return shareGetPhotoAlbumsManagerInstance;
}

+ (NSInteger)authorizationStatus {
    return [PHPhotoLibrary authorizationStatus];
}

- (void)requestAuthorizationWithCompletion:(void (^)(void))completion {
    void (^callCompletionBlock)(void) = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            callCompletionBlock();
        }];
    });
}

#pragma 获取相册名字
-(NSMutableArray *)getPhtotAlbums{
    return [self iOS8AboveAlbums];
}

- (NSString *)transformAblumTitle:(NSString *)title
{
    NSLog(@"title:%@",title);
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }else if ([title isEqualToString:@"Bursts"]) {
        return @"爆发";
    }else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景";
    }else if ([title isEqualToString:@"Hidden"]) {
        return @"隐藏";
    }else if ([title isEqualToString:@"Time-lapse"]) {
        return @"定时";
    }
    return title;
}


#pragma mark - 获取所有相册内的所有图片
-(NSMutableArray*)getPhtotAlbumsImages{
    NSMutableArray *albumPictures = [NSMutableArray array];
    
    albumPictures = [self getAlbumPictures];
    
    return albumPictures;
}

-(NSMutableArray*)getAlbumPictures{
    NSMutableArray *pictures = [NSMutableArray array];
    NSMutableArray *albums = [self iOS8AboveAlbums];
    
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull assetCollection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<PHAsset*> *albumAssets = [self getAssetsInAssetCollection:assetCollection];
        [pictures addObject:albumAssets];
    }];
    
    
    return pictures;
}

- (NSMutableArray *)iOS8AboveAlbums{
    
    NSMutableArray *albums = [NSMutableArray array];
    // 所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            if (fetchResult.count > 0&&collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos && collection.assetCollectionSubtype !=PHAssetCollectionSubtypeSmartAlbumTimelapses) {
                
                [albums addObject:collection];
            }
        } else {
            NSAssert1(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }];
    
    //所有用户创建的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            if (fetchResult.count > 0) {
                [albums addObject:collection];
            }
        } else {
            NSAssert1(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }];
    
    
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull Collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([Collection.localizedTitle containsString:@"Hidden"] || [Collection.localizedTitle isEqualToString:@"已隐藏"] || [Collection.localizedTitle containsString:@"Deleted"] || [Collection.localizedTitle isEqualToString:@"最近删除"]){
            //不添加这些相册
            [albums removeObjectAtIndex:idx];
        }
    }];
    
    return albums;
}

- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:asset];
    }];
    return arr;
}

#pragma mark 获取照片
//获取指定size照片
-(void)getAlbumImageWithAsset:(PHAsset*)asset andParamSize:(CGSize)size resultImage:(void (^)(UIImage *image))resultImage
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    //仅显示缩略图，不控制质量显示
    /**
     PHImageRequestOptionsResizeModeNone,
     PHImageRequestOptionsResizeModeFast, //根据传入的size，迅速加载大小相匹配(略大于或略小于)的图像
     PHImageRequestOptionsResizeModeExact //精确的加载与传入size相匹配的图像
     */
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = YES;
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            //解析出来的图片
        resultImage(image);
    }];
}

//获取原照片
- (void)getAlbumImageWithAsset:(PHAsset*)asset resultImage:(void (^)(UIImage *image))resultImage
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.networkAccessAllowed = YES;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        resultImage(image);
    }];
    
}

@end
