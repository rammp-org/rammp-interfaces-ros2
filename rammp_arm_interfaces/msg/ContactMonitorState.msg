# The arm's unexpected-contact monitor, published on /contact_monitor.
#
# Every float64[7] is per joint: index i is joint i+1. Torques are N·m, positions
# rad, velocities rad/s.
std_msgs/Header header
uint8 DETECTION_OFF=0
uint8 DETECTION_OBSERVE=1
uint8 DETECTION_ENFORCE=2
uint8 detection
uint8 PHASE_SETTLING=0
uint8 PHASE_ARMED=1
uint8 PHASE_LATCHED=2
uint8 phase
uint8 profile                 # SetContactThresholds.PROFILE_*; PROFILE_CUSTOM means `thresholds` came from a client
float64[7] residual           # N·m, observer estimate of external joint torque
float64[7] thresholds         # N·m, active; a joint is over when |residual| > threshold
uint64 would_trips            # crossings that reached the debounce count, cumulative since node start. In observe mode these are the would-be trips; in enforce each one latched
uint64 bad_samples            # feedback samples skipped as non-finite (q, qd or tau), cumulative since node start
# The last trip (enforce) or would-be trip (observe) since node start. The trip_*
# fields are valid only when has_trip is true; a clear does not reset them.
bool has_trip
int32 trip_joint              # 1-based: the first joint to reach the debounce count
float64[7] trip_residual      # N·m, at the trip
float64[7] trip_thresholds    # N·m, active at the trip
float64[7] trip_q             # rad, at the trip
float64[7] trip_qd            # rad/s, at the trip
