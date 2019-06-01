/**
 * @file ESpaceUMResource.h
 *
 * Copyright (c) 2015年 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:TUP um resource service class head file.
 * [cn]描述：TUP 富媒体业务类头文件。 \n
 **/

#import <Foundation/Foundation.h>
//#import "ESpaceRichTextBaseParser.h"
#import "ECSUMService.h"

#define IMAGE_MAX_SIZE CGSizeMake(960,1280)
#define IMAGE_MAX_SIZE_LANDSCAPE CGSizeMake(1280,960)

#define THUMBNAIL_PHOTO_WIDTH 110
#define THUMBNAIL_PHOTO_HEIGHT THUMBNAIL_PHOTO_WIDTH
#define THUMBNAIL_VIDEO_WIDTH 110
#define THUMBNAIL_VIDEO_HEIGHT THUMBNAIL_VIDEO_WIDTH
#define MAX_THUMBNAIL_SIZE (200 * 1024)
#define IMAGE_COMPRESSION_QUALITY (0.60)

#define FILETYPE_NORMAL @"normal"
#define FILETYPE_CIRCLE @"circle"
#define FILETYPE_GROUP @"group"

/**
 * [en]This enum is about um resource download or upload status.
 * [cn]富媒体下载或上传状态
 */
typedef NS_ENUM(NSInteger, ESpaceUMResourceStatus) {
    ESpaceUMStatusUnknown = 0,
    ESpaceUMStatusUploading = 1,
    ESpaceUMStatusDownloading = 2,
    ESpaceUMStatusUploaded = 4,
    ESpaceUMStatusDownloaded = 8,
    ESpaceUMStatusUploadFailed = 16,
    ESpaceUMStatusDownloadFailed = 32,
};

/**
 * [en]This enum is about um resource fail reason.
 * [cn]富媒体失败原因
 */
typedef NS_ENUM(NSInteger, ESpaceUMFailedReason){
    ESpaceUMfailed_Unknown = 0,
    ESpaceUMfailed_Forbidden = 1,
    ESpaceUMfailed_FileRemoved = 2
};

/**
 * [en]This enum is about um resource thumbnail status.
 * [cn]富媒体缩略图状态
 */
typedef NS_ENUM(NSInteger, ESpaceUMThumbnailStatus) {
    ESpaceThumbnailStatusUnknown = 0,
    ESpaceThumbnailStatusDownloading = 1,
    ESpaceThumbnailStatusDownloaded = 2,
    ESpaceThumbnailStatusDownloadFailed = 4, // For Images.
    ESpaceThumbnailStatusExporting = 8,
    ESpaceThumbnailStatusExported = 16,
    ESpaceThumbnailStatusExportFailed = 32 // For Videos
};


/**
 * [en]This class is about um resource, it supports basic upload and download operation, status update follow kvc 
 * [cn]富媒体资源类
 * [cn]支持基本上传下载操作，状态更新遵循kvc
 */
@interface ESpaceUMResource : NSObject {
@protected
    NSProgress* _progress;
}

typedef void(^ESpaceUMResourceCompletionBlock)(NSError *error);

/**
 *  resourcePath 资源路径，如果为网络资源则为http地址如果为本地资源为file path
 */
@property (nonatomic, assign) ECSUMResourceCatalog resourceCatalog;
@property (nonatomic, copy) NSString* resourcePath;
@property (nonatomic, assign) ESpaceUMType umType;//资源类型，见ESpaceUMType定义
@property (nonatomic, assign) long long size;//资源大小
@property (nonatomic, assign) NSUInteger duration;//资源时长
@property (nonatomic, copy) NSString* name;//文件名称带后缀
@property (nonatomic, copy) NSString* accessCode;//资源提取码
@property (nonatomic, assign) CGFloat width;//宽
@property (nonatomic, assign) CGFloat height;//高

@property (nonatomic, assign, readonly) BOOL cachedResource;

