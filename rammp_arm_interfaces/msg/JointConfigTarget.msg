# One target of GoToJointConfigs: GoToJointConfig's goal fields for one leg, the
# move TO this configuration, plus how far that move may cut the corner into the
# next one.
float64[7] target_joints   # rad, joint_1..joint_7, as GoToJointConfig's
# As GoToJointConfig's speed_scale, for this leg only. The trajectory carries
# every leg's speed, so a slow leg blends into a fast one.
float64 speed_scale 1.0
# m: how close the tool must pass where it is at this configuration, and how far
# it may leave the planned path, when the arm cuts the corner into the next leg
# instead of stopping here. 0 (the default) stops on it. The planner cuts only as
# far as the joint limits, collision and this radius all allow, which may be not
# at all. Not used on the last target, which always stops.
float64 blend_radius 0.0
