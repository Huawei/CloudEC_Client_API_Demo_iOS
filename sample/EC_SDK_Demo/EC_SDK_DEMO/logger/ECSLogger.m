//
//  ECSLogger.m
//  EC_SDK_DEMO
//
//  Created by EC Open support team.
//  Copyright(C), 2017, Huawei Tech. Co., Ltd. ALL RIGHTS RESERVED.
//
#import "ECSLogger.h"
// logger
#import "ECSDDASLLogger.h"
#import "ECSDDTTYLogger.h"
#import "ECSDDFileLogger.h"

static ECSLogger *stk_logger = nil;
//static DDLogLevel ddLogLevel = DDLogLevelAll;

@interface ECSLogger () <ECSDDLogFormatter>
{
 @private
    NSDateFormatter *_dateFormatter;
}

@end

@implementation ECSLogger

/**
 *This method is used to creat single instance of this class
 *创建该类的单例
 */
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stk_logger = [[ECSLogger alloc] init];
    });
    
    return stk_logger;
}

/**
 *This method is used to print current thread invoke stack when service is exception or param is not correspond to suppose
 *  打印当前线程的调用栈, 用于业务异常或者参数与预期不符合时候可以用来打印调用栈, PS：只有日志级别在debug一下才会打印。
 */
+ (void)printDebugStack
{
    NSString *strCallStack = [NSString stringWithFormat:@"call stack info:\n %@", [NSThread callStackSymbols]];
    DDLogDebug(@"%@", strCallStack);
}

/**
 *This method is used to update UI log level
 *更新UI日志级别
 */
- (void)updateUILoginLevel
{
    /*
     kECSLogDebug	= 0,
     kECSLogInfo		= 1,
     kECSLogError	= 2,
     kECSLogVerbose	= 3,
     */
    ECSDDLogLevel newLevel = ECSDDLogLevelDebug;
    
    self.logLevel = newLevel;
}

- (void)dealloc
{
}

/**
 *This method is used to init this class
 *初始化方法
 */
- (instancetype)init
{
    if (self = [super init]) {
        
        [self updateUILoginLevel];
        
        BOOL clolorsEnabled = NO;
#if USING_COLOR_LOGGER
        clolorsEnabled = YES;
        setenv("XcodeColors", "YES", 0);
#endif
        ECSDDTTYLogger *ttyLogger      = [ECSDDTTYLogger sharedInstance];
        // set log string colors
        UIColor *bgColor = [UIColor colorWithRed:0.264 green:0.420 blue:1.000 alpha:1.000];
        [ttyLogger setForegroundColor:[UIColor redColor] backgroundColor:bgColor forFlag:ECSDDLogFlagError];
        [ttyLogger setForegroundColor:[UIColor magentaColor] backgroundColor:bgColor forFlag:ECSDDLogFlagWarning];
        [ttyLogger setForegroundColor:[UIColor orangeColor] backgroundColor:bgColor forFlag:ECSDDLogFlagInfo];
        [ttyLogger setForegroundColor:[UIColor brownColor] backgroundColor:bgColor forFlag:ECSDDLogFlagDebug];
        [ttyLogger setForegroundColor:[UIColor lightGrayColor] backgroundColor:bgColor forFlag:ECSDDLogFlagVerbose];
        ttyLogger.colorsEnabled     = clolorsEnabled;
        ttyLogger.logFormatter      = self;
        [ECSDDLog addLogger:ttyLogger];

        
    }
    return self;
}

/**
 * This method is used to add UI log print
 *  添加UI日志打印文件
 */
- (void)addFileLogger {
    
    NSString *logPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/TUPC60log/UI"];
    id<ECSDDLogFileManager> logFileManage = [[ECSDDLogFileManagerDefault alloc] initWithLogsDirectory:logPath];
    ECSDDFileLogger *fileLogger    = [[ECSDDFileLogger alloc] initWithLogFileManager:logFileManage];
    // print log messages into one same log file every 24 hours.
    fileLogger.rollingFrequency = 60 * 60 * 24;
    // save 7 log files as maximum.
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    fileLogger.logFormatter = self;
    
    [ECSDDLog addLogger:fileLogger];
}

#pragma mark ECSDDLogFormatter
/**
 *This method is used to format log message
 *格式化日志输出格式
 */
- (NSString *)formatLogMessage:(ECSDDLogMessage *)logMessage
{
    if (nil == logMessage) {
        return @"nil logMessage";
    }
    @synchronized (self) {
        if (nil == _dateFormatter) {
            _dateFormatter = [[NSDateFormatter alloc] init];
            [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss,SSS"];
        }
    }
    NSString *dateAndTime = logMessage->_timestamp ? [_dateFormatter stringFromDate:(logMessage->_timestamp)] : @" ";
    
    NSString *strLogLevel = @"%@:<FILE>%@</FILE> <LINE>%u<LINE> <FUNC>%@</FUNC>";
    switch (logMessage.flag) {
        case ECSDDLogFlagError:
            strLogLevel = [NSString stringWithFormat:strLogLevel, @"<ERR>", logMessage->_fileName, logMessage->_line, logMessage->_function];
            break;
            
        case ECSDDLogFlagWarning:
            strLogLevel = [NSString stringWithFormat:strLogLevel, @"<WRN>", logMessage->_fileName, logMessage->_line, logMessage->_function];
            break;
            
        case ECSDDLogFlagInfo:
            strLogLevel = [NSString stringWithFormat:strLogLevel, @"<INF>", logMessage->_fileName, logMessage->_line, logMessage->_function];
            break;
            
        case ECSDDLogFlagDebug:
            strLogLevel = [NSString stringWithFormat:strLogLevel, @"<DBG>", logMessage->_fileName, logMessage->_line, logMessage->_function];
            break;
            
        case ECSDDLogFlagVerbose:
            strLogLevel = [NSString stringWithFormat:strLogLevel, @"<VBS>", logMessage->_fileName, logMessage->_line, logMessage->_function];
            break;
            
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"%@ [%@:%@] %@ %@",
            dateAndTime,
            logMessage->_threadName,
            logMessage->_threadID,
            strLogLevel,
            logMessage->_message];
}

@end
