## Credentials 

Populate credentials for SFTP in the following files:

- `ftp_username`
- `ftp_password`

These files are loaded by `systemd` and used by the unit files.

## Mailing list

Addresses to email on unit failure is in `mailing.list` (one email per line).

## Todo

- [ ] install script, copying into `/usr/bin`, and service files
- [ ] adapt directories to deployment
