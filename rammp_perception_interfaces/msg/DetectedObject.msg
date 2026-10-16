# One detected object in one camera frame. Its mask is the set of pixels in the accompanying
# ObjectDetections.label_image whose value equals `mask_id`.

uint8 STATE_VISIBLE=0    # the object was detected in this frame
uint8 STATE_OCCLUDED=1   # tracked but absent this frame: it keeps its instance_id and may come back

string instance_id       # "<perception_class>_<n>", e.g. "microwave_2". A publisher that tracks keeps it for as
                         # long as it tracks the object; per call for Detect.
string perception_class  # what the object is: the publisher's class name, or the prompt that found it
float32 score            # detection confidence in [0, 1]
uint8 state
float32[4] box           # [x_min, y_min, x_max, y_max] in source-image pixels; all 0 when not visible
uint16 mask_id           # this object's value in label_image, >= 1; 0 when it has no mask this frame (and always
                         # in TrackingStatus). A non-zero mask_id can still cover no pixels: overlapping masks go
                         # to the higher-scoring object.

bool has_pose            # false until the publisher can place the object in 3D (e.g. from aligned depth)
geometry_msgs/Pose pose  # in the enclosing message's header.frame_id (ObjectDetections or TrackingStatus);
                         # valid only when has_pose
