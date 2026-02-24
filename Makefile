.PHONY: help install uninstall verify

help:
	@echo "Available targets:"
	@echo ""
	@echo "  install - Install/update Piko system components"
	@echo "  uninstall - Remove Piko system components"
	@echo "  verify  - Verify installed Piko status"

install:
	@sudo ./install.sh

uninstall:
	@sudo ./uninstall.sh

verify:
	@state=$$(systemctl is-active piko-watchdog.timer || true); \
		echo "$$state"; \
		if [ "$$state" != "active" ]; then \
			echo "piko-watchdog.timer is not active (expected after uninstall)."; \
			exit 1; \
		fi
	@sudo -l | grep -q "!/usr/bin/chattr" && echo "chattr sudo policy: BLOCKED" || echo "chattr sudo policy: check manually"
	@ls -la /usr/local/bin/piko-block /usr/local/bin/piko-browser-cycle /usr/local/bin/piko-browser-guard /usr/local/bin/piko-request-unlock /usr/local/bin/piko-request-unblock /usr/local/bin/piko-status /usr/local/bin/piko-sync /usr/local/bin/piko-unblock /usr/local/bin/piko-unlocked-now /usr/local/bin/piko-watchdog
	@ls -la /var/lib/piko/
