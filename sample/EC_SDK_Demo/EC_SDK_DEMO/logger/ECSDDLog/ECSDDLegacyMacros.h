// Software License Agreement (BSD License)
//
// Copyright (c) 2010-2015, Deusty, LLC
// All rights reserved.
//
// Redistribution and use of this software in source and binary forms,
// with or without modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
//
// * Neither the name of Deusty nor the names of its contributors may be used
//   to endorse or promote products derived from this software without specific
//   prior written permission of Deusty, LLC.

/**
 * Legacy macros used for 1.9.x backwards compatibility.
 *
 * Imported by default when importing a DDLog.h directly and ECS_DD_LEGACY_MACROS is not defined and set to 0.
 **/
#if ECS_DD_LEGACY_MACROS

#warning CocoaLumberjack 1.9.x legacy macros enabled. \
Disable legacy macros by importing CocoaLumberjack.h or ESpaceDDLogMacros.h instead of ECSDDLog.h.h or add `#define ECS_DD_LEGACY_MACROS 0` before importing ECSDDLog.h.

#ifndef ECSLOG_LEVEL_DEF
//    #define ECSLOG_LEVEL_DEF ddLogLevel
    #define ECSLOG_LEVEL_DEF [ECSeLogger shareInstance].logLevel
#endif

#define ECSLOG_FLAG_ERROR    ECSDDLogFlagError
#define ECSLOG_FLAG_WARN     ECSDDLogFlagWarning
#define ECSLOG_FLAG_INFO     ECSDDLogFlagInfo
#define ECSLOG_FLAG_DEBUG    ECSDDLogFlagDebug
#define ECSLOG_FLAG_VERBOSE  ECSDDLogFlagVerbose

#define ECSLOG_LEVEL_OFF     ECSDDLogLevelOff
#define ECSLOG_LEVEL_ERROR   ECSDDLogLevelError
#define ECSLOG_LEVEL_WARN    ECSDDLogLevelWarning
#define ECSLOG_LEVEL_INFO    ECSDDLogLevelInfo
#define ECSLOG_LEVEL_DEBUG   ECSDDLogLevelDebug
#define ECSLOG_LEVEL_VERBOSE ECSDDLogLevelVerbose
#define ECSLOG_LEVEL_ALL     ECSDDLogLevelAll

#define ECSLOG_ASYNC_ENABLED YES

#define ECSLOG_ASYNC_ERROR    ( NO && ECSLOG_ASYNC_ENABLED)
#define ECSLOG_ASYNC_WARN     (YES && ECSLOG_ASYNC_ENABLED)
#define ECSLOG_ASYNC_INFO     (YES && ECSLOG_ASYNC_ENABLED)
#define ECSLOG_ASYNC_DEBUG    (YES && ECSLOG_ASYNC_ENABLED)
#define ECSLOG_ASYNC_VERBOSE  (YES && ECSLOG_ASYNC_ENABLED)

#define ECSLOG_MACRO(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
        [ECSDDLog log : isAsynchronous                                     \
             level : lvl                                                \
              flag : flg                                                \
           context : ctx                                                \
              file : __FILE__                                           \
          function : fnct                                               \
              line : __LINE__                                           \
               tag : atag                                               \
            format : (frmt), ## __VA_ARGS__]

#define ECSLOG_MAYBE(async, lvl, flg, ctx, fnct, frmt, ...)                       \
        do { if(lvl & flg) ECSLOG_MACRO(async, lvl, flg, ctx, nil, fnct, frmt, ##__VA_ARGS__); } while(0)

#define ECSLOG_OBJC_MAYBE(async, lvl, flg, ctx, frmt, ...) \
        ECSLOG_MAYBE(async, lvl, flg, ctx, __PRETTY_FUNCTION__, frmt, ## __VA_ARGS__)

#define DDLogError(frmt, ...)   ECSLOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   ECSLOG_LEVEL_DEF, ECSLOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define DDLogWarn(frmt, ...)    ECSLOG_OBJC_MAYBE(LOG_ASYNC_WARN,    ECSLOG_LEVEL_DEF, ECSLOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define DDLogInfo(frmt, ...)    ECSLOG_OBJC_MAYBE(LOG_ASYNC_INFO,    ECSLOG_LEVEL_DEF, ECSLOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define DDLogDebug(frmt, ...)   ECSLOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,   ECSLOG_LEVEL_DEF, ECSLOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define DDLogVerbose(frmt, ...) ECSLOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, ECSLOG_LEVEL_DEF, ECSLOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

#endif
