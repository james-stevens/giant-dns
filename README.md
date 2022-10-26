# giant-dns

## Intro

Giant-DNS is a high performance DNS server for very large data sets. 
- Tested to 500M names, but should scale to 1B
- <1ms response time
- DNSSEC, NSEC + NSEC3
- Memory reduction techniques
- Multiple instances, on the same LAN, can automatically form a cluster
- Longer start-up time for extreme fast runtime
- Can saturate 100Mb/s Ethernet with DNS responses
- Accepts updates with using a push journal-stream (not included in this demo)


## This Container

This container is a demo of Giant-DNS with all the data from the zone files for COM and NET
which uses about 6Gb of RAM to run in.

GLUE record mode has been set to "promiscuous", so all GLUE records will be included
in all responses whether the `NS` is in `COM` or `NET`.

All you need to do is run `./dkmk` to build the container, then `./dkrun` to run it.

By default, it's configured for one fork - set the environment variable `GIANT_FORKS=<n>`
to get `<n>` forks, if you have more CPU cores you wish to utilise.

On my Lab server it takes the container about 6 mins to load up COM & NET.

Set environment variable `GIANT_SYSLOG_SERVER` to an IP Address
if you want to syslog to a server, default is `stdout`.
