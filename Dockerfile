#################################################################
#    (c) Copyright 2009-2022 JRCS Ltd  - All Rights Reserved    #
#################################################################

FROM alpine:3.16

COPY db /usr/local/db/
COPY groups /usr/local/etc/groups/

COPY sbin /usr/local/sbin/
COPY bin /usr/local/bin/

COPY inittab /etc/inittab

CMD [ "/sbin/init" ]
