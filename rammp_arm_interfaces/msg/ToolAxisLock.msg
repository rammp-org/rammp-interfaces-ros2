# Tool-pose components to hold fixed for the whole trajectory.
#
# A locked component is held AT THE GOAL'S VALUE, so the start pose must already
# match the goal on that component. "Locked" means unchanged, not level: a tool
# at 45 degrees planning to a 45-degree goal stays at 45 the whole way.
# The planner judges whether the start matches against its own tolerance and,
# if not, refuses the goal with a reason naming the axis.
#
# `reference_frame` governs BOTH the lock and the approach offset: an
# ApproachOffset on the same goal is measured in this frame too, even when no
# axis is locked. The default, FRAME_BASE, is the robot base frame.
#
# All fields false (the default) means unconstrained.

uint8 FRAME_BASE=0    # the robot base frame — gravity-relative, what "level" means
uint8 FRAME_GOAL=1    # projected into the goal frame
uint8 reference_frame 0

bool lock_roll
bool lock_pitch
bool lock_yaw
bool lock_x
bool lock_y
bool lock_z
