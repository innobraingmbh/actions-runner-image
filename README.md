# actions-runner-image

The runner image for the self-hosted `asahi-arm64` runners (ARC on the rack
MacBooks): `ghcr.io/actions/actions-runner` plus PHP 8.4, Composer and
Node 22, so jobs skip the per-job toolchain install.

Built weekly and on push by the Build workflow, published as
`ghcr.io/innobraingmbh/actions-runner-php:8.4`. The runners pick it up from
`arc_runner_image` in the server-automation repo (`roles/arc`).
