FROM centos:7
MAINTAINER Marcos Entenza <mak@redhat.com>

LABEL io.k8s.description="OCP Infra Monitoring Agent" \
      io.k8s.display-name="OCP Infra Monitoring Agent" \
      io.openshift.expose-services="5665:tcp" \
      io.openshift.tags="inframon agent"

ADD include /root/

RUN chmod +x /root/inframon-agent.sh && \
    yum update -y && \
    yum install epel-release -y && \
    yum install nagios-plugins-all nrpe lvm2 -y && \
    yum clean all && \
    mkdir -p /node/root && \
    mkdir -p /etc/nrpe && \
    chmod 4755 /bin/ping /bin/ping6 && \
    cp /root/nrpe_conf/nrpe.cfg /etc/nrpe/

VOLUME /etc/nrpe.d

EXPOSE 5666

CMD ["/bin/bash", "-c", "/root/inframon-agent.sh"]
