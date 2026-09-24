# The joystick's stick, broadcast to the whole robot. An input stream, not a
# command to any one resource: each consumer (the base, arm teleop, ...)
# decides what the stick means for it -- which is why it lives in the common
# package. Calibrated on the joystick: 0 at rest, deadzones applied, X/Y
# within the unit circle. Twist always rotates in place. Sent best-effort and
# resent periodically; subscribe best_effort.

# a bit set
uint32 BUTTONS_NONE = 0
uint32 BUTTONS_JOYSTICK = 1   # the stick's button

uint32 DRIVE_MODE_NORMAL = 0  # car-like: Y drives, X steers
uint32 DRIVE_MODE_HOLO = 1    # holonomic: X/Y is the velocity vector
uint32 DRIVE_MODE_AUTO = 2    # reserved, not implemented

float32 x           # -1..+1, + = right
float32 y           # -1..+1, + = forward
float32 twist       # -1..+1, + = clockwise
uint32 buttons      # pressed buttons, BUTTONS_* bits
uint32 drive_mode   # chosen on the joystick, one of DRIVE_MODE_*
