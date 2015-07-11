name 'kitchen-travis-example'
maintainer 'Xabier de Zuazo'
maintainer_email 'xabier@zuazo.org'
license 'Apache 2.0'
description <<-EOH
Cookbook example to try to run test-kitchen inside Travis CI using
kitchen-docker in User Mode Linux.
EOH
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'nginx'
