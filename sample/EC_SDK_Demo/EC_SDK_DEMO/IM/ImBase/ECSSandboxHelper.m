//
//  ECSSandboxHelper.m
//  eSpaceIOSSDK
//
//  Created by wangxiangyang on 7/6/16.
//  Copyright © 2016 HuaWei. All rights reserved.
//

#import "ECSSandboxHelper.h"
//#import <ctk.h>
//#import "ECSLogCofig.h"

@implementation ECSSandboxConfiguration


@end

@implementation ECSSandboxHelper

@synthesize logFileSuperPath = _logFileSuperPath;
@synthesize logFileRootName = _logFileRootName;
@synthesize logFilePath = _logFilePath;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static ECSSandboxHelper *sandboxHelper = nil;
    dispatch_once(&onceToken, ^{
        sandboxHelper = [[ECSSandboxHelper alloc] init];
    });
    
    return sandboxHelper;
}

- (void)setSandboxConfiguration:(ECSSandboxConfiguration *)configuration{
    _sandboxConfiguration = configuration;
    //SDK_INFO_LOG("set app sandbox path:\n document:" << configuration.document.description.UTF8String << "\n library:" << configuration.library.description.UTF8String << "\n, caches:" << configuration.caches.description.UTF8String << "\n, preferences:" << configuration.preferences.description.UTF8String << "\n,temp:" << configuration.temp.description.UTF8String);
    
    if ([configuration.document length] && NO ==[[NSFileManager defaultManager] fileExistsAtPath:configuration.document]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:configuration.document withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([configuration.document length] && NO ==[[NSFileManager defaultManager] fileExistsAtPath:configuration.document]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:configuration.document withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([configuration.library length] && NO ==[[NSFileManager defaultManager] fileExistsAtPath:configuration.library]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:configuration.library withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([configuration.caches length] && NO ==[[NSFileManager defaultManager] fileExistsAtPath:configuration.caches]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:configuration.caches withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([configuration.preferences length] && NO ==[[NSFileManager defaultManager] fileExistsAtPath:configuration.preferences]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:configuration.preferences withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([configuration.temp length] && NO ==[[NSFileManager defaultManager] fileExistsAtPath:configuration.temp]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:configuration.temp withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)documentPath {
    
    NSString* path = nil;
    
    if ([self.sandboxConfiguration.document length]) {
        path = self.sandboxConfiguration.document;
    }
    else{
        NSArray* dcPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = ([dcPaths count] == 0 ? nil : [dcPaths objectAtIndex:0]);
    }
    return path;
}

- (NSString *)libraryPath {
    
    NSString* path = nil;
    
    if ([self.sandboxConfiguration.library length]) {
        path = self.sandboxConfiguration.library;
    }
    else{
        NSArray* lbPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        path = ([lbPaths count] == 0 ? nil : [lbPaths objectAtIndex:0]);
    }
    return path;
}

- (NSString *)cachesPath {
    
    NSString* path = nil;
    
    if ([self.sandboxConfiguration.caches length]) {
        path = self.sandboxConfiguration.caches;
    }
    else{
        NSArray* chPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        path = ([chPaths count] == 0 ? nil : [chPaths objectAtIndex:0]);
    }
    return path;
}

- (NSString *)preferencesPath {
    
    NSString* path = nil;
    
    if ([self.sandboxConfiguration.preferences length]) {
        path = self.sandboxConfiguration.preferences;
    }
    else{
        NSArray* pfPaths = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES);
        path = ([pfPaths count] == 0 ? nil : [pfPaths objectAtIndex:0]);
    }
    return path;
}

- (NSString *)tempPath {
    
    NSString* path = nil;
    
    if ([self.sandboxConfiguration.temp length]) {
        path = self.sandboxConfiguration.temp;
    }
    else{
        path = NSTemporaryDirectory();
    }
    return path;
}

- (NSBundle *)UIResourceBundle {
    if (self.sandboxConfiguration.UIResourceBundle) {
        return self.sandboxConfiguration.UIResourceBundle;
    }
    return [NSBundle mainBundle];
}

#pragma mark - logs
- (NSString *)logFileSuperPath {
    if (0 == [_logFileSuperPath length]) {
        _logFileSuperPath = [ECSSandboxHelper shareInstance].libraryPath;
    }
    
    return _logFileSuperPath;
}

- (NSString *)logFileRootName {
    if (0 == [_logFileRootName length]) {
        _logFileRootName = @"Logs";
    }
    
    return _logFileRootName;
}

- (NSString *)logFilePath {
    return [self.logFileSuperPath stringByAppendingPathComponent:self.logFileRootName];
}

@end
