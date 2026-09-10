# Broadcast emergency stop, robot-wide. ANY node may publish; engaging is fail-safe
# by design.
#
# Deliberately NOT std_msgs/Bool: std_msgs primitives "do not convey semantic meaning
# about their contents" and are "NOT intended for long-term usage" (std_msgs docs).
# The stamp is load-bearing, and the staleness policy is deliberately asymmetric:
# engaging is NEVER age-checked, clearing is. A stale message must never be able to
# release a stop.
std_msgs/Header header   # stamp: an all-zero stamp means "unstamped" and is accepted
bool   engaged           # true = engage the stop, false = clear it
string source            # who published it (node name / operator id), for the log
string reason            # free text, for the log