@property (nonatomic, copy, readonly) NSString* fileName;
@property (nonatomic, copy, readonly) NSString* localFilePath;//本地文件路径，会随本地文件目录及文件名称自计算
@property (nonatomic, readonly, assign) ESpaceUMResourceStatus umStatus;//网络传输状态遵循kvc
@property (nonatomic, copy) NSString* localDirectory;//本地文件目录
@property (nonatomic, strong, readonly) NSProgress* progress;//上传下载进度，遵循kvc
@property (nonatomic, readonly, assign) ESpaceUMFailedReason umFailedReason;//um上传或下载错误类型

//富媒体业务鉴权
//@property (nonatomic, copy) NSString *preFileID; //群文件预上传返回id，不支持群文件上传，暂无用
//@property (nonatomic, copy) NSString *groupID; //群文件上传对应的群组id，不支持群文件上传，暂无用
@property (nonatomic, copy) NSString *fileType; //对应的文件业务：normal:点对点文件+富媒体、群组富媒体； group：群文件 circle：同事圈
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileID;

@property (nonatomic, copy) NSString *tmpDirectory;//本地文件tmp目录，首先下载到tmp目录，下载成功后移到localDirectory目录下

/**
 * @brief [en] This method is used to init resource.
 *        <br>[cn] 初始化资源
 *
 * @param [in] ESpaceUMResource* resource         <b>:</b><br>[en] Indicates um resource.
 *                                                        <br>[cn] 富媒体资源
 * @retval instancetype                           <b>:</b><br>[en] Return an instance object.
 *                                                        <br>[cn] 返回一个单例对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (instancetype) initWithResource:(ESpaceUMResource*) resource;


/**
 * @brief [en] This method is used to download file.
 *        <br>[cn] 下载文件
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] 文件会存放在localFilePath中
 * @see NA
 **/
- (void) download:(void(^)(NSError* error)) completionBlock;


/**
 * @brief [en] This method is used to check whether need download.
 *        <br>[cn] 检查是否需要下载
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) needDownload;


/**
 * @brief [en] This method is used to download file if needed.
 *        <br>[cn] 下载文件
 *
 * @attention [en] If there has no file at local, then download file.
 *            <br>[cn] 如果本地没有文件则下载
 * @see NA
 **/
- (void) downloadIfNeeded;


/**
 * @brief [en] This method is used to download file if needed.
 *        <br>[cn] 下载文件
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] If there has no file at local, then download file, return error code
 *            <br>[cn] 如果本地没有文件则下载,会返回错误码
 * @see NA
 */
- (void) downloadIfNeeded:(void(^)(NSError* error))completionBlock;


/**
 * @brief [en] This method is used to upload file.
 *        <br>[cn] 上传文件
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] If upload finished, resource path will auto update to remote file address.
 *            <br>[cn] 上传完成后资源路径resourcePath会自动更新为远端文件地址
 * @see NA
 */
- (void) upload:(void(^)(NSError* error)) completionBlock;


/**
 * @brief [en] This method is used to judge whether need upload.
 *        <br>[cn] 判断是否需要上传
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) needUpload;


/**
 * @brief [en] This method is used to delete file.
 *        <br>[cn] 删除文件
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] delete um resource at cloud or umserver.
 *            <br>[cn] 在云盘orUMserver删除富媒体
 * @see NA
 */
- (void) deleted:(void(^)(NSError *error)) completionBlock;


/**
 * @brief [en] This method is used to upload file if needed.
 *        <br>[cn] 上传文件
 *
 * @attention [en] if needed then upload.
 *            <br>[cn] 如果没有启动上传则上传
 * @see NA
 **/
- (void) uploadIfNeeded;


