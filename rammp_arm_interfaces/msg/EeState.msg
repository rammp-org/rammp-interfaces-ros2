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
# frame. Linear and angular parts are both expressed in arm_mount orientation.
#
# The wrench is the driver's OWN estimate of the external wrench at the tool --
# what the environment applies to the EE, [force; torque] in N / N*m, same frame,
# model and sample as the rest: F = pinv(J^T) tau_ext, from one of two joint
# torque estimates. NOT KORTEX's tool_external_wrench, which is in KORTEX's tool
# frame and stops updating in low-level servoing.
#
# - WRENCH_SOURCE_OBSERVER: the contact monitor's momentum-observer residual.
#   Published while contact detection runs (enforce or observe) and its observer
#   has settled. It models the arm's own inertia and Coriolis terms, so it stays
#   accurate while the arm moves. It is a first-order filter (K = 25 rad/s): about
#   25 ms behind the quasi-static estimate (23-25 ms measured on hand taps).
# - WRENCH_SOURCE_QUASI_STATIC: g(q) - tau, gravity minus measured joint torque.
#   Published with contact_detection off, and for the ~200 ms the observer settles
#   after the driver (re)starts its control loop (at startup and after a fault or
#   reconnect) and after a contact stop is cleared. Exact at rest and with no
#   lag, but in motion the arm's own M*qdd + C*qd reads as external force.
#
# wrench_source says which one this message carries. Both read a held payload as
# external force. Contact-detection grade, not force-control grade: a few N of
# noise at the tool (on a position-mode tour with nobody touching, force error
# median 1.9 N with the observer, 3.3 N quasi-static). A client doing fast force
# control wants the quasi-static estimate's zero lag, or a faster source. NaN
# while the arm reports a fault, whichever the source. Zero in sim, where the
# simulated arm reports tau = g(q) and nothing pushes on it.
uint8 WRENCH_SOURCE_QUASI_STATIC=0
uint8 WRENCH_SOURCE_OBSERVER=1

std_msgs/Header header
geometry_msgs/Pose   pose
geometry_msgs/Twist  twist
geometry_msgs/Wrench wrench
uint8 wrench_source 0  # WRENCH_SOURCE_*; appended last (see the README's versioning rules)
