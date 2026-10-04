# bsdkit

bsdkit is a toolkit for installing, configuring and maintaining FreeBSD
servers. It covers the whole life of a machine: partitioning disks and
installing the base system, configuring it with Ansible, building cloud images
for AWS and DigitalOcean, and later upgrading the OS, packages and databases in
place.

> [!WARNING]
>
> **This is a personal toolkit, not a general-purpose product.**
>
> bsdkit encodes one administrator's opinions about how a FreeBSD server should
> look: package repositories, ZFS layout, dotfiles, SSH policy, service
> supervision and more. It is published because it is useful to its author, not
> because it has been made safe or convenient for anyone else.
>
> Many commands are destructive by design. The `install-*` commands wipe and
> repartition the disks you name. Others rewrite ZFS pools and filesystems, purge
> boot environments, delete snapshots, replace files under `/etc`, or upgrade
> the operating system of the machine they run on. Most of them do not ask for
> confirmation, and `bsdkit configure` will happily reshape a server that was
> set up some other way.
>
> Read the code before running anything, try it in a disposable VM first, and
> keep backups of any machine you point it at.

## Requirements

- FreeBSD (the default target is 15.x on amd64) for everything that runs on the
  server
- `zsh`, `git` and Ansible on the target machine; `bsdkit` checks for its
  dependencies and reports what is missing
- VirtualBox on the workstation, for the `bsdkit-vbox` image-building workflow

By default, releases and packages are fetched from a custom mirror
(`https://hub.olgeni.com/FreeBSD`). Set `BSDKIT_ROOT_URL`, `BSDKIT_TREE` and
`BSDKIT_PKGSET` to use a different source.

## Installation

bsdkit runs from a git checkout:

```sh
pkg install zsh git
git clone https://gitlab.com/olgeni/bsdkit.git /usr/local/bsdkit
ln -s /usr/local/bsdkit/bsdkit /usr/local/sbin/bsdkit
```

`bsdkit update` later resets the checkout to `origin/master`, discarding any
local changes.

`test/test-user-data.sh` shows a complete bootstrap script suitable for cloud
user data.

## Usage

`bsdkit` is a single zsh script; each command is a function, invoked as:

```sh
bsdkit <command> [arguments]
```

Prefix a command with `with-quiet` or `with-verbose` to control how much
Ansible output is shown.

### Installing a system

These commands partition the given disks, install FreeBSD into
`BSDKIT_DESTDIR` (default `/mnt`) and run the Ansible playbook in a chroot.
They erase the target disks.

| Command                   | Layout                                  |
| ------------------------- | --------------------------------------- |
| `install-gpt-zfs`         | GPT, root on ZFS                        |
| `install-mbr-zfs`         | MBR, root on ZFS                        |
| `install-zfs`             | Root on ZFS using whole disks           |
| `install-gpt-ufs`         | GPT, UFS (single or multi partition)    |
| `install-mbr-ufs`         | MBR, UFS (single or multi partition)    |
| `install-mbr-ufs-gmirror` | MBR, UFS on a gmirror(8) mirrored array |

Partition sizes and labels, the pool name and the installed components are
controlled by `BSDKIT_*` environment variables, listed at the top of the
`bsdkit` script.

### Configuring a system

| Command                        | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| `configure`                    | Apply the Ansible playbook to the local machine  |
| `configure-jail <jail>`        | Apply the playbook to a jail                     |
| `configure-crontab`            | Install the bsdkit crontab                       |
| `monit-setup`                  | Configure monit                                  |
| `install-dotfiles`             | Install the bsdkit dotfiles for the current user |
| `provision`                    | Run platform provisioning on AWS or DigitalOcean |
| `sysprep -t aws\|digitalocean` | Prepare the machine to be captured as an image   |
| `status`                       | Show the monit service summary                   |

Per-host settings live in `/usr/local/etc/bsdkit.yml` and are managed with
`config-get`, `config-set`, `config-del`, `config-keys` and `config-list`.

The playbook is split into roles under `playbook/roles` (SSH, pkg, ZFS,
PostgreSQL, MySQL, monit, runit services, Consul, Nomad, Vault, GitLab Runner
and others).

### Jails

`create-jail`, `make-thin-jail`, `make-full-jail`, `remove-jail`,
`start-jail` and `stop-jail` manage plain jails; `create-iocage` and
`create-iocage-jail` cover iocage.

### Maintenance and upgrades

These wrap the helpers in `libexec/`:

| Command                  | Description                                         |
| ------------------------ | --------------------------------------------------- |
| `upgrade-os`             | Upgrade the operating system                        |
| `upgrade-os-pkg`         | Upgrade a pkgbase system in a new boot environment  |
| `upgrade-etc`            | Merge configuration changes into `/etc`             |
| `upgrade-loader`         | Update the boot loader                              |
| `delete-old-files`       | Remove files left over by an upgrade                |
| `upgrade-postgresql`     | Upgrade PostgreSQL to a new major version           |
| `upgrade-php`            | Switch to a new PHP version                         |
| `upgrade-python`         | Switch to a new Python version                      |
| `pkg-diff`               | Compare the packages installed on two servers       |
| `rewrite-pool`           | Copy a ZFS pool onto a new device                   |
| `rewrite-filesystem`     | Rewrite a ZFS dataset and destroy the original      |
| `zfs-migrate-postgresql` | Move PostgreSQL data onto dedicated ZFS datasets    |
| `zfs-migrate-mysql`      | Move MySQL data onto dedicated ZFS datasets         |
| `update-runit`           | Update runit service definitions                    |
| `relocate-venv`          | Fix the paths in a Python virtualenv after a move   |
| `build`, `release`       | Build FreeBSD from source and produce release media |

There are also cleanup commands such as `purge-be`, `purge-ko`,
`purge-local-libdirs` and `destroy-zfs-snapshots`. As their names suggest, they
delete things.

## Building cloud images

`bsdkit-vbox` drives a local VirtualBox VM, and the `Makefile` chains its steps
into complete image builds:

```sh
make image-aws-zfs           # or image-aws-ufs
make image-digitalocean-zfs  # or image-digitalocean-ufs
```

Each target rebuilds the VM from a FreeBSD ISO, installs bsdkit over SSH with
`remote-exec`, reboots, and runs `sysprep`. The resulting disk can be uploaded
with `bin/upload-image-aws` or `bin/upload-image-do`.

The VM is configured with `BSDKIT_VBOX_*` variables (`BSDKIT_VBOX_ISO`,
`BSDKIT_VBOX_EFI`, `BSDKIT_VBOX_DISK_SIZE` and so on). Other useful targets are
`start-vm`, `stop-vm`, `shell`, `logcat` and the snapshot targets.

The SSH key pairs in `keypairs/` are public, since they are part of this
repository. They exist so the build workflow can reach the VM; never authorize
them on a machine that is reachable from the network.

## Development

```sh
make lint   # ansible-lint
```

## License

BSD 2-Clause. See [LICENSE.md](LICENSE.md).
