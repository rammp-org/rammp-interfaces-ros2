#header
std_msgs/Header header

# State Info
# State describes the current state / behavior of the robot:

# Create enum for the state field
uint8 STATE_INIT = 0
uint8 STATE_IDLE = 1
uint8 STATE_TUNER_MODE = 2
uint8 STATE_ESTOP = 3
uint8 STATE_SELF_LEVELING = 4
uint8 STATE_CONFIGURATION = 5
uint8 STATE_AUTO_CURB_CLIMBING = 6
uint8 STATE_CALIBRATING = 7
uint8 STATE_UNCALIBRATED = 8

uint8 state

#IMU
float64 tilt

