# actions-runner-image

The runner image for the self-hosted `asahi-arm64` runners (ARC on the rack
MacBooks): `ghcr.io/actions/actions-runner` plus PHP 8.4, Composer and
Node 22, so jobs skip the per-job toolchain install.

Built weekly and on push by the Build workflow, published as
`ghcr.io/innobraingmbh/actions-runner-php:8.4`. The runners pick it up from
`arc_runner_image` in the server-automation repo (`roles/arc`).

## Supply chain

- The base images and the actions are pinned by digest; Dependabot opens the
  bumps after a seven-day cooldown. The weekly rebuild only refreshes the
  apt packages.
- Every build pushes a provenance attestation and an SBOM next to the image.
  Check that a tag was built by this workflow from this repository with

  ```
  gh attestation verify oci://ghcr.io/innobraingmbh/actions-runner-php:8.4 --owner innobraingmbh
  ```

- Actions must be SHA-pinned (repository setting), the workflow token is
  read-only by default, and `main` accepts no force pushes.
