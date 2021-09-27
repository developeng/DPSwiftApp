//
//  WHEscCommand.m
//  WeiHong
//
//  Created by developeng on 2021/9/27.
//

#import "WHEscCommand.h"
#define kHLMargin 20
#define kHLPadding 2
#define kHLPreviewWidth 320

@interface WHEscCommand ()

/** 将要打印的排版后的数据 */
@property (strong, nonatomic)   NSMutableData            *printerData;

@end

@implementation WHEscCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (void)defaultSetting
{
    _printerData = [[NSMutableData alloc] init];
    
    // 1.初始化打印机
    Byte initBytes[] = {0x1B,0x40};
    [_printerData appendBytes:initBytes length:sizeof(initBytes)];
    // 2.设置行间距为1/6英寸，约34个点
    // 另一种设置行间距的方法看这个 @link{-setLineSpace:}
    Byte lineSpace[] = {0x1B,0x32};
    [_printerData appendBytes:lineSpace length:sizeof(lineSpace)];
    // 3.设置字体:标准0x00，压缩0x01;
    Byte fontBytes[] = {0x1B,0x4D,0x00};
    [_printerData appendBytes:fontBytes length:sizeof(fontBytes)];
    
}

#pragma mark - -------------基本操作----------------
/**
 *  换行
 */
- (void)appendNewLine
{
    Byte nextRowBytes[] = {0x0A};
    [_printerData appendBytes:nextRowBytes length:sizeof(nextRowBytes)];
}

/**
 *  回车
 */
- (void)appendReturn
{
    Byte returnBytes[] = {0x0D};
    [_printerData appendBytes:returnBytes length:sizeof(returnBytes)];
}

/**
 *  设置对齐方式
 *
 *  @param alignment 对齐方式：居左、居中、居右
 */
- (void)setAlignment:(WHTextAlignment)alignment
{
    Byte alignBytes[] = {0x1B,0x61,alignment};
    [_printerData appendBytes:alignBytes length:sizeof(alignBytes)];
}

/**
 *  设置字体大小
 *
 *  @param fontSize 字号
 */
- (void)setFontSize:(WHFontSize)fontSize
{
    Byte fontSizeBytes[] = {0x1D,0x21,fontSize};
    [_printerData appendBytes:fontSizeBytes length:sizeof(fontSizeBytes)];
}

/**
 *  选择加粗模式
 *
 *  @param fontStyle 加粗模式
 */
- (void)setFontStyle:(WHFontStyle)fontStyle{
    Byte fontSizeBytes[] = {0x1B,0x45,fontStyle};
    [_printerData appendBytes:fontSizeBytes length:sizeof(fontSizeBytes)];
}

/**
 *  添加文字，不换行
 *
 *  @param text 文字内容
 */
- (void)setText:(NSString *)text
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [text dataUsingEncoding:enc];
    [_printerData appendData:data];
}

/**
 *  添加文字，不换行
 *
 *  @param text    文字内容
 *  @param maxChar 最多可以允许多少个字节,后面加...
 */
- (void)setText:(NSString *)text maxChar:(int)maxChar
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [text dataUsingEncoding:enc];
    if (data.length > maxChar) {
        data = [data subdataWithRange:NSMakeRange(0, maxChar)];
        text = [[NSString alloc] initWithData:data encoding:enc];
        if (!text) {
            data = [data subdataWithRange:NSMakeRange(0, maxChar - 1)];
            text = [[NSString alloc] initWithData:data encoding:enc];
        }
        text = [text stringByAppendingString:@"..."];
    }
    [self setText:text];
}

/**
 *  设置偏移文字
 *
 *  @param text 文字
 */
- (void)setOffsetText:(NSString *)text
{
    // 1.计算偏移量,因字体和字号不同，所以计算出来的宽度与实际宽度有误差(小字体与22字体计算值接近)
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:22.0]};
    NSAttributedString *valueAttr = [[NSAttributedString alloc] initWithString:text attributes:dict];
    int valueWidth = valueAttr.size.width;
    
    // 2.设置偏移量
    [self setOffset:368 - valueWidth];
    
    // 3.设置文字
    [self setText:text];
}

/**
 *  设置偏移量
 *
 *  @param offset 偏移量
 */
