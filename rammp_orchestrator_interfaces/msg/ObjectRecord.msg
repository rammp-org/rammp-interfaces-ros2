# Mirrors rammp_orchestrator.interfaces.ObjectRecord.

string instance_id
string perception_class

# JSON-encoded {"x":.., "y":.., "theta":..} or similar; empty string if unset.
string last_pose_json

string location

# -1 = unknown/not-applicable, 0 = false, 1 = true (ROS2 msgs have no
# Optional[bool], so tri-state is modeled explicitly).
int8 opened

float64 last_seen

# Populated from whichever write path last touched this instance: a
# Perception subscription's DetectedObject.box (scene camera, pixel space
# of rammp-UI-bridge docs/NODE_INTERFACE.md §3.2's base layer), or an
# engine's update_object_state call refining an already-tracked instance's
# box from its own camera (overlay layer, see stream_id below). Lets the
# UI bridge get box data purely from GetDetectedObjects, without a direct
# Perception subscription of its own. All 0 when unset (no box has been
# reported for this instance yet).
float32[4] box      # [x_min, y_min, x_max, y_max] in source-image pixels

# Which camera stream box is in the pixel space of -- empty string means
# the scene camera (§3.2's base layer); otherwise the id of the engine
# camera stream (§3.3.1's overlay layer) that last supplied box. The UI
# bridge must hit-test/draw box against *that* stream's frame, not always
# the base layer.
string stream_id