/**
 * @brief [en] This method is used to cancel upload or download.
 *        <br>[cn] 取消上传或者下载文件
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) cancel;


/**
 * @brief [en] This method is used to set download completion block.
 *        <br>[cn] 向下载动作绑定多个下载完成回调
 *
 * @param [in] NSError* error                   <b>:</b><br>[en] Indicates error code.
 *                                                      <br>[cn] 错误码
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @param [in] NSString* key                    <b>:</b><br>[en] Indicates download block name, cannot be nil.
 *                                                      <br>[cn] 下载回调名称：注意不能为nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) setDownloadCompletion:(void(^)(NSError* error)) completionBlock forKey:(NSString*) key;


/**
 * @brief [en] This method is used to set upload completion block.
 *        <br>[cn] 向上传动作绑定多个上传回调
 *
 * @param [in] NSError* error                   <b>:</b><br>[en] Indicates error code.
 *                                                      <br>[cn] 错误码
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @param [in] NSString* key                    <b>:</b><br>[en] Indicates upload block name, cannot be nil.
 *                                                      <br>[cn] 上传回调名称：注意不能为nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) setUploadCompletion:(void(^)(NSError* error)) completionBlock forKey:(NSString*) key;


/**
 * @brief [en] This method is used to set delete completion block.
 *        <br>[cn] 向删除动作绑定多个删除回调
 *
 * @param [in] NSError* error                   <b>:</b><br>[en] Indicates error code.
 *                                                      <br>[cn] 错误码
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @param [in] NSString* key                    <b>:</b><br>[en] Indicates delete block name, cannot be nil.
 *                                                      <br>[cn] 删除回调名称：注意不能为nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) setDeleteCompletion:(void(^)(NSError* error)) completionBlock forKey:(NSString*) key;


/**
 * @brief [en] This method is used to judge whether exist at local.
 *        <br>[cn] 判断本地是否存在
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) localExites;


/**
 * @brief [en] This method is used to judge whether need encrypt.
 *        <br>[cn] 判断是否需要加密
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) needEncrypt;


/**
 * @brief [en] This method is used to judge whether is remote resource.
 *        <br>[cn] 判断是否为远端路径
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) remoteResource;


/**
 * @brief [en] This method is used to judge whether can preview.
 *        <br>[cn] 判断是否可以预览
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) canPreview;


/**
 * @brief [en] This method is used to create thumbnail image.
 *        <br>[cn] 制作缩略图
 *
 * @param [in] UIImage* image                     <b>:</b><br>[en] Indicates image.
 *                                                        <br>[cn] 原图
 * @param [in] CGSize* bounds                     <b>:</b><br>[en] Indicates bounds.
 *                                                        <br>[cn] 最大尺寸
 * @retval UIImage *                              <b>:</b><br>[en] Return thumbnail object if success, or return nil .
 *                                                        <br>[cn] 成功返回缩略图对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (UIImage*) createThumbnailForImage:(UIImage*) image maxSize:(CGSize) bounds;


/**
 * @brief [en] This method is used to judge whether need prompt .
 *        <br>[cn] 判断是否需要裁剪
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) needPrompt;


/**
 * @brief [en] This method is used to judge whether exist local file already.
 *        <br>[cn] 判断本地文件是否存在
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) isLocalFileReady;

@end


/**
 * [en] xxxx.
 * [cn] 图片资源类
 **/
@interface ESpaceUMImgResource : ESpaceUMResource

@property (nonatomic, copy) NSString* thumbnailDirectory;
@property (nonatomic, assign) CGFloat thumbnailWidth;
@property (nonatomic, assign) CGFloat thumbnailHeight;
@property (nonatomic, assign) CGFloat maxThumbnailWidthHeight;

@property (nonatomic, readonly, copy) NSString* localThumbFilePath;

@property (nonatomic, assign, readonly) ESpaceUMThumbnailStatus thumbnailStatus;


/**
 * @brief [en] This method is used to judge whether support download thumbnail.
 *        <br>[cn] 判断是否支持缩略图下载
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) supportThumbnailDownload;


/**
 * @brief [en] This method is used to download thumbnail.
 *        <br>[cn] 下载缩略图
 *
 * @param [out] completionBlock             <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                  <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) downloadThumbnail:(void(^)(NSError* error)) completionBlock;


/**
 * @brief [en] This method is used to download thumbnail.
 *        <br>[cn] 下载缩略图
 *
 * @attention [en] if needed, then download thumbnail.
 *            <br>[cn] 如果需要的话进行缩略图下载
 * @see NA
 **/
- (void) downloadThumbnailIfNeeded;


