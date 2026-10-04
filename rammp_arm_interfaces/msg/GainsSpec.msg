# How a command names its compliance (core's GainsSpec).
#
# PROFILE_SESSION_DEFAULT -- the default -- means "whatever the session default
# points at" (initially the MEDIUM profile; /set_gains re-points it). The named
# profiles are complete, core-owned parameter sets. PROFILE_CUSTOM overrides
# kq/zeta/torque_limit on top of the session default, and is bounds-checked at
# accept time: a value out of range is REFUSED with a reason, never clamped.
#
# `custom` is read iff profile == PROFILE_CUSTOM.
uint8 PROFILE_SESSION_DEFAULT=0
uint8 PROFILE_SOFT=1
uint8 PROFILE_MEDIUM=2
uint8 PROFILE_STIFF=3
uint8 PROFILE_CUSTOM=4
uint8 profile 0
JointImpedanceGains custom
