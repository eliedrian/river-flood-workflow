## Requirements

- `lftp`

## Directories

- `/etc/river-flood-workflow`: contains configuration
- `/var/cache/glofas`: location of GloFAS data download

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
