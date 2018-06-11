//
//  ContactInterface.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#ifndef ContactInterface_h
#define ContactInterface_h

#define PAGE_ITEM_SIZE  50 //suggest twenty per page

extern NSString *const TUP_CONTACT_EVENT_RESULT_KEY;
extern NSString *const TUP_CONTACT_KEY;
extern NSString *const TUP_DEPARTMENT_KEY;
extern NSString *const TUP_DEPARTMENT_RESULT_KEY;
extern NSString *const TUP_CONTACT_HEADERIMG_KEY;
extern NSString *const TUP_SYS_ICON_ID_KEY;
extern NSString *const TUP_ICON_FILE_KEY;

/**
 *Indicates contact event type
 *联系人事件类型
 */
typedef enum : NSUInteger {
    CONTACT_E_SEARCH_CONTACT_RESULT,
    CONTACT_E_SEARCH_DEPARTMENT_RESULT,
    CONTACT_E_SEARCH_GET_ICON_RESULT
} TUP_CONTACT_EVENT_TYPE;

@protocol TUPContactServiceDelegate <NSObject>

/**
 * This method is used to deel contact event callback
 * 处理联系人事件回调
 *@param contactEvent              Indicates contact event type, see TUP_CONTACT_EVENT_TYPE value
 *                                 联系人事件类型， 参考TUP_CONTACT_EVENT_TYPE
 *@param resultDictionary          result value
 *                                 回调信息集
 */
-(void)contactEventCallback:(TUP_CONTACT_EVENT_TYPE)contactEvent result:(NSDictionary *)resultDictionary;

@end

@class UIImage;
@class SearchParam;
@class LoginServerInfo;
@protocol ContactInterface <NSObject>

/**
 *Indicates contact service delegate
 *联系人业务代理
 */
@property (nonatomic, weak) id<TUPContactServiceDelegate> delegate;

/**
 * This method is used to search self terminalNumber;
 * 搜索自己的软终端号码
 */
- (void)searchContactsToConfigSelfTerminalNum;

/**
 * This method is used to set system head image (0~9) (if completionBlock result is YES, set self head ID with sysIconID)
 * 设置系统头像
 *@param sysIconID                 Indicates system head image ID
 *                                 系统头像id
 *@param completionBlock           Indicates callback(result: set head image result. YES or NO)
 *                                 回调，返回设置头像成功与否
 */
- (void)setSystemHead:(int)sysIconID withCmpletion:(void(^)(BOOL result))completionBlock;

/**
 * This method is used to set custom head image (if completionBlock result is YES, set self hedID with headID)
 * 设置自定义头像
 *@param image                     Indicates custom image
 *                                 自定义头像
 *@param completionBlock           Indicates callback(result: set head image result. YES or NO)
 *                                 回调，返回设置头像成功与否
 */
- (void)setHeadImage:(UIImage *)image completion:(void(^)(BOOL result, NSString *headID))completionBlock;

/**
 * This method is used to search corporate directory contacts
 * 搜索联系人信息
 *@param searchParam               Indicates search param, see SearchParam value (Search conditions)
 *                                 用于搜索联系人的参数
 */
- (void)searchContactWithParam:(SearchParam *)searchParam;

/**
 * This method is used to search corporate directory departments list
 * 搜索部门列表
 *@param deptID                    Indicates parent department ID
 *                                 部门id
 */
- (void)searchDeptListWithID:(NSString *)deptID;

/**
 * This method is used to load contact head image from corporate directory
 * 加载个人头像
 *@param account                   Indicates user account
 *                                 用户账号
 */
- (void)loadPersonHeadIconWithAccount:(NSString *)account;

@end

#endif /* ContactInterface_h */


