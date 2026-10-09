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