- (void)setOffset:(NSInteger)offset
{
    NSInteger remainder = offset % 256;
    NSInteger consult = offset / 256;
    Byte spaceBytes2[] = {0x1B, 0x24, remainder, consult};
    [_printerData appendBytes:spaceBytes2 length:sizeof(spaceBytes2)];
}

/**
 *  设置行间距
 *
 *  @param points 多少个点
 */
- (void)setLineSpace:(NSInteger)points
{
    //最后一位，可选 0~255
    Byte lineSpace[] = {0x1B,0x33,points};
    [_printerData appendBytes:lineSpace length:sizeof(lineSpace)];
}

/**
 *  设置二维码模块大小
 *
 *  @param size  1<= size <= 16,二维码的宽高相等
 */
- (void)setQRCodeSize:(NSInteger)size
{
    Byte QRSize [] = {0x1D,0x28,0x6B,0x03,0x00,0x31,0x43,size};
//    Byte QRSize [] = {29,40,107,3,0,49,67,size};
    [_printerData appendBytes:QRSize length:sizeof(QRSize)];
}

/**
 *  设置二维码的纠错等级
 *
 *  @param level 48 <= level <= 51
 */
- (void)setQRCodeErrorCorrection:(NSInteger)level
{
    Byte levelBytes [] = {0x1D,0x28,0x6B,0x03,0x00,0x31,0x45,level};
//    Byte levelBytes [] = {29,40,107,3,0,49,69,level};
    [_printerData appendBytes:levelBytes length:sizeof(levelBytes)];
}

/**
 *  将二维码数据存储到符号存储区
 * [范围]:  4≤(pL+pH×256)≤7092 (0≤pL≤255,0≤pH≤27)
 * cn=49
 * fn=80
 * m=48
 * k=(pL+pH×256)-3, k就是数据的长度
 *
 *  @param info 二维码数据
 */
- (void)setQRCodeInfo:(NSString *)info
{
    NSInteger kLength = info.length + 3;
    NSInteger pL = kLength % 256;
    NSInteger pH = kLength / 256;
    
    Byte dataBytes [] = {0x1D,0x28,0x6B,pL,pH,0x31,0x50,48};
//    Byte dataBytes [] = {29,40,107,pL,pH,49,80,48};
    [_printerData appendBytes:dataBytes length:sizeof(dataBytes)];
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    [_printerData appendData:infoData];
//    [self setText:info];
}

/**
 *  打印之前存储的二维码信息
 */
- (void)printStoredQRData
{
    Byte printBytes [] = {0x1D,0x28,0x6B,0x03,0x00,0x31,0x51,48};
//    Byte printBytes [] = {29,40,107,3,0,49,81,48};
    [_printerData appendBytes:printBytes length:sizeof(printBytes)];
}

/**
 *  打印并走纸多少行
 *
 *  @param n 走纸n行
 */
- (void)appendGoLine:(NSInteger)n{
    
    Byte line[] = {0x1B, 0x64, n};
    [_printerData appendBytes:line length:sizeof(line)];
    
}

- (void)printCutPaper:(WHCutPaperModel)model Num:(int)n {
   if (model == WHCutPaperModelFull) {
       Byte cut[] = {0x1D, 0x56, model, n};
       [_printerData appendBytes:cut length:sizeof(cut)];
      
   } else {
       Byte cut[] = {0x1D, 0x56, model};
       [_printerData appendBytes:cut length:sizeof(cut)];
   }
}




#pragma mark - ------------function method ----------------
#pragma mark  文字
- (void)appendText:(NSString *)text alignment:(WHTextAlignment)alignment
{
    [self appendText:text alignment:alignment fontSize:WHFontSizeTitleSmalle fontStyle:WHFontStyleBoldCancel];
}

- (void)appendText:(NSString *)text alignment:(WHTextAlignment)alignment fontSize:(WHFontSize)fontSize fontStyle:(WHFontStyle)fontStyle
{
    // 1.文字对齐方式
    [self setAlignment:alignment];
    
    if (fontSize == WHFontSizeTitleSmalle) {
        [self setLineSpace:36];
    }
    // 2.设置字号
    [self setFontSize:fontSize];
    if (self.isfontBold) {
        [self setFontStyle:WHFontStyleBold];
    } else {
        [self setFontStyle:fontStyle];
    }
    // 3.设置标题内容
    [self setText:text];
    if (!self.isfontBold) {
        [self setFontStyle:WHFontStyleBoldCancel];
    }
}

