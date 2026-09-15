# IronCore Brokers

[![REUSE status](https://api.reuse.software/badge/github.com/ironcore-dev/brokers)](https://api.reuse.software/info/github.com/ironcore-dev/brokers)
[![GitHub License](https://img.shields.io/static/v1?label=License&message=Apache-2.0&color=blue)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://makeapullrequest.com)

This repository contains the [IronCore](https://github.com/ironcore-dev/ironcore) brokers — the IRI (IronCore Runtime
Interface) broker implementations that sit between the poollets and the underlying infrastructure providers:

- **machinebroker** — serves the machine IRI (`broker/machinebroker`)
- **volumebroker** — serves the volume IRI (`broker/volumebroker`)
- **bucketbroker** — serves the bucket IRI (`broker/bucketbroker`)

Shared broker infrastructure lives under `broker/common`.

## Building

```shell
# Build all broker binaries into ./bin
make build

# Build the broker container images
make docker-build
```

Run `make help` for the full list of targets.

## Testing

```shell
make test
```

## Contributing

We'd love to get feedback from you. Please report bugs, suggestions or post questions by opening a GitHub issue.

> ⚠️ Before contributing, make sure you read the [contribution guidelines](https://ironcore.dev/community/contributing.html)

## Licensing

Copyright 2025 SAP SE or an SAP affiliate company and IronCore contributors. Please see our [LICENSE](LICENSE) for
copyright and license information. Detailed information including third-party components and their licensing/copyright
information is available [via the REUSE tool](https://api.reuse.software/info/github.com/ironcore-dev/brokers).

<p align="center"><img alt="Bundesministerium für Wirtschaft und Energie (BMWE)-EU funding logo" src="https://apeirora.eu/assets/img/BMWK-EU.png" width="400"/></p>
