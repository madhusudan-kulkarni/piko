.PHONY: help install uninstall verify

help:
	@echo "Available targets:"
	@echo ""
	@echo "  install   - Install/update Piko system components"
	@echo "  uninstall - Remove Piko system components"
	@echo "  verify    - Verify installed Piko status"

install:
	@sudo ./install.sh

uninstall:
	@sudo ./uninstall.sh

verify:
	@systemctl is-active piko-watchdog.timer || (echo "piko-watchdog.timer is not active (expected after uninstall)."; exit 1)
	@sudo -l 2>/dev/null | grep -q "!/usr/bin/chattr" && echo "chattr sudo policy: BLOCKED" || echo "chattr sudo policy: check manually"
	@ls -la ~/.piko/bin/ ~/.piko/state/ /usr/local/bin/piko 2>/dev/null || echo "Piko not found in ~/.piko/"
