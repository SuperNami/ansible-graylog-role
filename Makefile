graylog: pull-images


pwgen: install-pwgen generate-pw

install-pwgen:
	apt-get install whois

generate-pw:
	pwgen -N 1 -s 96

echo-sha2:
	echo -n yourpassword | shasum -a 256


ansible: galaxy-download-role galaxy-copy-role galaxy-deploy

galaxy-download-role:
	ansible-playbook main.yml -i localhost -t galaxy_download_role

galaxy-copy-role:
	ansible-playbook main.yml -i localhost -t galaxy_copy_role

galaxy-deploy:
	ansible-playbook /etc/ansible/role.yml -i localhost


docker: pull-images copy-config compose-up

pull-images:
	docker pull mongo:3 && docker pull elasticsearch:2 && docker pull graylog2/server:latest

copy-config:
	ansible-playbook main.yml -i localhost -t compose_copy_config

dl-config:
	ansible-playbook main.yml -i localhost -t compose_dl_config

compose-up:
	docker-compose -f compose.yml up -d

compose-down:
	docker-compose -f compose.yml down


server: plugin-collector-jar

plugin-beats-jar:
	ansible-playbook main.yml -i localhost -t plugin_beats_jar

plugin-collector-jar:
	ansible-playbook main.yml -i localhost -t plugin_collector_jar

plugin-collector-deb:
	ansible-playbook main.yml -i localhost -t plugin_collector_deb


client: filebeat

nxlog: install-nxlog install-collector configure-collector-nxlog
filebeat: remove-nxlog install-collector configure-collector-filebeat

install-nxlog:
	ansible-playbook main.yml -i localhost -t install_nxlog

remove-nxlog:
	ansible-playbook main.yml -i localhost -t remove_nxlog

install-collector:
	ansible-playbook main.yml -i localhost -t install_collector

configure-collector-nxlog:
	ansible-playbook main.yml -i localhost -t configure_collector_nxlog

configure-collector-filebeat:
	ansible-playbook main.yml -i localhost -t configure_collector_filebeat


syslog: configure-rsyslog

configure-rsyslog:
	ansible-playbook main.yml -i localhost -t configure_rsyslog

configure-syslog-ng:
	ansible-playbook main.yml -i localhost -t configure_syslog_ng


debug-collector: stop-collector start-collector-debug

stop-collector:
	sudo service collector-sidecar stop

start-collector-debug:
	graylog-collector-sidecar -c /etc/graylog/collector-sidecar/collector_sidecar.yml


debug-nxlog: start-nxlog-debug

start-nxlog-debug:
	sudo nxlog -v -f /etc/graylog/collector-sidecar/generated/nxlog.conf


debug-filebeat:
	cd /etc/graylog/collector-sidecar/generated && filebeat -configtest -e filebeat.yml

debug-ports:
	netstat -tulpn

debug-server-container:
	docker exec -it [container-id] bash



.PHONY:
