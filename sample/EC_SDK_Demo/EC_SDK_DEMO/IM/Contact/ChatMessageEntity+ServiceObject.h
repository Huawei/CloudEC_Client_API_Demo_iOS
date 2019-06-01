/**
 * @file ChatMessageEntity+ServiceObject.h
 *
 * Copyright(C), 2012-2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED. \n
 *
 * @brief [en]Description:TUP chat message operation class head file.
 * [cn]描述：TUP 聊天消息操作类头文件。 \n
 **/

#import "ChatSessionEntity.h"
//#import "ESpaceUMResource.h"
#import "ChatMessageEntity.h"
//#import "ESpaceUMResource.h"

//PublicAccountMsgData{
//    "publicSource"  :"公众号来源，1：内部公众号，2：w3m公众号"
//    "publicAccount" :"公众号账号"
//    "publicName"    :"公众号名称"
//    "sourceUrl"     :"分享原文路径"
//    "title"         :"分享的标题"
//    "digest"        :"分享的正文摘要"
//    "mediaPath"     :"图片下载地址"
//    "msgType"       :"消息类型"
//    "contentUrl"    :"链接地址"
//}

//ShareLinkData{
//    "appid"         :""
//    "imgSourceType" :"分享类型：1 内部；2 外部"
//    "source"        :"分享来源，分享来自"
//    "imgUrl"        :"图片下载地址"
//    "sourceUrl"     :"分享原文路径"
//    "title"         :"分享的标题"
//    "digest"        :"分享的正文摘要"
//    "comment"       :"评论意见"
//}

@class PublicAccountMsgEntity;

@interface ESpaceJSONMessage : NSObject

- (instancetype) initWithContent:(NSString*) body;

@end

@interface ESpacePublicAccountMessage : ESpaceJSONMessage

- (instancetype)initWithPublicAccountMsg:(PublicAccountMsgEntity *)paMsg forMessageItemIndex:(NSInteger)index;

@property (nonatomic, strong) NSNumber * publicSource;
@property (nonatomic, copy) NSString * publicAccount;
@property (nonatomic, copy) NSString * publicName;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * digest;
@property (nonatomic, copy) NSString * mediaPath;
@property (nonatomic, strong) NSNumber * msgType;
@property (nonatomic, copy) NSString * contentUrl;
@property (nonatomic, copy) NSString * sourceUrl;
//@property (nonatomic, strong) ESpaceUMResource * umResource;
@end

@interface ESpaceSharedLinkMessage : ESpaceJSONMessage
@property (nonatomic, copy) NSString * source;
@property (nonatomic, copy) NSString * imgSource;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * digest;
@property (nonatomic, copy) NSString * imgUrl;
@property (nonatomic, copy) NSString * sourceUrl;
@property (nonatomic, strong) NSNumber * accessMode;
@property (nonatomic, copy) NSString * comment;
//@property (nonatomic, strong) ESpaceUMResource * umResource;
@end


/**
 * [en] This class is about chat message.
 * [cn] 聊天消息类
 **/
@interface ChatMessageEntity (ServiceObject)



/**
 * @brief [en] This method is used to get message content type.
 *        <br>[cn] 获取消息内容类型
 *
 * @param [in] NSInteger typeValue                <b>:</b><br>[en] Indicates message type.
 *                                                        <br>[cn] 消息类型
 * @param [in] NSString* body                     <b>:</b><br>[en] Indicates message content.
 *                                                        <br>[cn] 消息内容
 * @retval ESpaceContentType                      <b>:</b><br>[en] Indicate message content type.
 *                                                        <br>[cn] 消息内容类型
 * @attention [en] This method  parse message content by original message type, get final message content type.
 *            <br>[cn] 此方法通过原始消息类型解析消息内容，获取最终的消息内容类型
 * @see NA
 **/
- (ESpaceContentType)contentTypeFromServerValue:(NSInteger)typeValue content:(NSString*)body;


/**
  * @brief [en] This method is used to get message content type.
 *        <br>[cn] 获取消息内容类型
 *
 * @param [in] NSString* body                     <b>:</b><br>[en] Indicates message content.
 *                                                        <br>[cn] 消息内容
 * @retval ESpaceContentType                      <b>:</b><br>[en] Indicates message content type.
 *                                                        <br>[cn] 消息内容类型
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (ESpaceContentType) typeFromContent:(NSString*) body;


/**
  * @brief [en] This method is used to mark read detail.
 *        <br>[cn] 设置已读消息详情
 *
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)markReadDetail;


/**
  * @brief [en] This method is used to get next unread detail message.
 *        <br>[cn] 获取下一个未读消息详情
 *
 * @retval ChatMessageEntity *                    <b>:</b><br>[en] Return message object if success, or return nil .
 *                                                        <br>[cn] 成功返回消息对象，失败返回nil
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (ChatMessageEntity *)nextUnreadDetailMessage;

/**
  * @brief [en] This method is used to send message content.
 *        <br>[cn] 发送消息内容
 *
 * @param [out] completionBlock              <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                   <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] This method can't do offline file parsing.
 *            <br>[cn] 该方法不会进行富媒体解析
 */
- (void) sendBody:(void (^)(NSError* error)) completionBlock;

/**
  * @brief [en] This method is used to send message content.
 *        <br>[cn] 发送消息内容
 *
 * @param [out] completionBlock              <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                   <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] This method can parse whether sending content is offline message.
 *            <br>[cn] 该接口会解析发送内容是否为富媒体消息
 */
- (void) send:(void (^)(NSError* error)) completionBlock;


/**
  * @brief [en] This method is used to recall message.
 *        <br>[cn] 撤回消息
 *
 * @param [out] completionBlock              <b>:</b><br>[en] Indicates deeling result block, carry error message.
 *                                                   <br>[cn] 处理结果Block，携带错误信息(NSError*)
 * @attention [en] NA.
 *            <br>[cn] NA.
 */
- (void) recallMessage:(void (^)(NSError* error)) completionBlock;


/**
  * @brief [en] This method is used to mark message read to server.
 *        <br>[cn] 向服务器置消息已读
 *
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)markReadToServer;


/**
  * @brief [en] This method is used to check sensitive words.
 *        <br>[cn] 检查敏感词
 *
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
-(void)checkSensitivewWords;


/**
  * @brief [en] This method is used to check whether message at person.
 *        <br>[cn] 检查消息是否@了自己
 *
 * @attention [en] xxxx.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)checkAtPerson;
@end
