//
//  ECSafeMutableDictionary.m
//  eSpace
//
//  Created by yemingxing on 8/7/15.
//  Copyright (c) 2015 www.huawei.com. All rights reserved.
//

#import "ECSafeMutableDictionary.h"

@interface ECSafeMutableDictionary() {
    NSRecursiveLock * _lock;
    CFMutableDictionaryRef _dictionaryRef;
}

@end

@implementation ECSafeMutableDictionary

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [super init]) {
        _lock = [[NSRecursiveLock alloc] init];
        _dictionaryRef = CFDictionaryCreateMutable(kCFAllocatorDefault, numItems, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (instancetype) init {
    if (self = [super init]) {
        _lock = [[NSRecursiveLock alloc] init];
        _dictionaryRef = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt {
    if (self = [self init]) {
        for (NSInteger idx = 0; idx < cnt; ++idx) {
            CFDictionaryAddValue(_dictionaryRef, (__bridge const void *)(keys[idx]), (__bridge const void *)(objects[idx]));
        }
    }
    return self;
}

- (void)dealloc {
    if (_dictionaryRef) {
        CFRelease(_dictionaryRef);
        _dictionaryRef = NULL;
    }
}

- (NSUInteger)count {
    [_lock lock];
    NSUInteger count = CFDictionaryGetCount(_dictionaryRef);
    [_lock unlock];
    return count;
}

- (id)objectForKey:(id)aKey {
    if (!aKey) {
        return nil;
    }
    [_lock lock];
    id result = CFDictionaryGetValue(_dictionaryRef, (__bridge const void *)aKey);
    [_lock unlock];
    return result;
}

- (NSEnumerator *)keyEnumerator {
    [_lock lock];
    id result = [(__bridge id)_dictionaryRef keyEnumerator];
    [_lock unlock];
    return result;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject || !aKey) {
        return;
    }
    [_lock lock];
    CFDictionarySetValue(_dictionaryRef, (__bridge const void *)aKey, (__bridge const void *)anObject);
    [_lock unlock];
}

- (void)removeObjectForKey:(id)aKey {
    if (!aKey) {
        return;
    }
    [_lock lock];
    CFDictionaryRemoveValue(_dictionaryRef, (__bridge const void *)aKey);
    [_lock unlock];
}

- (void)removeAllObjects {
    [_lock lock];
    CFDictionaryRemoveAllValues(_dictionaryRef);
    [_lock unlock];
}

- (void)lock {
    [_lock lock];
}

- (void)unlock {
    [_lock unlock];
}

@end
