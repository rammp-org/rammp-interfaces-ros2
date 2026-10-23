# A tappable object offered to the user as part of a RequestUserInput goal
# (rammp_ui_bridge_interfaces/action/RequestUserInput.action). Deliberately
# not rammp_orchestrator_interfaces/ObjectRecord: the Orchestrator has no
# part in this exchange, and this is the minimum UE needs to render and
# hit-test one tappable box on the calling engine's own overlay camera
# stream -- no stream_id field, since every object in one goal implicitly
# belongs to that engine's own stream (the bridge tags them when forwarding
# to UE).

string instance_id
string perception_class
float32[4] box   # [x_min, y_min, x_max, y_max] in the calling engine's own camera's pixel space
