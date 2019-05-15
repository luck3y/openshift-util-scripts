
# docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge
172.17.0.0/16

firewall-cmd --permanent --new-zone dockerc
firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
firewall-cmd --permanent --zone dockerc --add-port 53/udp
firewall-cmd --permanent --zone dockerc --add-port 8053/udp
firewall-cmd --permanent --zone dockerc --add-port 5000/tcp
firewall-cmd --reload
