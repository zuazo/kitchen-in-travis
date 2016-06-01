kitchen-in-travis CHANGELOG
===========================

This file is used to list changes made in each version of the `kitchen-in-travis` cookbook.

## v0.5.0 (2016-06-01)

* Fix *Installing new version of config file /etc/bash_completion.d/lxc* error (issues [#2](https://github.com/zuazo/kitchen-in-travis/issues/2) and [#3](https://github.com/zuazo/kitchen-in-travis/pull/3), thanks [Pedro Salgado](https://github.com/steenzout)).

## v0.4.0 (2016-01-24)

* Update Berkshelf to version `4`.
* Reinstall AppArmor to fix *Could not open 'tunables/global'* error.
* Docker script big refactor using *travis_* shell functions.
* Improve Rakefile integration tasks to support different actions and regexp.
* README: Multiple documentation improvements.

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
