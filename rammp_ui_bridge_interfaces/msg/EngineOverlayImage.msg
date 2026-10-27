# One frame on the shared overlay-camera topic (NODE_INTERFACE.md §3.3.1): every
# engine that has its own camera (e.g. a wrist cam) publishes this to the SAME topic
# -- there is no per-engine topic name. `token` is what lets the bridge tell frames
# from the currently-active engine apart from a stale/second publisher: it is the
# arbitration capability the engine was handed by rammp_common_interfaces/AcquireControl,
# called against the bridge's own arbitration server for this resource (see the UI
# bridge's README/NODE_INTERFACE.md for the exact service names). The bridge drops
# any frame whose token doesn't match the token it most recently granted, so a second
# engine racing to publish (or one that never released control) can't bleed its frames
# into UE -- same token-gating pattern as rammp_arm_interfaces/JointSetpoint and
# rammp_base_interfaces/TwistSetpoint, just applied to a bridge-owned resource instead
# of a piece of hardware.
sensor_msgs/Image image
uint8[16] token
