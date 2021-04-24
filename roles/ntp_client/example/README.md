# ntp_client
Sets up clients that synchronize with an NTP server setup on your network. Tested with a two device setup.

Note that for proper time synchronization, this "local" NTP server should still synchronize with Internet time servers. Otherwise, the NTP clock would eventually still drift, and lead to inaccurate results. However, the rest of the `ntp_clients` do not have to be exposed to the Internet to sync with this "local" time server.

## Setting up NTP server
```
# On the NTP server
sudo apt install ntp -y
sudo vim /etc/ntp.conf        # Edit to configure the time servers to synchronize to.
sudo service ntp restart
sudo ufw allow from any to any port 123 proto udp   # Allow NTP clients to communicate on this port
```

## Setting up NTP clients
You can configure the clients in `inventory` and `host_vars` folder.

You should now be able to run the runfile:
```
bash roles/ntp_client/example/run
```

