class tomcat::war{
  staging::deploy{"quantum.war":
        source => "/opt/quantum.war",
        target => "/home/app",
  }

}
