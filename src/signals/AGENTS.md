# Signals Project Guidance

## Scope

This project formalizes signal-processing and physics statements.
It is maintained as a downstream research project under the sustainablefactory repository and
is intended to eventually produce focused PRs for Physlib or Mathlib.

Normally, the instructions would be:

> Do not encode unsupported experimental claims as definitions with hidden
> semantics, `axiom` declarations, or `sorry` proofs. A theorem may describe a
> conditional model, but its assumptions must be visible and documented.

Here we're working toward a more complete model; starting from an exploratory research chat and attempting to use Lean to model the domain (although there are limits to what Lean can do and what we need a sim and/or an experiment for)

## Dependencies

- Use the sibling `../mathlib4` checkout for general mathematics.
- Use the sibling `../physlib` checkout for physics definitions and results.
- Keep the Lean toolchain aligned with Physlib's declared baseline.
- Do not modify either dependency checkout from this project.

## Code Style

- Put reusable mathematics in the narrowest appropriate module.
- Give every public definition and important lemma a docstring.
- Prefer `lemma` for ordinary established consequences.
- Make sign, phase, coordinate, and unit conventions explicit.
- Keep source files free of trailing whitespace.

## Validation

The normal task from the repository root is:

```text
make signals_build
```

It attempts to download available Mathlib/Physlib Lake artifacts and then
builds the Signals library. A cache miss or an unavailable cache for a local
fork is reported and the local build continues. From inside `src/signals`, use
the equivalent commands:

```text
make lean-cache
make lean-build
```

If the container does not yet have Elan, install the pinned project toolchain
with:

```text
make -C src/signals install-elan
```

GitHub Actions runs the same `make signals_build` build after checking out
compatible mathlib and Physlib revisions.

## Container Workflow

The devcontainer mounts the repository at `/workspaces/sustainablefactory` and
persists `src/signals/.lake` in the named volume
`sustainablefactory-${localWorkspaceFolderBasename}-signals-lake`.
The E2E Make task also persists Elan toolchains in
`sustainablefactory-${localWorkspaceFolderBasename}-elan-toolchains`, mounted
at `/home/appuser/.elan/toolchains`; this prevents Lake from downloading the
workspace-selected Lean toolchain again after its first successful install.

After the container is created, run the build from the workspace root:

```text
make signals_build
```

If the current directory is `src/signals`, the equivalent command is:

```text
make
```

To run the same build in the E2E image with the devcontainer workspace,
Podman socket, and persistent `.lake` volume, run from the repository root:

```text
make signals_build_e2e
```

This task mounts both persistent volumes. Override the Elan toolchain volume
with `SIGNALS_ELAN_TOOLCHAINS_VOLUME=...` when sharing a cache between related
workspaces.

The default image is `sustainablefactory-e2e-lean`. If that image is missing,
the task builds it from `Dockerfile.e2e` first. Override the image when using a
different tag:

```text
make signals_build_e2e SIGNALS_E2E_IMAGE=localhost/my-e2e-image:latest
```

To build the image explicitly without running Lean, use
`make signals_build_e2e_build_image`.

The target expects the rootless Podman socket at
`$XDG_RUNTIME_DIR/podman/podman.sock`, matching the devcontainer mount. Start
it on the host with `systemctl --user enable --now podman.socket` when needed.
It uses the `podman` executable directly by default; override it with
`SIGNALS_CONTAINER_RUNTIME` if the container runtime is installed elsewhere.

Do not compile Signals in `Dockerfile.e2e`; that image installs the Lean
toolchain only. Mathlib, Physlib, and Signals compilation belongs in the
mounted workspace so the persistent `.lake` volume can be reused.

## Upstreaming

Before proposing a change to Physlib or Mathlib, add a focused local proof,
record the source or textbook reference, remove unnecessary application
vocabulary, and verify that the result is useful outside Signals. Submit
separate pull requests for physics-specific results and general mathematics.
