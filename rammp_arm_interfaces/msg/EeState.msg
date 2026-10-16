# Cartesian state of the tool, the sibling of /joint_states.
#
# All fields come from the SAME URDF model and the SAME feedback sample: pose is
# fk(q) and twist is J(q)*qd, computed together in the driver's pump. So they agree
# by construction, and they agree with the model cuRobo plans against.
#
# NOT the arm's own tool_pose/tool_twist feedback. KORTEX reports those in its
# configured tool frame, which carries an offset the URDF does not know about --
# mixing the two sources would give a pose and a twist that disagree by an unknown
# transform.
#
# Frame: LOCAL_WORLD_ALIGNED -- a world-aligned frame at the tool, NOT the body
# frame. Linear and angular parts are both expressed in base_link orientation.
#
# The wrench is the driver's OWN estimate of the external wrench at the tool --
# what the environment applies to the EE, [force; torque] in N / N*m, same frame,
# model and sample as the rest. A quasi-static estimate from the joint-torque
# residual (F = pinv(J^T)(g(q) + tau)), NOT KORTEX's tool_external_wrench, which
# is in KORTEX's tool frame and stops updating in low-level servoing.
# Contact-detection grade, not force-control grade: a few N of noise floor at
# the tool, Coriolis/inertial terms ignored. Zero in sim, where the transport
# synthesises no torque feedback.
std_msgs/Header header
geometry_msgs/Pose   pose
geometry_msgs/Twist  twist
geometry_msgs/Wrench wrench
