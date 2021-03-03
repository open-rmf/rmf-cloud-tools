require 'erb'
require 'fileutils'
require 'yaml'

def generate_wireguard_key()
    private_key = `wg genkey`.chop
    public_key = `echo "#{private_key}" | wg pubkey`.chop
    return private_key, public_key
end

if ARGV.length != 1
    puts "Usage: generate_config.rb [num of clients]"
    exit
end
num_clients = ARGV[0].to_i

WIREGUARD_SERVER_TEMPLATE = <<WGTEMPLATE
[Interface]
Address = <%= server_ip%>/24
SaveConfig = true
PrivateKey = <%= server_private_key%>
ListenPort = <%= server_port %>

<% clients.each do |client| %>
[Peer]
PublicKey = <%= client["client_public_key"] %>
AllowedIPs = <%= client["client_ip"] %>/32
<%end%>
WGTEMPLATE

FASTRTPS_SERVER_TEMPLATE = <<WGTEMPLATE
<?xml version="1.0" encoding="utf-8"?>
<dds>
<profiles>
<participant profile_name="initial_peers_example_profile" is_default_profile="true">
<rtps>
<builtin>
<initialPeersList>
    <locator>
    <udpv4>
      <address><%= server_ip%></address>
      <port>7400</port>
    </udpv4>
    </locator>
    <% clients.each do |client| %>
	<locator>
		<udpv4>
		 <address><%= client["client_ip"]%></address>
		 <port>7400</port>
		</udpv4>
    </locator>
    <% end %>
</initialPeersList>
</builtin>
</rtps>
</participant>
</profiles>
</dds>
WGTEMPLATE

WIREGUARD_CLIENT_TEMPLATE = <<WGTEMPLATE
[Interface]
Address = <%= client_ip %>
SaveConfig = true
PrivateKey = <%= client_private_key %>
ListenPort = <%= server_port %>

[Peer]
PublicKey = <%= server_public_key %>
AllowedIPs = <%= server_ip%>
Endpoint = <%= remote_ip%>:<%= server_port%>
WGTEMPLATE

FASTRTPS_CLIENT = <<WGTEMPLATE
<?xml version="1.0" encoding="utf-8"?>
<dds>
<profiles>
<participant profile_name="initial_peers_example_profile" is_default_profile="true">
<rtps>
<builtin>
<initialPeersList>
	<locator>
		<udpv4>
		 <address><%= server_ip%></address>
		 <port>7400</port>
		</udpv4>
    </locator>
    <% clients.each do |client| %>
        <locator>
            <udpv4>
             <address><%= client["client_ip"]%></address>
             <port>7400</port>
            </udpv4>
        </locator>
    <% end %>
</initialPeersList>
</builtin>
</rtps>
</participant>
</profiles>
</dds>
WGTEMPLATE

VAGRANT_FILE = <<VAGRANT

Vagrant.configure("2") do |config|
    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://vagrantcloud.com/search.
    config.vm.box = "bento/ubuntu-20.04"
    config.vm.provision "shell", inline: <<-SHELL
        curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
        echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list
        apt update
        apt install -y ros-foxy-base
        mkdir -p /etc/wireguard/
        mkdir -p /etc/fastrtps_cloud/
        cp /vagrant/wg0.conf /etc/wireguard/
        cp /vagrant/fastrtps.xml /etc/fastrtps_cloud/
        apt-get update -y
        apt-get install -y wireguard 
        wg-quick up wg0
        systemctl enable wg-quick@wg0
        echo "source /opt/ros/foxy/setup.bash" >> /home/vagrant/.bashrc
        echo "export FASTRTPS_DEFAULT_PROFILES_FILE=/etc/fastrtps_cloud/fastrtps.xml" >> /home/vagrant/.bashrc
        EOSU
    SHELL
end
  
VAGRANT

server_private_key, server_public_key = generate_wireguard_key()

