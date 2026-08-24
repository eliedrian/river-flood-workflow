UNITS_DIR=/etc/systemd/system
BIN_DIR=/usr/bin
ETC_DIR=/etc/river-flood-workflow

UNITS:=glofas-fetch.service failure-email-send@.service river-flood-process.service river-flood-workflow.target river-flood-workflow.timer \
       glofas-cache-cleanup.service
BINS:=failure-email-send.sh glofas-fetch.sh river-flood-process.sh glofas-cache-cleanup.sh river-flood-alert.sh csv-extraction.py
ETCS:=failure-email.tmpl ftp_password ftp_username mailing.list alert.list alert-email.tmpl

.phony: install uninstall purge diff

diff:
	$(foreach unit,$(UNITS),diff -u $(unit) $(UNITS_DIR)/$(unit) ;)
	$(foreach bin,$(BINS),diff -u $(bin) $(BIN_DIR)/$(basename $(bin)) ;)
	$(foreach etc,$(ETCS),diff -u $(etc) $(ETC_DIR)/$(etc) ;)

install: 
	$(foreach unit,$(UNITS),install -Dm644 $(unit) $(UNITS_DIR)/$(unit) ;)
	$(foreach bin,$(BINS),install -Dm755 $(bin) $(BIN_DIR)/$(basename $(bin)) ;)
	$(foreach etc,$(ETCS),install -Dm644 $(etc) $(ETC_DIR)/$(etc) ;)
	systemctl daemon-reload

uninstall:
	-$(foreach unit,$(UNITS),rm $(UNITS_DIR)/$(unit) ;)
	-$(foreach bin,$(BINS),rm $(BIN_DIR)/$(basename $(bin)) ;)
	systemctl daemon-reload

purge: uninstall
	-rm -rfv $(ETC_DIR)
