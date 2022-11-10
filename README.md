# giant-dns

## Intro

Giant-DNS is a high performance DNS server for very large data sets. 
- Tested to 500M names, but should scale to 1B (further, with some code changes)
- <<<1ms response time
- DNSSEC, NSEC + NSEC3
- Memory reduction techniques
- Multiple instances, on the same LAN, automatically cluster (load-balancing & fail-over)
- Longer start-up time for extreme fast runtime
- Can saturate 100Mb/s Ethernet with DNS responses (approx 250K queries / sec)
- Accepts updates using a push journal-stream (not included in this demo)

It can handle 1000s of small domains (test to 250K), or a few really large domains (like this demo), or any mix.
Maximum memory optimisation is achieved with a small number of large domains that consist mostly of delegations.

Journal updates run at least 100K per second, but obviously this will impact the query performance.
There will always be a trade-off and where that trade-off lies depends on your hardware - esp, BUS & Ethernet contention.

## This Container

This container is a demo of Giant-DNS with all the data from the zone files for COM and NET
which uses about 10Gb of RAM to run in. serving a total of 173,919,049 names

| Zone | SOA Serial | Date & Time |
| --- | ---: | --- |
| COM | 1666828823 | Thu Oct 27 00:00:23 UTC 2022 |
| NET | 1666742427 | Wed Oct 26 00:00:27 UTC 2022 |

GLUE record mode has been set to "promiscuous", so all GLUE records will be included
in all responses whether the SLD or `NS` is in `COM` or `NET`. You can disable
this by removing the `-a` flag in `bin/start_giant_dns`.

All you need to do is run `./dkmk` to build the container, then `./dkrun` to run it.

By default, it's configured for one fork - set the environment variable `GIANT_FORKS=<n>`
to get `<n>` forks, if you have more CPU cores you wish to utilise. More forks will also use more memory.

On my Lab server it takes the container about 1 min 10 seconds to load up COM & NET and be ready to answer queries.

Set environment variable `GIANT_SYSLOG_SERVER` to an IP Address if you want to syslog to a server, default is `stdout`.


## Memory Usage

Since 2017 the memory usage has increased from 6.6Gb to 10Gb. This is due to two factors

- The number of names has increased from 144M to 174M
- Far more names are now signed. This is the most significant factor.

All reoccurring DNSSEC RRs (DS, NSEC3 & RRSIG) are unique and use hashes that create a result that will be (mostly) uncompress-able.


Currently it breaks down as follows
| db | size |
| --- | ---: |
| COM NSEC3 db | 1.56Gb |
| NET NSEC3 db | 151.33Mb |
| Shared Data | 39.35Mb |
| Main db | 7.24Gb |


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
