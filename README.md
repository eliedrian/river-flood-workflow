## Requirements

- `lftp`

## Services

Responsibility of tasks are spread across different systemd units.

- `glofas-cache-cleanup.service` handles deletion of old cache data for space considerations.
- `glofas-fetch.service` handles fetching GloFAS data from the FTP server.
- `river-flood-process.service` then processes the downloaded GloFAS data.
- `river-flood-workflow.target` ties all above services together.
- `river-flood-workflow.timer` starts target at a specific time (10:30 UTC).

## Scripts

Services above run scripts located in `/usr/bin`

- `failure-email-send` script reading in the failure template from configuration directory.
- `glofas-fetch` handles running `lftp` and mirroring the GloFAS data in cache.
- `river-flood-process` runs the actual script

## Directories

- `/etc/river-flood-workflow`: contains configuration
- `/var/cache/glofas`: location of GloFAS data download
- `/opt/river-flood-workflow`: script from https://github.com/rodekruis/river-flood-workflow

## Credentials 

Populate credentials for SFTP in the following files:

- `ftp_username`
- `ftp_password`

`make` will copy these files into the `/etc/river-flood-workflow`.

TODO: combine these into a credentials file

## Mailing list

Addresses to email on unit failure is in `mailing.list` (one email per line).

## Todo

- [ ] install script, copying into `/usr/bin`, and service files
- [ ] adapt directories to deployment
