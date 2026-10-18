# Target base velocity, body frame (base_link, REP 103: x forward, y left, z up).
#
# Same shape as rammp_arm_interfaces/TwistSetpoint, deliberately NOT the same type:
# the two are expected to diverge, and a shared type would make every base-only
# change a major bump for the arm. See the README.
#
# The base moves in the plane: only linear.x, linear.y and angular.z are meaningful,
# and the rest are ignored. A base that cannot move sideways ignores linear.y too.
geometry_msgs/Twist twist
uint8[16]           token   # from /acquire_control; validates the sender, every message
