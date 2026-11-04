# An engine's answer, at activation time, to "can I do X right now".
# Mirrors rammp_orchestrator.interfaces.ActionAvailability.

string action_id
bool available
string reason
string suggested_params_json
