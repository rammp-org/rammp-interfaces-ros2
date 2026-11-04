cmake_minimum_required(VERSION 3.8)
project(rammp_perception_interfaces)
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(builtin_interfaces REQUIRED)
find_package(std_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/DetectedObject.msg"
  "msg/ObjectDetections.msg"
  "msg/TrackingStatus.msg"
  "srv/Detect.srv"
  "srv/StartTracking.srv"
  "srv/RenewTracking.srv"
  "srv/StopTracking.srv"
  DEPENDENCIES builtin_interfaces std_msgs sensor_msgs geometry_msgs)
ament_package()
