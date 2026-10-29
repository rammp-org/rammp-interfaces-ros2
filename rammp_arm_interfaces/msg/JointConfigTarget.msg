# One target of GoToJointConfigs: GoToJointConfig's goal fields for one leg, the
# move TO this configuration, plus how far that move may cut the corner into the
# next one.
#
# AN ARRAY ELEMENT: the goal carries a list of these with fields after it, so a
# field added here later shifts everything after it, the MAJOR "insertion" case
# of this repo's versioning rules, not the minor "append". Per-leg fields a caller
# might want and that are deliberately left out: control_mode and gains (one
# trajectory runs under one mode, so they stay on the goal). No orientation_hold,
# as on GoToJointConfig: planning is in joint space.
float64[7] target_joints   # rad, joint_1..joint_7, as GoToJointConfig's
# As GoToJointConfig's speed_scale, for this leg only. The trajectory carries
# every leg's speed, so a slow leg blends into a fast one.
float64 speed_scale 1.0
# m: how close the tool's POSITION must pass where it is at this configuration,
# and how far it may leave the planned path, when the arm cuts the corner into the
# next leg instead of stopping here. With a radius above 0 THE CONFIGURATION ITSELF
# IS NOT REACHED: only the tool passes near where it would be. Use 0 where the
# joints themselves matter (an elbow kept clear, a singularity avoided). 0 (the
# default) stops on it. The planner cuts only as far as the joint velocity and
# acceleration limits, collision and this radius all allow, which may be not at
# all. Not used on the last target, which always stops, but still rejected there
# if negative or not finite.
float64 blend_radius 0.0
