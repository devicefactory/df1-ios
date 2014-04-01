DF1 BLE Services
================

The following document describes supported GATT services in DF1 device.

Concepts / Glossary
===================

* Services

  Primary groups of data generating or data storing interface.

* Characteristics

  Specific units under each primary group. These characteristics directly serve
  data or can be written to.  

* GATT

  Generic ATtribute Table

* OAD

  Over-Air-Download. Texas Instruments implementation of flashing and bootloading runnable firmware
  through Bluetooth transport. All the firmware data transmission and control is done through 
  bluetooth link, thereby eliminating the need to upload the firmware via physical connection. 

* ImgA

  Smaller firmware that takes care of OAD.
  The device needs to boot into ImgA so that ImgB (actual application) can be downloaded.

* ImgB

  Larger firmware that contains the actual running app.


Services
========

Here are the primary list of services DF1 supports.

| ServiceName    | UUID    | Description                                         |  
|:-------------- |:-------:| --------------------------------------------------- |
| Accelerometer  | 0xAA10  | 3-axis accelerometer data and config parameters.    |
| Battery        | 0x180F  | battery level indicator.                            |
| Test           | 0xAA60  | allows toggle of LED, and reset function.           |
| OAD            | 0xFFC0  | TI CC2541 Over-Air-Download (OAD) profile.          |


> You can use `gatttool` from bluez package to inspect the BLE services.

```{sh}
gatttool> primary
attr handle: 0x0001, end grp handle: 0x000b uuid: 00001800-0000-1000-8000-00805f9b34fb
attr handle: 0x000c, end grp handle: 0x000f uuid: 00001801-0000-1000-8000-00805f9b34fb
attr handle: 0x0010, end grp handle: 0x0022 uuid: 0000180a-0000-1000-8000-00805f9b34fb
attr handle: 0x0023, end grp handle: 0x0027 uuid: 0000180f-0000-1000-8000-00805f9b34fb
attr handle: 0x0028, end grp handle: 0x006a uuid: 0000aa10-0000-1000-8000-00805f9b34fb
attr handle: 0x006b, end grp handle: 0x0071 uuid: 0000aa60-0000-1000-8000-00805f9b34fb
attr handle: 0x0072, end grp handle: 0xffff uuid: f000ffc0-0451-4000-b000-000000000000
```


0xAA10 : Accelerometer Service
==============================


Characterisitics that are exposed under `0xAA10` Accelerometer Service.
These services can be modified by future OAD updates of the ImgB firmware.

* _r_ : read access
* _w_ : write access
* _n_ : notification access

Supported Characteristics
-------------------------

