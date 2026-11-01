# The seat's pose, as the MIB (the base board) last measured it. Nested in MibStatus,
# which is how it reaches ROS 2; there is no topic of its own.
#
# Mirrors rammp::SeatState in rammp-org/rammp-rtps (messages/mib_message.hpp), field for
# field and in wire order; not the source of truth. Whole units: degrees and millimetres.
float32 front_back_tilt   # deg, front-to-back seat tilt
float32 lateral_tilt      # deg, side-to-side seat tilt
float32 elevation         # mm, seat elevation
float32 translation       # mm, seat translation
