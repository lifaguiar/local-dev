# -*- mode: ruby -*-
# vi: set ft=ruby :

HOST = RbConfig::CONFIG["host_os"]

# Give VM 1/4 system memory 
if HOST =~ /darwin/
	# sysctl returns Bytes and we need to convert to MB
	BOX_MEMORY = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
elsif HOST =~ /linux/
	# meminfo shows KB and we need to convert to MB
	BOX_MEMORY = `grep "MemTotal" /proc/meminfo | sed -e "s/MemTotal://" -e "s/ kB//"`.to_i  / 1024 / 4
elsif HOST =~ /mswin|mingw|cygwin/
	# Windows code via https://github.com/rdsubhas/vagrant-faster
	BOX_MEMORY = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024 / 1024 / 4
end

BASE_BOX = "lifaguiar/centos73"
BOX_NET = "10.9.4"
BOX_DOMAIN = "api.lincolmlabs"
BOX_VCPUS = 2

if File.exists?("boxindex")
	BOX_INDEX = File.read("boxindex").strip 
else
	r = Random.new
	BOX_INDEX = r.rand(2...255)
	File.write("boxindex", BOX_INDEX)
end 

BOX_ADDRESS = "#{BOX_NET}.#{BOX_INDEX.to_i}"
BOX_HOSTNAME = "node#{BOX_INDEX}"

passwordFile = "vagrant-box"

#Ensure we have required plugins installed on host machine
required_plugins = %w( vagrant-vbguest vagrant-triggers vagrant-hostsupdater )
required_plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
  end
end

# Ok! Let"s start the kidding!
Vagrant.configure("2") do |config|
  config.vm.box = BASE_BOX
  config.vm.box_check_update = false
  
  config.trigger.before :up do
	if File.exists?("protected")
		print "The VM is encrypted, please enter the password: "
		password = STDIN.noecho(&:gets).strip
		File.write(passwordFile, password)
		puts ""
	end
  end
  
  config.vm.provider "virtualbox" do |vb|
	vb.memory = BOX_MEMORY
	vb.cpus = BOX_VCPUS
	vb.name = BOX_HOSTNAME
	vb.customize ["modifyvm", :id, "--cpuexecutioncap", 75]
	vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
	vb.gui = false
	
	if File.exists?(passwordFile)
		vb.gui = true
		vb.customize "post-boot", [
			"controlvm", :id, "addencpassword", "#{BOX_HOSTNAME}", "#{passwordFile}", "--removeonsuspend", "no"
		]
	end	  
  end
  
  config.vm.network :private_network, ip: BOX_ADDRESS
  
  config.vm.hostname = BOX_HOSTNAME
  config.hostsupdater.aliases = [
		"#{BOX_HOSTNAME}.#{BOX_DOMAIN}",
		"api.#{BOX_HOSTNAME}.#{BOX_DOMAIN}",
		"repository.#{BOX_HOSTNAME}.#{BOX_DOMAIN}"
  ]
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
  
  #We must have all this commands executed inside VM in order to everything runs fine.
  config.vm.provision "shell", path: "provision.sh"
  
  config.trigger.after :up do
    File.delete(passwordFile) if File.exists?(passwordFile)
  end
  
  config.trigger.after :destroy do
    File.delete(passwordFile) if File.exists?(passwordFile)
  end
end
