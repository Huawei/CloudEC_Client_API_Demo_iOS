/**
 * @file PersonEntity.h
 *
 * @brief [en]Description:personal basic service info class head file.
 * [cn]描述：个人基础业务信息类头文件。 \n
 **/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ContactEntity.h"

@class EmployeeCategoryEntity, LocalContactEntity;

/**
 * [en] This class is about personal basic service info.
 * [cn] 个人基础业务信息类
 **/
@interface PersonEntity : ContactEntity

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * assistantList;
@property (nonatomic, retain) NSNumber * bdHideFlag;
@property (nonatomic, retain) NSString * bindNumber;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * deptDesc;
@property (nonatomic, retain) NSString * deptDescEnglish;
@property (nonatomic, retain) NSString * deptName;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * faxList;
@property (nonatomic, retain) NSString * foreignName;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * homePage;
@property (nonatomic, retain) NSString * homePhone;
@property (nonatomic, retain) NSString * interPhoneList;
@property (nonatomic, retain) NSNumber * isFriend;
@property (nonatomic, retain) NSString * m2;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * mobileList;
@property (nonatomic, retain) NSString * nativeName;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * notesMail;
@property (nonatomic, retain) NSString * officePhone;
@property (nonatomic, retain) NSString * originMobile;
@property (nonatomic, retain) NSString * originOffice;
@property (nonatomic, retain) NSString * otherInfo;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * phoneList;
@property (nonatomic, retain) NSString * pinyinName;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSNumber * recvCircleMsg;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSNumber * sendCircleMsg;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * shortNumber;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * simplifiedPinyin;
@property (nonatomic, retain) NSString * softClientExtPhone;
@property (nonatomic, retain) NSString * softClientExtPhoneDomain;
@property (nonatomic, retain) NSString * sp2;
@property (nonatomic, retain) NSString * sp2Domain;
@property (nonatomic, retain) NSString * sp3;
@property (nonatomic, retain) NSString * sp3Domain;
@property (nonatomic, retain) NSString * sp4;
@property (nonatomic, retain) NSString * sp4Domain;
@property (nonatomic, retain) NSString * sp5;
@property (nonatomic, retain) NSString * sp5Domain;
@property (nonatomic, retain) NSString * sp6;
@property (nonatomic, retain) NSString * sp6Domain;
@property (nonatomic, retain) NSString * spDomain;
@property (nonatomic, retain) NSString * staffNo;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSString * timezoneValue;
@property (nonatomic, retain) NSNumber * userStatus;
@property (nonatomic, retain) NSString * voip;
@property (nonatomic, retain) NSString * voip2;
@property (nonatomic, retain) NSString * voip2Domain;
@property (nonatomic, retain) NSString * voip3;
@property (nonatomic, retain) NSString * voip4;
@property (nonatomic, retain) NSString * voip5;
@property (nonatomic, retain) NSString * voip6;
@property (nonatomic, retain) NSString * voipDomain;
@property (nonatomic, retain) NSString * voipList;
@property (nonatomic, retain) NSSet *category;
@property (nonatomic, retain) NSString * personId;
@end

/**
 * [en] This class is about person basic service entity.
 * [cn] 个人基础业务功能类
 **/
@interface PersonEntity (CoreDataGeneratedAccessors)

/**
 * @brief [en] This method is used to add group.
 *        <br>[cn] 添加分组
 *
 * @param [in] EmployeeCategoryEntity* value        <b>:</b><br>[en] Indicates group object.
 *                                                          <br>[cn] 分组对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addCategoryObject:(EmployeeCategoryEntity *)value;

/**
 * @brief [en] This method is used to remove group.
 *        <br>[cn] 删除分组
 *
 * @param [in] EmployeeCategoryEntity* value        <b>:</b><br>[en] Indicates group object.
 *                                                          <br>[cn] 分组对象
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeCategoryObject:(EmployeeCategoryEntity *)value;

/**
 * @brief [en] This method is used to add group set.
 *        <br>[cn] 添加分组集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates group object set.
 *                                                          <br>[cn] 分组对象(EmployeeCategoryEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)addCategory:(NSSet *)values;

/**
 * @brief [en] This method is used to remove group set.
 *        <br>[cn] 删除分组集合
 *
 * @param [in] NSSet* values                        <b>:</b><br>[en] Indicates group object set.
 *                                                          <br>[cn] 分组对象(EmployeeCategoryEntity *)集合
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (void)removeCategory:(NSSet *)values;


/**
 * @brief [en] This method is used to get plain name by need.
 *        <br>[cn] 根据需要取个人的名字
 *
 * @param [in] BOOL show                        <b>:</b><br>[en] Indicates whether show id.
 *                                                      <br>[cn] 是否显示工号
 * @param [in] BOOL need                        <b>:</b><br>[en] Indicates whether need display nick name.
 *                                                      <br>[cn] 是否需要显示昵称
 * @param [in] BOOL needRemark                  <b>:</b><br>[en] Indicates whether need show remark name.
 *                                                      <br>[cn] 是否需要显示备注名称
 * @retval NSString *                           <b>:</b><br>[en] Return chosed name if success, or return nil.
 *                                                      <br>[cn] 成功返回按需选择的名字，失败返回nil
 * @attention [en] weLine use.
 *            <br>[cn] weLink使用
 * @see NA
 **/
