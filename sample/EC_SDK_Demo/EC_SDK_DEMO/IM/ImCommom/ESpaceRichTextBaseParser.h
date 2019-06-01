/**
 * @file ESpaceRichTextBaseParser.h
 *
 * Copyright (c) 2015 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:um resource file parse service operation class head file.
 * [cn]描述：富媒体文件解析业务操作类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import "ECSRichTextView.h"
#import "ESpaceEmotions.h"

#define UM_FILE_TYPE   @"File"
#define UM_AUDIO_TYPE  @"Audio"
#define UM_VIDEO_TYPE  @"Video"
#define UM_FAX_TYPE    @"Fax"
#define UM_IMG_TYPE    @"Img"

/**
 * [en]This enum is about um resource type.
 * [cn]富媒体类型
 */
typedef NS_ENUM(NSInteger, ESpaceUMType) {
    ESpaceUMTypeUnknown = 0,        /**< [en]Indicates unknown.
                                     <br>[cn]未知 */
    ESpaceUMTypeFile = 1,           /**< [en]Indicates file.
                                     <br>[cn]文件 */
    ESpaceUMTypeAudio = 2,          /**< [en]Indicates audio.
                                     <br>[cn]音频 */
    ESpaceUMTypeVideo = 3,          /**< [en]Indicates video.
                                     <br>[cn]视频 */
    ESpaceUMTypeFax = 4,            /**< [en]Indicates fax.
                                     <br>[cn]传真 */
    ESpaceUMTypeImage = 5           /**< [en]Indicates image.
                                     <br>[cn]图片 */
};

//@class ESpaceUMResource;

/**
 * [en] This class is about emotion token.
 * [cn] 表情token类
 */
@interface ESpaceEmotion : ECSEmotion

@property (nonatomic, strong) ESpaceEmotionItem* emotionItem;

/**
 * @brief [en] This method is used to init with emotion item.
 *        <br>[cn] 根据表情item生成表情占位对象
 *
 * @param [in] ESpaceEmotionItem* emotionItem     <b>:</b><br>[en] Indicates emotion item.
 *                                                        <br>[cn] 表情item
 * @param [in] NSRange range                      <b>:</b><br>[en] Indicates emotion range.
 *                                                        <br>[cn] 表情所在文本中的位置
 * @retval id                                     <b>:</b><br>[en] Return ESpaceEmotion object if success, or return nil.
 *                                                        <br>[cn] 成功返回ESpaceEmotion对象，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (id) initWithEmotionItem:(ESpaceEmotionItem*) emotionItem range:(NSRange) range;
@end

/**
 * [en] This class is about picture or video token.
 * [cn] 图片或者视频token类
 */
@interface ESpaceUMPlaceHolder : ECSPlaceHolder
//@property (nonatomic, strong) ESpaceUMResource* umResource;
@end

/**
 * [en] This class is about url link token.
 * [cn] 链接token类
 */
@interface ESpaceUrlLink : ECSTextLabel
@property (nonatomic, strong) NSURL* url;
@end

/**
 * [en] This class is about telephone number token.
 * [cn] 电话号码token类
 */
@interface ESpaceTelLink : ECSTextLabel
@end

/**
 * [en] This class is about email token.
 * [cn] 邮件token类
 */
@interface ESpaceEmailLink : ECSTextLabel
@end

/**
 * [en] This class is about rich text base parser.
 * [cn] 解析富媒体资源基础类
 */
@interface ESpaceRichTextBaseParser : NSObject <ECSRichTextParserDelegate>


/**
 * @brief [en] This method is used to get match result of text
 *        <br>[cn] 根据正则表达式返回匹配结果
 *
 * @param [in] NSString* text                     <b>:</b><br>[en] Indicates text.
 *                                                        <br>[cn] 待检查文本
 * @param [in] NSString* regularExpression        <b>:</b><br>[en] Indicates regular expression.
 *                                                        <br>[cn] 正则表达式
 * @param [in] NSRegularExpressionOptions options <b>:</b><br>[en] Indicates regular expression options.
 *                                                        <br>[cn] 匹配选项
 * @retval NSArray *                              <b>:</b><br>[en] Return match result if success, meta is (NSTextCheckingResult *) type array, if failed retrun nil.
 *                                                        <br>[cn] 成功返回匹配结果,元素是(NSTextCheckingResult *)类型数组，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
-(NSArray*)returnMatchResultOfText:(NSString*)text  withRegularExpression:(NSString*)regularExpression option:(NSRegularExpressionOptions) options;
@end
