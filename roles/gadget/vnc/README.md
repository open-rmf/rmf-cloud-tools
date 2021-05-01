# vnc

It can be very convenient to use VNC. This allows you to open a virtual GUI to your hosts, as long as your hosts have the necessary backend installed, and your viewer has a VNC viewer. 

You can view your virtual GUI on any device with a VNC viewer. You could even open up visualization tools like `rviz` on a mobile phone or PC, allowing visualization setups with minimal compute power or setup required on the viewer.

The setup is very simple, so automation is hardly required. Here are some steps:

We first need to set up a VNC server on the host(s):
```
# Make sure your Server host has the necessary backend installed. 
sudo apt update
sudo apt upgrade
sudo apt install ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal 

# We use TigerVNC
sudo apt install tigervnc-standalone-server

# Next, run the following command and set up your credentials for the server
tigervncserver

# If you have firewalls, you might need to open up a port. The default ports are 5900+N, where N is the Nth VNC display. With a single call of tigervncserver, the default is a display of :1, meaning port 5901 is used.
```

On your viewing hosts, you might have to do some setup. The most straightfoward is to forward the `5900+N` port of VNC server onto your localhost. This is more secure since you are doing this over SSH and do not have to expose more ports on your host. If using port `5901`:
```
ssh -L 5901:localhost:5901 [your-host]
```

Then install tiger VNC viewer and login with the credentials you supplied.
```
sudo apt install tigervnc-viewer
vncviewer   # Enter localhost:5901 or localhost:1
```

You could also directly expose your device `5901` port. If you do that, you can use `tigervnc-viewer` ( on Linux ) or apps like `VNC Viewer` ( android ).
