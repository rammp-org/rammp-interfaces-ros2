# The MIB's (the base board's) high-level operating state. Sent best-effort
# and resent periodically, so a subscriber that starts late catches up on the
# next tick; subscribe best_effort.

uint8 SYSTEM_STATE_INITIALIZING = 0  # not ready
uint8 SYSTEM_STATE_IDLE = 1          # waiting for enable; seat control available, drive disabled
uint8 SYSTEM_STATE_ENABLED = 2       # operational; manual seat control disabled
uint8 SYSTEM_STATE_ERROR = 3         # a fault; error_message says why

uint8 system_state       # one of SYSTEM_STATE_*
string error_message     # human-readable; "No error" when none
