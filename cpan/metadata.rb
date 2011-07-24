maintainer       "AMZ"
maintainer_email "melezhik@gmail.com"
license          "Apache 2.0"
description      "- cpan modules package provider - features: - install / update - dry-run - skip_test - verbose "
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.3"

%w{ ubuntu gentoo }.each do |os|
  supports os
end

