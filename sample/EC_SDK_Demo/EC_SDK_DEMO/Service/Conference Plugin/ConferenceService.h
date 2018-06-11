//
//  ConferenceService.h
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//

#import <Foundation/Foundation.h>
#import "ConferenceInterface.h"

/*create conference steps :
1、tup_confctrl_book_conf.
2、CONFCTRL_E_EVT_UPORTAL_BOOK_CONF_RESULT ,if conference is immediately ,need to join conference ;if conference is subscribe,no need to join conference.
3、join voice conference
 */


/* join voice conference
1、three steps : create ConfHandle -- subscribe Conference -- create ConfConfCtrl.
2、CONFCTRL_E_EVT_ATTENDEE_LIST_UPDATE_IND ,update confInfo.
3、if self status is not leave conference and conference is going ,jump to confRunningView.
 */


/* join data conf need get confDataParams , from three path :
1、onReceiveTupCallSipInfoNotification.
2、CONFCTRL_E_EVT_ATTENDEE_LIST_UPDATE_IND.
3、CONFCTRL_E_EVT_REQUEST_CONF_RIGHT_RESULT.
 */

@interface ConferenceService : NSObject<ConferenceInterface>

@end
