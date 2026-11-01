# The MIB's (the base board's) status: operating state, drive profile in force, seat
# pose, speed, clock and error text. Published every 500 ms, best-effort, resent
# whether or not anything changed, so a subscriber that starts late catches up on the
# next tick; subscribe best_effort.
#
# This message mirrors rammp::MibStatus in rammp-org/rammp-rtps
# (messages/mib_message.hpp), field for field and in wire order, and is not the source
# of truth: the MIB publishes that struct as raw RTPS (XCDR1) under this type name, and
# a ROS 2 node reads it with no bridge. Do not reorder, insert or retype fields.

# system_state values (rammp::MibSystemState)
uint8 SYSTEM_STATE_INITIALIZING = 0  # bringing up the board; not ready
uint8 SYSTEM_STATE_IDLE = 1          # waiting for a DriveCommand; seat control available, drive disabled
uint8 SYSTEM_STATE_ENABLED = 2       # the joystick drives; manual seat control disabled
uint8 SYSTEM_STATE_ERROR = 3         # bring-up or runtime fault; error_message says why
uint8 SYSTEM_STATE_AUTONOMOUS = 4    # the Jetson drives on TwistSetpoint; a joystick touch ends it (IDLE)
uint8 SYSTEM_STATE_SHARED = 5        # the Jetson and the joystick drive together
uint8 SYSTEM_STATE_ESTOP = 6         # emergency stop: drive cut and held; IDLE once the latch clears
uint8 SYSTEM_STATE_PUSH_ASSIST = 7   # an assistant drives from the push handle; the joystick is not read for driving

# active_profile values (rammp::DriveProfile)
uint8 PROFILE_LOW = 0
uint8 PROFILE_NORMAL = 1
uint8 PROFILE_HIGH = 2

uint8     system_state        # one of SYSTEM_STATE_*
uint8     active_profile      # one of PROFILE_*; what DriveCommand.profile asked for, once granted
SeatState current_seat_state  # where the seat is
string    error_message       # human-readable; "No error" when none
int64     epoch_s             # the MIB's clock: Unix time, s since 1970-01-01 UTC; 0 = not known
float32   speed               # ground speed, m/s
int16     utc_offset_min      # minutes east of UTC, to turn epoch_s into local wall time
uint8     seq                 # +1 per message, wraps; a gap is a dropped sample
string    status_text         # optional wording for the state label; "" = use the state's name
string    error_footer        # what to do about error_message
