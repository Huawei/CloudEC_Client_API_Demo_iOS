//
//  ESpaceEmotionParser.h
//  eSpaceUI
//
//  Created on 3/20/15.
//  Copyright (c) 2015 Huawei Tech. Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ESpaceEmotionItem : NSObject

@property (nonatomic, strong, readonly) NSString* escapeString;
@property (nonatomic, strong, readonly) NSString* imageName;
@property (nonatomic, strong, readonly) UIImage* image;
@property (nonatomic, strong, readonly) NSRegularExpression* regExp;

@end

@interface ESpaceEmotions : NSObject

@property (nonatomic, strong, readonly) NSArray* emotionItems;
@property (nonatomic, strong, readonly) NSString* regExp;
@property (nonatomic, strong, readonly) NSDictionary *emotionDict;

+ (instancetype) sharedInstance;

- (ESpaceEmotionItem*) searchEmotion:(NSString*) escapeStr;

@end
