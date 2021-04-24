# ntp_client
Sets up clients that synchronize with an NTP server setup on your network. Tested with a two device setup.

Note that for proper time synchronization, this "local" NTP server should still synchronize with Internet time servers. Otherwise, the NTP clock would eventually still drift, and lead to inaccurate results. However, the rest of the `ntp_clients` do not have to be exposed to the Internet to sync with this "local" time server.

## Setting up NTP server
```
# On the NTP server
sudo apt install ntp -y
sudo vim /etc/ntp.conf        # Edit to configure the time servers to synchronize to.
sudo service ntp restart
sudo service ntp status       # Check ntp is running
sudo ufw allow from any to any port 123 proto udp   # Allow NTP clients to communicate on this port
sudo ufw enable
```

## Setting up NTP clients
You can configure the clients in `inventory` and `host_vars` folder.

You should now be able to run the runfile:
```
bash roles/ntp_client/example/run
```

## Expected results
```
#On your clients, if you run this, you should see "Initial Synchronization to the time server ..
journalctl -u systemd-timesyncd.service -f

# If you get "timed out" errors, check that your ntp service is up and that your port is open
# on your server
sudo service ntp status
sudo ufw status

# If you now change the time on the server
sudo timedatectl set-time 10:30
# And restart the client, your client time should also update
sudo timedatectl set-ntp false
sudo timedatectl set-ntp true
```
