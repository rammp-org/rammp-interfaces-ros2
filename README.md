# rammp-interfaces-ros2

The ROS 2 contracts for talking to RAMMP robots. One repo, one version, several
packages — a consumer depends on the surface it uses, not on all of them.

| package | what it covers |
| --- | --- |
| `rammp_common_interfaces` | what no single subsystem owns: emergency stop, and the arbitration protocol for taking control of a resource |
| `rammp_peripheral_interfaces` | optional add-on devices broadcasting their input for any consumer: the joystick |
| `rammp_arm_interfaces` | commanding and observing an arm: trajectories, planned moves, setpoint streaming, the gripper |
| `rammp_base_interfaces` | observing and commanding the mobile base: the MIB's status, seat state, velocity and pose setpoints |
| `rammp_orchestrator_interfaces` | the contract between the Orchestrator and any capability engine: manifest registration, object selection, action execution with progress/result, intent delegation between engines, and World State read/write |
| `rammp_perception_interfaces` | what perception sees: detected objects with masks (`ObjectDetections`, the one detection message every perception node publishes), one-shot detection, tracking sessions |

### Where the line between them is

A type belongs in `rammp_common_interfaces` when its contract is complete
**without knowing what is being controlled**. E-stop qualifies: it is a broadcast
about the whole robot. Arbitration qualifies: a token, an owner and a generation
mean the same thing whether the resource is an arm or a base, so the arm and the
base run separate arbitration servers speaking one protocol — and an operator
override tool needs one client, not one per subsystem.

Most of the arm's types would *also* survive that test read literally — a service
of strings and a token has nothing arm-shaped in its fields. That is why the test
is about the contract and not the field list. `OpenStream` is the case worth
naming: it looks generic, but it hands back `channels` that you must then publish
arm-shaped setpoints onto, so it is only meaningful alongside a setpoint
vocabulary. Trajectory following is the same — it is tuned to arm control modes.
Both stay in `rammp_arm_interfaces` until a second subsystem exists to show what,
if anything, they genuinely share. Guessing at that shape before there is a
consumer is how you ship a contract you cannot honour.

`rammp_orchestrator_interfaces` also passes the test, by a different route: its
types (`CapabilityManifest`, `ActionSpec`, `Intent`, `Progress`, `Result`, ...)
describe how the Orchestrator and an engine talk to each other, and that
conversation is identical whether the engine behind it drives an arm, a base, or
a microwave. The contract is complete without knowing what is being controlled —
it is, in fact, specifically the layer that lets the Orchestrator not know.

Setpoints are kept per subsystem. The arm's and the base's `TwistSetpoint` and
`PoseSetpoint` share a shape (a `geometry_msgs` payload plus a token) but are
separate types: the payload's frame and meaningful components are specific to each
subsystem and expected to diverge, and a shared type would make every base-only
change a major bump for the arm. The part they do share, the token protocol,
lives here. Locomanipulation follows the same rule: a whole-body controller is its
own contract (an end-effector target in a world frame), not a merge of the two
setpoints, and the shared piece it needs is atomic arbitration over the arm and
the base together.

## Everything shared lives here

Every interface shared between RAMMP modules belongs here, whichever subsystem
it describes. Install this one repo and you have every message needed to talk to
anything else on the robot — no hunting for which repo owns which type, and no
second pin to keep in step.

Carrying messages you never publish costs next to nothing. These packages depend
on nothing but `builtin_interfaces` and the standard message packages, so there
is no transitive dependency to inherit and nothing to conflict with; the price of
the messages you do not use is some generated headers and a library you never
link.

An interface is also a contract between two parties, so it should not live
inside either one. A package that ships the messages it implements forces every
consumer to depend on that implementation in order to speak to it, and makes the
contract's version whatever the implementation's happens to be.

## Versioning

Semantic versioning. Which bump a field change earns depends on **where the
field goes**, not just that one was added.

| change | bump |
| --- | --- |
| new message, service or action | **minor** |
| new field **appended at the end** with a default value | **minor** |
| comments, docs, whitespace | **patch** |
| a field added **anywhere but the end**, or appended without a default | **MAJOR** |
| a field removed, renamed or retyped | **MAJOR** |

**These rules hold only under Cyclone DDS**, which is what the RAMMP base image
runs. On another RMW the appended-field minor bump is not safe.

### Appending is safe, inserting is not

