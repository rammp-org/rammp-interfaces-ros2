# A request from one engine, delegated to whichever engine handles `type`
# (e.g. "MOVE_BASE" -> Base Navigation). Mirrors
# rammp_orchestrator.interfaces.Intent.

string type
string params_json
string reason
