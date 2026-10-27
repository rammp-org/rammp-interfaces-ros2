cmake_minimum_required(VERSION 3.8)
project(rammp_ui_bridge_interfaces)
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(action_msgs REQUIRED)
find_package(builtin_interfaces REQUIRED)
find_package(sensor_msgs REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/EngineOverlayImage.msg"
  "action/RequestUserInput.action"
  "srv/UpdateUserInputPanel.srv"
  DEPENDENCIES action_msgs builtin_interfaces sensor_msgs)
ament_package()
