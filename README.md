# rammp-interfaces-ros2

The ROS 2 contracts for talking to RAMMP robots. One repo, one version, several
packages — a consumer depends on the surface it uses, not on all of them.

| package | what it covers |
| --- | --- |
| `rammp_arm_interfaces` | commanding and observing an arm: trajectories, planned moves, arbitration, setpoint streaming, the gripper |

## Why these live outside the driver

An interface is a contract between two parties, so it should not live inside
either one. When the arm's messages lived in the arm driver, every consumer took
a build dependency on the driver to speak to it, and the contract's version was
whatever the driver happened to be.

The cost is real and worth naming: the messages and the code implementing them
now move in separate repositories, so a change to both is two PRs. That is the
price of one contract that many modules can share.

## Versioning

Semantic versioning, with one rule that is stricter than you would expect.

| change | bump |
| --- | --- |
| new message, service or action | **minor** |
| comments, docs, whitespace | **patch** |
| **any change to an existing type** — field added, removed, renamed, retyped | **MAJOR** |

### Why adding a field is a major bump

On ROS 2 Humble, a subscriber matches a publisher on the **type name**. It does
not check the type's content.

Type hashes (`RIHS01_…`) arrived in Iron; Humble has no `type_hash.h` and no
`RIHS` symbols in `librmw`. So a node built against a 4-field message and one
built against the same message with 5 fields **will connect to each other**, and
the second will deserialise the first's bytes as though the extra field were
there. No error. No refused connection. Just wrong numbers, arriving at a robot.

That is worse than a build failure, and it is why "we only added a field" is not
a safe change here. Add fields by adding a **new message**, which is a minor
bump and cannot be misread, or accept the major.

Revisit this the moment RAMMP moves past Humble — on Iron and later the runtime
can tell, and this rule can relax.

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
  version: v1.0.0
```

A colcon workspace holds exactly one version of a package, so "can these modules
run together" reduces to **do they all speak the same major?** That is a
question you can answer by reading pins, without running anything.

## Design notes

**Joint arrays are fixed at `float64[7]`.** `JointSetpoint.values`,
`JointImpedanceGains.kq` / `torque_limit`, and `GoToJointConfig.target_joints`
are sized, not unbounded. That matches the driver's fixed-size `JointVec`, and a
wrong-length message becomes impossible rather than a runtime check every
consumer has to remember. The cost is that a non-7-DOF arm needs new types —
deliberate, because `float64[7]` → `float64[]` would be a breaking change made
under pressure later.

**Some fields are deliberately absent.** They are documented in the `.msg` files
themselves, and the reasoning matters more than the omission:

- `GripperSetpoint` has no `active` flag. The driver's internal struct has one,
  but it is a wire-level gate on the outgoing frame, not a client control —
  setting it false does not stop the gripper being commanded. A field that reads
  as its own opposite is worse than no field.
- `EeState` has no wrench. The driver has no force estimate of its own, and the
  arm's own reading is in a frame the model does not know about. Publishing a
  frame-mismatched value would be worse than publishing nothing.
- Gripper `velocity` does not exist. It was measured to be the commanded speed
  echoed back rather than a measurement.

**No `WrenchSetpoint` in v1.0.0.** No controller consumes a wrench, so shipping
the topic would promise something the contract cannot honour. It can arrive as a
minor bump when a controller exists.

## Provenance

`rammp_arm_interfaces` was extracted from `rammp-org/kinova-gen3-ros2`, where it
was `kinova_gen3_interfaces`. The design records for each tier — arbitration,
streaming, the gripper — live in that repo under `docs/superpowers/specs/`.
