# One box obstacle for the arm's motion planner (AddObstacles), in the
# request's frame.
string name                 # unique in the planner's collision world
geometry_msgs/Pose pose     # the box's centre and orientation
# Full extents along the box's own x, y, z (m), each > 0: the object's own
# size. The planner pads every side by its own collision margin, as it pads
# every obstacle, so do not add a margin of your own.
geometry_msgs/Vector3 dims
