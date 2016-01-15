# == Class: aws-ec2-tools
#
# This class installs the AWS ec2 CLI tools
#
# === Parameters
#
# [*ec2_tools_version*]
#   String. Controls the version of the ec2-api-tools to be installed
#   Defaults to 1.7.3.0
#
# [*source_server*]
#   String url.  The url to where the package (zip) can be found without trailing /
#   Default: true
#
# === Examples
#
# * Installation:
#       class { 'aws-ec2-tools': }
#
# === Authors
#
# * Neil Millard <mailto:neil@neilmillard.com>
#
class aws-ec2-tools(
  $ec2_tools_version  = '1.7.3.0',
  $source_server      = 'http://s3.amazonaws.com/ec2-downloads',
) {

  include java

  # Configure JAVA_HOME globlly.
  file { '/etc/profile.d/java.sh':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 644,
    content => "export JAVA_HOME=/usr/java/default",
  }

  include wget

  package{'unzip':
    ensure => installed,
  }

  $ec2_pkg_name = "ec2-api-tools-${ec2_tools_version}"
  $ec2_filename = "${ec2_pkg_name}.zip"

  wget::fetch { 'Fetch ec2-api-tools':
    source      => "${source_server}/${ec2_filename}",
    destination => "/tmp/${ec2_filename}",
    verbose     => false,
  }

  file { ["/home/ec2/", "/home/ec2/bin", "/home/ec2/lib"]:
    ensure   => directory,
    owner    => root,
    mode     => 644,
    require  =>  Wget::Fetch["Fetch ec2-api-tools"],
  }

  exec { "unzip -o $ec2_filename -d /tmp/":
    alias   => 'unzip_api_tools',
    path    => [ '/usr/local/bin/','/sbin/','/usr/bin' ],
    user    => 'root',
    cwd     => '/tmp/',
    creates => "/tmp/${ec2_pkg_name}",
    require => [File["/home/ec2"],Package['unzip']],
  }

  exec { "mv tools/bin":
    command => "mv /tmp/${ec2_pkg_name}/bin /home/ec2/bin && \
                mv /tmp/${ec2_pkg_name}/lib /home/ec2/lib",
    path    => [ '/usr/local/bin/','/sbin/','/usr/bin' ],
    require => Exec['unzip_api_tools'],
  }

}