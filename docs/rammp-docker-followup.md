# RAMMP-docker follow-up: retiring the vendored base interfaces

`rammp_base_interfaces` now lives here. `rammp-org/RAMMP-docker` still carries
the original as `RAMMP-interfaces/rammp_prototype_interfaces` and vendors it into
the base image with a plain `COPY`. Until that repo changes, the same contract
exists in two places under two package names, and nothing forces them to agree.

This is the work to close that. It is a separate PR against RAMMP-docker; none
of it has been done.

## Do this after `rammp-interfaces-ros2` is tagged

The Dockerfile change pins a tag, so it cannot land before the tag exists. See
"Tag state" below — the existing `v1.0.0` is not yet the tag you want.

## Changes

### 1. Delete the vendored package

```
RAMMP-interfaces/rammp_prototype_interfaces/     delete
```

Leave `RAMMP-interfaces/arm_interfaces/` alone. It is a different, older contract
(`SetMode`, `SetSpeedPreset`, `CheckReachability`, `ReachPreset`) that
`rammp_arm_interfaces` supersedes but does not replace field-for-field. Retiring
it is its own decision with its own consumers to check.

### 2. Fetch the contract instead of vendoring it

`docker/base/Dockerfile:50` currently reads:

```dockerfile
COPY RAMMP-interfaces/ /ros2_ws/src/RAMMP-interfaces/
```

Replace with a `vcs import` of this repo at an exact tag, alongside the `COPY`
that remains for `arm_interfaces`. The build already runs from the repo root
because of that `COPY`; if `arm_interfaces` is also retired later, that
constraint goes away and the comments at `docker/base/Dockerfile:8` and
`Makefile:28` need revisiting.

### 3. Rename in the smoke test

`scripts/smoke-test.sh` names the types directly:

- lines 63-70 — the type-resolution loop: the four
  `rammp_prototype_interfaces/...` entries become `rammp_base_interfaces/...`
- line 77 — `from rammp_prototype_interfaces.msg import RAMMPPrototypeState`
- lines 139 and 144 — `ros2 topic pub` / `ros2 topic echo` on
  `rammp_prototype_interfaces/msg/SeatCommand`

The message and action names themselves did not change, so this is a package
prefix substitution and nothing more.

### 4. Prose

- `RAMMP-interfaces/README.md` — says the directory "holds exactly two packages"
  and lists `rammp_prototype_interfaces`
- `docker/base/Dockerfile:3,12,22`, `docker/cuda/Dockerfile:21`,
  `templates/module.Dockerfile:10`, `docker/entrypoint.sh:6` — all describe
  RAMMP-interfaces as the vendored robot-level contract
- `Makefile:11,26` — the version-bump comment, and the `package.xml` it reads to
  derive the image version

## Tag state

`v1.0.0` is pushed and already pinned by `kinova_arm_ros2/kinova_gen3.repos`,
but it predates this package. The intent is to fold `rammp_base_interfaces` into
v1.0.0 rather than ship it as v1.1.0, which means the tag gets moved once `dev`
merges to `main` and the release is actually final:

1. delete `v1.0.0` locally and on the remote, re-tag the merged `main`, force-push
2. re-point `kinova_arm_ros2/kinova_gen3.repos` at the new `v1.0.0` — git will
   not re-fetch a tag it already has, so this needs to be deliberate
3. tell anyone else who has cloned

Moving a published tag is exactly what this repo's README tells consumers to
rely on not happening. It is defensible only because the release is days old and
the change is purely additive to `rammp_arm_interfaces`. If anything in the arm
package changes before release, that reasoning no longer holds and it should
ship as v1.1.0 instead.
