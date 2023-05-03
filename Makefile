BSDKIT_ROOT_URL?=https://hub.olgeni.com/FreeBSD
BSDKIT_VERSION?=13.2
BSDKIT_PKGSET?=nox11

all:

format:
	@inplace "shfmt -ci -sr -s -i 4" bsdkit* *.sh cloud-init/*.sh

lint:
	@ansible-lint -c ansible-lint.yml

start-vm:
	@$(CURDIR)/bsdkit-vbox start

stop-vm:
	@$(CURDIR)/bsdkit-vbox stop

rebuild-vm:
	@$(CURDIR)/bsdkit-vbox poweroff || :
	@$(CURDIR)/bsdkit-vbox destroy || :
	@$(CURDIR)/bsdkit-vbox create
	@$(CURDIR)/bsdkit-vbox start

restart-vm:
	@$(CURDIR)/bsdkit-vbox stop || :
	@$(CURDIR)/bsdkit-vbox start

purge-vm:
	@$(CURDIR)/bsdkit-vbox purge || :

destroy-vm:
	@$(CURDIR)/bsdkit-vbox poweroff || :
	@$(CURDIR)/bsdkit-vbox destroy || :

sync-vm:
	@$(CURDIR)/bsdkit-vbox sync_vm

logcat:
	@$(CURDIR)/bsdkit-vbox logcat

shell:
	@$(CURDIR)/bsdkit-vbox shell

install-gpt-zfs-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0

install-gpt-zfs-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1

install-gpt-zfs-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1 ada2

install-mbr-zfs-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0

install-mbr-zfs-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1

install-mbr-zfs-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1 ada2

install-zfs-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0

install-zfs-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1

install-zfs-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_zfs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1 ada2

install-mbr-ufs-single-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} single ada0

install-gpt-ufs-single-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_ufs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} single ada0

install-gpt-ufs-multi-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_ufs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} multi ada0

install-mbr-ufs-multi-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} multi ada0

install-mbr-ufs-gmirror-single-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs_gmirror -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} single gm0 ada0 ada1

install-mbr-ufs-gmirror-single-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs_gmirror -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} single gm0 ada0 ada1 ada2

install-mbr-ufs-gmirror-multi-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs_gmirror -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} multi gm0 ada0 ada1

install-mbr-ufs-gmirror-multi-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs_gmirror -r ${BSDKIT_ROOT_URL} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} multi gm0 ada0 ada1 ada2

sysprep-aws:
	$(CURDIR)/bsdkit-vbox remote_exec sysprep -t aws

sysprep-digitalocean:
	$(CURDIR)/bsdkit-vbox remote_exec sysprep -t digitalocean

image-aws-zfs: rebuild-vm install-gpt-zfs-1 restart-vm sync-vm sysprep-aws

image-aws-ufs: rebuild-vm install-gpt-ufs-single-1 restart-vm sync-vm sysprep-aws

image-digitalocean-zfs: rebuild-vm install-gpt-zfs-1 restart-vm sync-vm sysprep-digitalocean

image-digitalocean-ufs: rebuild-vm install-gpt-ufs-single-1 restart-vm sync-vm sysprep-digitalocean
