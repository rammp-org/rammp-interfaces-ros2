# What the tracker is doing, published at a low fixed rate whether or not a session is open.

std_msgs/Header header
bool     active
uint32   session_id          # 0 when no session is open
string[] prompts
string   image_topic
float64  lease_remaining_s   # the session ends when this reaches 0 unless renewed; inf when the server does not
                             # enforce leases
float32  rate_hz             # tracked frames per second, recent average
DetectedObject[] objects     # latest state of every tracked object, without masks
