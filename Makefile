all:

format:
	@inplace "shfmt -ci -kp -sr -s -i 4" bsdkit* *.sh cloud-init/*.sh

reset-vm:
	@$(CURDIR)/bsdkit-vbox poweroff || :
	@$(CURDIR)/bsdkit-vbox destroy || :
	@$(CURDIR)/bsdkit-vbox create
	@$(CURDIR)/bsdkit-vbox start

restart-vm:
	@$(CURDIR)/bsdkit-vbox stop || :
	@$(CURDIR)/bsdkit-vbox start

test-install-gpt-zfs-1:
	@$(CURDIR)/bsdkit-vbox remote_deploy install_gpt_zfs -r http://192.168.0.1:8080 -z nox11 -v 12.1 ada0

logcat:
	@$(CURDIR)/bsdkit-vbox logcat >/tmp/bsdkit.log