On Humble a subscriber matches a publisher on the **type name** and nothing
else. Type hashes (`RIHS01_…`) arrived in Iron; Humble has no `type_hash.h` and
no `RIHS` symbols in `librmw`. Two builds of the same type name connect even
when their fields differ.

Appending is safe because the deserialiser stops at the end of the payload and
leaves the trailing field as constructed — the declared default when there is
one, zero when there is not. That is why the default is what makes an appended
field a minor bump: without one the field silently reads `0`, which a consumer
cannot tell apart from a zero the publisher meant to send.

Inserting is not safe, and a default does not change that. Every field after the
insertion point reads the previous field's bytes, and the last one falls off the
end of the payload. No error, no refused connection, just wrong numbers reaching
the robot.

### Cyclone matches on type name; Fast-DDS does not

The table above describes Cyclone DDS, which is what the RAMMP base image runs.
Under Fast-DDS a subscriber whose definition differs from the publisher's does
not match at all, so the topic carries nothing rather than carrying wrong
values.

The appended-field minor bump therefore holds only while every module on the
robot runs Cyclone. Point one module at a different RMW and a change this policy
calls minor becomes a topic that silently never delivers. A mid-struct insertion
is a major bump under either.

Revisit all of this the moment RAMMP moves past Humble — on Iron and later the
runtime can tell, and these rules can relax.

### Version history

Every package carries the repo's one version.

