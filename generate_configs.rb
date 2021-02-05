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
ListenPort = 51820

[Peer]
PublicKey = <%= server_public_key %>
AllowedIPs = 10.200.200.2/32
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
</initialPeersList>
</builtin>
</rtps>
</participant>
</profiles>
</dds>
WGTEMPLATE


server_private_key, server_public_key = generate_wireguard_key()

ip_prefix = "10.200.200"
server_port = 51820
server_ip = "#{ip_prefix}.0"

clients = []

(1..num_clients).each do |x|
    client_private, client_public = generate_wireguard_key()
    clients.append({
        "client_ip" => "#{ip_prefix}.#{x}",
        "client_private_key" => client_private,
        "client_public_key"=> client_public
    })
end

FileUtils.mkdir_p "scripts"

wireguard_server_config = ERB.new(WIREGUARD_SERVER_TEMPLATE).result()
fastrtps_server_config = ERB.new(FASTRTPS_SERVER_TEMPLATE).result()

cloud_init = {
    "write_files" => [
        {
            "path" => "/etc/wireguard/wg0.conf",
            "content" => wireguard_server_config
        },
        {
            "path" => "/etc/fastrtps_cloud_config/cloud_config.xml",
            "content"=> fastrtps_server_config
        }
    ],
    "packages" => [
        "wireguard"
    ],
    runcmd:[
        "wg-quick up wg0",
        "sudo systemctl enable wg-quick@wg0",
        "sudo systemctl start wg-quick@wg0"]
}

File.open("scripts/wg_setup.yaml", "w") { |f| 
    f.puts "#cloud-config"
    YAML.dump(cloud_init, f)
}

#puts ERB.new(WIREGUARD_SERVER_TEMPLATE).result()
#puts ERB.new(FASTRTPS_SERVER_TEMPLATE).result()