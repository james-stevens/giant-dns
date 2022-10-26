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
- Accepts updates using a push journal-stream (not included in this demo)


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

## Example

NOTE: this is not the standard `dig` from ISC, but quite similar.

```
$ dig @127.0.0.1 sun.com
;;
;; HEADER: opcode: QUERY, status: NOERROR, id: 44935
;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 6, ADDITIONAL: 8

QUESTION SECTION:
sun.com.                 IN      A

;; AUTHORITY SECTION:
sun.com.                 172800   IN      NS      a2-67.akam.net.
sun.com.                 172800   IN      NS      a1-198.akam.net.
sun.com.                 172800   IN      NS      a22-64.akam.net.
sun.com.                 172800   IN      NS      orcldns1.ultradns.com.
sun.com.                 172800   IN      NS      orcldns2.ultradns.net.
sun.com.                 172800   IN      NS      orcldns3.ultradns.biz.

;; ADDITIONAL SECTION:
a2-67.akam.net.          172800   IN      A       95.100.174.67
orcldns1.ultradns.com.   172800   IN      A       156.154.64.64
orcldns1.ultradns.com.   172800   IN      AAAA    2001:502:f3ff::64
a22-64.akam.net.         172800   IN      A       23.211.61.64
orcldns2.ultradns.net.   172800   IN      A       156.154.65.64
orcldns2.ultradns.net.   172800   IN      AAAA    2610:a1:1014::64
a1-198.akam.net.         172800   IN      A       193.108.91.198
a1-198.akam.net.         172800   IN      AAAA    2600:1401:2::c6

;; Query time: 0 msec
;; SERVER: 127.0.0.1;53
;; MSG SIZE  rcvd: 358

```
