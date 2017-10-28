FROM centos:7
MAINTAINER Marcos Entenza <mak@redhat.com>

LABEL io.k8s.description="Icinga 2 All-in-one" \
      io.k8s.display-name="Icinga 2 All-in-one" \
      io.openshift.expose-services="80:tcp,5665:tcp" \
      io.openshift.tags="icinga2"

ADD include /root/

RUN chmod +x /root/initicinga.sh && \
    curl -o /etc/yum.repos.d/icinga.repo http://packages.icinga.com/epel/ICINGA-release.repo && \
    yum update -y && \
    yum install epel-release -y && \
    yum install --setopt tsflags= nginx nagios-plugins-all nagios-plugins-nrpe mariadb-server mariadb icinga2 icinga2-doc icinga2-ido-mysql icingaweb2 icingacli php-fpm \
    php-ZendFramework php-ZendFramework-Db-Adapter-Pdo-Mysql lvm2 -y && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    #icinga2 feature enable command && \ ### Need to move this to CMD script, to start icinga, enable modules and then restart it
    #icinga2 feature enable api && \
    #icinga2 feature enable ido-mysql && \
    mkdir -p /node/root && \
    #mkdir /icingaconf && \
    #chown icinga:icinga /icingaconf && \
    mkdir -p /var/log/supervisor && \
    chmod 4755 /bin/ping /bin/ping6 && \
    chown -R icinga:root /etc/icinga2 && \
    mkdir -p /etc/icinga2/pki && \
    chown -R icinga:icinga /etc/icinga2/pki && \
    mkdir -p /var/log/icinga2 && \
    chown icinga:icingacmd /var/log/icinga2 && \
    chown -R icinga:icinga /var/lib/icinga2 && \
    #usermod -a -G icingacmd apache >> /dev/null && \
    usermod -a -G icingacmd nginx >> /dev/null && \
    chown root:icingaweb2 /etc/icingaweb2 && \
    chmod 2770 /etc/icingaweb2 && \
    mkdir -p /etc/icingaweb2/enabledModules && \
    ln -s /usr/share/icingaweb2/modules/monitoring /etc/icingaweb2/enabledModules/monitoring && \
    #chown -R apache:icingaweb2 /etc/icingaweb2/* && \
    chown -R nginx:icingaweb2 /etc/icingaweb2/* && \
    cp /root/nginx.conf /etc/nginx/nginx.conf && \
    cp /root/etcd/resources.ini /etc/icingaweb2/resources.ini && \
    cp /root/etcd/config.ini /etc/icingaweb2/config.ini && \
    cp /root/etcd/authentication.ini etc/icingaweb2/authentication.ini && \
    cp /root/etcd/roles.ini /etc/icingaweb2/roles.ini && \
    cp /root/php.ini /etc/php.ini && \
    mkdir /etc/icingaweb2/modules/monitoring && \
    cp /root/icinga2.conf /etc/icinga2/icinga2.conf && \
    cp /root/etcd/modmon/config.ini /etc/icingaweb2/modules/monitoring/config.ini && \
    cp /root/etcd/modmon/backends.ini /etc/icingaweb2/modules/monitoring/backends.ini && \
    cp /root/etcd/modmon/commandtransports.ini /etc/icingaweb2/modules/monitoring/commandtransports.ini && \
    cp /root/my.cnf /etc/my.cnf && \
    ln -s /etc/icinga2/features-available/command.conf /etc/icinga2/features-enabled/command.conf && \
    find /etc/icingaweb2 -type f -name "*.ini" -exec chmod 660 {} \; && \
    find /etc/icingaweb2 -type d -exec chmod 2770 {} \;

VOLUME /var/lib/mysql /etc/icinga2/conf.d

EXPOSE 80 5665

CMD ["/bin/bash", "-c", "/root/initicinga.sh"]
