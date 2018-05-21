//
//  MNGetPhotoAlbums.h
//  MyNewPhoto
//
//  Created by CardLan on 2018/5/16.
//  Copyright © 2018年 CardLan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>  

@interface MNGetPhotoAlbums : NSObject

+(MNGetPhotoAlbums *)shareManager;

/**
 * 获取是否有访问相册的权限
 **/
+ (NSInteger)authorizationStatus;

/**
 * 处理打开提示访问相册的权限
 **/
- (void)requestAuthorizationWithCompletion:(void (^)(void))completion;

/**
 *  获取相册列表
 *
 *  @return 返回列表
 */
- (NSMutableArray *)getPhtotAlbums;

/**
 * 获取相对应的相册名称
 **/
- (NSString *)transformAblumTitle:(NSString *)title;

/**
 *  获取照片数组列表
 *
 *  @return 返回照片数组
 */
- (NSMutableArray *)getPhtotAlbumsImages;

/**
 * 获取某一组相册里的所有照片对象
 *
 *  @return 返回照片数组
 **/
- (NSArray *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection;

/**
 *  按尺寸获取照片
 *
 *  @param asset       照片对象
 *  @param size        照片尺寸
 *  @param resultImage 返回处理后的图片
 */
- (void)getAlbumImageWithAsset:(PHAsset*)asset
                 andParamSize:(CGSize)size
                  resultImage:(void (^)(UIImage *image))resultImage;

/**
 *  获取照片原图
 *
 *  @param asset       照片对象
 *  @param resultImage 返回照片原图
 */
- (void)getAlbumImageWithAsset:(PHAsset*)asset
                  resultImage:(void (^)(UIImage *image))resultImage;  
@end
