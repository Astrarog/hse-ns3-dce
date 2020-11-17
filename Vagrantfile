Vagrant.configure("2") do |config|
  
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.define "ns3-dce" do |server|
    server.vm.box = "ubuntu/trusty64"
    	
	# copying perfomance test source code
	server.vm.provision "file", source: "import/dce-iperf.cc", destination: "/home/vagrant/dce-iperf.cc"
	
	# copying perfomance test startup file
	server.vm.provision "file", source: "import/run-perf.sh", destination: "/home/vagrant/run-perf.sh"
	server.vm.provision "shell", privileged: true, inline: "chmod 777 /home/vagrant/run-perf.sh"
	server.vm.provision "shell", privileged: true, inline: "sed -i -e 's/\r$//' /home/vagrant/run-perf.sh"
	
	# shared folder creation
	server.vm.synced_folder  "share/", "/home/vagrant/share", create: true
	
    # network
    # server.vm.network "private_network", ip: "172.16.0.10", netmask: "255.255.255.0"

    # do basic setup
    server.vm.provision "shell", privileged: true, path: "ns3-pre.sh"

    # do basic setup
    server.vm.provision "shell", privileged: false, path: "ns3-dce-setup.sh"

  end

end
