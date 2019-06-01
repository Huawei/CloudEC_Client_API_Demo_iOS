/**
 * @file ECSRichTextView.h
 *
 * Copyright (c) 2015 Huawei Tech. Co., Ltd. All rights reserved. \n
 *
 * @brief [en]Description:um resource content parse service operation head file.
 * [cn]描述：富媒体内容解析业务操作类头文件。 \n
 **/

#import <UIKit/UIKit.h>

@protocol ECSRichTextParserDelegate <NSObject>


/**
 * @brief [en] This method is used to parse content.
 *        <br>[cn] 对文本内容进行解析
 *
 * @param [in] NSString* content    <b>:</b><br>[en] Indicates content.
 *                                          <br>[cn] 文本内容
 * @retval NSArray *                <b>:</b><br>[en] Return ECSControl * array if success, or return nil.
 *                                          <br>[cn] 成功返回(ECSControl *)数组，失败返回nil
 * @attention [en] match priority level: umresource>link>emotion>telephone number
 *            <br>[cn] 匹配优先级: 富媒体 > 链接 > 表情 > 电话号码
 * @see NA
 **/
- (NSArray*) parseContent:(NSString*) content;


/**
 * @brief [en] This method is used to get suit size for displaying content.
 *        <br>[cn] 返回适合显示文本的尺寸
 *
 * @param [in] NSString* content            <b>:</b><br>[en] Indicates content.
 *                                                  <br>[cn] 文本内容
 * @param [in] CGFloat width                <b>:</b><br>[en] Indicates maximum width.
 *                                                  <br>[cn] 最大宽度
 * @param [in] UIFont* font                 <b>:</b><br>[en] Indicates font.
 *                                                  <br>[cn] 字体
 * @param [in] CGFloat lineSpace            <b>:</b><br>[en] Indicates line space.
 *                                                  <br>[cn] 行间距
 * @param [in] NSLineBreakMode breakMode    <b>:</b><br>[en] Indicates break mode.
 *                                                  <br>[cn] 换行类型
 * @retval CGSize                           <b>:</b><br>[en] Return suit size for displaying content if success, or return CGSizeZero.
 *                                                  <br>[cn] 成功返回适合显示文本的尺寸，失败返回CGSizeZero
 * @attention [en] according to paragraph format return suit size for displaying content
 *            <br>[cn] 根据设置的段落格式返回适合显示文本的尺寸
 * @see NA
 **/
- (CGSize) suggestSizeWithContent:(NSString*) content maxWidth:(CGFloat) width font:(UIFont*) font lineSpace:(CGFloat) lineSpace lineBreakMode:(NSLineBreakMode) breakMode;


/**
 * @brief [en] This method is used to get suit size for displaying content.
 *        <br>[cn] 返回适合显示文本的尺寸
 *
 * @param [in] NSArray* controls            <b>:</b><br>[en] Indicates ECSControl array.
 *                                                  <br>[cn] ECSControl数组
 * @param [in] CGFloat width                <b>:</b><br>[en] Indicates maximum width.
 *                                                  <br>[cn] 最大宽度
 * @param [in] UIFont* font                 <b>:</b><br>[en] Indicates font.
 *                                                  <br>[cn] 字体
 * @param [in] CGFloat lineSpace            <b>:</b><br>[en] Indicates line space.
 *                                                  <br>[cn] 行间距
 * @param [in] NSLineBreakMode breakMode    <b>:</b><br>[en] Indicates break mode.
 *                                                  <br>[cn] 换行类型
 * @retval CGSize                           <b>:</b><br>[en] Return suit size for displaying content if success, or return CGSizeZero.
 *                                                  <br>[cn] 成功返回适合显示文本的尺寸，失败返回CGSizeZero
 * @attention [en] according to paragraph format return suit size for displaying content
 *            <br>[cn] 根据给定的段落格式，给ECSControl数组返回适合显示文本的尺寸
 * @see NA
 **/
- (CGSize) suggestSizeWithControls:(NSArray*) controls maxWidth:(CGFloat) width font:(UIFont*) font lineSpace:(CGFloat) lineSpace lineBreakMode:(NSLineBreakMode) breakMode;
@end

@class ECSRichTextView;

/**
 * [en] This class is about place holder.
 * [cn] 占位的类
 **/
