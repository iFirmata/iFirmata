//
//  Firmata.h
//  TemperatureSensor
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LeDataService.h"
#import "LeDiscovery.h"

// message command bytes (128-255/0x80-0xFF)
#define START_SYSEX                 0xF0
#define SET_PIN_MODE                0xF4
#define RESET                       0xFF
#define END_SYSEX                   0xF7
#define REPORT_VERSION              0xF9 // report firmware version

// extended command set using sysex (0-127/0x00-0x7F)
/* 0x00-0x0F reserved for user-defined commands */
#define REPORT_ANALOG               0xC0 // query for analog pin
#define REPORT_DIGITAL              0xD0 // query for digital pin
#define ANALOG_MESSAGE              0xE0 // data for a analog pin

#define REPORT_FIRMWARE             0x79 // report name and version of the firmware
#define DIGITAL_MESSAGE             0x90 // data for a digital port

#define RESERVED_COMMAND            0x00 // 2nd SysEx data byte is a chip-specific command (AVR, PIC, TI, etc).
#define ANALOG_MAPPING_QUERY        0x69 // ask for mapping of analog to pin numbers
#define ANALOG_MAPPING_RESPONSE     0x6A // reply with mapping info
#define CAPABILITY_QUERY            0x6B // ask for supported modes and resolution of all pins
#define CAPABILITY_RESPONSE         0x6C // reply with supported modes and resolution
#define PIN_STATE_QUERY             0x6D // ask for a pin's current mode and value
#define PIN_STATE_RESPONSE          0x6E // reply with a pin's current mode and value
#define EXTENDED_ANALOG             0x6F // analog write (PWM, Servo, etc) to any pin
#define SERVO_CONFIG                0x70 // set max angle, minPulse, maxPulse, freq
#define STRING_DATA                 0x71 // a string message with 14-bits per char
#define SHIFT_DATA                  0x75 // shiftOut config/data message (34 bits)
#define I2C_REQUEST                 0x76 // I2C request messages from a host to an I/O board
#define I2C_REPLY                   0x77 // I2C reply messages from an I/O board to a host
#define I2C_CONFIG                  0x78 // Configure special I2C settings such as power pins and delay times
#define SAMPLING_INTERVAL           0x7A // sampling interval
#define SYSEX_NON_REALTIME          0x7E // MIDI Reserved for non-realtime messages
#define SYSEX_REALTIME              0x7F // MIDI Reserved for realtime messages

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class Firmata;

typedef enum {
    WRITE               = 0,
    READ                = 1,
    READ_CONTINUOUSLY   = 2,
    STOP                = 3,
} I2CMODE;

typedef enum {
    INPUT   = 0,
    OUTPUT  = 1,
    ANALOG  = 2,
    PWM     = 3,
    SERVO   = 4,
    SHIFT   = 5,
    I2C     = 6,
} PINMODE;
#define pinmodeArray @"input", @"output", @"analog", @"pwm", @"servo", @"shift", @"i2c", nil



@protocol FirmataProtocol<NSObject>

- (void) didDisconnect;
- (void) didConnect;
- (void) didUpdatePin:(int)pin currentMode:(PINMODE)mode value:(unsigned short int)value;
- (void) didReportFirmware:(NSString*)name major:(unsigned short int)major minor:(unsigned short int)minor;
- (void) didReportVersionMajor:(unsigned short int)major minor:(unsigned short int)minor;
- (void) didUpdateCapability:(NSMutableArray*)pins;
- (void) didReceiveAnalogPin:(int)pin value:(unsigned short int)value;
- (void) didReceiveDigitalPort:(int)port mask:(unsigned short int)mask;
- (void) didReceiveDigitalPin:(int)pin status:(BOOL)status;
- (void) didUpdateAnalogMapping:(NSMutableDictionary *)analogMapping;
@end


/****************************************************************************/
/*						Firmata service.                                    */
/****************************************************************************/
@interface Firmata : NSObject  <LeDataProtocol, LeServiceDelegate>

@property (strong, nonatomic) LeDataService         *currentlyDisplayingService;

@property (strong, nonatomic) NSMutableData         *firmataData;
@property (strong, nonatomic) NSMutableArray        *nonSysexData;
@property (strong, nonatomic) NSMutableDictionary   *analogMapping;
@property (strong, nonatomic) NSMutableArray        *ports;
@property (strong, nonatomic) NSMutableArray        *pins;

- (id) initWithService:(LeDataService*)service controller:(id<FirmataProtocol>)controller;
- (void) setController:(id<FirmataProtocol>)controller;

- (NSString*) pinmodeEnumToString:(PINMODE)enumVal;
- (PINMODE) modeStringToEnum:(NSString*)strVal;

- (void) reset;
//- (void) start;

- (void) pinStateQuery:(int)pin;
- (void) reportFirmware;
- (void) reportVersion;

- (void) analogMappingQuery;
- (void) capabilityQuery;

- (void) i2cConfig:(unsigned short int)delay data:(NSData *)data;
- (void) i2cRequest:(I2CMODE)i2cMode address:(unsigned short int)address data:(NSData *)data;

- (void) reportDigital:(int)port enable:(BOOL)enable;
- (void) reportAnalog:(int)pin enable:(BOOL)enable;

- (void) analogMessagePin:(int)pin value:(unsigned short int)value;
- (void) digitalMessagePort:(int)port mask:(unsigned short int)mask;

- (void) setPinMode:(int)pin mode:(PINMODE)mode;

- (void) samplingInterval:(unsigned short int)intervalMilliseconds;
- (void) servoConfig:(int)pin minPulse:(unsigned short int)minPulse maxPulse:(unsigned short int)maxPulse;

/* Behave properly when heading into and out of the background */

- (int) portForPin:(int)pin;
- (unsigned short int) bitMaskForPin:(int)pin;

@end