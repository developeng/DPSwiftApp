//
//  WHBluetooth.h
//  WeiHong
//
//  Created by developeng on 2021/8/23.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

#define BLE_UPDATEDEVICE @"BLEupdateDevice"
#define BLE_STATE @"BLESTATE"

#define LastTimeConnectId @"lastTimeConnectId"


typedef NS_ENUM(NSInteger,WHManagerState) {
    WHManagerStateUnknown = 0,
    WHManagerStateResetting,
    WHManagerStateUnsupported,
    WHManagerStateUnauthorized,
    WHManagerStatePoweredOff,
    WHManagerStateStartScan,//开始扫描
    WHManagerStateStopScan//结束扫描
};


typedef void(^BleStateBlock)(WHManagerState state,NSString *message);

@interface WHBluetooth : NSObject

@property (strong, nonatomic,nullable)   NSData  *printerData;

@property (strong, nonatomic, readonly)   CBPeripheral      *connectedPerpheral;  /**< 当前连接的外设 */

@property(nonatomic,copy) BleStateBlock bleStateBlock;
@property(nonatomic, assign) WHManagerState  bleState;  //蓝牙状态

@property(nonatomic, assign) BOOL  isClickPrint;  //是否点了打印

+ (instancetype)shared;

//蓝牙初始化
-(void)initBluetooth;

//连接打印机
-(void)connectPrinter:(CBPeripheral *)peripheral;

//连接打印机 是否打印
- (void)goToPrinter:(BOOL)isPrint;

//停止扫描
-(void)stopScan;

//开始打印
-(void)startPrint;

//断开连接
-(void)close;

//判断状态(是否已连接打印机)
- (BOOL)isConnectedPrinter;



@end

NS_ASSUME_NONNULL_END
