# Ask the MIB (the base board) for a drive state. Any node may send it: the joystick
# sends DISABLE and ENABLE (and push_assist), the Jetson sends AUTONOMOUS and SHARED.
# Each command states the whole target, so the sender's idea of the current state does
# not matter:
#
#   request     push_assist   MIB state
#   DISABLE     false         IDLE
#   DISABLE     true          PUSH_ASSIST
#   ENABLE      any           ENABLED
#   AUTONOMOUS  any           AUTONOMOUS
#   SHARED      any           SHARED
#
# The MIB decides. It accepts ENABLE from IDLE and ENABLED (a profile change while
# driving), AUTONOMOUS and SHARED from IDLE, ENABLED and PUSH_ASSIST, and nothing from
# INITIALIZING, ESTOP or ERROR. AUTONOMOUS, SHARED and PUSH_ASSIST each have their own
# ways out (a joystick touch ends AUTONOMOUS and PUSH_ASSIST; DISABLE ends all three),
# so ENABLE is refused there: leave first, then enable. Send it on change.
# MibStatus.system_state is the answer: a request the MIB has not answered yet may be
# repeated (the link is
# best-effort), and once MibStatus has shown the requested state the request is done. A
# later change of state is the MIB's decision, not a lost packet, so ask again only on a
# new decision of your own: a joystick touch ends AUTONOMOUS and stands until the Jetson
# has a new reason to ask. Repeating the old request would take the chair back from the
# user. Publish best_effort.
#
# Mirrors rammp::DriveCommand in rammp-org/rammp-rtps (messages/joystick_message.hpp),
# field for field and in wire order; not the source of truth. Do not reorder, insert
# or retype fields.

# request values (rammp::DriveRequest)
uint8 REQUEST_DISABLE = 0     # not driving on the joystick: IDLE, or PUSH_ASSIST if push_assist
uint8 REQUEST_ENABLE = 1      # the joystick drives
uint8 REQUEST_AUTONOMOUS = 2  # the Jetson drives on TwistSetpoint
uint8 REQUEST_SHARED = 3      # the Jetson and the joystick drive together

# profile values (rammp::DriveProfile), reported back in MibStatus.active_profile
uint8 PROFILE_LOW = 0
uint8 PROFILE_NORMAL = 1
uint8 PROFILE_HIGH = 2

uint8 request      # one of REQUEST_*
uint8 profile      # one of PROFILE_*; ignored by push assist
bool  push_assist  # with REQUEST_DISABLE: an assistant drives from the push handle
