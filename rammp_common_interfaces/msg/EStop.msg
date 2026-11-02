# Broadcast emergency stop, robot-wide. ANY node may publish; engaging is fail-safe
# by design, and only the clearer (the MIB, which owns the latch) can end the stop.
#
# This message definition mirrors rammp::EStop in rammp-org/rammp-rtps
# (components/rammp_rtps_messages/include/messages/estop_message.hpp) field for
# field and is not meant to be taken as a source of truth: the protocol's rules
# and timing (send period, deadman timeout, clear window) live there.
#
# Deliberately NOT std_msgs/Bool: std_msgs primitives "do not convey semantic meaning
# about their contents" and are "NOT intended for long-term usage" (std_msgs docs).
#
# What a message means:
#
#   state        clear_target  meaning                                   who sends it
#   ENGAGED      (any)         engage; always acted on, never age- or    any node
#                              pub_seq-checked
#   NOT_ENGAGED  ""            heartbeat: "alive, not engaging"; it      any node, every period
#                              never ends the stop
#   NOT_ENGAGED  "<src>"       clear attempt for <src>'s engagement      the clearer only
#
# A plain NOT_ENGAGED is NOT a clear: otherwise any node's heartbeat would end
# another node's stop. The stop is released only when a clear attempt succeeds:
# the target accepts it (clear_pub_seq >= the pub_seq of its first ENGAGED after
# its latest press) and answers NOT_ENGAGED with a pub_seq > clear_pub_seq,
# received within the timeout. A source silent longer than the timeout counts as
# engaged (deadman).
#
# The stamp is for the log only. Staleness is judged by receive time on the
# receiver's own clock, never by the stamp, which depends on clock sync.
#
# Sent best-effort, every 100 ms per node: the period resend is the reliability,
# and silence is fail-safe (deadman). Subscribe best_effort, or a firmware
# publisher never matches your subscription.

# `state` is one octet on the wire. A receiver treats any value other than
# STATE_NOT_ENGAGED as STATE_ENGAGED: the fail-safe reading.
uint8 STATE_NOT_ENGAGED = 0   # heartbeat: this node is not asking for the stop
uint8 STATE_ENGAGED = 1       # this node asks for the stop

std_msgs/Header header   # stamp: for the log only, never for decisions; frame_id ""
uint8  state             # one of STATE_*: ENGAGED = engage; NOT_ENGAGED = heartbeat, or a clear attempt
string source            # who published it (node name), for the log and the clear attempt
string reason            # free text, for the log
uint32 pub_seq           # this publisher's message number: +1 per message, wraps
string clear_target      # clear attempts only: whose engagement to clear; "" otherwise
uint32 clear_pub_seq     # clear attempts only: newest pub_seq the clearer had received
                         # from clear_target when the attempt started