| CharacteristicName    | UUID    | Mode   | Description                                                    |  
|:--------------------- |:-------:|:------:| -------------------------------------------------------------- |
| ACC_GEN_CFG_UUID      | 0xAA11  | r/w    | general cfg: 2g/4g/8g range,possible ODR rates                 |
| ACC_ENABLE_UUID       | 0xAA12  | r/w    | enable cfg: each bit will toggle features on and off           |
| ACC_XYZ_DATA8_UUID    | 0xAA13  | r/n    | _DATA_: 8 bit resolution data per axis                         |
| ACC_XYZ_DATA14_UUID   | 0xAA14  | r/n    | _DATA_: 14 bit resolution data per axis                        |
| ACC_TAP_DATA_UUID     | 0xAA15  | r/n    | _DATA_: DSP Tap detection                                      |
| ACC_TAP_THSZ_UUID     | 0xAA16  | r/w    | tap threshhold on z axis (0.063g increment)                    |
| ACC_TAP_THSX_UUID     | 0xAA17  | r/w    | tap threshhold on x axis                                       |
| ACC_TAP_THSY_UUID     | 0xAA18  | r/w    | tap threshhold on y axis                                       |
| ACC_TAP_TMLT_UUID     | 0xAA19  | r/w    | tap time limit (how "fast" is the tap)                         |
| ACC_TAP_LTCY_UUID     | 0xAA1A  | r/w    | tap latency (how long of wait after tap timelimit)             |
| ACC_TAP_WIND_UUID     | 0xAA1B  | r/w    | tap window for subsequent double tap                           |
| ACC_FF_DATA_UUID      | 0xAA1C  | r/n    | _DATA_: DSP Freefall detection                                 |
| ACC_FF_THS_UUID       | 0xAA1D  | r/w    | freefall threshhold (0.063g increment)                         |
| ACC_MO_DATA_UUID      | 0xAA1E  | r/n    | _DATA_: DSP Motion detection (mutually exclusive with Freefall)|
| ACC_MO_THS_UUID       | 0xAA1F  | r/w    | motion threshhold (0.063g increment)                           |
| ACC_FFMO_DEB_UUID     | 0xAA20  | r/w    | freefall,motion debounce counter                               |
| ACC_TRAN_DATA_UUID    | 0xAA21  | r/n    | _DATA_: DSP Shake (transient) detection                        |
| ACC_TRAN_THS_UUID     | 0xAA22  | r/w    | transient threshhold (0.063g increment)                        |
| ACC_TRAN_DEB_UUID     | 0xAA23  | r/w    | transient debounce counter                                     |
| ACC_TRAN_HPF_UUID     | 0xAA24  | r/w    | highpass filter for removing gravity, small accelerations      |

 
```{sh}
gatttool> characteristics
... trimmed ...
handle: 0x0029, char properties: 0x0a, char value handle: 0x002a, uuid: 0000aa11-0000-1000-8000-00805f9b34fb
handle: 0x002c, char properties: 0x0a, char value handle: 0x002d, uuid: 0000aa12-0000-1000-8000-00805f9b34fb
handle: 0x002f, char properties: 0x12, char value handle: 0x0030, uuid: 0000aa13-0000-1000-8000-00805f9b34fb
handle: 0x0033, char properties: 0x12, char value handle: 0x0034, uuid: 0000aa14-0000-1000-8000-00805f9b34fb
handle: 0x0037, char properties: 0x12, char value handle: 0x0038, uuid: 0000aa15-0000-1000-8000-00805f9b34fb
handle: 0x003b, char properties: 0x0a, char value handle: 0x003c, uuid: 0000aa16-0000-1000-8000-00805f9b34fb
handle: 0x003e, char properties: 0x0a, char value handle: 0x003f, uuid: 0000aa17-0000-1000-8000-00805f9b34fb
handle: 0x0041, char properties: 0x0a, char value handle: 0x0042, uuid: 0000aa18-0000-1000-8000-00805f9b34fb
handle: 0x0044, char properties: 0x0a, char value handle: 0x0045, uuid: 0000aa19-0000-1000-8000-00805f9b34fb
handle: 0x0047, char properties: 0x0a, char value handle: 0x0048, uuid: 0000aa1a-0000-1000-8000-00805f9b34fb
handle: 0x004a, char properties: 0x0a, char value handle: 0x004b, uuid: 0000aa1b-0000-1000-8000-00805f9b34fb
handle: 0x004d, char properties: 0x12, char value handle: 0x004e, uuid: 0000aa1c-0000-1000-8000-00805f9b34fb
handle: 0x0051, char properties: 0x0a, char value handle: 0x0052, uuid: 0000aa1d-0000-1000-8000-00805f9b34fb
handle: 0x0054, char properties: 0x12, char value handle: 0x0055, uuid: 0000aa1e-0000-1000-8000-00805f9b34fb
handle: 0x0058, char properties: 0x0a, char value handle: 0x0059, uuid: 0000aa1f-0000-1000-8000-00805f9b34fb
handle: 0x005b, char properties: 0x0a, char value handle: 0x005c, uuid: 0000aa20-0000-1000-8000-00805f9b34fb
handle: 0x005e, char properties: 0x12, char value handle: 0x005f, uuid: 0000aa21-0000-1000-8000-00805f9b34fb
handle: 0x0062, char properties: 0x0a, char value handle: 0x0063, uuid: 0000aa22-0000-1000-8000-00805f9b34fb
handle: 0x0065, char properties: 0x0a, char value handle: 0x0066, uuid: 0000aa23-0000-1000-8000-00805f9b34fb
handle: 0x0068, char properties: 0x0a, char value handle: 0x0069, uuid: 0000aa24-0000-1000-8000-00805f9b34fb
... trimmed ...
```

Control UUID registers
----------------------

The ACC_GEN_CFG_UUID (0xAA11) is used to control the supported modes in the accelerometer.

* noise & power modes (normal mode recommended)
* internal sampling modes
* acceleration measurement range : 2,4,8g
* 8bit vs 14bit (controlled by other UUIDs)

Below shows the register at ACC_GEN_CFG_UUID and what each pair of bits mean.

>   ACC_GEN_CFG bits: MRRR (Mode, Rate, Range, Resolution)
>   ======================================================
>
>      MODE      RATE     RANGE   RESOLUTION
>     7    6    5    4    3    2    1    0
>     M1  M0  RT1  RT0  RA1  RA0  RS1  RS0
> 
>     M1:M0    0 0   normal mode
>              0 1   low noise low power
>              1 0   low power sleep
>              1 1   low power
>     RT1:RT0  0 0   mid rate  (50Hz, 50Hz)
>              0 1   high rate (100Hz, 50Hz)
>              1 0   low rate  (12.5Hz, 12.5Hz)
>              1 1   unused
>     RA1:RA0  0 0   2G
>              0 1   4G
>              1 0   8G
>              1 1   unused
>     RS1:RS0  0 0   8 bit
>              0 1   14 bit
>              1 0   unused
>              1 1   unused
>    
>    GEN_CFG_M1_MASK    0x80
>    GEN_CFG_M0_MASK    0x40
>    GEN_CFG_RT1_MASK   0x20
>    GEN_CFG_RT0_MASK   0x10
>    GEN_CFG_RA1_MASK   0x08
>    GEN_CFG_RA0_MASK   0x04
>    GEN_CFG_RS1_MASK   0x02
>    GEN_CFG_RS0_MASK   0x01

