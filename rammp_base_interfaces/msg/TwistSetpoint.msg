# Target base velocity, body frame (base_link, REP 103: x forward, y left, z up).
#
# Same shape as rammp_arm_interfaces/TwistSetpoint but a separate type, so the two
# can diverge; see the README.
#
# Planar: only linear.x, linear.y and angular.z are used; the rest are ignored. A base
# that cannot move sideways ignores linear.y too.
geometry_msgs/Twist twist
uint8[16]           token   # from /acquire_control; validates the sender, every message
