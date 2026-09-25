# actions-runner-image

The runner image for the self-hosted `asahi-arm64` runners (ARC on the rack
MacBooks): `ghcr.io/actions/actions-runner` plus PHP 8.4 and 8.5, Composer
and Node 22, so jobs skip the per-job toolchain install. `php` is 8.4 until
a job's `setup-php` asks for 8.5, which switches the alternatives. The Node
tool cache lives in `/opt/hostedtoolcache`, with `/__t` (where the runner
points the actions inside a job container) leading to it.

Built weekly and on push by the Build workflow, published as
`ghcr.io/innobraingmbh/actions-runner-php:latest` (and as the run number,
for a rollback). The runners pick it up from `arc_runner_image` in the
server-automation repo (`roles/arc`).

## Supply chain

- The base images and the actions are pinned by digest; Dependabot opens the
  bumps after a seven-day cooldown. Node is pinned by version and checksum
  (`NODE_VERSION`, `NODE_SHA256` in the Dockerfile). The weekly rebuild only
  refreshes the apt packages.
- Every build is smoke-tested (both PHP versions, Node, Composer) and pushes
  a provenance attestation and an SBOM next to the image. Check that a tag
  was built by this workflow from this repository with

  ```
  gh attestation verify oci://ghcr.io/innobraingmbh/actions-runner-php:latest --owner innobraingmbh
  ```

- Actions must be SHA-pinned (repository setting), the workflow token is
  read-only by default, and `main` accepts no force pushes.
