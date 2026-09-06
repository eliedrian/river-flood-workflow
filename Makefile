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
	$(foreach unit,$(units),install -Dm644 $(unit) $(unitsdir)/$(unit) ;)
	$(foreach bin,$(bins),install -Dm755 $(bin) $(bindir)/$(basename $(bin)) ;)
	$(foreach etc,$(etcs),install -Dm644 $(etc) $(etcdir)/$(etc) ;)
	systemctl daemon-reload

uninstall:
	-$(foreach unit,$(units),rm $(unitsdir)/$(unit) ;)
	-$(foreach bin,$(bins),rm $(bindir)/$(basename $(bin)) ;)
	systemctl daemon-reload

clean:
	-rm *.service

purge: uninstall
	-rm -rfv $(etcdir)

.phony: install uninstall purge diff clean

%.service : %.service.in
	sed \
		-e 's|@bindir@|$(bindir)|g' \
		-e 's|@etcdir@|$(etcdir)|g' \
		$< > $@