ip_prefix = "10.200.200"
server_port = 51820
server_ip = "#{ip_prefix}.1"

clients = []

(1..num_clients).each do |x|
    client_private, client_public = generate_wireguard_key()
    clients.append({
        "client_num" => x,
        "client_ip" => "#{ip_prefix}.#{x+1}",
        "client_private_key" => client_private,
        "client_public_key"=> client_public
    })
end

FileUtils.mkdir_p "scripts"

wireguard_server_config = ERB.new(WIREGUARD_SERVER_TEMPLATE).result()
fastrtps_server_config = ERB.new(FASTRTPS_SERVER_TEMPLATE).result()

puts "Generating SSH key"
`ssh-keygen -b 2048 -t rsa -f server_access.key -q -N ""`
pub_key = `ssh-keygen -f server_access.key -y`

cloud_init = {
    "write_files" => [
        {
            "path" => "/etc/fastrtps_cloud_config/cloud_config.xml",
            "content"=> fastrtps_server_config
        }
    ],
    "packages" => [
        "wireguard", "curl", "gnupg2", "lsb-release", "build-essential", "npm"
    ],
    "ssh_authorized_keys" => [
        pub_key
    ],
    "runcmd" => [
        "curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -",
        'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list',
        "apt update",
        "apt install -y ros-foxy-ros-base",
    ]
}

File.open("scripts/wg_setup.yaml", "w") { |f| 
    f.puts "#cloud-config"
    YAML.dump(cloud_init, f)
}


puts "Initiallizing terraform"
res  =`terraform -chdir=terraform/ init -input=false`

if not $?.success?
    puts res
    fail
end

puts "Deploying server"
`terraform -chdir=terraform/ apply -auto-approve`
if not $?.success?
    puts "failed to deploy server"
    fail
end

remote_ip = `echo "aws_instance.rmf_demo_server.public_ip" | terraform -chdir=terraform/ console | sed 's/"//g'`.chop

if not $?.success?
    puts "failed to retrieve remote ip"
    fail
end

puts "Configuring wireguard (in 50s)"
# sleep to give time for firewall rules to propagate
sleep(50)
`ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'sudo mkdir -p /etc/wireguard/'`
if not $?.success?
    puts "failed to copy wireguard configs over... retrying in 20s"
    sleep(20)
    `ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'sudo mkdir -p /etc/wireguard/'`
    if not $?.success?
        fail
    end
end

`ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'echo "#{wireguard_server_config}" | sudo tee /etc/wireguard/wg0.conf'`
`ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'sudo wg-quick up wg0'`
`ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'sudo systemctl enable wg-quick@wg0'`
`ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'echo ". /opt/ros/foxy/setup.bash" >> ~/.bashrc'`
`ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'echo "export FASTRTPS_DEFAULT_PROFILES_FILE=/etc/fastrtps_cloud_config/cloud_config.xml" >> ~/.bashrc'`
wireguard = `ssh -T -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -i server_access.key ubuntu@#{remote_ip} 'sudo wg'`

puts wireguard

puts "Provisioned VPN server on #{remote_ip}"
puts "You may ssh like so:"
puts "\t ssh -i  server_access.key ubuntu@#{remote_ip}"


FileUtils.mkdir_p "clients"
client_ip = ""
client_private_key = ""
clients.each do |client|
    FileUtils.mkdir_p "clients/client_#{client["client_num"]}"
    client_ip = client["client_ip"]
    client_private_key = client["client_private_key"]
    File.open("clients/client_#{client["client_num"]}/wg0.conf", "w") { |f| 
        f.puts ERB.new(WIREGUARD_CLIENT_TEMPLATE).result()
    }
    File.open("clients/client_#{client["client_num"]}/fastrtps.xml", "w") { |f| 
        f.puts ERB.new(FASTRTPS_CLIENT).result()
    }
    File.open("clients/client_#{client["client_num"]}/Vagrantfile", "w") { |f| 
        f.puts VAGRANT_FILE
    }
end