In order to receive data from notification UUID''s, desired features first need
to be enabled on the ACC_ENABLE_UUID register (0xAA12).
For example, in order to receive 8bit XYZ data, you need to:

* write "0x01" to ACC_ENABLE_UUID 0xAA12 to enable 8bit xyz data
* enable notification by writing "0x0100" to ACC_XYZ_DATA8_UUID 0xAA13

Here are the rest of the bits in the ACC_ENABLE_UUID register and their corresponding features.

>   ACC_ENABLE bits
>   ===============
>
>       7     6     5     4     3     2     1     0
>    USR2  USR1  TRAN    MO    FF   TAP XYZ14  XYZ8
>
>    Setting any of these bits will put accelerometer in
>    active state and start populating static vars on App layer
>
>   ENABLE_XYZ8_MASK   0x01
>   ENABLE_XYZ14_MASK  0x02
>   ENABLE_TAP_MASK    0x04
>   ENABLE_FF_MASK     0x08
>   ENABLE_MO_MASK     0x10
>   ENABLE_TRAN_MASK   0x20
>   ENABLE_USR1_MASK   0x40
>   ENABLE_USR2_MASK   0x80


Accelerometer DSP Configuration UUID Registers
----------------------------------------------

The DF1 sets sensible defaults to accelerometer parameters and various configuration registers.
The configuration registers can drastically change the way in which user can interact with the onboard accelerometer.
The accelerometer IC is top-of-the-line low G sensors from Freescale,
[mma8451Q](http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=MMA8451Q).

Here are the supported accelerometer config UUIDs and their purpose.

| CharacteristicName    | UUID    | Description                                                             |  
|:--------------------- |:-------:|:----------------------------------------------------------------------- |
| ACC_XYZ_DATA8_UUID    | 0xAA13  | NOTIFICATION handle for 8bit xyz data                                   |
| ACC_XYZ_DATA14_UUID   | 0xAA14  | NOTIFICATION handle for 14bit xyz data                                  |
| ACC_TAP_DATA_UUID     | 0xAA15  | NOTIFICATION handle tap detection data                                  |
| ACC_TAP_THSZ_UUID     | 0xAA16  | tap event is triggered when z-acceleration exceeds this threshhold      |
| ACC_TAP_THSX_UUID     | 0xAA17  |                                                                         |
| ACC_TAP_THSY_UUID     | 0xAA18  |                                                                         |
| ACC_TAP_TMLT_UUID     | 0xAA19  |                                                                         |
| ACC_TAP_LTCY_UUID     | 0xAA1A  |                                                                         |
| ACC_TAP_WIND_UUID     | 0xAA1B  |                                                                         |
| ACC_FF_DATA_UUID      | 0xAA1C  |                                                                         |
| ACC_FF_THS_UUID       | 0xAA1D  |                                                                         |
| ACC_MO_DATA_UUID      | 0xAA1E  |                                                                         |
| ACC_MO_THS_UUID       | 0xAA1F  |                                                                         |
| ACC_FFMO_DEB_UUID     | 0xAA20  |                                                                         |
| ACC_TRAN_DATA_UUID    | 0xAA21  |                                                                         |
| ACC_TRAN_THS_UUID     | 0xAA22  |                                                                         |
| ACC_TRAN_DEB_UUID     | 0xAA23  |                                                                         |
| ACC_TRAN_HPF_UUID     | 0xAA24  |                                                                         |

```{c}
// DEFAULT VALUES
#define MMA_DEFAULT_TAP_THSZ     20
#define MMA_DEFAULT_TAP_THSX     20
#define MMA_DEFAULT_TAP_THSY     20
#define MMA_DEFAULT_TAP_TMLT     6
#define MMA_DEFAULT_TAP_LTCY     20
#define MMA_DEFAULT_TAP_WIND     30
// 20*0.063g = 1.26g, 4*0.063g = 0.252g
#define MMA_DEFAULT_FF_THS       4
#define MMA_DEFAULT_FF_DEB      10
#define MMA_DEFAULT_MO_THS      20
#define MMA_DEFAULT_MO_DEB      10
// 16*0.063g = 1.008g
#define MMA_DEFAULT_TRAN_THS    16
#define MMA_DEFAULT_TRAN_DEB    1
// 8*0.063Hz = 0.5Hz
#define MMA_DEFAULT_TRAN_HPF    8
```

0x180F : Battery Characteristics
================================

When the estimated battery level falls below 30%, the device will go into power saving mode and toggle
the red LED to suggest battery swap.


| CharacteristicName    | UUID    | Mode   | Description                                                    |  
|:--------------------- |:-------:|:------:| -------------------------------------------------------------- |
| BATT_LEVEL_UUID       | 0x1A19  | r/n    | battery level derived from ADC internal voltage level.         |


