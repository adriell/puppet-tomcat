class tomcat{
  class {"java":}
  java::setup{"jdk-7u21-linux-x64":
    source       => "jdk-7u79-linux-x64.tar.gz",
    deploymentdir => "/opt/java",
    user         => "root",
    pathfile     => "/etc/profile.local"
  }
  staging::deploy{"apache-tomcat-6.0.44.tar.gz":
    source => "http://mirror.nbtelecom.com.br/apache/tomcat/tomcat-6/v6.0.44/bin/apache-tomcat-6.0.44.tar.gz",
    target => "/home/quantum/server/",
  }
  user {"quantum":
    ensure => present,
    shell  => "/bin/bash",
    before => [File["tomcat6.service"],Service["tomcat6"]]
  }
  
  file{"tomcatdirectory":
    path   => "/home/quantum/server",
    ensure => directory,
    owner  => "quantum",
    group  => "quantum",
  }

  file {"tomcat6.service":
    path   => "/usr/lib/systemd/system/tomcat6.service",
    ensure => file,
    mode   => "0644",
    owner  => "root",
    group  => "root",
    source => "puppet:///modules/tomcat/tomcat6.service",
    notify => Service["tomcat6"]
  }
  file {"/home/quantum/server/apache-tomcat-6.0.44/conf/server.xml":
    ensure  => file,
    content => template("tomcat/serverxml.erb"),
    notify  => Service["tomcat6"]
  }
  service{"tomcat6":
    ensure  => running,
    enable  => true,
  }
  tomcat::deployment { "Quantum":
    path   => "/home/quantum/Deploy/quantum.war",
    notify => Service["tomcat6"]
  }

  define tomcat::deployment($path){
    include tomcat
    file {"/home/quantum/web/quantum.war":
      owner  =>" quantum",
      group  => "quantum",
      source => $path,
    }
   exec {"Deploy":
         path    => "/usr/bin:/usr/sbin:/bin",
         user    => "quantum",
         group   => "quantum",
         command => "cd /home/quantum/web && unzip *.war",
      }
  }
}
