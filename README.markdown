# ServerStats — the Server Status dashboard widget brought to Linux

Server Status is a dashboard widget found in every Mac OS X Leopard installation
that allows you to remotely connect to a server and see CPU, network and disk usage
([see Mac OS X Server product page](http://www.apple.com/server/macosx/features/admin.html))

This patch makes adjustments for it to be suitable for any kind of servers by modifying its connection
transport from a closed source ObjC plugin to a plain HTTP interface.

That only requires you to run an agent on the target server to gather the statistics.
In the agent/ subdirectory you will find such an agent for a typical Linux installation
(currently tested only on Debian Lenny).
You will need to have ruby installed along with some gems listed in the comments on the top of the script.

## Installation
1. On the server: make sure you have sysstat installed on your server.  Also install ruby and rubygems.
Then copy the agent/ directory to a place of your choice and run it with a supplied start script.

2. On the client: go to /dashboard\_patch and issue install.sh command.  That will make
a copy of your /Library/Widgets/Server Status.wdgt, add a bunch of new files to it and apply a patch.
A newly created dashboard widget will appear in the same directory called ServerStats.wdgt.  Then just
open it using Finder, and you will be prompted to install the new widget.

## Security

The widget supports basic authorization (a login and a password), but you will need to
enable that on the server yourself using a proxy server such as nginx, apache or lighttpd.
In my nginx config, I have a server running on port 8018 that checks basic auth and then
proxy\_passes to localhost:8818, where the agent is running.

## Contact
Leave a note on the blog post at [melfar.wordpress.com](http://melfar.wordpress.com)