- (void)appendTitle:(NSString *)title value:(NSString *)value
{
    [self appendTitle:title value:value fontSize:WHFontSizeTitleSmalle fontStyle:WHFontStyleBoldCancel];
}

- (void)appendTitle:(NSString *)title value:(NSString *)value fontSize:(WHFontSize)fontSize fontStyle:(WHFontStyle)fontStyle
{
    [self appendTitle:title value:value fontSize:fontSize titleFontStyle:fontStyle valueFontStyle:fontStyle];

}

- (void)appendTitle:(NSString *)title value:(NSString *)value fontSize:(WHFontSize)fontSize titleFontStyle:(WHFontStyle)titleFontStyle valueFontStyle:(WHFontStyle)valueFontStyle{
    // 1.设置对齐方式
    [self setAlignment:WHTextAlignmentLeft];
    // 2.设置字号
    [self setFontSize:fontSize];
    // 3.设置是否加粗
    if (self.isfontBold) {
        [self setFontStyle:WHFontStyleBold];
    } else {
        [self setFontStyle:titleFontStyle];
    }
   
    [self setLineSpace:36];
    
    // 3.设置标题内容
    [self setText:title];
    
    if (self.isfontBold) {
        [self setFontStyle:WHFontStyleBold];
    } else {
        [self setFontStyle:valueFontStyle];
    }
    // 4.设置实际值
    [self setOffsetText:value];
    //放弃加粗
    if (!self.isfontBold) {
        [self setFontStyle:WHFontStyleBoldCancel];
    }
    // 5.换行
    [self appendNewLine];
}

    
- (void)appendTitle:(NSString *)title value:(NSString *)value valueOffset:(NSInteger)offset
{
    [self appendTitle:title value:value valueOffset:offset fontSize:WHFontSizeTitleSmalle];
}

- (void)appendTitle:(NSString *)title value:(NSString *)value valueOffset:(NSInteger)offset fontSize:(WHFontSize)fontSize
{
    // 1.设置对齐方式
    [self setAlignment:WHTextAlignmentLeft];
    // 2.设置字号
    [self setFontSize:fontSize];
    // 3.设置标题内容
    [self setText:title];
    // 4.设置内容偏移量
    [self setOffset:offset];
    // 5.设置实际值
    [self setText:value];
    // 6.换行
    [self appendNewLine];
    if (fontSize != WHFontSizeTitleSmalle) {
        [self appendNewLine];
    }
}

- (void)appendLeftText:(NSString *)left middleText:(NSString *)middle rightText:(NSString *)right isTitle:(BOOL)isTitle
{
    [self appendLeftText:left middleText:middle rightText:right isTitle:isTitle fontSize:WHFontSizeTitleSmalle fontStyle:WHFontStyleBoldCancel];
}

- (void)appendLeftText:(NSString *)left middleText:(NSString *)middle rightText:(NSString *)right isTitle:(BOOL)isTitle fontSize:(WHFontSize)fontSize fontStyle:(WHFontStyle)fontStyle{
    
    [self setAlignment:WHTextAlignmentLeft];
    [self setFontSize:fontSize];
    if (self.isfontBold || fontStyle == WHFontStyleBold) {
        [self setFontStyle:WHFontStyleBold];
    } else {
        [self setFontStyle:WHFontStyleBoldCancel];
    }
    NSInteger offset = 0;
    if (!isTitle) {
        offset = 10;
    }
    
    if (left) {
        [self setText:left];
//        [self setText:left maxChar:10];
    }
    
    if (middle) {
        [self setOffset:220 + offset];
        [self setText:middle];
    }
    
    if (right) {
        [self setOffsetText:right];
    }
    
    [self appendNewLine];
}

#pragma mark 图片
- (void)appendImage:(UIImage *)image alignment:(WHTextAlignment)alignment maxWidth:(CGFloat)maxWidth
{
    if (!image) {
        return;
    }
    // 1.设置图片对齐方式
    [self setAlignment:alignment];
    
    // 2.设置图片
    UIImage *newImage = [image imageWithscaleMaxWidth:maxWidth];
//    newImage = [newImage blackAndWhiteImage];
    
    NSData *imageData = [newImage bitmapData];
    [_printerData appendData:imageData];
    
    // 3.换行
    [self appendNewLine];
    
    // 4.打印图片后，恢复文字的行间距
    Byte lineSpace[] = {0x1B,0x32};
    [_printerData appendBytes:lineSpace length:sizeof(lineSpace)];
    
}

