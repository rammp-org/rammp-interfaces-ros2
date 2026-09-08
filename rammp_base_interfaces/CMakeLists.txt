cmake_minimum_required(VERSION 3.8)
project(rammp_base_interfaces)
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(builtin_interfaces REQUIRED)
find_package(std_msgs REQUIRED)
find_package(action_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/RAMMPPrototypeState.msg"
  "msg/SeatCommand.msg"
  "action/Calibration.action"
  "action/CurbTraverse.action"
  DEPENDENCIES builtin_interfaces std_msgs action_msgs geometry_msgs)
ament_package()