/**
 * @brief [en] This method is used to set thumbnail download completion block.
 *        <br>[cn] 设置缩略图下载回调
 *
 * @param [in] NSError* error                   <b>:</b><br>[en] Indicates error code.
 *                                                      <br>[cn] 错误码
 * @param [out] completionBlock                 <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                      <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @param [in] NSString* key                    <b>:</b><br>[en] Indicates key.
 *                                                      <br>[cn] 键值
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) setThumbnailDownloadCompletion:(void (^)(NSError* error))completionBlock forKey:(NSString *)key;


/**
 * @brief [en] This method is used to judge whether thumbnail exist.
 *        <br>[cn] 判断缩略图是否存在
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) thumbExites;


/**
 * @brief [en] This method is used to get local image.
 *        <br>[cn] 获取本地图像
 *
 * @retval NSData *                 <b>:</b><br>[en] Return image data if success, or return nil .
 *                                          <br>[cn] 成功返回图像数据，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSData*) localImageData;


/**
 * @brief [en] This method is used to get thumbnail data.
 *        <br>[cn] 获取缩略图数据
 *
 * @retval NSData *                 <b>:</b><br>[en] Return thumbnail data if success, or return nil.
 *                                          <br>[cn] 成功返回缩略图数据，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSData*) localThumbnailData;


/**
 * @brief [en] This method is used to get thumbnail image.
 *        <br>[cn] 获取缩略图
 *
 * @retval UIImage *                <b>:</b><br>[en] Return thumbnail object if success, or return nil.
 *                                          <br>[cn] 成功返回缩略图对象，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage*) localThumbnail;


/**
 * @brief [en] This method is used to get local image.
 *        <br>[cn] 获取原图
 *
 * @retval UIImage *                <b>:</b><br>[en] Return image object if success, or return nil.
 *                                          <br>[cn] 成功返回图像对象，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage*) localImage;


/**
 * @brief [en] This method is used to get image size.
 *        <br>[cn] 获取原图大小
 *
 * @retval CGSize                   <b>:</b><br>[en] Return image size if success, or return nil.
 *                                          <br>[cn] 成功返回图像大小，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (CGSize) imageSize;


/**
 * @brief [en] This method is used to judge whether is gif picture.
 *        <br>[cn] 判断是否是GIF图片
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) isGif;


/**
 * @brief [en] This method is used to check whether can preview original picture.
 *        <br>[cn] 检查是否可以预览原图
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) canPreviewOriginal;


/**
 * @brief [en] This method is used to check whether thumbnail is ready.
 *        <br>[cn] 检查缩略图是否准备好
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) isThumbnailReady;


/**
 * @brief [en] This method is used to reuser um resource.
 *        <br>[cn] 复用富媒体resource
 *
 * @param [in] ESpaceUMImgResource* imgResource     <b>:</b><br>[en] Indicates um resource.
 *                                                          <br>[cn] 富媒体
 * @param [in] BOOL keepOriginal                    <b>:</b><br>[en] Indicates whether keep original  picture.
 *                                                          <br>[cn] 是否保持原图
 * @param [in] BOOL encrypted                       <b>:</b><br>[en] Indicates whether encrypted.
 *                                                          <br>[cn] 是否加密
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) reuseUMImageResourceThumbnail:(ESpaceUMImgResource *)imgResource keepOriginal:(BOOL)keepOriginal encrypted:(BOOL)encrypted;

@end


/**
 * @brief [en] This method is used to finish playing.
 *        <br>[cn] 播放结束
 *
 * @param [out] ESpaceUMAudioResourceFinishPlayingBlock <b>:</b><br>[en] Indicates finish playing block.
 *                                                              <br>[cn] 播放结束回调
 * @param [in] BOOL force                               <b>:</b><br>[en] Indicates whether force stop.
 *                                                              <br>[cn] 是否强制停止
 */
typedef void(^ESpaceUMAudioResourceFinishPlayingBlock)(BOOL force);

/**
 * [en] Indicates audio resource.
 * [cn] 音频资源
 */