- (void)appendBarCodeWithInfo:(NSString *)info
{
    [self appendBarCodeWithInfo:info alignment:WHTextAlignmentCenter maxWidth:300];
}

- (void)appendBarCodeWithInfo:(NSString *)info alignment:(WHTextAlignment)alignment maxWidth:(CGFloat)maxWidth
{
    UIImage *barImage = [UIImage barCodeImageWithInfo:info];
    [self appendImage:barImage alignment:alignment maxWidth:maxWidth];
}

- (void)appendQRCodeWithInfo:(NSString *)info size:(NSInteger)size
{
    [self appendQRCodeWithInfo:info size:size alignment:WHTextAlignmentCenter];
}

- (void)appendQRCodeWithInfo:(NSString *)info size:(NSInteger)size alignment:(WHTextAlignment)alignment
{
    [self setAlignment:alignment];
    [self setQRCodeSize:size];
    [self setQRCodeErrorCorrection:48];
    [self setQRCodeInfo:info];
    [self printStoredQRData];
    [self appendNewLine];
}

- (void)appendQRCodeWithInfo:(NSString *)info
{
    [self appendQRCodeWithInfo:info centerImage:nil alignment:WHTextAlignmentCenter maxWidth:250];
}

- (void)appendQRCodeWithInfo:(NSString *)info centerImage:(UIImage *)centerImage alignment:(WHTextAlignment)alignment maxWidth:(CGFloat )maxWidth
{
    UIImage *QRImage = [UIImage createQRCodeWithTargetString:info logoImage:centerImage];
    [self appendImage:QRImage alignment:alignment maxWidth:maxWidth];
}
/**
 添加自定义的data
 
 @param data 自定义的data
 */
- (void)appendCustomData:(NSData *)data
{
    if (data.length <= 0) {
        return;
    }
    [_printerData appendData:data];
}

#pragma mark 其他
- (void)appendSeperatorLine
{
    // 1.设置分割线居中
    [self setAlignment:WHTextAlignmentCenter];
    // 2.设置字号
    [self setFontSize:WHFontSizeTitleSmalle];
    // 3.添加分割线
    NSString *line = @"- - - - - - - - - - - - - - - -\n";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [line dataUsingEncoding:enc];
    [_printerData appendData:data];
}

/**
 *  添加一条分割线，like this:— —— —— —— —
 */
- (void)appendSplitLine{
    // 1.设置分割线居中
    [self setAlignment:WHTextAlignmentCenter];
    // 2.设置字号
    [self setFontSize:WHFontSizeTitleSmalle];
    // 3.添加分割线
    NSString *line = @"— —— —— —— —— —— ——\n";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [line dataUsingEncoding:enc];
    [_printerData appendData:data];
}


- (void)appendDottedLine{
    // 1.设置分割线居中
    [self setAlignment:WHTextAlignmentCenter];
    // 2.设置字号
    [self setFontSize:WHFontSizeTitleSmalle];
    // 3.添加分割线
    NSString *line = @"===============================\n";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [line dataUsingEncoding:enc];
    [_printerData appendData:data];
}

/**
 *  添加一条分割线，like this:-——————————
 */
- (void)appendSolidLine{
    // 1.设置分割线居中
    [self setAlignment:WHTextAlignmentCenter];
    // 2.设置字号
    [self setFontSize:WHFontSizeTitleSmalle];
    // 3.添加分割线
    NSString *line = @"————————————————\n";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [line dataUsingEncoding:enc];
    [_printerData appendData:data];
}


- (void)appendFooter:(NSString *)footerInfo
{
    [self appendSeperatorLine];
    if (!footerInfo) {
        footerInfo = @"谢谢惠顾，欢迎下次光临！";
    }
    [self appendText:footerInfo alignment:WHTextAlignmentCenter];
    [self appendSeperatorLine];
}

- (NSData *)getFinalData
{
    return _printerData;
}

@end
