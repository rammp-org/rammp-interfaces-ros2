# Arm Cartesian frame is `arm_mount` (rammp-interfaces-ros2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The arm interfaces document their Cartesian fields in `arm_mount` (Z against gravity when the chair is level, origin at `arm_base_link`) instead of `base_link` / "the base frame".

**Architecture:** Comment-only edits in four files of `rammp_arm_interfaces`. No field, constant, default or type changes, so the generated types are identical; no version bump, because this lands on `dev` alongside the interface changes still being merged there.

**Tech Stack:** ROS 2 Humble `rosidl` (`.msg`/`.action`), colcon.

**Spec:** rammp-deployments: `docs/superpowers/specs/2026-10-15-tilted-arm-mount-design.md`

## Global Constraints

- Branch `docs/arm-mount-frame` from `origin/dev`; PR to `dev`. Commits end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Comments only. No version bump, no README version-history entry, no `package.xml` change.
- The frame is written `arm_mount` everywhere; where it is first defined in a file: "Z against gravity when the chair is level", origin at `arm_base_link`.
- The tool frame is `arm_tool_frame` (the spec's new link; the old `tool_frame` name no longer exists in the model).
- Verification is offline: a build on abra in `/tmp`, removed afterwards. No arm is powered and nothing else on abra changes.
- Out of scope: any other package, `PlanToPose` (RAMMP-CuRobo owns it), the IMU, cuRobo, worlds.

## Review Focus

- **A stale frame word survives in a comment that is not on the spec's line list** (the spec names `GoToEEPose.action:1-2`; the same file also says "base frame", "base axis" and "base Z" six more times, and carries a "tilted mount tips the object" caveat that this change makes false): the grep in Step 1 lists all 12 stale lines and the same grep in Step 5 finds none. Pinned in Steps 1 and 5.
- **`arm_base_link` matched as stale**: the grep uses `\bbase_link`, so the new definition's `arm_base_link` does not count. Pinned in Step 5.
- **A comment edit that accidentally changes a field or a default** (e.g. a `#` lost on a wrapped line, turning prose into a field): the built `GoToEEPose` and `PoseSetpoint` show the same fields as before. Pinned in Steps 6–7.

______________________________________________________________________

### Task 1: Document the arm's Cartesian frame as `arm_mount`

**Files:**

- Modify: `rammp_arm_interfaces/action/GoToEEPose.action:1-2,14,17,23,36,42-46,64`
- Modify: `rammp_arm_interfaces/msg/EeState.msg:13`
- Modify: `rammp_arm_interfaces/msg/PoseSetpoint.msg:1`
- Modify: `rammp_arm_interfaces/msg/TwistSetpoint.msg:1`

**Interfaces:**

- Produces: nothing new. The documented contract the kinova-gen3-ros2 driver enforces: `GoToEEPose.target.header.frame_id == "arm_mount"`; `/ee_state`, `/setpoint/pose`, `/setpoint/twist` are in `arm_mount`.

- [ ] **Step 1: Record the stale wording (the failing check)**

Run: `grep -rnE '\bbase_link|base frame|base Z|base axis|ROBOT BASE|\btool_frame' rammp_arm_interfaces | cut -d: -f1,2`
Expected: 12 lines — `PoseSetpoint.msg:1`, `TwistSetpoint.msg:1`, `EeState.msg:13`, and `GoToEEPose.action` 1, 2, 14, 17, 23, 36, 42, 44, 64.

- [ ] **Step 2: `GoToEEPose.action`**

Replace lines 1–2:

```
# Goal — move the tool (tool_frame) to a base_link pose; cuRobo plans collision-free.
geometry_msgs/PoseStamped target   # frame_id MUST be base_link (rejected otherwise)
```

with:

```
# Goal — move the tool (arm_tool_frame) to a pose in arm_mount; cuRobo plans
# collision-free. arm_mount: Z against gravity when the chair is level, X forward,
# origin at arm_base_link. The arm's mount tilt sits between it and arm_base_link.
geometry_msgs/PoseStamped target   # frame_id MUST be arm_mount (rejected otherwise)
```

Replace `# Two modes and no frame field. "Hold roll and pitch in the base frame" is a`
with `# Two modes and no frame field. "Hold roll and pitch in arm_mount" is a`.

Replace `# only express "travel along one base axis", and a straight line in an`
with `# only express "travel along one arm_mount axis", and a straight line in an`.

Replace `# every mode. HOLD_LEVEL frees spin about base Z only IN TRANSIT.`
with `# every mode. HOLD_LEVEL frees spin about arm_mount Z only IN TRANSIT.`

Replace `# WHICH MODE FOR WHICH OBJECT. HOLD_LEVEL leaves the spin about base Z free in`
with `# WHICH MODE FOR WHICH OBJECT. HOLD_LEVEL leaves the spin about arm_mount Z free in`.

Replace the paragraph:

```
# "LEVEL WITH THE WORLD" MEANS "LEVEL WITH THE ROBOT BASE". That is the same
# thing while the arm is mounted level, and stops being the same thing the
# moment it is not: HOLD_LEVEL frees rotation about base Z, so on a tilted
# mount that freedom tips the object it was meant to protect. Mount tilt has
# to be declared in the robot model, not corrected here.
```

with (the spec's "level relative to the chair, not the world"; the tilt is now in the model):

```
# "LEVEL" MEANS LEVEL WITH THE CHAIR, NOT THE WORLD. HOLD_LEVEL frees rotation
# about arm_mount Z, which is vertical while the chair stands on level ground,
# however the arm is tilted on it (the tilt is declared in the robot model). On
# a ramp arm_mount tilts with the chair, and "level" is off by the ramp angle.
```

Replace `uint8 HOLD_LEVEL=1    # keep the tool's tilt; spin about base Z free in transit`
with `uint8 HOLD_LEVEL=1    # keep the tool's tilt; spin about arm_mount Z free in transit`.

- [ ] **Step 3: `EeState.msg`**

Replace line 13:

```
# frame. Linear and angular parts are both expressed in base_link orientation.
```

with:

```
# frame. Linear and angular parts are both expressed in arm_mount orientation.
```

- [ ] **Step 4: `PoseSetpoint.msg` and `TwistSetpoint.msg`**

`PoseSetpoint.msg`, replace line 1 `# Target tool pose in the base frame.` with:

```
# Target tool pose in arm_mount (Z against gravity when the chair is level,
# origin at arm_base_link). There is no frame field: it is always arm_mount.
```

`TwistSetpoint.msg`, replace line 1 `# Target tool twist, base frame. Core carries this as [linear; angular].` with:

```
# Target tool twist in arm_mount (Z against gravity when the chair is level,
# origin at arm_base_link). Core carries this as [linear; angular].
```

- [ ] **Step 5: No stale frame wording is left**

Run: `grep -rnE '\bbase_link|base frame|base Z|base axis|ROBOT BASE|\btool_frame' rammp_arm_interfaces; echo "exit $?"`
Expected: no lines, `exit 1`.

Run: `git diff --stat`
Expected: the four files only — `GoToEEPose.action | 25`, `EeState.msg | 2`, `PoseSetpoint.msg | 3`, `TwistSetpoint.msg | 3` (18 insertions, 15 deletions).

Run: `git diff -U0 | grep '^[-+][^-+#]'`
Expected: exactly the two `GoToEEPose` lines that are fields with trailing comments (`geometry_msgs/PoseStamped target …` and `uint8 HOLD_LEVEL=1 …`), each once with `-` and once with `+`, identical up to the `#`. Every other changed line is a comment.

- [ ] **Step 6: Build on abra (offline, in `/tmp`)**

The repo has no CI; this is the build every consumer does. abra has ROS 2 Humble and colcon; its login shell is zsh, so the build runs under `bash -c`.

```bash
ssh abra 'mkdir -p /tmp/arm-mount-frame-check'
rsync -a --exclude .git ./ abra:/tmp/arm-mount-frame-check/src/
ssh abra "bash -c 'cd /tmp/arm-mount-frame-check && source /opt/ros/humble/setup.bash &&
  colcon build --packages-select rammp_arm_interfaces 2>&1 | tail -3 &&
  source install/setup.bash &&
  ros2 interface show rammp_arm_interfaces/action/GoToEEPose 2>/dev/null | head -4 &&
  ros2 interface show rammp_arm_interfaces/msg/PoseSetpoint;
  cd / && rm -rf /tmp/arm-mount-frame-check'"
```

Expected: `Summary: 1 package finished`. (`1 package had stderr output` is pre-existing: colcon's git listing fails because `.git` is not copied.) Then:

```
# Goal — move the tool (arm_tool_frame) to a pose in arm_mount; cuRobo plans
# collision-free. arm_mount: Z against gravity when the chair is level, X forward,
# origin at arm_base_link. The arm's mount tilt sits between it and arm_base_link.
geometry_msgs/PoseStamped target   # frame_id MUST be arm_mount (rejected otherwise)
# Target tool pose in arm_mount (Z against gravity when the chair is level,
# origin at arm_base_link). There is no frame field: it is always arm_mount.
geometry_msgs/Pose pose
	Point position
		float64 x
		float64 y
		float64 z
	Quaternion orientation
		float64 x 0
		float64 y 0
		float64 z 0
		float64 w 1
uint8[16]          token
```

- [ ] **Step 7: Commit**

```bash
git add rammp_arm_interfaces/action/GoToEEPose.action rammp_arm_interfaces/msg/EeState.msg \
  rammp_arm_interfaces/msg/PoseSetpoint.msg rammp_arm_interfaces/msg/TwistSetpoint.msg
git commit -m "docs(arm): Cartesian fields are in arm_mount, not base_link

arm_mount is gravity-aligned when the chair is level, with its origin at
arm_base_link; the arm's mount tilt sits between the two. Comments only:
no field, default or type changes, so no version bump.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```
