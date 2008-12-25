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

## Contact
Leave a note on the blog post at [melfar.wordpress.com](http://melfar.wordpress.com)


