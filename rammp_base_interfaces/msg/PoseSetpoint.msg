# Target base pose in the odom frame (REP 105).
#
# Same shape as rammp_arm_interfaces/PoseSetpoint but a separate type; see the README.
#
# Planar: only x, y and yaw are commanded; position.z, roll and pitch are ignored.
geometry_msgs/Pose pose
uint8[16]          token    # from /acquire_control; validates the sender, every message
