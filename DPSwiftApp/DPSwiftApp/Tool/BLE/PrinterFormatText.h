//
//  PrinterFormatText.h
//  BLPrint
//
//  Created by YJ on 16/6/7.
//  Copyright © 2016年 YJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSeperaterLine  @"--------------------------------"
#define kFinishLine  @"********************************"
#define kPaddingPlaceholder @"  "

@interface PrinterFormatText : NSObject

+ (NSString *)getTextsWithLeft:(NSString *)left middle:(NSString *)middle right:(NSString *)right;




@end
