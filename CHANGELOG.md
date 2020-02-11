# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.3.0 - 2020-02-11
### Added
- CHANGELOG.md
- Supported Swift versions in podspec (4.0, 5.0)
- Support for transformers in ResponseDefinition
- Minimum deployment target for tvOS to podspec
- Support for verifying requests made to the Wiremock server


## 1.2.1 - 2018-06-15
### Changed
- Made all URLSession data tasks synchronous

## 1.2.0 - 2018-02-26
### Added
- Minimum deployment target for macOS to podspec
- Support for shutting down server Wiremock instance
- Support for checking if Wiremock instance is running
- Access to ResponseDefinition data
- Support for SPM

## 1.1.2 - 2017-10-19
### Changed
- .swift-version file syntax
- README
### Added
- Support for handling JSON array objects in ResponseDefinition

## 1.1.1 - 2017-10-12
### Added
- Support for adding headers to ResponseDefinition

## 1.1.0 - 2017-09-11
### Added
- Access to ResponseDefinition JSON

## 1.0.0 - 2017-07-26
### Added
- WiremockClient 1.0.0