@interface ESpaceUMAudioResource : ESpaceUMResource

@property (nonatomic, assign, readonly)BOOL playing;

- (BOOL)play:(ESpaceUMAudioResourceFinishPlayingBlock)finishBlock;//播放
- (BOOL)stop;//停止

@end

/**
 * [en] Indicates video resource.
 * [cn] 视频资源
 **/
@interface ESpaceUMVideoResource : ESpaceUMResource
@property (nonatomic, copy) NSString* thumbnailDirectory;
@property (nonatomic, readonly, copy) NSString* localThumbFilePath;
@property (nonatomic, assign, readonly) ESpaceUMThumbnailStatus thumbnailStatus;


/**
 * @brief [en] This method is used to judge whether has thumbnail picture.
 *        <br>[cn] 判断是否有缩略图
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no .
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL)hasThumbnail;


/**
 * @brief [en] This method is used to get thumbnail picture.
 *        <br>[cn] 获取缩略图
 *
 * @retval UIImage *                <b>:</b><br>[en] Return thumbnail object if success, or return nil .
 *                                          <br>[cn] 成功返回缩略图对象，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (UIImage*)localThumbnail;


/**
 * @brief [en] This method is used to export video thumbnail if needed.
 *        <br>[cn] 导出视频缩略图
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)exportThumbnailIfNeed;


/**
 * @brief [en] This method is used to reuse um video resource.
 *        <br>[cn] 复用富媒体resource
 *
 * @param [in] ESpaceUMVideoResource* videoResource <b>:</b><br>[en] Indicates video resource.
 *                                                          <br>[cn] 富媒体
 * @param [in] BOOL keepOriginal                    <b>:</b><br>[en] Indicates whether keep original.
 *                                                          <br>[cn] 是否保持原图
 * @param [in] BOOL encrypted                       <b>:</b><br>[en] Indicates whether encrypted.
 *                                                          <br>[cn] 是否加密
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)reuseUMVideoResourceThumbnail:(ESpaceUMVideoResource *)videoResource keepOriginal:(BOOL)keepOriginal encrypted:(BOOL)encrypted;
@end

/**
 * [en] This class is about um resource manager.
 * [cn] 富媒体资源管理类
 **/
@interface ESpaceUMResourceManager : NSObject

/**
 * @brief [en] This method is used to get instance object.
 *        <br>[cn] 获取单例对象
 *
 * @retval instancetype                           <b>:</b><br>[en] Return an instance object .
 *                                                        <br>[cn] 返回一个单例对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
+ (instancetype) sharedInstance;


/**
 * @brief [en] This method is used to get resource cache.
 *        <br>[cn] 获取富媒体缓存
 *
 * @param [in] NSString* url                      <b>:</b><br>[en] Indicates resource url.
 *                                                        <br>[cn] 富媒体链接
 * @retval ESpaceUMResource *                     <b>:</b><br>[en] Return resource cache object if success, or return nil .
 *                                                        <br>[cn] 成功返回富媒体缓存对象，失败返回nil
 * @attention [en] Get corresponding resource by url.
 *            <br>[cn] 根据url获取对应的富媒体缓存
 * @see NA
 **/
- (ESpaceUMResource*) cachedResourceForUrl:(NSString*) url;


/**
 * @brief [en] This method is used to clear all cache.
 *        <br>[cn] 清空富媒体缓存
 *
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) clearAllCache;


/**
 * @brief [en] This method is used to parse um resource.
 *        <br>[cn] 解析富媒体资源
 *
 * @param [in] NSString* umString                 <b>:</b><br>[en] Indicates description string.
 *                                                        <br>[cn] 描述字符串
 * @retval ESpaceUMResource *                     <b>:</b><br>[en] Return ESpaceUMResource instance if success, or return nil .
 *                                                        <br>[cn] 成功返回ESpaceUMResource实例，失败返回nil
 * @attention [en] parse um resource from string description.
 *            <br>[cn] 从string描述中解析umresource
 * @see NA
 **/
- (ESpaceUMResource*) umResourceFromString:(NSString*) umString;

@end
