# The joystick's stick, broadcast to the whole robot. An input stream, not a
# command to any one resource: each consumer (the base, arm teleop, ...)
# decides what the stick means for it.
# Calibrated on the joystick: 0 at rest, deadzones applied, X/Y
# within the unit circle. Twist always rotates in place. Sent best-effort and
# resent periodically; subscribe best_effort.

# This message definition mirrors the corresponding rammp_rtps message and is 
# not meant to be taken as a source of truth.

# a bit set
uint32 BUTTONS_NONE = 0
uint32 BUTTONS_JOYSTICK = 1   # the stick's button

float32 x           # -1..+1, + = right
float32 y           # -1..+1, + = forward
float32 twist       # -1..+1, + = clockwise
uint32 buttons      # pressed buttons, BUTTONS_* bits
