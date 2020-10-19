FROM ubuntu

RUN apt-get update
RUN apt-get install -y git

ADD ./check-for-changes/check_for_changes.sh /bin/
RUN chmod +x /bin/check_for_changes.sh

RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container

CMD ["/bin/bash"]

