# Mirrors rammp_orchestrator.interfaces.Result / Status.

uint8 STATUS_SUCCESS=0
uint8 STATUS_FAILED=1
uint8 STATUS_CANCELLED=2

uint8 status

# JSON-encoded dict of result payload fields.
string payload_json

string error_code
bool recoverable
string[] suggestions
