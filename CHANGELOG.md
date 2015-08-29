kitchen-in-travis CHANGELOG
===========================

This file is used to list changes made in each version of the `kitchen-in-travis` cookbook.

## v0.3.0 (2015-08-29)

* Revert "Gemfile: kitchen-docker ~> 2.3" (fixes *Kitchen::ActionFailed: Failed to complete #create action: [undefined method `create' for Tempfile:Class]*, see [`kitchen-docker` issue #148](https://github.com/portertech/kitchen-docker/issues/148)).
* *.travis.yml*: use rvm `2.0.0` for Ruby version `2.0`.
* README: Add a link to the `netstat` cookbook.

## v0.2.0 (2015-08-29)

* Use cURL instead of Wget (fixes *gpg: no valid OpenPGP data found*).
* *travis.yml*:
 * Add `sudo: true`.
 * Remove `language` configuration option.
* README: Multiple documentation improvements.

## v0.1.0 (2015-07-16)

* Initial release of `kitchen-in-travis`.
