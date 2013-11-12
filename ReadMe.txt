### iosFirmata ###
 
===========================================================================
DESCRIPTION:
 
A basic firmata host implmentation for ios. This example utilizes the OpenBLE code and DataService files. https://github.com/jacobrosenthal/OpenBLE. It allows you to test your firmata setup and do some basic operations, and then utilize the source code to make your own application.

Currently supports the Seeed Studio Xadow BLE device http://www.seeedstudio.com/depot/xadow-ble-slave-p-1546.html and whoever else uses that part. The Xadow is a Leonardo style arduino part. It was necessary to change the Firmata classes to use Serial1 instead of Serial.

Important:
This project requires a Bluetooth LE Capable Device (iPhone 4s and later; iPad 3 and later; iPod Touch 5; iPad mini) and will not work on the simulator.
 
===========================================================================
BUILD REQUIREMENTS:
 
- Xcode 5 or greater
- iOS 7 SDK or greater
 
===========================================================================
RUNTIME REQUIREMENTS:
 
iOS 6 or later
Bluetooth LE Capable Device
Bluetooth LE Sensor/s