# rammp-interfaces-ros2

The ROS 2 contracts for talking to RAMMP robots. One repo, one version, several
packages — a consumer depends on the surface it uses, not on all of them.

| package | what it covers |
| --- | --- |
| `rammp_common_interfaces` | what no single subsystem owns: emergency stop, and the arbitration protocol for taking control of a resource |
| `rammp_arm_interfaces` | commanding and observing an arm: trajectories, planned moves, setpoint streaming, the gripper |

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
run together" reduces to **do they all speak the same major?** — answerable by
reading pins, without running anything.
