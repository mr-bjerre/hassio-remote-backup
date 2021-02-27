# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][keep-a-changelog] this project adheres to [Semantic Versioning][semantic-versioning].

## [v0.4.3++] (????-??-??)

[Full Changelog](https://github.com/nigelm/hassio-remote-backup/compare/v0.3.2...master)

### Fixed

## [v0.4.3] (2021-02-27)

- Updated `hassio-cli` to version 3.1.1
- Modified `run.sh` hassio calls to work with version 3.1.1
- Converted snapshot removal selection logic to a jq filter
- Merged in changes from rccoleman - https://github.com/rccoleman/hassio-remote-backup
    - Updated `hassio-cli` to 4.3.0
    - Added README notes
    - Reformatted run.sh for change of `hassio-cli` binary name
- Updated `hassio-cli` to 4.10.1
- Since the previous maintainers do not appear to be keeping up with this, and
  have not got available docker builds, I have updated the references to point
  to my repositories.
- Fixed updating changelog on release :-)

## [v0.3.2] (2018-10-12)

[Full Changelog](https://github.com/overkill32/hassio-remote-backup/compare/v0.3.1...v0.3.2)

### Fixed

- Role-based permissions in hassio - use `backup` permissions

## [v0.3.1] (2018-10-12)

[Full Changelog](https://github.com/overkill32/hassio-remote-backup/compare/v0.3.0...v0.3.1)

### Fixed

- Fix `config.json` for multidigit `keep_local_backup` values
- Role-based permissions in hassio - use `manager` permissions

## [v0.3.0] (2018-03-12)

[Full Changelog](https://github.com/overkill32/hassio-remote-backup/compare/v0.2.1...v0.3.0)

### Added

- New input `keep_local_backup` to control how many local snapshots there should be preserved.

## [v0.2.1] (2018-03-11)

[Full Changelog](https://github.com/overkill32/hassio-remote-backup/compare/v0.2.0...v0.2.1)

### Fixed

- `config.json` in the [addons repository][addons-repo] was not aligned with the updates from v0.1.0 to v0.2.0. All backups created with v0.2.0 is password protected with the password _null_.


## [v0.2.0] (2018-03-07)

[Full Changelog](https://github.com/overkill32/hassio-remote-backup/compare/v0.1.0...v0.2.0)

### Added

- Possibilty to contain the backup in a password protected zip file.

## [v0.1.0] (2018-03-06)

### Added

- Initial release

[keep-a-changelog]: http://keepachangelog.com/en/1.0.0/
[semantic-versioning]: http://semver.org/spec/v2.0.0.html
[addons-repo]: https://github.com/overkill32/hassio-addons/blob/master/remote-backup/config.json