- (NSString *)plainNameShowId:(BOOL)show needNickName:(BOOL)need needRemarkName:(BOOL)needRemark;


/**
 * @brief [en] This method is used to get plain name by need.
 *        <br>[cn] 根据需要取个人的名字
 *
 * @param [in] BOOL show                        <b>:</b><br>[en] Indicates whether show id.
 *                                                      <br>[cn] 是否显示工号
 * @param [in] BOOL need                        <b>:</b><br>[en] Indicates whether need display nick name.
 *                                                      <br>[cn] 是否需要显示昵称
 * @retval NSString *                           <b>:</b><br>[en] Return chosed name if success, or return nil.
 *                                                      <br>[cn] 成功返回按需选择的名字，失败返回nil
 * @attention [en] eSpace use.
 *            <br>[cn] eSpace使用
 * @see NA
 **/
- (NSString *)plainNameShowId:(BOOL)show needNickName:(BOOL)need;


/**
 * @brief [en] This method is used to get number supports sms.
 *        <br>[cn] 获取支持发送短信的号码
 *
 * @retval NSString *                           <b>:</b><br>[en] Return telephone number if success, or return nil.
 *                                                      <br>[cn] 成功返回电话号码，失败返回nil
 * @attention [en] NA.
 *            <br>[cn] NA
 * @see NA
 **/
- (NSString *)phoneNumSuportsSMS;


/**
 * @brief [en] This method is used to display name by order.
 *        <br>[cn] 按顺序取名字
 *
 * @param [in] BOOL need                        <b>:</b><br>[en] Indicates whether need nick.
 *                                                      <br>[cn] 是否取昵称
 * @param [in] BOOL needRemark                  <b>:</b><br>[en] Indicates whether need remark espace as no.
 *                                                      <br>[cn] 是否取备注名称eSpace均设置为NO
 * @retval NSString *                           <b>:</b><br>[en] Return name if success, or return nil.
 *                                                      <br>[cn] 成功返回名字，失败返回nil
 * @attention [en] welink use.
 *            <br>[cn] weLink使用
 * @see NA
 **/
- (NSString *)displayNameNeedNickName:(BOOL)need needRemarkName:(BOOL)needRemark;


/**
 * @brief [en] This method is used to display name by order.
 *        <br>[cn] 按顺序取名字
 *
 * @param [in] BOOL need                        <b>:</b><br>[en] Indicates whether need nick.
 *                                                      <br>[cn] 是否取昵称
 * @retval NSString *                           <b>:</b><br>[en] Return name if success, or return nil.
 *                                                      <br>[cn] 成功返回名字，失败返回nil
 * @attention [en] espace use.
 *            <br>[cn] eSpace使用
 * @see NA
 **/
- (NSString *)displayNameNeedNickName:(BOOL)need;


/**
 * @brief [en] This method is used to get contact name, delete id, default english name when created group.
 *        <br>[cn] 取联系人name,删除工号，默认为建群时构建群英文名用
 *
 * @retval NSString *                           <b>:</b><br>[en] Return name whitout id if success, or return nil .
 *                                                      <br>[cn] 成功返回返回不带工号的name，失败返回nil
 * @attention [en] get contact name, delete id, default english name when created group.
 *            <br>[cn] 获取联系人name,删除工号，默认为建群时构建群英文名用
 * @see NA
 **/
- (NSString *)enNamewithOutAccount;
@end