@interface ECSControl : NSObject

@property (nonatomic, assign) NSUInteger tag;
@property (nonatomic, assign) NSRange rangeInContent;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, strong) ECSRichTextView* parentView;


/**
 * @brief [en] This method is used to add target.
 *        <br>[cn] 添加点击动作
 *
 * @param [in] id target               <b>:</b><br>[en] Indicates target object.
 *                                             <br>[cn] 目标对象
 * @param [in] SEL action              <b>:</b><br>[en] Indicates action.
 *                                             <br>[cn] 动作
 * @attention [en] add target for this place holder object.
 *            <br>[cn] 给该占位对象添加点击动作
 * @see NA
 **/
- (void) addTarget:(id) target action:(SEL)action;

@end

/**
 * [en] This class is about content label.
 * [cn] 文本label类
 **/
@interface ECSTextLabel : ECSControl

@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, assign) NSUnderlineStyle underlineStyle;
@property (nonatomic, strong) UIColor* underlineColor;

@end

/**
 * [en] This class is about emotion place holder.
 * [cn] 表情占位类
 **/
@interface ECSEmotion : ECSControl

@property (nonatomic, copy) NSString* replacement;
@property (nonatomic, strong) UIImage* emotionImage;

@end

/**
 * [en] This class is about ecs place holder.
 * [cn] 占位器类
 **/
@interface ECSPlaceHolder : ECSControl

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) UIView* view;

@end

/**
 * [en] This class is about rich text view.
 * [cn] 富文本视图类
 **/
@interface ECSRichTextView : UIView

@property (nonatomic, strong) NSArray* controls;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, weak) id<ECSRichTextParserDelegate> parser;
@property (nonatomic, readonly, strong) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic, readonly, strong) UILongPressGestureRecognizer* longPressGestureRecognizer;
@property (nonatomic, assign) BOOL touchEnabled;
@property (nonatomic, assign) NSUInteger maxLineCount;
@property (nonatomic, assign) BOOL allowCopy;
//该属性用于做自动化测试，用于本身text为nil同时又不能赋值text的情况下使用
@property (nonatomic, copy) NSString *accessibilityTextValue;
@property (nonatomic, copy) NSString *accessibilityTextLabel;


/**
 * @brief [en] This method is used to get text string content.
 *        <br>[cn] 返回文本字符内容
 *
 * @param [in] NSArray* controls            <b>:</b><br>[en] Indicates ECSControl array.
 *                                                  <br>[cn] ECSControl数组
 * @param [in] CGFloat width                <b>:</b><br>[en] Indicates width.
 *                                                  <br>[cn] 最大宽度
 * @param [in] UIFont* font                 <b>:</b><br>[en] Indicates font.
 *                                                  <br>[cn] 字体
 * @param [in] CGFloat lineSpace            <b>:</b><br>[en] Indicates line space.
 *                                                  <br>[cn] 行间距
 * @param [in] NSLineBreakMode breakMode    <b>:</b><br>[en] Indicates break mode.
 *                                                  <br>[cn] 换行类型
 * @retval NSMutableAttributedString *      <b>:</b><br>[en] Return text string content if success, or return nil.
 *                                                  <br>[cn] 成功返回文本字符内容，失败返回nil
 * @attention [en] according to paragraph format return suit size for displaying content
 *            <br>[cn] 根据给定的段落格式给传入的ECSControl数组返回文本字符内容
 * @see NA
 **/
+ (NSMutableAttributedString*) attributeStringForSuggestSize:(NSArray*) _controls
                                                    maxWidth:(CGFloat) width
                                                        font:(UIFont*) font
                                                   lineSpace:(CGFloat) lineSpace
                                               lineBreakMode:(NSLineBreakMode) breakMode;


/**
 * @brief [en] This method is used to set default target.
 *        <br>[cn] 添加默认动作
 *
 * @param [in] id defTarget            <b>:</b><br>[en] Indicates target object.
 *                                             <br>[cn] 目标对象
 * @param [in] SEL action              <b>:</b><br>[en] Indicates action.
 *                                             <br>[cn] 动作
 * @attention [en] add default target to view.
 *            <br>[cn] 给视图添加默认动作
 * @see NA
 **/
- (void) setDefaultTarget:(id) defTarget withAction:(SEL) action;

@end
