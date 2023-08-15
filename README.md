# cb-bootstrap

## issues
There ae 3 physical machines each with 7 containers. 5 of them are used to form cluster 
accross the 3 machines. So the lxd cluster has total of 5x3 containers.
At times when one physical machine goes off, it looses contact with the rest of the cluster.

'''
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
|    NAME    |            URL             |      ROLES       | ARCHITECTURE | FAILURE DOMAIN | DESCRIPTION |  STATE  |                                  MESSAGE                                   |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-93  | https://192.168.0.93:8443  |                  | x86_64       | default        |             | OFFLINE | No heartbeat for 27.192933202s (2023-08-13 18:21:16.94460288 +0000 UTC)    |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-94  | https://192.168.0.94:8443  |                  | x86_64       | default        |             | OFFLINE | No heartbeat for 20.038320819s (2023-08-13 18:21:24.099231126 +0000 UTC)   |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-95  | https://192.168.0.95:8443  |                  | x86_64       | default        |             | OFFLINE | No heartbeat for 6m26.242280501s (2023-08-13 18:15:17.895278233 +0000 UTC) |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-103 | https://192.168.0.103:8443 | database-standby | x86_64       | default        |             | ONLINE  | Fully operational                                                          |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-104 | https://192.168.0.104:8443 | database-standby | x86_64       | default        |             | ONLINE  | Fully operational                                                          |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-105 | https://192.168.0.105:8443 |                  | x86_64       | default        |             | ONLINE  | Fully operational                                                          |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-113 | https://192.168.0.113:8443 | database         | x86_64       | default        |             | ONLINE  | Fully operational                                                          |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-114 | https://192.168.0.114:8443 | database-leader  | x86_64       | default        |             | ONLINE  | Fully operational                                                          |
|            |                            | database         |              |                |             |         |                                                                            |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
| routed-115 | https://192.168.0.115:8443 | database         | x86_64       | default        |             | ONLINE  | Fully operational                                                          |
+------------+----------------------------+------------------+--------------+----------------+-------------+---------+----------------------------------------------------------------------------+
'''
1. By restarting each of the 5 containers, the cluster is resotred after a long while.
There has been a case where this has failed completly while the machine reports that it is 
running a healthy cluster and it is the rest of the cluster members outside the physical machines
that are offline.  The other section of the cluster also reports the same so there are two clusters.

What is the recommended method to restore the above?

--------------------------

2. After updating on container using ubuntu:22.04, the container hungs while trying to 
auto restart snapd.seeded.service

'''
Restarting services...
 systemctl restart snapd.seeded.service
'''

3.

'''


Aug 13 10:10:28 emp-09 lxd.daemon[2178]: - proc_swaps
Aug 13 10:10:28 emp-09 lxd.daemon[2178]: - proc_uptime
Aug 13 10:10:28 emp-09 lxd.daemon[2178]: - proc_slabinfo
Aug 13 10:10:28 emp-09 lxd.daemon[2178]: - shared_pidns
Aug 13 10:10:28 emp-09 lxd.daemon[2178]: - cpuview_daemon
Aug 13 10:10:28 emp-09 lxd.daemon[2178]: - loadavg_daemon
Aug 13 10:10:28 emp-09 lxd.daemon[2178]: - pidfds
Aug 13 10:10:28 emp-09 lxd.daemon[2178]: Reloaded LXCFS
Aug 13 10:11:51 emp-09 lxd.daemon[459040]: time="2023-08-13T10:11:51Z" level=error msg="Failed writing error for HTTP response" err="write unix /var/snap/lxd/common/lxd/unix.socket->@: write: broken pipe" url=/1.0 writeErr="write unix /var/snap/lxd/common/lxd/unix.socket->@: write: broken pipe"lxd/unix.socket->@: write: broken pipe" url=/1>
Aug 13 10:11:56 emp-09 lxd.daemon[458677]: => LXD is ready
'''

Frequent error
'''
Error: Failed to begin transaction: context deadline exceeded
'''
https://discuss.linuxcontainers.org/t/failed-to-begin-transaction-context-deadline-exceeded/13247

This usually indicates that you have a very high commit latency on your database, effectively that creating a new DB transaction took over 3s.

I’d recommend checking that none of your servers are overloaded (especially those with the database or database-leader roles in lxc cluster list if on a cluster) and having a close look at I/O performance since this most likely indicates that a disk write couldn’t be completed in that time frame.

-----------------------
Migration:
https://documentation.ubuntu.com/lxd/en/latest/migration/

