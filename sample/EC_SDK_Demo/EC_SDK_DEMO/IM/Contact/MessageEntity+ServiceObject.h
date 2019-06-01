/**
 * @file MessageEntity+ServiceObject.h
 *
 * Copyright(C), 2012-2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED. \n
 *
 * @brief [en]Description:Tup general message operation class head file.
 * [cn]描述：TUP 通用消息操作类头文件。 \n
 **/

#import "MessageEntity.h"
//#import "ESpaceUMResource.h" //su TODO
#import "ChatMessageEntity+ServiceObject.h"


/**
 * [en] This class is about general message operation.
 * [cn] 通用消息操作类
 **/
@interface MessageEntity (ServiceObject)

/**
 * @brief [en] This method is used to judge whether message from self.
 *        <br>[cn] 判断是否自己的消息
 *
 * @retval BOOL *                   <b>:</b><br>[en] Return yes if true, or return no.
 *                                          <br>[cn] 是返回YES，否返回NO
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (BOOL) fromSelf;

/**
 * @brief [en] This method is used to get message um resource.
 *        <br>[cn] 获取消息的富媒体
 *
 * @retval NSArray *                <b>:</b><br>[en] Return umresource array if success, or return nil.
 *                                          <br>[cn] 成功返回umresource数组，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSArray*) umResources;

/**
 * @brief [en] This method is used to get directory for um resource.
 *        <br>[cn] 获取消息富媒体的路径
 *
 * @retval NSString *               <b>:</b><br>[en] Return umresource directory if success, or return nil.
 *                                          <br>[cn] 成功返回umresource的路径，失败返回nil
 * @attention [en] xxxx
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*) directoryForUMResources;

/**
 * @brief [en] This method is used to get directory for um resource thumbnails.
 *        <br>[cn] 获取消息富媒体缩略图的路径
 *
 * @retval NSString *               <b>:</b><br>[en] Return umresource thumbnails directory if success, or return nil..
 *                                          <br>[cn] 成功返回umresource的缩略图路径，失败返回nil
 * @attention [en] NA
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString*) directoryForUMResourceThumbnails;

/**
 * @brief [en] This method is used to reuse thumbnails.
 *        <br>[cn] 重用缩略图
 *
 * @param [in] ESpaceUMResource* umResource       <b>:</b><br>[en] Indicates um resource object.
 *                                                        <br>[cn] 富媒体对象
 * @param [in] BOOL keepOriginal                  <b>:</b><br>[en] Indicates whether keep original picture.
 *                                                        <br>[cn] 是否保持原始图
 * @param [in] BOOL encrypted                     <b>:</b><br>[en] Indicates whether need encryted.
 *                                                        <br>[cn] 是否需要加密
 * @retval ESpaceUMResource *                     <b>:</b><br>[en] Return ESpaceUMResource object if success, or return nil.
 *                                                        <br>[cn] 成功返回ESpaceUMResource对象，失败返回nil
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
//- (ESpaceUMResource *) umResourceByReuseUMResourceLocalFile:(ESpaceUMResource *)umResource keepOriginal:(BOOL)keepOriginal encrypted:(BOOL) encrypted;

/**
 * @brief [en] This method is used to reuse text message body.
 *        <br>[cn] 重用文本消息体
 *
 * @param [in] MessageEntity* message  <b>:</b><br>[en] Indicates messageEntity object.
 *                                             <br>[cn] messageEntity对象
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) reuseMessageBody:(MessageEntity *)message;

/**
 * @brief [en] This method is used to reuse um resource body.
 *        <br>[cn] 重用富媒体消息体
 *
 * @param [in] ESpaceUMResource* umResource  <b>:</b><br>[en] Indicates ESpaceUMResource object.
 *                                                   <br>[cn] ESpaceUMResource对象
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
//- (void) reuseUMResourceBody:(ESpaceUMResource *)umResource;

/**
 * @brief [en] This method is used to reuse shared link message.
 *        <br>[cn] 重用分享链接消息体
 *
 * @param [in] ESpaceSharedLinkMessage* msg         <b>:</b><br>[en] Indicates ESpaceSharedLinkMessage object.
 *                                                          <br>[cn] ESpaceSharedLinkMessage对象
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (void) reuseShareLineMessageBody:(ESpaceSharedLinkMessage *)msg;

/**
 * @brief [en] This method is used to download thumbnails.
 *        <br>[cn] 下载缩略图
 *
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
//- (void) downloadThumbnails;

/**
 * @brief [en] This method is used to delete message.
 *        <br>[cn] 删除消息
 *
 * @param [out] completionBlock                    <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                         <br>[cn] 处理结果Block，携带错误信息(NSError*)
 */
- (void) removeSelf:(void (^)(NSError* error)) completionBlock;

/**
 * @brief [en] This method is used to mark read local.
 *        <br>[cn] 本地设置消息已读
 *
 * @attention [en] This operate won't notify server.
 *            <br>[cn] 此操作不通知服务器
 * @see NA
 **/
- (void) markReadLocal;
@end
