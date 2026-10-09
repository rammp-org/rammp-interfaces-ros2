# One action an engine offers, generic across whatever object it is bound to
# at call time. Mirrors rammp_orchestrator.interfaces.ActionSpec.

string action_id
string label

# JSON-encoded dict describing accepted params (kept as JSON text since ROS2
# messages have no generic map/schema type).
string params_schema_json

bool sticky_followup

# Which of the engine's own CapabilityManifest.perception_classes this
# action applies to. Empty means "applies to every class this engine
# supports" (mirrors ActionSpec.perception_classes).
string[] perception_classes
