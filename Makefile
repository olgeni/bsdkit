HOST?=192.168.0.1
PORT?=8080
BSDKIT_VERSION?=12.2
BSDKIT_PKGSET?=nox11

all:

format:
	@inplace "shfmt -ci -sr -s -i 4" bsdkit* *.sh cloud-init/*.sh

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

destroy-vm:
	@$(CURDIR)/bsdkit-vbox poweroff || :
	@$(CURDIR)/bsdkit-vbox destroy || :

sync-vm:
	@rsync -av -e "ssh -p 2200" . root@localhost:/root/bsdkit/

logcat:
	@$(CURDIR)/bsdkit-vbox logcat > /tmp/bsdkit.log

shell:
	@$(CURDIR)/bsdkit-vbox shell

test-install-gpt-zfs-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0

test-install-gpt-zfs-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1

test-install-gpt-zfs-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1 ada2

test-install-mbr-zfs-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0

test-install-mbr-zfs-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1

test-install-mbr-zfs-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1 ada2

test-install-zfs-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0

test-install-zfs-2:
	$(CURDIR)/bsdkit-vbox remote_deploy install_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1

test-install-zfs-3:
	$(CURDIR)/bsdkit-vbox remote_deploy install_zfs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} ada0 ada1 ada2

test-install-mbr-ufs-single-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} single ada0

test-install-gpt-ufs-single-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_ufs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} single ada0

test-install-gpt-ufs-multi-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_ufs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} multi ada0

test-install-mbr-ufs-multi-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} multi ada0

test-install-mbr-ufs-gmirror-single-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs_gmirror -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} single gm0 ada0 ada1 ada2

test-install-mbr-ufs-gmirror-multi-1:
	$(CURDIR)/bsdkit-vbox remote_deploy install_mbr_ufs_gmirror -r http://${HOST}:${PORT} \
		-z ${BSDKIT_PKGSET} -v ${BSDKIT_VERSION} multi gm0 ada0 ada1 ada2
