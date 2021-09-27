//
//  WHTscCommand.m
//  WeiHong
//
//  Created by developeng on 2021/9/26.
//

#import "WHTscCommand.h"

@interface WHTscCommand ()

/** 将要打印的排版后的数据 */
@property (strong, nonatomic)   NSMutableData            *printerData;

@end

@implementation WHTscCommand

- (instancetype)init{
    self = [super init];
    if (self) {
        [self defaultSetting];
    }
    return self;
}

- (void)defaultSetting{
    _printerData = [[NSMutableData alloc] init];
}

- (void)addAd{
    NSString *AD = @"\r\n";
    [_printerData appendData:[AD dataUsingEncoding:NSUTF8StringEncoding]];
}


-(void)addSize:(int) width :(int) height{
    NSString *SIZE = [NSString stringWithFormat:@"SIZE %d mm,%d mm",width,height];
    [_printerData appendData:[SIZE dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addGapWithM:(int) m withN:(int) n{
    NSString *GAP = [NSString stringWithFormat:@"GAP %d mm,%d mm",m,n];
    [_printerData appendData:[GAP dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addReference:(int) x :(int)y{
    NSString *REFERENCE = [NSString stringWithFormat:@"REFERENCE %d,%d",x,y];
    [_printerData appendData:[REFERENCE dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addSpeed:(int) speed{
    NSString *SPEED = [NSString stringWithFormat:@"SPEED %d",speed];
    [_printerData appendData:[SPEED dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addDensity:(int) density{
    NSString *DENSITY = [NSString stringWithFormat:@"DENSITY %d",density];
    [_printerData appendData:[DENSITY dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addDirection:(int) direction{
    NSString *DIRECTION = [NSString stringWithFormat:@"DIRECTION %d",direction];
    [_printerData appendData:[DIRECTION dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addCls{
    NSString *CLS = @"CLS";
    [_printerData appendData:[CLS dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addTextwithX:(int)x withY:(int)y withFont:(NSString*)font withRotation:(int)rotation withXscal:(int)xScal withYscal:(int)yScal withText:(NSString*) text{
    
    NSString *TEXT = [NSString stringWithFormat:@"TEXT %d,%d,\"%@\",%d,%d,%d,\"%@\"",x,y,font,rotation,xScal,yScal,text];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data1 = [TEXT dataUsingEncoding:enc];
    [_printerData appendData:data1];
    [self addAd];
}

-(void) addBitmapwithX:(int)x withY:(int) y withWidth:(int) width withHeight:(int) height withMode:(int) mode withData:(NSData*) data{
    NSString *BITMAP = [NSString stringWithFormat:@"BITMAP %d,%d,%d,%d,%d,%@",x,y,width,height,mode,data];
    [_printerData appendData:[BITMAP dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
    
}

-(void)addBitmapwithX:(int)x withY:(int)y withMode:(int)mode withWidth:(int)width withImage:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self addBitmapwithX:x withY:y withWidth:width withHeight:100 withMode:mode withData:imageData];
}

-(void)addBitmapwithX:(int)x withY:(int)y withMode:(int)mode withImage:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self addBitmapwithX:x withY:y withWidth:100 withHeight:100 withMode:mode withData:imageData];
}

-(void) addBarcode:(int)x :(int)y :(NSString*)barcodeType :(int)height :(int)readable :(int)rotation :(int)narrow :(int)wide :(NSString*)content{
    NSString *BARCODE = [NSString stringWithFormat:@"BARCODE %d,%d,\"%@\",%d,%d,%d,%d,%d,\"%@\"",x,y,barcodeType,height,readable,rotation,narrow,wide,content];
    [_printerData appendData:[BARCODE dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addQRCode:(int)x :(int)y :(NSString*)ecclever :(int)cellwidth :(NSString*)mode :(int)rotation :(NSString*)content{
    NSString *QRCODE = [NSString stringWithFormat:@"QRCODE %d,%d,%@,%d,%@,%d,\"%@\"",x,y,ecclever,cellwidth,mode,rotation,content];
    [_printerData appendData:[QRCODE dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addPrint:(int) m :(int) n{
    NSString *PRINT = [NSString stringWithFormat:@"PRINT %d,%d",m,n];
    [_printerData appendData:[PRINT dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(NSData*) getCommand{
    return _printerData;
}

-(void) addPeel:(NSString *) peel{
    NSString *PEEL = [NSString stringWithFormat:@"SET PEEL %@",peel];
    [_printerData appendData:[PEEL dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addTear:(NSString *) tear{
    
    NSString *TEAR = [NSString stringWithFormat:@"SET TEAR %@",tear];
    [_printerData appendData:[TEAR dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addCashdrawer:(int) m :(int) t1 :(int) t2{
    NSString *CASHDRAWER = [NSString stringWithFormat:@"CASHDRAWER %d,%d,%d",m,t1,t2];
    [_printerData appendData:[CASHDRAWER dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addBline:(int) m :(int) n{
    NSString *BLINE = [NSString stringWithFormat:@"BLINE %d mm,%d mm",m,n];
    [_printerData appendData:[BLINE dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addFormfeed{
    NSString *FORMFEED = @"FORMFEED";
    [_printerData appendData:[FORMFEED dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addHome{
    NSString *HOME = @"HOME";
    [_printerData appendData:[HOME dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
    
}

-(void) addSound:(int) level :(int) interval{
    NSString *SOUND = [NSString stringWithFormat:@"SOUND %d,%d",level,interval];
    [_printerData appendData:[SOUND dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addSelfTest{
    NSString *SELFTEST = @"SELFTEST";
    [_printerData appendData:[SELFTEST dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addBar:(int) x :(int) y :(int) width :(int) height{
    NSString *BAR = [NSString stringWithFormat:@"BAR %d,%d,%d,%d",x,y,width,height];
    [_printerData appendData:[BAR dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addBox:(int) xStart :(int) yStart :(int) xEnd :(int) yEnd :(int) lineThickness{
    NSString *BAR = [NSString stringWithFormat:@"BOX %d,%d,%d,%d,%d",xStart,yStart,xEnd,yEnd,lineThickness];
    [_printerData appendData:[BAR dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) addReverse:(int) xStart :(int) yStart :(int) xWidth :(int) yHeight{
    NSString *REVERSE = [NSString stringWithFormat:@"REVERSE %d,%d,%d,%d",xStart,yStart,xWidth,yHeight];
    [_printerData appendData:[REVERSE dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void) queryPrinterStatus{
    NSString *ESC = @"<ESC>!?";
    [_printerData appendData:[ESC dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

-(void)addQueryPrinterStatus:(WHResponse)response{
    NSString *state;
    if (response == ResponseON) {
        state = @"ON";
    } else if (response == ResponseOFF) {
        state = @"OFF";
    } else {
        state = @"BATCH";
    }
    NSString *RESPONSE = [NSString stringWithFormat:@"SET RESPONSE %@",state];
    [_printerData appendData:[RESPONSE dataUsingEncoding:NSUTF8StringEncoding]];
    [self addAd];
}

@end
