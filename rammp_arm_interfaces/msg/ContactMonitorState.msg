std_msgs/Header header
uint8 DETECTION_OFF=0
uint8 DETECTION_OBSERVE=1
uint8 DETECTION_ENFORCE=2
uint8 detection
uint8 PHASE_SETTLING=0
uint8 PHASE_ARMED=1
uint8 PHASE_LATCHED=2
uint8 phase
uint8 profile                 # SetContactThresholds.PROFILE_*
float64[7] residual           # N·m, observer estimate of external joint torque
float64[7] thresholds
uint64 would_trips
uint64 bad_samples
bool has_trip
int32 trip_joint              # 1-based
float64[7] trip_residual
float64[7] trip_thresholds
float64[7] trip_q
float64[7] trip_qd
