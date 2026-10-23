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
| `rammp_ui_bridge_interfaces` | the contract an active capability engine uses to ask the UI bridge directly for user input -- a button choice, an object tap on the engine's own overlay camera stream, or both -- bypassing the Orchestrator entirely |

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

`rammp_ui_bridge_interfaces` is the same test applied to a different pair: its
one action (`RequestUserInput`) describes how an active engine and the UI
bridge talk to each other while soliciting mid-task user input, and the
Orchestrator is deliberately not a party to that conversation at all — the
UI bridge serves the action, any engine may call it, and nothing about the
contract depends on which engine or which capability is running. Keeping it
out of `rammp_orchestrator_interfaces` keeps that package's own contract
honest: the Orchestrator genuinely has no field, service, or type involved
in this exchange to point to. Its other message, `EngineOverlayImage`, reuses
`rammp_common_interfaces`'s token field directly (not by depending on that
package's types — the field is just `uint8[16] token`, same convention as
the arm/base setpoints) because the overlay-camera topic has the identical
problem a hardware resource does: more than one caller *could* publish to it,
and only whoever currently holds the bridge's grant should actually be heard.

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

- **Unreleased** (`feat/UI-bridge-interface`): new package
  `rammp_ui_bridge_interfaces` (`ObjectCandidate`; `RequestUserInput`) --
  the contract an active engine uses to ask the UI bridge directly for
  user input (a button choice, an object tap on the engine's own overlay
  camera stream, or both), bypassing the Orchestrator entirely. Minor:
  new package only. `rammp_orchestrator_interfaces/ObjectRecord` appends
  `box` (`float32[4]`, all-zero default) and `stream_id` (`string`,
  empty default) so the UI bridge can read pixel-space bounding boxes
  from `GetDetectedObjects` without its own Perception subscription --
  populated from whichever write path (Perception, or an engine's
  `update_object_state`) last touched an instance. Minor: appended at
  the end with defaults that mean "no box reported yet," so an older
  client is unaffected under Cyclone DDS (see the policy above).
  New message `EngineOverlayImage` (`sensor_msgs/Image image`,
  `uint8[16] token`): the shared overlay-camera topic every engine
  publishes its own camera to (NODE_INTERFACE.md §3.3.1) carries this
  type instead of a plain `sensor_msgs/Image`, so the bridge can tell
  which engine's frames are current. `token` is the arbitration
  capability from `rammp_common_interfaces/AcquireControl`, called
  against the bridge's own arbitration server for this resource -- same
  token-gating convention as `rammp_arm_interfaces/JointSetpoint` and
  `rammp_base_interfaces/TwistSetpoint`, just for a bridge-owned
  resource rather than a piece of hardware. Minor: new message only.

- **Unreleased** (`SwapnilPande/move-shareable-message-types-to-rammp_control_in`):
  new base messages `TwistSetpoint` (body frame) and `PoseSetpoint` (odom
  frame), each carrying the arbitration token. Same shape as the arm's
  setpoints but separate types; see "Where the line between them is" above.
  Minor: new messages only.
- **Unreleased** (`feat/compliant-everything`): new `ImpedanceGains` message (a
  named compliance profile — session default / soft / medium / stiff — or
  custom gains) and token-gated `SetGains` service (re-points the session
  default). `ExecuteJointTrajectory`'s goal RETYPES `gains` from
  `JointImpedanceGainValues` to `ImpedanceGains` in place — a **MAJOR** change under the
  policy above. The three `GoTo*` goals and `OpenStream`'s request append
  `control_mode` (`GoTo*` only) and `ImpedanceGains gains`, with defaults that mean
  today's behaviour.
- **Unreleased** (`feature/11-perception-interfaces`): new package
  `rammp_perception_interfaces` (`DetectedObject`, `ObjectDetections`,
  `TrackingStatus`; `Detect`, `StartTracking`, `RenewTracking`, `StopTracking`).
  `ObjectDetections` moves here from `rammp_orchestrator_interfaces` (anyone
  building from `dev` switches the import) and is the one detection message
  every perception node publishes, whichever model is behind it; the
  Orchestrator reads it and keeps `ObjectRecord` as its World State record.
  Masks travel as one mono16 label image per frame, pixel value = `mask_id`, so
  a frame with ten objects is one image rather than ten. A tracking session may
  hold a lease like `OpenStream`, so a crashed client cannot leave the GPU busy.
- **1.2.0**, 2026-10-09: new package `rammp_orchestrator_interfaces` — the
  Orchestrator/engine contract (`CapabilityManifest`, `ActionSpec`,
  `ActionAvailability`, `EngineActivation`, `Intent`, `ObjectDetections`,
  `ObjectRecord`, `Progress`, `Result`; `Activate`, `Control`, `Deselect`,
  `GetDetectedObjects`, `GetWorldState`, `Hibernate`, `RegisterEngine`,
  `RequestIntent`, `SelectObject`, `UpdateObjectState`, `WriteWorldState`;
  `ExecuteAction`). Minor: new package, no changes to any existing type.
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
  version: v1.1.0
```

A colcon workspace holds exactly one version of a package, so "can these modules
run together" reduces to **do they all speak the same major?** — answerable by
reading pins, without running anything.

## RTPS compatibility

Some types are compatible with the robot's RTPS messages. The embedded boards
publish raw RTPS (XCDR1 — the same encoding ROS 2 speaks), and the
corresponding types here are kept in step with `rammp-org/rammp-rtps` so a ROS
node reads the boards' own packets with no bridge in between.
