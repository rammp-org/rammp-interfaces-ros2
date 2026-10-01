# How much of the tool's ORIENTATION to keep for the whole move.
#
# Two modes and no frame field. "Hold roll and pitch in the base frame" is a
# mechanism, not a request, in a frame whose axes mean nothing to a caller;
# HOLD_LEVEL is the request. Position holds are not offered at all: they could
# only express "travel along one base axis", and a straight line in an
# arbitrary direction is not expressible through the planner's constraint
# machinery. A Cartesian linear move is a different operation.

uint8 HOLD_NONE=0     # orientation free — the planner reorients as it likes
uint8 HOLD_LEVEL=1    # keep the tool's tilt; spin about vertical stays free
uint8 HOLD_FIXED=2    # keep the orientation entirely
uint8 hold 0

# HOLD_LEVEL PRESERVES TILT, IT DOES NOT CREATE LEVEL. Roll and pitch are held
# at the goal's values, so a gripper that starts 20 degrees off stays 20 degrees
# off the whole way — faithfully, just not level. "Level" means "as level as you
# already are".
#
# So a goal orientation that disagrees with where the arm IS, on the components
# being held, is REFUSED rather than quietly re-aimed: it asks for two
# different orientations at once. Send the current orientation as the goal's,
# or get there with an unconstrained move first.
#
# WHICH MODE FOR WHICH OBJECT. HOLD_LEVEL leaves the spin about vertical free,
# which is right for anything rotationally symmetric about its upright axis —
# a cup, a bottle, a plate. A spoon is NOT symmetric: the bowl has to face a
# particular way, so no spin is free and it needs HOLD_FIXED. Choosing LEVEL
# for a spoon will plan happily and tip the contents out.
#
# "LEVEL WITH THE WORLD" MEANS "LEVEL WITH THE ROBOT BASE". That is the same
# thing while the arm is mounted level, and stops being the same thing the
# moment it is not: HOLD_LEVEL frees rotation about the base's vertical axis,
# so on a tilted mount that freedom tips the object it was meant to protect.
# Mount tilt has to be declared in the robot model, not corrected here.
#
# IT IS CHECKED, NOT HOPED FOR. The planner's hold is a cost rather than a hard
# limit, so it measures the trajectory it produced and refuses a plan whose
# worst deviation exceeds its configured tolerance. A plan that comes back
# SUCCESSFUL has been verified to hold within that tolerance.
