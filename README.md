# giant-dns

## Intro

Giant-DNS is a high performance DNS server for very large data sets. 
- Tested to 500M names, but should scale to 1B (further with some code changes)
- <<<1ms response time
- DNSSEC, NSEC + NSEC3
- Memory reduction techniques
- Multiple instances, on the same LAN, can automatically form a cluster
- Longer start-up time for extreme fast runtime
- Can saturate 100Mb/s Ethernet with DNS responses
- Accepts updates using a push journal-stream (not included in this demo)

It can handle 1000s of small domains (test to 250K), or a few really large domains (like this demo), or any mix.
Maximum memory optimisation is achieved with a small numnber of large domains that consist mostly of delegations.


## This Container

This container is a demo of Giant-DNS with all the data from the zone files for COM and NET
which uses about 10Gb of RAM to run in (see below). serviing a total of 173,919,049 names

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


## Discussion of Memory Over-Allocation

It looks like the `musl-libc` `malloc` can lead to excessive memory [over allocation](https://musl.openwall.narkive.com/J9ymcXt2/what-s-wrong-with-s-malloc).

I've run `giant_dns` with `valgrind` and I'm pretty sure the memory usage reported at start-up is correct. 
This reports about 5.5Gb - so the 10Gb reported by `ps` represents a very significant over-allocation.

There's probably a better `alloc` library I could use, but I've not really spent time looking into this.

However, the data on disk (in `db` & `groups`) is about 8Gb + 1Gb and
I wouldn't expect the memory usage to be wildly different from that.
From that respect 10Gb makes sense.

So right now I'm not totally sure what is going on, but its gonna use 10Gb to run!

Maybe I'm just adding up wrong, but I don't think so.


Because it knows there aren't going to be any changes to the zone data loaded, it does tighten
up the allocations. This helps reduce memory usage, but by perentages, not vastly.



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
