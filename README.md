# kind-setup

Scripts to install [KIND](https://kind.sigs.k8s.io/) (Kubernetes IN Docker) on
Ubuntu and spin up a local Kubernetes cluster for learning/dev use.

## Layout

```
kind-setup/
├── 01.kind.sh        # Install Docker, kubectl, KIND
├── 02.compile.sh      # Create cluster(s) + deploy an nginx test app
├── 03.commands.sh     # Reference cheat-sheet of useful commands (can be sourced)
├── run-all.sh         # Runs 01 -> 02 -> 03 in sequence
└── README.md
```

## Requirements

- Ubuntu (x86_64 by default — edit `ARCH` in `01.kind.sh` if you're on arm64)
- `sudo` privileges
- Internet access to `dl.k8s.io`, `kind.sigs.k8s.io`, and Docker's package repos

## Quick start

Run everything in one go (single-node cluster):

```bash
chmod +x *.sh
./run-all.sh
```

Multi-node cluster instead:

```bash
./run-all.sh multi
```

Both single and multi-node clusters:

```bash
./run-all.sh both
```

## Step-by-step (if you'd rather run things individually)

```bash
./01.kind.sh              # installs docker.io, kubectl, kind
newgrp docker              # apply docker group membership (or log out/in)
./02.compile.sh single      # creates 'dev-cluster' + deploys nginx
./02.compile.sh multi       # creates 'multi-node' (1 control-plane, 2 workers)
```

## Cheat-sheet

`03.commands.sh` can be sourced into your shell for handy functions:

```bash
source 03.commands.sh
kind-list                  # list all KIND clusters
kind-nodes dev-cluster      # show nodes for a cluster
kind-pods-all dev-cluster   # pods across all namespaces
kind-delete dev-cluster     # delete a cluster
```

Or just run it directly to print the raw command reference:

```bash
./03.commands.sh
```

## Notes

- `01.kind.sh` adds your user to the `docker` group so `docker`/`kind` commands
  don't need `sudo`. You must run `newgrp docker` or log out/in for this to
  take effect before running `02.compile.sh`.
- `02.compile.sh` is idempotent — re-running it skips cluster creation if a
  cluster with the same name already exists.
- To clean up: `kind delete cluster --name dev-cluster` (or `multi-node`).
