# What an engine declares once, at registration time. Mirrors
# rammp_orchestrator.interfaces.CapabilityManifest. This is the single
# mechanism that lets a third-party engine plug in -- it constructs one of
# these and calls the RegisterEngine service -- no orchestrator code changes.

string engine_id
string display_name
string[] perception_classes
rammp_orchestrator_interfaces/ActionSpec[] actions
string[] required_resources
string[] state_reads
string[] state_writes

# Intent type names this engine can serve when another engine delegates to it
# (e.g. "MOVE_BASE"). Free-form strings so new intent types don't require an
# interface change.
string[] intents_handled
