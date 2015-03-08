// DF1 Service and Characteristic UUIDs
#define TI_BASE_LONG_UUID     @"F0000000-0451-4000-B000-000000000000"

//
// Accelerometer Service
//
#define ACC_SERV_UUID         0xAA10  // Service UUID: F0000000-0451-4000-B000-00000000-AA10
// XYZ related
#define ACC_GEN_CFG_UUID      0xAA11  // general cfg: 2g/4g/8g range,possible ODR rates
#define ACC_ENABLE_UUID       0xAA12  // enable cfg: each bit will toggle features on and off
#define ACC_XYZ_DATA8_UUID    0xAA13  // 8 bit resolution data per axis
#define ACC_XYZ_DATA14_UUID   0xAA14  // 14 bit resolution data per axis
// Tap Event
#define ACC_TAP_DATA_UUID     0xAA15  // DSP Tap detection
#define ACC_TAP_THSZ_UUID     0xAA16  // tap threshhold on z axis (0.063g increment)
#define ACC_TAP_THSX_UUID     0xAA17  // tap threshhold on x axis
#define ACC_TAP_THSY_UUID     0xAA18  // tap threshhold on y axis
#define ACC_TAP_TMLT_UUID     0xAA19  // tap time limit (how "fast" is the tap)
#define ACC_TAP_LTCY_UUID     0xAA1A  // tap latency (how long of wait after tap timelimit)
#define ACC_TAP_WIND_UUID     0xAA1B  // tap window for subsequent double tap
// Freefall Event
#define ACC_FF_DATA_UUID      0xAA1C  // DSP Freefall detection
#define ACC_FF_THS_UUID       0xAA1D  // freefall threshhold (0.063g increment)
// Motion Event
#define ACC_MO_DATA_UUID      0xAA1E  // DSP Motion detection (mutually exclusive with Freefall)
#define ACC_MO_THS_UUID       0xAA1F  // motion threshhold (0.063g increment)
#define ACC_FFMO_DEB_UUID     0xAA20  // freefall,motion debounce counter
// Transient Event 
#define ACC_TRAN_DATA_UUID    0xAA21  // DSP Shake (transient) detection
#define ACC_TRAN_THS_UUID     0xAA22  // transient threshhold (0.063g increment)
#define ACC_TRAN_DEB_UUID     0xAA23  // transient debounce counter
#define ACC_TRAN_HPF_UUID     0xAA24  // highpass filter for removing gravity, small accelerations
// Derived Event
#define ACCD_FALL_DATA_UUID   0xAA25  // Derived Human Fall detection
#define ACC_XYZ_FREQ_UUID     0xAA26  // notification frequency for XYZ data
//
// Battery Service
//
#define BATT_SERVICE_UUID     0x180F  // Battery Service
#define BATT_LEVEL_UUID       0x2A19  // Battery Level
//
// Test Service
//
#define TEST_SERV_UUID        0xAA60  // F0000000-0451-4000-B000-00000000-AA60
#define TEST_DATA_UUID        0xAA61
#define TEST_CONF_UUID        0xAA62  // used for LED toggle and hidden OAD control
//
// OAD Service
//
#define OAD_SERVICE_UUID      0xFFC0
#define OAD_IMG_IDENTIFY_UUID 0xFFC1
#define OAD_IMG_BLOCK_UUID    0xFFC2


// Copy of the firmware defs
// 
// ACC_GEN_CFG bits: MRRR (Mode, Rate, Range, Resolution)
// ======================================================
//      MODE      RATE     RANGE   RESOLUTION
//     7    6    5    4    3    2    1    0
//     M1  M0  RT1  RT0  RA0  RA0  RS1  RS0                                      
//
//  M1:M0    0 0   normal mode
//           0 1   low noise low power
//           1 0   low power sleep
//           1 1   low power
//  RT1:RT0  0 0   mid rate  (50Hz, 50Hz)  
//           0 1   high rate (100Hz, 50Hz)  
//           1 0   low rate  (12.5Hz, 12.5Hz)  
//           1 1   unused
//  RA1:RA0  0 0   2G 
//           0 1   4G
//           1 0   8G
//           1 1   unused
//  RS1:RS0  0 0   8 bit
//           0 1   14 bit
//           1 0   unused
//           1 1   unused
#define GEN_CFG_M1_MASK    0x80
#define GEN_CFG_M0_MASK    0x40
#define GEN_CFG_RT1_MASK   0x20
#define GEN_CFG_RT0_MASK   0x10
#define GEN_CFG_RA1_MASK   0x08
#define GEN_CFG_RA0_MASK   0x04
#define GEN_CFG_RS1_MASK   0x02
#define GEN_CFG_RS0_MASK   0x01

// ACC_ENABLE bits
// ===============
//
//     7     6     5     4     3     2     1     0
//  USR2  USR1  TRAN    MO    FF   TAP XYZ14  XYZ8
//
//  Setting any of these bits will put accelerometer in
//  active state and start populating static vars on App layer
#define ENABLE_XYZ8_MASK   0x01
#define ENABLE_XYZ14_MASK  0x02
#define ENABLE_TAP_MASK    0x04
#define ENABLE_FF_MASK     0x08
#define ENABLE_MO_MASK     0x10
#define ENABLE_TRAN_MASK   0x20
#define ENABLE_USR1_MASK   0x40
#define ENABLE_USR2_MASK   0x80

//
// NSUser Config keys
//
#define CFG_NAME       @"defaultName"
#define CFG_UUID       @"uuid"
#define CFG_CELLS      @"detailCells"
#define CFG_XYZ8_RANGE @"xyz8_range"
#define CFG_XYZ14_ON   @"xyz14_on"
#define CFG_TAP_THSZ   @"tap_thsz"
#define CFG_TAP_THSY   @"tap_thsy"
#define CFG_TAP_THSX   @"tap_thsx"
#define CFG_TAP_TMLT   @"tap_tmlt"
#define CFG_TAP_LTCY   @"tap_ltcy"
#define CFG_TAP_WIND   @"tap_wind"
#define CFG_XYZ_FREQ   @"xyz_freq"
