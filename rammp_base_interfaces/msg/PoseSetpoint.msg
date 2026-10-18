# Target base pose in the odom frame (REP 105).
#
# Same shape as rammp_arm_interfaces/PoseSetpoint, deliberately NOT the same type:
# see TwistSetpoint.msg and the README.
#
# The base moves in the plane: position.z and any roll or pitch in the orientation
# are ignored; only x, y and yaw are commanded.
geometry_msgs/Pose pose
uint8[16]          token    # from /acquire_control; validates the sender, every message
