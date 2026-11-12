# What a system-level capability engine declares once, at registration time.
# A system engine is NOT bound to any perceived object (e.g. an arm-error
# recovery handler) -- this is deliberately a separate, smaller type from
# CapabilityManifest rather than a variant of it, so CapabilityManifest and
# every engine already using it are completely unaffected. Mirrors
# rammp_orchestrator.interfaces.SystemCapabilityManifest. A third-party
# system engine plugs in by constructing one of these and calling
# RegisterSystemEngine -- no orchestrator code change needed.

string engine_id
string display_name

# Error domains (e.g. "arm", "base") this engine can recover from. Matched
# against the per-domain error state written to World State by whichever
# capability engine detected the fault.
string[] recovers_domains

# Resources (e.g. "arm") this engine needs to hold for the duration of a
# recovery attempt. Arbitrated the same way as
# CapabilityManifest.required_resources (one ResourceManager, shared by
# object-bound and system engines alike).
string[] required_resources
