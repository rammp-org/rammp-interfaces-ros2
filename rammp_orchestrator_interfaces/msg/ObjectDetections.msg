# A full "current frame" of detected object instances, published by a
# perception node (mock or real) to the Orchestrator's ~/object_detections
# topic. Each publish replaces the Orchestrator's notion of "what's
# currently visible" -- objects not included in the latest message are
# considered no longer detected (see OrchestratorNode._on_object_detections).

ObjectRecord[] objects