- **2.0.0**, 2026-10-30. **MAJOR**: in `rammp_arm_interfaces` one field is
  retyped in place, one message is renamed, and the Cartesian fields change
  frame. Everything else is additive.
  (An in-tree 1.2.0 of 2026-10-09 carried `rammp_orchestrator_interfaces` but
  was never tagged; this release subsumes it.)

  **What breaks, and what a client does about it:**
  - `ExecuteJointTrajectory`'s goal **retypes `gains`** from
    `JointImpedanceGains` to `ImpedanceGains` in place (#9). An old client's
    bytes land in the wrong fields with no error, so every node that sends or
    serves this action moves to 2.0.0 together. Leave `gains` at its default
    (`PROFILE_SESSION_DEFAULT`) for the session default, name a profile
    (`PROFILE_SOFT` / `_MEDIUM` / `_STIFF`), or set `PROFILE_CUSTOM` and fill
    `custom`.
  - **`JointImpedanceGains` is renamed `JointImpedanceGainValues`** (#9). It
    now appears only as `ImpedanceGains.custom`. Code that imports the old name
    no longer compiles; switch the import.
  - **Cartesian arm fields are in `arm_mount`, not `base_link`** (#14).
    `GoToEEPose` requires `target.header.frame_id: arm_mount` and refuses
    `base_link`. `PoseSetpoint`, `TwistSetpoint` and the new `EEPoseTarget`
    are in `arm_mount` (Z against gravity when the chair is level, origin at
    `arm_base_link`), and `EeState` is expressed in `arm_mount` orientation. No field changes here, only the frame
    the numbers mean. On a level mount (dojo) the numbers are the same; on
    flatbot and gen_1_5 they change by the 30° tilt, so re-record saved poses.
  - `EeState` appends `geometry_msgs/Wrench wrench` (#13). Appended at the end,
    so it is safe on the wire, but a nested message cannot carry a default: an
    old driver's `EeState` reads as a zero wrench, not a missing one.

  **`rammp_arm_interfaces`, additive:**
  - **Compliance on every motion surface** (#9). New `ImpedanceGains` (a
    named profile or custom gains) and token-gated `SetGains`, which re-points
    the session default. `GoToEEPose`, `GoToJointConfig` and `GoToPreset`
    append `control_mode` (`CONTROL_MODE_POSITION` = 0, the default, or
    `CONTROL_MODE_IMPEDANCE`) and `ImpedanceGains gains`. `OpenStream`'s request
    appends `gains`, applied at open. The defaults mean today's behaviour, and
    a non-default `gains` where it cannot act is refused, not ignored.
  - **Several targets in one motion** (#21). New actions `GoToEEPoses` and
    `GoToJointConfigs`, and their target messages `EEPoseTarget` (pose, speed
    scale, orientation hold, blend radius) and `JointConfigTarget` (joints,
    speed scale, blend radius). Result and feedback are the single-target
    actions'. The legs are blended by RAMMP-CuRobo's `/rammp_curobo/blend`.
    The two target messages are array elements inside a goal, so **a field
    added to either later is a MAJOR change**, appended or not (see their
    header comments).
  - **Contact detection** (#23). New token-gated `SetContactThresholds`
    (`PROFILE_DEFAULT`, `_SENSITIVE`, `_LOOSE`, or `_CUSTOM` with 7 per-joint
    values in N·m; it answers with the profile and thresholds now active). New
    result code `CONTACT_STOP = -11`, documented on every arm action's
    `error_code` and on `OpenStream`'s: the arm stopped on unexpected contact
    and needs `/clear_faults`.
  - `EeState`'s header comment says which estimate the wrench is: the
    driver's contact observer while it runs and has settled, the quasi-static
    `g(q) − τ` otherwise (#25, kinova-gen3-driver#112). Comment only.

  **`rammp_common_interfaces`:** `AcquireControl`'s request appends an
  optional pre-generated `uint8[16] token` (#19), so an orchestrator can use
  one key across several resources. All-zero, the default, means "mint one",
  as before.

  **`rammp_base_interfaces`:** new `TwistSetpoint` (body frame) and
  `PoseSetpoint` (odom frame), each carrying the arbitration token (#18). Same
  shape as the arm's setpoints but separate types; see "Where the line between
  them is" above.

  **New package `rammp_orchestrator_interfaces`** (#10): the
  Orchestrator/engine contract. Messages `CapabilityManifest`, `ActionSpec`,
  `ActionAvailability`, `EngineActivation`, `Intent`, `ObjectRecord`,
  `Progress`, `Result`; services `Activate`, `Control`, `Deselect`,
  `GetDetectedObjects`, `GetWorldState`, `Hibernate`, `RegisterEngine`,
  `RequestIntent`, `SelectObject`, `UpdateObjectState`, `WriteWorldState`;
  action `ExecuteAction`.

  **New package `rammp_perception_interfaces`** (#12, #16): `DetectedObject`
  (with `size`, the 3D box extent around `pose`), `ObjectDetections`,
  `TrackingStatus`; `Detect`, `StartTracking`, `RenewTracking`,
  `StopTracking`. `ObjectDetections` is the one detection message every
  perception node publishes, whichever model is behind it; the Orchestrator
  reads it and keeps `ObjectRecord` as its World State record. Masks travel as
  one mono16 label image per frame, pixel value = `mask_id`. A tracking session
  may hold a lease like `OpenStream`, so a crashed client cannot leave the GPU
  busy. `ObjectDetections` first landed in `rammp_orchestrator_interfaces`
  (#10) and moved here (#12) before any tag, so only builds from `dev` need to
  switch the import.
- **1.1.0**, 2026-10-02: new packages `rammp_base_interfaces` (`MibState`,
  `SeatState`) and `rammp_peripheral_interfaces` (`XYTwist`); new goal fields
  `speed_scale` (all four arm actions) and `orientation_hold` (`GoToEEPose`, a
  `uint8` with `HOLD_NONE`/`HOLD_LEVEL`/`HOLD_FIXED` constants on the goal).
  Minor because the fields are appended at the end of the goal with defaults
  that mean today's behaviour, so an older client is unaffected under Cyclone
  DDS (see the policy above). `GoToJointConfig` and `GoToPreset` get
  `speed_scale` only, deliberately: they plan in joint space, where holding a
  tool orientation has no meaning. (An in-tree 1.1.0 of 2026-09-24 carried the
  two new packages but was never tagged; this release subsumes it.)
- **1.0.0**, 2026-09-10: first tag.

### Release order

These packages depend on nothing, so they always release first. Tag here, then
each consumer bumps its pin in an ordinary PR. There is no ordering deadlock to
manage.

### For consumers

Pin an exact tag, not a branch:

```yaml
# your-module.repos
rammp-interfaces-ros2:
  type: git
  url: https://github.com/rammp-org/rammp-interfaces-ros2.git
  version: v2.0.0
```

A colcon workspace holds exactly one version of a package, so "can these modules
run together" reduces to **do they all speak the same major?** — answerable by
reading pins, without running anything.

## RTPS compatibility

Some types are compatible with the robot's RTPS messages. The embedded boards
publish raw RTPS (XCDR1 — the same encoding ROS 2 speaks), and the
corresponding types here are kept in step with `rammp-org/rammp-rtps` so a ROS
node reads the boards' own packets with no bridge in between.
