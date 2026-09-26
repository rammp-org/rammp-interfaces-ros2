# The seat's pose, published by the MIB (the base board). Sent best-effort
# and resent periodically, so a subscriber that starts late catches up on the
# next tick; subscribe best_effort.
float32 front_back_tilt   # front-to-back seat tilt
float32 lateral_tilt      # side-to-side seat tilt
float32 elevation         # seat elevation
float32 translation       # seat translation
