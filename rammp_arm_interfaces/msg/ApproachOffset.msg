# Approach the goal along one tool axis, through a blended intermediate target.
#
# IMPORTANT: an approach holds the OTHER FIVE pose components at the goal's
# values while travelling along the freed axis — but only from `at_fraction`
# onward, NOT from the start. So unlike a lock, an approach does NOT require the
# start pose to match the goal; it constrains the end of the motion only.
# (Measured on the arm: a lock on a travelled axis is refused with
# INVALID_PARTIAL_POSE_COST_METRIC, while the same goal carrying an approach
# plans normally.)
#
# THE FRAME IS NOT YOURS TO CHOOSE. `axis` is resolved in the GOAL (tool) frame,
# always, and `axis_lock.reference_frame` has NO effect on it. The planner builds
# this through cuRobo's create_grasp_approach_metric, which accepts a
# project_to_goal_frame argument and then ignores it, falling back to
# PoseCostConfig's projected-distance default. So AXIS_Z is the tool's own
# approach direction — for a forward-facing gripper that is horizontal, not
# "from above".
#
# It is also a preference, not a waypoint: the path passes NEAR the offset
# without stopping there and without hitting it exactly.
#
# distance of 0.0 (the default) means no approach offset. A negative distance
# or an at_fraction outside (0, 1) is refused, not clamped.

# Axes are read in axis_lock.reference_frame. Under the default FRAME_BASE, Z is
# the base's vertical, so AXIS_Z approaches from above. Under FRAME_GOAL, Z is
# the tool's own approach axis.
uint8 AXIS_X=0
uint8 AXIS_Y=1
uint8 AXIS_Z=2

float64 distance      # metres back from the goal along `axis`, in the frame set by
                      # axis_lock.reference_frame (robot base frame by default)
uint8 axis 2
float64 at_fraction 0.8   # fraction of the motion at which it engages, in (0, 1)
