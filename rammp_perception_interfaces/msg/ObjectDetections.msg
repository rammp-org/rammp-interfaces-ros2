# Every object detected in one camera frame: the one detection message every perception node publishes,
# whichever model is behind it, and what the Orchestrator reads as "what is currently visible". Objects
# missing from the latest message are no longer detected.

std_msgs/Header header       # copied from the source image, so stamp and frame_id match it exactly
DetectedObject[] objects

# mono16, the same size as the source image. Each pixel holds the mask_id of the object covering it,
# 0 where there is none. Where masks overlap, the higher-scoring object wins. Empty (0 x 0) when the
# publisher sends no masks.
sensor_msgs/Image label_image
