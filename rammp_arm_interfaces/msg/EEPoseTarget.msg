# One target of GoToEEPoses: GoToEEPose's goal fields for one leg, the move TO
# this pose, plus how far that move may cut the corner into the next one.
geometry_msgs/PoseStamped pose   # frame_id MUST be arm_mount (refused otherwise)
# As GoToEEPose's speed_scale, for this leg only. The trajectory carries every
# leg's speed, so a slow leg blends into a fast one.
float64 speed_scale 1.0
# As GoToEEPose's orientation_hold, for this leg only; kept through this leg's
# overlaps with its neighbours too. As on GoToEEPose, a hold is checked against
# where the arm IS when the leg starts, and for every leg but the first that is
# the PREVIOUS target: a held leg's pose must agree with the previous target's
# on the held components (its tilt under HOLD_LEVEL), or the leg fails to plan.
uint8 HOLD_NONE=0     # orientation free — the planner reorients as it likes
uint8 HOLD_LEVEL=1    # keep the tool's tilt; spin about arm_mount Z free in transit
uint8 HOLD_FIXED=2    # keep the orientation entirely
uint8 orientation_hold 0
# m: how close the tool must pass this pose, and how far it may leave the planned
# path, when the arm cuts the corner into the next leg instead of stopping here.
# 0 (the default) stops on this pose. The planner cuts only as far as the joint
# limits, collision, the held legs' holds and this radius all allow, which may be
# not at all. Not used on the last target, which always stops.
float64 blend_radius 0.0
