name 'kitchen-in-travis'
maintainer 'Xabier de Zuazo'
maintainer_email 'xabier@zuazo.org'
license 'Apache 2.0'
description <<-EOH
Cookbook example to run test-kitchen inside Travis CI using kitchen-docker in
User Mode Linux.
EOH
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'

depends 'nginx', '~> 2.7'
