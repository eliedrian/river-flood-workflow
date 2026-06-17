UNITS_DIR=/etc/systemd/system
BIN_DIR=/usr/bin
ETC_DIR=/etc/river-flood-workflow

UNITS:=glofas-fetch.service failure-email-send@.service river-flood-process.service river-flood-workflow.target river-flood-workflow.timer
BINS:=failure-email-send.sh glofas-fetch.sh river-flood-process.sh
ETCS:=failure-email.tmpl ftp_password ftp_username mailing.list

.phony: install uninstall

install:
        $(foreach unit,$(UNITS),install -Dm644 $(unit) $(UNITS_DIR)/$(unit) ;)
        $(foreach bin,$(BINS),install -Dm755 $(bin) $(BIN_DIR)/$(basename $(bin)) ;)
        $(foreach etc,$(ETCS),install -Dm644 $(etc) $(ETC_DIR)/$(etc) ;)
        systemctl daemon-reload

uninstall:
        $(foreach unit,$(UNITS),rm $(UNITS_DIR)/$(unit) ;)
        $(foreach bin,$(BINS),rm $(BIN_DIR)/$(basename $(bin)) ;)
        $(foreach etc,$(ETCS),rm $(ETC_DIR)/$(etc) ;)
        systemctl daemon-reload
