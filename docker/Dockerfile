FROM centos:7
MAINTAINER Marcos Entenza <mak@redhat.com>

LABEL io.k8s.description="Icinga 2 All-in-one" \
      io.k8s.display-name="Icinga 2 All-in-one" \
      io.openshift.expose-services="80:tcp,443:tcp,5665:tcp" \
      io.openshift.tags="icinga2"

ADD include /root/

RUN chmod +x /root/initicinga.sh && \
    curl -o /etc/yum.repos.d/icinga.repo http://packages.icinga.com/epel/ICINGA-release.repo && \
    yum update -y && \
    yum install epel-release -y && \
    yum install nginx nagios-plugins-all mariadb-server mariadb icinga2 icinga2-doc icinga2-ido-mysql icingaweb2 icingacli php-ZendFramework php-ZendFramework-Db-Adapter-Pdo-Mysql -y && \
    yum clean all && \
    #icinga2 feature enable command && \
    #icinga2 feature enable api && \
    icinga2 feature enable ido-mysql && \
    mkdir -p /var/log/supervisor && \
    chmod 4755 /bin/ping /bin/ping6 && \
    chown -R icinga:root /etc/icinga2 && \
    mkdir -p /etc/icinga2/pki && \
    chown -R icinga:icinga /etc/icinga2/pki && \
    mkdir -p /var/run/icinga2 && \
    mkdir -p /var/log/icinga2 && \
    chown icinga:icingacmd /var/run/icinga2 && \
    chown icinga:icingacmd /var/log/icinga2 && \
    mkdir -p /var/run/icinga2/cmd && \
    mkfifo /var/run/icinga2/cmd/icinga2.cmd && \
    chown -R icinga:icingacmd /var/run/icinga2/cmd && \
    chmod 2750 /var/run/icinga2/cmd && \
    chown -R icinga:icinga /var/lib/icinga2 && \
    #usermod -a -G icingacmd apache >> /dev/null && \
    usermod -a -G icingacmd nginx >> /dev/null && \
    chown root:icingaweb2 /etc/icingaweb2 && \
    chmod 2770 /etc/icingaweb2 && \
    mkdir -p /etc/icingaweb2/enabledModules && \
    #chown -R apache:icingaweb2 /etc/icingaweb2/* && \
    chown -R nginx:icingaweb2 /etc/icingaweb2/* && \
    cp /root/icingaweb.conf /etc/nginx/conf.d && \
    find /etc/icingaweb2 -type f -name "*.ini" -exec chmod 660 {} \; && \
    find /etc/icingaweb2 -type d -exec chmod 2770 {} \;


EXPOSE 80 443 5665

CMD ["/bin/bash", "-c", "/root/initicinga.sh"]
