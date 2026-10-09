cmake_minimum_required(VERSION 3.8)
project(rammp_orchestrator_interfaces)
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(action_msgs REQUIRED)
find_package(builtin_interfaces REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/ActionAvailability.msg"
  "msg/ActionSpec.msg"
  "msg/CapabilityManifest.msg"
  "msg/EngineActivation.msg"
  "msg/Intent.msg"
  "msg/ObjectDetections.msg"
  "msg/ObjectRecord.msg"
  "msg/Progress.msg"
  "msg/Result.msg"
  "srv/Activate.srv"
  "srv/Control.srv"
  "srv/Deselect.srv"
  "srv/GetDetectedObjects.srv"
  "srv/GetWorldState.srv"
  "srv/Hibernate.srv"
  "srv/RegisterEngine.srv"
  "srv/RequestIntent.srv"
  "srv/SelectObject.srv"
  "srv/UpdateObjectState.srv"
  "srv/WriteWorldState.srv"
  "action/ExecuteAction.action"
  DEPENDENCIES action_msgs builtin_interfaces)
ament_package()
