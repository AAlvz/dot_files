package {'sudo':
  ensure => 'installed',
}

package { 'byobu':
  ensure => 'latest',
}
package { 'git':
  ensure => 'latest',
}
package { 'anki':
  ensure => 'latest',
}
package { 'mercurial':
  ensure => 'latest',
}
package { 'nmap':
  ensure => 'latest',
}
package { 'openssh-server':
  ensure => 'latest',
}
# package { 'skype':
#   ensure => 'latest',
# }
package { 'tree':
  ensure => 'latest',
}
package { 'tuxguitar':
  ensure => 'latest',
}
package { 'unzip':
  ensure => 'latest',
}
package { 'unrar-free':
  ensure => 'latest',
}
package { 'vagrant':
  ensure => 'latest',
}
package { 'virtualbox':
  ensure => 'latest',
}
package { 'wine':
  ensure => 'latest',
}
package { 'openjdk-7-jre':
  ensure => 'latest',
}
package { 'emacs':
  ensure => 'installed',
}

package { 'htop':
  ensure => 'installed',
}

package { 'gparted':
  ensure => 'installed',
}

file {'/etc/apt/sources.list.d/non-free.list':
  ensure  => file,
  content => "deb http://http.debian.net/debian/ ${lsbdistcodename} main contrib non-free",
  notify  => Exec['apt-get update'],
}

package {'gnome-tweak-tool':
  ensure  => present,
  require => File['/etc/apt/sources.list.d/non-free.list'],
}

exec { "apt-get update":
    command => "/usr/bin/apt-get update",
}

exec {'dot_files':
  creates   => "/home/${hostname}/.git",
  user     => 'aalvz',
  command  => "/bin/mkdir -p /home/${hostname}/tmp; /usr/bin/git clone https://github.com/AAlvz/dot_files.git /home/${hostname}/tmp; /bin/cp -a /home/${hostname}/tmp/. /home/${hostname}/ && /bin/rm -rf /home/${hostname}/tmp",
  require  => Package['git'],
  path     => ["/usr/bin", "/bin"],
}

file {"/home/${hostname}/.git/info/exclude":
  content => "*",
  ensure  => file,
}

package {'xsel':
  ensure  => present,
}

exec {'download_chrome':
  user     => "aalvz",
  command  => "wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb",
  creates  => "/tmp/google-chrome-stable_current_amd64.deb",
  path     => ["/usr/bin", "/bin"],
}

exec {'install_chrome':
  user     => 'root',
  command  => "sudo /usr/bin/dpkg -i /tmp/google-chrome-stable_current_amd64.deb",
  path     => ["/usr/bin", "/bin"],
  require  => [
               Exec['download_chrome'],
               Package['libappindicator1'],
              ]
}

#chrome dependencies
package{'libappindicator1':
  ensure   => installed,
  provider => "apt",
  install_options => ["--allow-unauthenticated", "-f"],
}
