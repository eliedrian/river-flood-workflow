.POSIX:

PREFIX ?= /usr

ifeq ($(PREFIX),/usr)
sysconfdir = /etc
else
sysconfdir = $(PREFIX)/etc
endif

unitsdir = $(DESTDIR)$(PREFIX)/lib/systemd/system
etcdir = $(DESTDIR)$(sysconfdir)/river-flood-workflow
bindir = $(DESTDIR)$(PREFIX)/bin
cachedir = $(DESTDIR)$(PREFIX)/var/cache

test_unitsdir = $(PREFIX)/share/systemd/user

units := glofas-fetch.service failure-email-send@.service \
	 river-flood-process.service river-flood-workflow.target \
	 river-flood-workflow.timer glofas-cache-cleanup.service \
	 river-flood-report.timer river-flood-report.service

bins := failure-email-send.sh glofas-fetch.sh river-flood-process.sh \
	glofas-cache-cleanup.sh river-flood-alert.sh csv-extraction.py \
	river-flood-report.sh

etcs := failure-email.tmpl ftp_password ftp_username mailing.list alert.list \
	alert-email.tmpl report-email.tmpl weekly_report.list

diff:
	$(foreach unit,$(units),diff -u $(unit) $(unitsdir)/$(unit) ;)
	$(foreach bin,$(bins),diff -u $(bin) $(bindir)/$(basename $(bin)) ;)
	$(foreach etc,$(etcs),diff -u $(etc) $(etcdir)/$(etc) ;)

install: $(units)
	$(foreach unit,$(units),\
		sed \
		-e 's|@bindir@|$(bindir)|g' \
		-e 's|@etcdir@|$(etcdir)|g' \
		-e 's|@cachedir@|$(cachedir)|g' \
		$(unit) | install -Dm644 /dev/stdin $(unitsdir)/$(unit) ;)
	$(foreach bin,$(bins),\
		sed \
		-e 's|@bindir@|$(bindir)|g' \
		-e 's|@etcdir@|$(etcdir)|g' \
		-e 's|@cachedir@|$(cachedir)|g' \
		$(bin) | install -Dm755 /dev/stdin $(bindir)/$(basename $(bin)) ;)
	$(foreach etc,$(etcs),install -Dm644 $(etc) $(etcdir)/$(etc) ;)
	mkdir -p $(cachedir)/glofas
	systemctl daemon-reload

install-test:
	$(foreach unit,$(units),\
		sed \
		-e 's|@bindir@|$(bindir)|g' \
		-e 's|@etcdir@|$(etcdir)|g' \
		-e 's|@cachedir@|$(cachedir)|g' \
		$(unit) | install -Dm644 /dev/stdin $(test_unitsdir)/$(unit) ;)
	$(foreach bin,$(bins),\
		sed \
		-e 's|@bindir@|$(bindir)|g' \
		-e 's|@etcdir@|$(etcdir)|g' \
		-e 's|@cachedir@|$(cachedir)|g' \
		$(bin) | install -Dm755 /dev/stdin $(bindir)/$(basename $(bin)) ;)
	$(foreach etc,$(etcs),install -Dm644 $(etc) $(etcdir)/$(etc) ;)
	mkdir -p $(cachedir)/glofas
	systemctl --user daemon-reload

uninstall:
	-$(foreach unit,$(units),rm $(unitsdir)/$(unit) ;)
	-$(foreach bin,$(bins),rm $(bindir)/$(basename $(bin)) ;)
	systemctl daemon-reload

purge: uninstall
	-rm -rfv $(etcdir)

.PHONY: install uninstall purge diff install-test

