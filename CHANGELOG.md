# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][keep-a-changelog] this project adheres to [Semantic Versioning][semantic-versioning].

## [v0.3.2++] (????-??-??)

[Full Changelog](https://github.com/overkill32/hassio-remote-backup/compare/v0.3.2...master)

### Fixed

- Updated `hassio-cli` to version 3.1.1
- Modified `run.sh` hassio calls to work with version 3.1.1
- Converted snapshot removal selection logic to a jq filter

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
