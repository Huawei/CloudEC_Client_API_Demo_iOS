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
 * Welcome to CocoaLumberjack!
 *
 * The project page has a wealth of documentation if you have any questions.
 * https://github.com/CocoaLumberjack/CocoaLumberjack
 *
 * If you're new to the project you may wish to read "Getting Started" at:
 * Documentation/GettingStarted.md
 *
 * Otherwise, here is a quick refresher.
 * There are three steps to using the macros:
 *
 * Step 1:
 * Import the header in your implementation or prefix file:
 *
 * #import <CocoaLumberjack/CocoaLumberjack.h>
 *
 * Step 2:
 * Define your logging level in your implementation file:
 *
 * // Log levels: off, error, warn, info, verbose
 * static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
 *
 * Step 2 [3rd party frameworks]:
 *
 * Define your ECSLOG_LEVEL_DEF to a different variable/function than ddLogLevel:
 *
 * // #undef ECSLOG_LEVEL_DEF // Undefine first only if needed
 * #define ECSLOG_LEVEL_DEF myLibLogLevel
 *
 * Define your logging level in your implementation file:
 *
 * // Log levels: off, error, warn, info, verbose
 * static const DDLogLevel myLibLogLevel = DDLogLevelVerbose;
 *
 * Step 3:
 * Replace your NSLog statements with DDLog statements according to the severity of the message.
 *
 * NSLog(@"Fatal error, no dohickey found!"); -> DDLogError(@"Fatal error, no dohickey found!");
 *
 * DDLog works exactly the same as NSLog.
 * This means you can pass it multiple variables just like NSLog.
 **/

#import <Foundation/Foundation.h>

// Disable legacy macros
#ifndef ECS_DD_LEGACY_MACROS
    #define ECS_DD_LEGACY_MACROS 0
#endif

// Core
#import "ECSDDLog.h"

// Main macros
#import "ECSDDLogMacros.h"
#import "ECSDDAssertMacros.h"

// Capture ASL
#import "ECSDDASLLogCapture.h"

// Loggers
#import "ECSDDTTYLogger.h"
#import "ECSDDASLLogger.h"
#import "ECSDDFileLogger.h"

