# Approach the goal along one tool axis, through a blended intermediate target.
#
# IMPORTANT: an approach is not independent of locking. The planner holds the
# OTHER FIVE pose components at the goal's values while travelling along the
# freed axis, so requesting an approach also requests those five locks — and
# therefore requires the start to already match the goal on them.
#
# The frame `distance` and `axis` are measured in is `axis_lock.reference_frame`
# (see ToolAxisLock.msg), even when no axis is locked.
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
