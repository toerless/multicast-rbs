---
coding: utf-8

title: Stateless Multicast Replication with Segment Routed Recursive Tree Structures (RTS) 
abbrev: pim-rts
docname: draft-eckert-pim-rts-forwarding-00
wg: PIM
category: info
ipr: trust200902

stand_alone: yes
pi: [toc, sortrefs, symrefs, comments]

author:
  -
       name: Toerless Eckert
       role: editor
       org: Futurewei Technologies USA
       street: 2220 Central Expressway
       city: Santa Clara
       code: CA 95050
       country: USA
       email: tte@cs.fau.de
  -
       name: Michael Menth
       org: University of Tuebingen
       country: Germany
       email: menth@uni-tuebingen.de
  -
       name: Steffen Lindner
       org: University of Tuebingen
       country: Germany
       email: steffen.lindner@uni-tuebingen.de

contributor:
- name: Xuesong Geng
  org: Huawei
  country: China
  email: gengxuesong@huawei.com
- name: Xiuli Zheng
  org: Huawei
  country: China
  email: zhengxiuli@huawei.com
- name: Rui Meng
  org: Huawei
  country: China
  email: mengrui@huawei.com
- name: Fengkai Li
  org: Huawei
  country: China
  email: lifengkai@huawei.com


normative:
  RFC6554:
  RFC8279:
  RFC8296:
  RFC9262:
  RFC8200:
  RFC8402:
  RFC8754:

informative:
  I-D.eckert-bier-rbs:
  I-D.eckert-bier-cgm2-rbs-00:
  I-D.eckert-bier-cgm2-rbs-01:
  I-D.eckert-msr6-rbs:
  I-D.xu-msr6-rbs:
  I-D.eckert-bier-cgm2-rbs:
  RFC791:

  Menth23:
    title: Efficiency of BIER Multicast in Large Networks
    ann: preprint
    author:
     - name: D. Merling
     - name: Thomas Stüber
     - name: M. Menth
    seriesinfo: 
      IEEE: accepted for "IEEE Transactions on Network and Service Managment"
      preprint: <https://atlas.cs.uni-tuebingen.de/~menth/papers/Menth21-Sub-5.pdf>

  Menth23f:
    title: Learning Multicast Patterns for Efficient BIER Forwarding with P4
    author:
     - name: S. Lindner
     - name: D. Merling
     - name: M. Menth
    seriesinfo: 
      IEEE: in "IEEE Transactions on Network and Service Managment", vol. 20, no. 2, June 2023
      preprint: https://atlas.cs.uni-tuebingen.de/~menth/papers/Menth22-Sub-2.pdf

  Menth21:
    title: Hardware-based Evaluation of Scalable and Resilient Multicast with BIER in P4
    author:
     - name: D. Merling
     - name: S. Lindner
     - name: M. Menth
    seriesinfo:
      IEEE: in "IEEE Access", <https://ieeexplore.ieee.org/xpl/RecentIssue.jsp?punumber=6287639>, vol. 9, p. 34500 - 34514, March 2021, <https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=9361548>

  Menth20h:
    title: P4-Based Implementation of BIER and BIER-FRR for Scalable and Resilient Multicast
    author:
     - name: D. Merling
     - name: S. Lindner
     - name: M. Menth
    seriesinfo:
      IEEE: in "Journal of Network and Computer Applications" (JNCA), vol. 196, Nov. 2020
      preprint: https://atlas.informatik.uni-tuebingen.de/~menth/papers/Menth20h.pdf
      DOI: 10.1016/j.jnca.2020.102764

  CGM2Design:
    title: Novel Multicast Protocol Proposal Introduction
    date: 2021-10-10
    target: <https://github.com/BingXu1112/CGMM/blob/main/Novel%20Multicast%20Protocol%20Proposal%20Introduction.pptx>
    author:
      -
        name: Sheng Jiang
      -
        name: Bing (Robin) Xu
      -
        name: Yan Shen
      -
        name: Meng Rui
      -
        name: Wan Junjie
      -
        name: Wang Chuang

  CGM2report:
    title: Carrier Grade Minimalist Multicast CENI Networking Test Report
    date: 2022-08-01
    target: <https://raw.githubusercontent.com/network2030/publications/main/CENI_Carrier_Grade_Minimalist_Multicast_Networking_Test_Report.pdf>

  RBSatIETF115:
    title: RBS (Recursive BitString Structure) to improve scalability beyond BIER/BIER-TE, IETF115
    date: 2022-11
    target: <https://datatracker.ietf.org/meeting/115/materials/slides-115-bier-recursive-bitstring-structure-rbs-beyond-bierbier-te-00>
    author:
      -
        name: Toerless Eckert
      -
        name: Michael Menth
      -
        name: Xuesong Gend
      -
        name: Xiuli Zhen
      -
        name: Rui Meng
      -
        name: Fengkai Li

--- abstract

BIER provides stateless multicast in BIER domains using bitstrings to indicate receivers.
BIER-TE extends BIER with tree engineering capabilities. 
Both suffer from scalability problems in large networks as bitsrings are of limited size
so the BIER domains need to be subdivided using set identifiers so that possibly many
packets need to be sent to reach all receivers of a multicast group within a subdomain.

This problem can be mitigated by encoding explicit multicast trees in packet headers with
bitstrings that have only node-local significance. A drawback of this method is that
any hop on the path needs to be encoded so that long paths consume lots of header space.

This document presents the idea of Segment Routed Recursive Tree Structures (RTS), a unifying
approach to use either bitstrings with local node-local significance or SIDs with 
local or domain-wide significance to encode multicast trees in packet headers.   

{::comment}
This draft expands on prior experimental work called "Recursive BitString Structure" (RBS)
for stateless multicast replication with source routed data structures in the
header of multicast data packets. Its changes and enhancements over RBS are a result from further
scalability analysis and further matching against different use cases. Its proposed design
also includes Proof of Concept work on Tofino programmable forwarding plane via P4.

Compared to RBS, RTS includes encoding options using either a per-hop bitstring or
a per-hop list of segment identifiers (SID) to address next hops in the multicast tree.
It also adopts a SID terminology for all of its functionality to best fit into well-established
terminology in unicast source routing.
{:/comment}

RTS, like RBS is intended to expand the applicability of deployment for stateless
multicast replication beyond what BIER and BIER-TE support and expect: larger networks, less
operational complexity, and utilization of more modern forwarding planes
as those expected to be possible when BIER was designed (ca. 2010).

This document only specifies the forwarding plane but discusses possible architectural
options, which are primarily determined through the future definition/mapping to encapsulation
headers and controller-plane functions.

--- middle

# Introduction

This draft expands on prior experimental work called "Recursive BitString Structure" (RBS)
for stateless multicast replication with source routed data structures in the
header of multicast data packets. Its changes and enhancements over RBS are a result from further
scalability analysis and further matching against different use cases. Its proposed design
also includes Proof of Concept work on Tofino programmable forwarding plane via P4.

Compared to RBS, RTS includes encoding options using either a per-hop bitstring or
a per-hop list of segment identifiers (SID) to address next hops in the multicast tree.

RTS, like RBS is intended to expand the applicability of deployment for stateless
multicast replication beyond what BIER and BIER-TE support and expect: larger networks, less
operational setup complexity, and utilization of more flexible programmable forwarding planes
as those expected to be possible when BIER was designed (ca. 2010). Unlike RBS, RTS does not
limit itself to a design that is only based on the use of bitstrings but instead offers
both bitstring and SID based addressing inside the recursive tree structure to support
to allow more scalability for a wider range of use cases.

# Overview

## From BIER to RTS

### Example topology and tree

~~~~~~~~
          Src                         Src
           |                           ||
           R1                          R1
          /  \                       //  \\
         R2   R3                     R2   R3
        /  \ /  \                  //  \ /  \\
       R5  R6    R7                R5  R6    R7
      /  \ | \  /  \             // \\ | \ //  \\
    R8    R9  R10  R11          R8    R9  R10  R11
    |     |    |    |           ||    ||   ||   ||
   Rcv1 Rcv2  Rcv3 Rcv4        Rcv1 Rcv2  Rcv3 Rcv4

    Example Network            Example BIER-TE / RTS Tree,
      Topology               // and || indicate tree segments
~~~~~~~~
{: #fig-ov-topo title="Example topology and tree"}

The following explanations use above example topology in {{fig-ov-topo}} on the
left, and example tree on the right.

### IP Multicast

Assume a multicast packet is originated by Src and needs to be replicated and
forwarded to be received by Rcv1...Rcv4. In IP Multicast with PIM multicast
routing, router R1...R11 will have so-called PIM multicast tree state, especially
the intermediate routers R2...R7. Whenever an IP Multicast router has multiple
upstream routers to choose from, then the path election is based on routing
RPF, so the routing protocol on R9 would need to route Src via R5, and R10 would
need to route Src via R7 to arrive at the tree shown in the example. 

### BIER

In stateless multicast forwarding with Bit Index Explicit Replication (BIER),
{{RFC8279}}, a packet has a header with a bitstring,
and each bit in the bitstring indicates one receiver side BIER router (BFER).

~~~~~~~~
[R8:5 R9:9 R10:11 R11:17] =

00001000001000001000000000000000000000000 
~~~~~~~~
{: #fig-ov-bier title="Example BIER bitstring"}

In {{fig-ov-bier}}, the term \[Ri:bi...\] (i=5,9,10,11; bi=5,9,11,17) indicates the routers "Ri"
that have their associated bit in the bitstring number "bi" set.  In this
example, the bitstring is assumed to be 42 bit long. The actual
length of bitstring supported depends on the header, such as {{RFC8296}}
and implementation. The assignment of routers to bits in this example is
random.

With BIER, there is no tree state in R2...R7, but the packet is forwarded
from R2 across these routers based on those "destination" bits bi and information of
the hop-by-hop IP routing protocol, e.g.: IS-IS or OSPF. The intervening
routers traversed therefore also solely depend on that routing protocols
routing table, and as in IP multicast, there is no guarantee that the
shown intermediate hops in the example picture are chosen if, as shown there
are multiple equal cost paths (e.g.: src via R10->R6->R3 and R10->R7->R3).

The header and hence bitstring size is a limiting factor for BIER and
any source-routing.  When the network becomes larger, not all receiver
side routers or all links in the topology can be expressed by this number
of bits. A network with 10,000 receivers for example would require at least
40 different bitstrings of 256 bits to represent all 
receiver routers with separate bits. In addition, the packet header needs
to indicate which of those 40 bitstrings is contained in the packet header.

When then receiver routers in close proximity in the topology are assigned
to different bitstrings, then the path to these receivers will need to
carry multiple copies of the same packet payload, because each copy is
required to carry a different bitstring. In the worst case, even as few
as 40 receivers may require still 40 separate copies, as if unicast was
used - because each of the 40 bits is represented in a different bitstring.

### BIER-TE

In BIER with Tree Engineering (BIER-TE), {{RFC9262}}, the bits in the bitstring do
not only indicate the receiver side routers, but also the intermediate links in the
topology, hence allowing to explicitly "engineer" the tree, for purposes such
as load-splitting or bandwidth guarantees on the tree.

~~~~~~~~
[R1R2:4 R2R5:10 R5R8:15 R5R9:16 R1R3:25 R3R7:32 R7R10:39 R7R11:42]

000100000100001100000000100000010000001001
~~~~~~~~
{: #fig-ov-bierte title="Example BIER-TE bitstring"}

In {{fig-ov-bierte}}, the list of \[RxRy:bi...\] indicates the set of
bits needed to describe the tree in {{fig-ov-topo}}, using the same
notation as in {{fig-ov-bier}}.

Each RxRy indicates one bit in the bitstring for the link Rx->Ry. The need to express
every link in a topology as a separate bit makes scaling even more challenging
and requiring more bitstrings to represent a network than BIER does, but
in result of this representation, BIER-TE allows to explicitly steer copies
along the engineered path, something requiredfor services that provide
traffic engineering, or when non-equal-cost load splitting is required (without
strict guarantees).

### RTS

With Recursive Tree Structure (RTS) encoding, the concept of steered forwarding
from BIER-TE is modified to actually encode the tree structure in the header as
opposed to just one single "flat" bitstring out of a large number of such bitstrings (in a
large network). For the same tree as above, the structure
in the header will logically look as follows.

~~~~~~~~
Syntax:
  RU  = SID { :[  NHi+ ] }
  NHi = SID
  SID = Ri

Example tree with SID list on R1:
  R1 :[ R2 :[ R5 :[ R8   ,R9   ]], R3 :[R7 :[R10,  R11]]]

Semantic:
  R1 replicates to neighbors R2, R3.
  R2 replicates to R5
  R3 replicates to R7
  ...

Encoding structure:
  1 byte SID always followed by
  1 byte length of recursive structure legth (":[" in example)
    If no recursive structure follows, length is 0.

Example SID list serialization (decimal):

  R1 :[ R2 :[ R5 :[ R8   ,R9   ]], R3 :[ R7 :[R10,  R11 ]]]
   |  |  |  |  |  |  | |   | |      | |   | |   | |   | | 
   v  v  v  v  v  v  v v   v v      v v   v v   v v   v v

   ..........SIDs according to above example..........
   |     |     |     |     |        |     |     |     |
  01 16 02 06 05 04 08 00 09 00    03 06 07 04 10 00 11 00
      |     |     |    |     |        |     |     |     |
      ......................Length fields................

Tree with SID list on R2:
  R2 :[ R5 :[ R8   ,R9   ]]
~~~~~~~~
{: #fig-ov-rts title="Example RTS structure with SIDs"}

In the example the simplified RTS tree representation in {{fig-ov-rts}}, Rx:\[NH1,... NHn\]
indicates that Rx needs to replicate the packet to NH1, NH2 up to NHn.
This \[NH1,... NHn\] list is called the SID-list.  Each NH can again be a "recursive" structure
Rx:\[NH1',...NHn'\], such as R5, or a leaf, such as R8, R9, Ro10, R11.

A simplified RTS serialization of this structure for the packet header is
also shown: Each router Ri is represented by am 8-bit SID i. The 
length of the following SID list, :\[NHi,...NHn\], is also encoded in one byte.
If no SID list follows, it is 00.

When a packet copy is made for a next-hop, only the relevant
part of the structure is kept in the header as shown for R2.

~~~~~~~~
Example tree with bitstrings on R1:
  BS1 :[ BS2 :[ BS5 :[ BS8,  BS9  ]], BS3  :[BS7 :[BS10, BS11]]]

Example bitstring serialization (decimal):

   ....List of next-hops indicated by the BitStrings.........
   |       |    |       |     |        |      |       |     |
  R2,R3   R5   R8,R9   Rcv   Rcv      R7     R10,R11 Rcv   Rcv
   |       |    |       |     |        |      |       |     |
  06 16   02 06 05 04  01 00 01 00    02  06 06  04  01 00 11 00
      |       |     |      |     |         |      |      |     |
      ......................Length fields.......................

Example tree with bitstrings on R2:
  BS2 :[ BS5 :[ BS8,  BS9  ]]
~~~~~~~~
{: #fig-ov-rts-bits title="Example RTS structure with bitstrings"}

Instead of enumerating for each router the list of next-hop
neigbors by their number (SID), RTS can also use a bitstring
on each router, resulting in a potentially more compact encoding.
Scalability comparison of the two encoding options is discussed later
in the document. Unlike BIER/BIER-TE bitstrings, each of these bitstring will be small,
as it only needs to indicate the direct neighbors of the router for which
the bitstring is intended.

In {{fig-ov-rts-bits}}, the example tree is shown with this 
bitstring encoding, also simplified over the actual RTS encoding.
BSi indicates the bitstring for Ri as an 8-bit bitstring.
On R8, R9, R10, R11 this bitstring has bit 1 set, which
is indicating that these routers should receive ("Rcv") and decapsulate
the packet.

{::comment}
Note that the actual RTS encoding has optimizations over this simplified
encoding to shorten the encoding, so this example encoding is just meant as
an overview of the principles. Specifically, RTS allows also
to eliminate the length field for leaves and to encode efficiently
broadcasting on the edge for aplications such as IPTV. Therefore the
bit 1 to indicate "Rcv" would in actual RTS not be replaceable by a
value of 0 in the length field.
{:/comment}

### Summary and Benefits of RTS

In BIER for large networks, even small number of receivers may
not fit into a single packet header, such as aforementioned when having 10,000
receiver routers with a bitstring size of 256. BIER always requires to
process the whole bitstring, bit-by-bit, so longer bitstrings may cause
issues in the ability of routers to process them, even if the actual length of
the bitstring would fit into processable packet header memory in the router.

In BIER-TE, these problems are even more pronounced because the bitstrings
now need to also carry bits for the intermediate node hops, which are
necessary whenever the path for a packet need to be explicitly predetermined
such as in traffic engineering and global network capacity optimization through
non-equal cost load-balancing, which in unicast is also a prime reason
for deployment of Segment Routing.

These scalability problems in BIER and BIER-TE can be reduced by intelligent
allocation of bits to bitstrings, but this requires global coordination, and
for best results good predictions of the most important required future multicast
trees.

In RTS, no such network wide intelligent assignment of addresses is required,
and any combination of receiver routers can be put into a single packet header
as long as the maximum size of the header is not exceeded (including of course
the intermediate nodes along the path).

Unlike Bier/BIER-TE, the RTS header can likely on many platforms be larger
than a BIER/BIER-TE bitstring, because the router never needs to examine every
bit in the  header, but only the (local) bitstring or list of SIDs for this router
itself and then for each copy to a neighbor, it only needs to copy the recursive structure
for that neighbor. The only significant limit for RTS in processing
is hence the maximum amount of bytes in a header that can be addressed.

# Architecture

This version of the document does not specify an architecture for RTS. 

The forwarding described in this document can allow different architectures,
also depending on the encapsulation chosen. The following high-level architectural
considerations and possible goals/benefits apply:

(A) If embedding RTS in an IP or IPv6 source-routing extension header, RTS can provide
source-routing to eliminate stateful (IP) Multicast hop-by-hop tree building protocols
such as PIM. This can be specifically attractive in use cases that previously used
end-to-end IP Multicast without a more complex P/PE architecture, such as enterprises,
industrial and other non-SP networks.

(B) The encoding of the RTS multicast tree in the packet header makes
it natural to think about RTS providing a multicast "Segment Routing" architecture
style service with stateless replication segments: Each recursive structure is an RTS segment.

This too can be a very attractive type of architecture to support, especially for networks
that already use MPLS or IPv6 Segment Routing for unicast. Nevertheless, RTS can also be beneficial
in SP networks not using unicast Segment Routing, and there are no dependencies
for networks running RTS to also support unicast SR, other than sharing architecture concepts. 

(C) RTS naturally aligns with many goals and benefits of BIER and even more so BIER-TE,
which it could most easily supersede for better scalability and ease of operations.

In one possible option, the RTS header specified in this document could even replace the bitstring of the
BIER {{RFC8296}} header, keeping all other aspects of BIER/BIER-TE reusable. In such an
option, the architectural aspects of RTS would be derived and simplified from {{RFC9262}},
similar to details described in {{I-D.eckert-bier-cgm2-rbs-01}}.

# Specification

## RTS Encapsulation

~~~~~~~~
+----------+--------+------------+
| Encap    | RTS    | Next Proto |
| Header(s)| Header | Payload    |
+----------+--------+------------+
~~~~~~~~
{: #fig-rts-encap title="RTS encapsulation"}

This document specifies the formatting and functionality of the 
"Recursive Tree Structure" (RTS) Header, which is assumed to be located in a packet
between some Encap Header and some Next Proto / Payload. 

The RTS header contains only elements to support replication to next-hops,
not any element for forwarding to next-hop. This is left as a task for the Encap Header
so that RTS can most easily be combined with potentially multiple alternative
Encapsulation Header(s) for different type of network protocols or deployment use cases.
Common Encap Headers will also require an Encap Header specific description of the total length of the RTS Header.

{::comment}
To operationalize RTS, an Encap Header needs to allow forwarding to
RTS next-hop SIDs, and indicate a type of the Next Proto Payload if that is not self-identifying
(which it is not in Ethernet, MPLS or IP/IPv6!).
{:/comment}

In a minimum (theoretical) example, RTS could be used on top of Ethernet with an
ethertype of RTS+Payload, which indicates not only that an RTS Header follows, but also
the type of the Next Proto Payload.

See the encap discussions in {{encap-discussions}} for considerations regarding BIER
or IPv6 extension headers as Encap Headers.

## RTS Addressing

Addresses of next-hops to which RTS can replicata are called RTS Segment IDentifiers (SIDs).
This is re-using the terminology established by {{RFC8402}} to be agnostic of the addressing
of the routing underlay used for forwarding to next-hops and obtaining routing information
for those routing underlay addresses. Specifying an encapsulation for RTS requires specifying how
to map RTS SIDs to addresses of the addresses used by that (unicast) forwarding mechanism.

RTS SIDs are more accurately called RTS replication SIDs. They are assigned to RTS
nodes. When a packet is directed to a particular RTS SID of an RTS node it means that
that node needs then to process the RTS Header and perform replication according to it.

Using the SR terminology does not mean that RTS is constrained to be used
with forwarding planes for which (unicast) SR mappings exist: IPv6 and MPLS, but
it means that for other forwarding planes, mappings need to be defined.
For example, when using RTS with {{RFC8296}} encapsulation, and hence BIER addressing,
which is relying on 16-bit BFR-id addressing (especially the BFIR-id in the
{{RFC8296}} header), then RTS SIDs need to map to these BFR-ids. 

If instead RTS is to be deployed with (only) an IPv6 extension header as the Encap Header,
then RTS SIDs need to be mapped to IPv6 SIDs.

This document uses three types of RTS SIDs to support three type of encoding
of next-hops in an RTS Header: Global, Local and Local bitstring RTS SIDs.

All SIDs map to a unicast address or unicast SID of the node which the RTS SID addresses.
This unicast address or SID is used in an Encap Header when sending an RTS
packet to that node.

The type of an RTS SID determines the encoding and scope of the SID. Global and Local SIDs
are used in the SID-list encoding option of the RTS header, Local bitstring SIDs are used
in the local-bitstring encoding option of the RTS header.

Local and local bitstring RTS SID are valid only on an individual RTS node because they are both
so compact in their encoding that only a limited number of RTS nodes can be addressed by them.
Global RTS SIDs are valid on every RTS node: Using Global RTS SIDs allow the creator of an
RTS Header to steer a packet copy from any RTS to any other RTS node. Local and
local bitstring SIDs allow to only steer traffic across adjacencies predetermined by network
and/or operator policy that allocates these SIDs, typically L2 adjcencies between RTS nodes.

* Global RTS SIDs are 15 or 23 bit values depending on the size of the deployment.

* Local RTS SIDs (or abbreviated local SIDs) are 7-bit values 1...127.

* Local bitstring RTS SIDs (or abbreviated local bitstring SIDs) are values from 1.. (8*N).
  N is the size of the local bitstring for the node on which the local bitstring SID is
  allocated. The value of the local bitstring SID indicates the bit in that bitstring  that
  needs to be set to indicate that a copy to the node addressed by the SID is needed.

Each RTS SID has flags associated with it that define encoding and processing of
RTS packet when the SID is processed in the RTS header by an RTS node that is
sending a packet to that SID. 

* The D)eliver Flag indicates that the node addressed by the SID needs to receive
  a copy of the packet by appropriate disposing of the RTS Header and processing
  of the Next Proto Payload.

* The B)roadcast Flag indicates that the node addressed by the SID need to broadcast
  a copy of the packet to a preconfigured list of "all-leaf-neighbors".

* The RU Flag indicates that the RTS header contains a recursive unit for the SID.
  When the node addressed by the SID receives the packet, it will act as a transit node
  and create copies to the nodes in that RU. 

All Flags for a SID are processed by the node that is sending a copy to the addressed SID,
but not the node which is addressed by the SID itself. That node is only the receiver of
a copy of the packet. The sending node moifies the RTS Header accordingly
for the Flags so that the addressed node when it receives the copy will have the
Flags in the RTS Header. This is done so that network or operator policy can allocate
from the limited local and local bitstring SID space only those (combination of) Flags
for a node that are deemed necessary, as opposed to costing space in the RTS header
if the Flags where all static part of the RTS Header encoding.

The network is expected to make SID information available to the creators of RTS headers so they can
create one or more RTS headers to achieve the desired replication tree(s) for a payload. This includes:

* Global SID for each node and the unicast address it maps to.
* For each node its Local SIDs and local bitstring SIDs, its flags and the unicast address/SID it maps to.
* For each node its "all-leaf-neighbors" list of global SIDs (see {#all-leaf-neighbors})

## RTS Header 

~~~~~~~~
+--------+---------------------------------------------+ 
|        | RU0 (optional)                              |
| RTS    |+----------++--------++-------+     +-------+|
| Params ||RU0 Params|| RU-NH1 ||RU-NH2 | ....|RU-NHn ||
|        |+----------++--------++-------+     +-------+|
+--------+---------------------------------------------+
~~~~~~~~
{: #fig-rts-header title="RTS Header"}

The RTS Header consists of the "RTS Params" field followed by an optional element
called "Recursive Unit 0" (RU0).

When the RTS header is processed by a router, RU0 (if present) is composed of RU0 Params as well
as 0 or more RU's, one for each next-hop.  Each of these RUs is composed like RU0 itself from
a RU Params field and potentially following RU-NHi fields.

RU Params differ depending on whether bitstring or SID encoding is chosen
for the packet. These differences are explained later.

~~~~~~~~
RTS Params:
 0 1 2 3 4 5 6 7
+-+-+-+-+-+-+-+-+
|R|D|B|S| Rsvd  |
+-+-+-+-+-+-+-+-+
~~~~~~~~
{: #fig-rts-params title="RTS Params"}

The (R)U0 bit indicates whether a RU0 follows.

R=0: No RU0 follows. In this case, D MUST be 1, or else the packet is misformed.

R=1: An RU0 follows.

The (D)eliver bit indicates whether a copy of the packet should be delivered on this node
by disposing the RTS Param and processing the next-header. 

D=0: Do not deliver a copy of the packet.

D=1: Deliver a copy of the packet by disposing of the RTS Header and processing of the next-header.

The (B)roadcast bit determines if copies of the packet should be send to all "all leaf neighbors".

B=0: Do not send copies to all "all leaf neighbors"

B=1: Send copies to all "all leaf neighbors"

Creating copies because of the presence D, B and RU is orthogonal from each other and can
happen in any combination. At least one copy needs to be indicated or else the packet is invalid.

The (S) bit indicates whether next-hops are encoded as a bitstring or SID-list. This flag
is irrelevant if R=0 (because there is no bitstring nor SID-list).

S=0: next-hops are encoded as a bitstring

S=1: next-hops are encoded as a SID-list.

## Creating and Receiving copies

RTS relies on unicast forwarding procedures using the Encap Header(s) 
to receive packets and send copies of packets. Every copy of a packet created,
except for those that are for local reception by a node, is sent towards a unicast address/SID
according to the RTS SID it addresses.

In summary, RTS Params is responsible for distinguishing the encoding of the following
(optional) RU0 but also provides the bits used for processing by so-called "leaves" of an
RTS tree, where packets need to be delivered and/or broadcast to all "leaf" neighbors (where
they are then delivered).

## Creating copies because of RTS Header D=1 {#dcopy}

When D=1 is encountered in the RTS Params, an (internal) copy of the packet is created
in which the headers up to the RTS Header are disposed of according to the procedures specified
for Encap Header(s) so that the Next Proto Payload after the RTS Header is processed.

## Creating copies because of RTS Header B=1 {#all-leaf-neighbors}

When B=1 is set in the RTS Params, a list of uncast addresses/SIDs called the
"all leaf neighbors" is used to create a separate copy of the packet for each element
in that list.  Each RTS node MAY have such a list.

For each packet copy made because of B=1, RU0 is removed, D is set to 1 and B to 0.
Typically, the "all-leaf-neighbors" list is (auto-)configured with the list of
RTS L2 neighbors that are known to be leaves of the RTS domain. 

## Creating copies because of the presence of an RU0

The common processing of RU0 to create copies, independent of whether SID-list 
or local bitstring list encoding of next-hops is used is as follows.

If R=1, then the RTS router examines the RU0 header and the following RU-NHi to determine
the copies it needs to create.

When packet gets replicated to a NHi (1...n) with an RU-NHi, RU0 gets replaced by RU-NHi,
all RU0 data before and after RU-NHi is skipped when rewriting the packet header for
the copy to NHi. If a packet copy gets replicated to a next-hop not including an RU-NHi,
the copy to that next-hop will not include any RU0. In this case, the Flags for the
SID of that next-hop will include the D and/or B flag, and these flags will be accordingly
set in the copy sent to the node so that it delivers and/or broadcasts the packet.

The following example shows how a copy made to NH2 will cause RU-NH2 to become RU0 on the
copy of the packet made for NH2:
   
~~~~~~~~
Original RTS Header at this hop:
+--------+---------------------------------------------+
|        | RU0                                         |
| RTS    |+--....----++--------++-------+     +-------+|
| Params ||RU0 Params|| RU-NH1 ||RU-NH2 | ....|RU-NHn ||
|        |+--....----++--------++-------+     +-------+|
|        |            |<........... RU List..........>||
+--------+---------------------------------------------+
         <--- discard -------->||<-copy>||<--discard-->|
                                  (&strip)

Copy sent to NH2:
+--------+-------------------------------------------+
|        | RU0 (was RU-NH2 on prior hop)             |
| RTS    |+--....----+--------+-------+     +-------+|
| Params ||RU0 Params| RU-NH1'|RU-NH2'| ....|RU-NHn'||
|        |+--....----+--------+-------+     +-------+|
+--------+-------------------------------------------+
~~~~~~~~
{: #fig-rts-example-nh2 title="Example copy to NH2"}

   
### Replication with SID-lists

~~~~~~~~
+--------+--------------------------------------------+
|        | RU0 (present if RTS Params RU=1)           |
| RTS    |+...........+--------+-------+     +-------+|
| Params |. RU0 Params| RU-NH1 |RU-NH2 | ....|RU-NHn ||
| (S=1)  |+...........+--------+-------+     +-------+|
+--------+--------------------------------------------+
~~~~~~~~
{: #fig-rts-slist title="RTS Header with SID-list format (S=1)"}

This section describes replication with SID-list. The SID-list
format is indicated by S=1 in the RTS Param field of the header.

~~~~~~~~
|<--- RU-NHi RU Params ------>|<-- RU-NHi RU List --------->|
+-+-+-+ ... +-+-+-+-+-+-+-+-+-+-+....-+-+....-+     +-+....-+
|G| RU-NHi    |  RUlength     |RU-NH1'|RU-NH2'| ... |RU-NHn'|
| | SID       |  (optional)   |       |       |     |       |
+-+-+-+ ... +-+-+-+-+-+-+-+-+-+-+....-+-+....-+     +-+....-+
  |<-7/15/23->|               |<....... optional ..........>|
~~~~~~~~
{: #fig-rts-ru-nhi-sid title="RU-NHi in SID-list format"}

When forwarding with the SID-list RTS format, RU Params in RU-NHi
contains the SID of the router to which the RU is destined.
If the SID indicates the RU flag, then the SID is followed by
a RUlength field and a list of zero or more RU-NHi' as shown in
{{fig-rts-ru-nhi-sid}}. 

If the G)lobal bit of RU Params is 0, SID is 
a 7-bit long local RTS SID assigned by the router
processing the RU0. If G is 1, SID is a global SID with
a deployment chosen length of 23 or 17 bit, which needs
to be common across all RTS nodes in the RTS domain.

Note that instead of being configurable, this length could
also become a specification defined size in later versions of this document.

RU0 Params in the SID-list format is empty. It is stripped
from RU-NHi when the packet copy is made so that that RU-NHi
becomes RU0 of the packet copy.

The reason for stripping it is because it serves no
purpose anymore. The Encap Header is responsible to deliver
the packet to the correct RTS neighbor. Once that RTS
neighbor receives the packet, it may not be able 
to interpret the SID, because that SID could be a local SID
from the context of the sending node, and some forwarding
planes like MPLS make it impossible to know who sent a packet.

Likewise, the RUlength field is redundant: It was only necessary
when creating the packet copy, copying RU-NHi into the new
packet copy towards NHi, based on RU-NHi's RUlength field. 
Once the new packet copy is created, it's Encap Header will
need to have it's length field updates according to the new
RU0 length, so this information does not need to be duplicated
in the RU0 itself.

#### Encoding and Allocation of SIDs

D), B) and RU) flags are properties of SIDs so that they
do not unnecessarily require a fixed amount of bits in the encoding,
when it is clear for specific nodes that they do not ever need
all of the encodings. This is especially true, when local SIDs
are used, or global SIDs with 15 bit in networks close that that
amount of required SIDs.

When global SIDs use 23 bits instead, there should be enough
SID space to allocate all 7 possible Flag combination for
each node, maybe even by allocating the last 3 bit of the
numeric SID representation, wasting one SID number for every
node, just to have a simple addressing scheme. 

~~~~~~~~
+----------+--------------+-------+---------------------+
| Type     | SID          | Flags | Encap data          |
+----------+--------------+-------+---------------------+
| Global   | <Node1 SID1> |D      | <Unicast Address 1> |
| Global   | <Node1 SID2> |  B    | <Unicast Address 1> |
| Global   | <Node1 SID3> |D B    | <Unicast Address 1> |
| Global   | <Node1 SID4> |    RU | <Unicast Address 1> |
| Global   | <Node1 SID5> |D   RU | <Unicast Address 1> |
| Global   | <Node1 SID6> |  B RU | <Unicast Address 1> |
| Global   | <Node1 SID7> |D B RU | <Unicast Address 1> |
| <unused> | <unused>     | ...   | ...                 |
| Global   | <Node2 SID1> |D      | <Unicast Address 2> |
| Global   | <Node2 SID2> |  B    | <Unicast Address 2> |
| ...      | ...          | ...   | ...                 |
+----------+--------------+-------+---------------------+
~~~~~~~~
{: #fig-rts-glob-sid title="Global SID allocation example"}

For optimized allocation of SIDs, the following considerations
may be used as a starting point to limit the numbrer of
local SIDs requird for nodes.

A large number of nodes may be leaves in the network topology.
For example, when PE routers are not in a ring, but only attached
to two P routers, they are not assumed to carry transit traffic,
and even the unicast routing protocol may accordingly be configured.
In this case this PE never needs to have the RU flag, it would
also not need a B flag, but all RTS packets arriving at it would
solely be for delivering RTS packets. Hence such
nodes only need a single SID with D flag.

P router attaching to such PE would need RU flag SIDs, they
may not need D flag SIDs because typically they would not
need to consume the service offered by RTS services themselves.

These P routers may benefit from B flag, where the list of "all-leaf-neighbors"
are all the directly connected PE routers.  In result they would
need one SID with just RU, one with B/RU and one with just B.
This third SID (B) could be avoided, in which case RTS Header
encodings would need to add a zero-filled RUlength field for this
node.

PE router in a ring would likely require only D, D/RU and RU
given how they have no obvious neighbors to broadcast to, and
where broadcasting would save significant encoding space.

In result, a common assignment scheme could use 1 SID per leaf PE,
2 per P router and 3 per ring-PE.

#### Receiving and processing RTS packet with SID-list

An RTS node receiving an RTS packet with SID-list format creates
copies because of D and B flags in the RTS Params field as
described in {{dcopy}} and {{all-leaf-neighbors}}.

If the RU flag is set and thus an RU0 is present, the node sequentially
examines the RU-NHi, determining from its global and local SID
table and the RU-NHi's SID its Flags and accordingly creates
a copy and rewrites the copies RTS Params field as described before.
The total number n of RU-NHi present is determined by the length
of the RU0 field which needs to be determined by some Encap Header
field.

The node determines the size of the RU-NHi from the SID and
if the SID flags indicate the RU flag from the RUlength field.
It subtracts the size of the RU-NHi from the remaining RU0 size.
If this value is less than 0, this indicates an RTS header
encoding error and processing of the packet SHOULD stop and
an error be raised.

If RUlength is present and larger than 0, the node rewrites 
the RU0 field of the packet so that the RU-NHi
becomes the RU0 of the packet copy - except for the RU Params
field (G/SID, RUlength), which is also stripped. If the
SID has no RU flag or RUlength is 0, then instead the packet
copy will not contain any RU0, and the RU flag in the RTS Params
is cleared for the packet copy. The node also updates the
according Encap Header field for the size of the new RTS Header.

### Replication with local bitstrings (RBS)

Replication with local bitstrings is an procedure in which
RU do not have a SID, but where these SID are represented
by a local bitstring in the RU0 Params. Each bit set that
local bitstring indicates a neighbors local bitstring SID to
which a copy is to be made, or a bit to indicate local
deliver or broadcast operation. This encoding is
equivalent to prior "Recursive BitString Structure" encoding,
except that it is optimized for common processing with SID-lists
and for P4 processing.

A local bitstring SID in the local bitstring only requires an RU-NHi if it
has the RU flag.

The formatting is as follows.

~~~~~~~~
+--------+-----------------------+
|        | RU0                   |
| RTS    |+---------+-+- ... -+-+|
| Params ||RU Params| RU list   ||
| (S=0)  |+---------+--- ... -+-+|
+--------+-----------------------+
~~~~~~~~
{: #fig-rts-bitstring title="RTS Header with local bitstring format (S=0)"}

~~~~~~~~
|<--- RU Params ----------->|<--------- RU List --------->|
|0 1 2 3 4 5 6 7|<- N*8 --->|                             |
+-+-+-+-+-+-+-+-+-+- ... -+-+-+....-+-+....-+     +-+....-+
| RUlength      | local     |RU-NH1'|RU-NH2'| ... |RU-NHn'|
|               | bitstring |       |       |     |       |
+-+-+-+-+-+-+-+-+-+- ... -+-+-+....-+-+....-+     +-+....-+
  |<-7/15/23->|             |<....... optional ..........>|
~~~~~~~~
{: #fig-ru-bitstring title="RU (/RU0) with local bitstring format"}

RUlength indicates the length of the RU without the length of RUlength itself,
which is 8 bit.

The length of local bitstring is configured on the node and MUST
be a multiple of 8 bits. Different nodes can have different lengths.

Each bit in the BitString indicates a local bitstring SID.
The considerations for those SIDs and what type SIDs
(with which flags) to allocate are like those for
local SIDs with the following changes in considerations.

#### Receiving and processing RTS packet with local bitstring

An RTS node receiving an RTS packet with SID-list format creates
copies because of D and B flags in the RTS Params field the same as
for SID-list encoding.

If the RU flag is set in RTS params and thus an RU0 is present, the node sequentially
examines the bits (local bitstring SIDs) of the local bitstring. If a bit
is set and the local bitstring SID it represents has the RU flag,
then RU list has an RU-NHi element for this SID, and that RU becomes the
RU0 of the packet copy sent towards that neighbor. If the SDI has no RU flag,
then no RU-NHi element for this SID is expected in SID list.

When creating a copy for a SID, the RTS header size is according updated
in the appropriate Encap Header field, and the RTS Param fields D/B/RU
are updated from the SID flags.

# Discussion

## Encoding and allocation of SIDs for delivering and broadcasting

Instructing an RTS node "target" to deliver and/or broadcast
a packet can be done through a RTS node  "neighbor"
that forwards the packet to target. When SID-list encoding is used,
this is either through a global SID for target with D and/or B flag,
or a local SID from neighbor that is addressing target with D and/or B
flag. When bitstring encoding is used this is through a local bitstring
SID from neighbor that is addressing target with D and/or B flag.

Alternatively, deliver and/or broadcast may also happen
because of target itself evaluating a SID for itself with D and/or B
flag. When using SID-list encoding, this could happen, when neighbor
sends a packet copy to target without D or B flag in RTS Params
of the local SID or global SID. target itself could then have a 
local SID indicating itself as the destination and D and/or B flag set.

This option is is likely not very encoding efficient though. It would 
cost 8 bit for example to encode one out of three local SID without RU
flag on target pointing to itself as the destination and indicating D and/or B flag
(3 local SID = D, B, D/B).

If the packet header uses a global SID to steer the packet from neighbor
to target, then there should never be a need for this option because
there are enough global SIDs to encode all combination of flags. If a local
SID is used and this option is necessary because there are not enough
local SID to encode all desired flag combinations for target, then
the most compact encoding depends on the size of global SIDs. If it is
15 bit, then the use of a global SID would have the same encoding size.
If it is 23 bit, then this option would save one byte of encoding space.
 
When using bitstring encoding, the minimum encoding size cost of evaluating
D and/or B flags on target or on neighbor is as follows.

PE that are always leaves would always get only one local bitstring
SID in the bitstrings of its neighbors indicating the D bit.

PE that can be transit nodes, such as in rings would get one
local bitstring SID without D bit, but with RU bit in the bitstrings of their neighbors,
the PE ring node itself would have a local bitstring
SID in its own local bitstring to indicate its own delivery copy.

P routers adjacent to PE leaf nodes would require only
local bitstring SIDs without D bit by their neighbors. Their
own bitstring SIDs includes one SID with B bit for itself to indicate
broadcasting of packet copies to all PE leaf node neighbors.

## Encapsulation considerations {#encap-discussions}

### Comparison with BIER header and forwarding

The RTS header is equivalent to the elements of a BIER/BIER-TE header required for
BIER and BIER-TE replication.

(SI, SD, BSL, Entropy, Bitstring)

RTS currently does not specify an ECMP procedure to next-hop SIDs because it is part
of the (unicast) forwarding to next-hops, but not to RTS replication.

Note that this is not the same set of header fields as {{RFC8296}}, because
that header contains more and different fields for additional functionality, which RTS
would require to be in an Encap Header.

For the same reason, the RTS Header does also not include the {{RFC8296}} fields TC/DSCP
for QoS, OAM, Proto (for next proto identification) and BFIR-id. Note that BFIR-id is not
used by BIER forwarding either, but by BIER overlay-flow forwarding on BFIR and BFER. 

Constraining the RTS header to only the necessary fields was chosen to make it most
easy to combine it with any desirable encapsulation header. 

RTS could use {{RFC8296}} as an Encap Header and BIER/{{RFC8296}}
forwarding procedures, replacing only BIER bitstring replication to next-hop functionality
with RTS replication.

In this case, the RTS Header could take the place of the bitstring field in
the {{RFC8296}} header, using the next largest size allowed by BIER to fit the RTS header.
SI would be unused, and SD could be used to run RTS, BIER and even BIER-TE in parallel
through different values of SD, and all BIER forwarding procedures including ECMP to
next-hop SIDs could be used in conjunction with RTS replication.

### Comparison with IPv6 extension headers

The RTS header could be used as a payload of an an IPv6 extension header
as similarly proposed for RBS in {{I-D.eckert-msr6-rbs}}. Note that the RTS
header itself does not contain a simple length field that allows to completely
skip across it. This is done because such functionality may not be required
by all encapsulation headers / forwarding planes, or the format in which such
a length is expected (unit) may be different for different forwarding planes.
If required, such as when using the RTS header in an IPv6 extension header, then
such a total-length field would have to be added to the Encap Header.

## Encoding choices and complexity

Work on analysis of scalability of stateless source routing broaches a very wide
field: size and topology of network, size and distribution of receivers just to name
a few. This makes it impossible at this time to decide on a single, most simple encoding
option for structured tree source-routing encodings. Instead, RTS attempts to
combine the currently understood aspects of encoding into an as-simple-as-possible to implement
single forwarding machinery and is in process of validating this encoding with P4 Tofino.
Precursors of this work with subsets of these encoding options have already been validated
through proof-of-concept implementations.

The use of SID-lists in the encoding is a natural fit when the target tree is one
that does not require replication on many of the hops through which it passes, such as
when doing non-equal-cost load-splitting, such as in capacity optimization in service provider
networks. In {{RFC9262}}, Figure 2, such an example is called an "Overlay" (tree). In the
SID list, each of the SID can easily be global, making it possible for a next-hop to be anywhere
in the network. While it is possible to also use global SIDs in a bitstring, the decision to
include any global (remote) SID as a bit in a bitstring introduces additional encoding size
cost for every tree, and not only the ones that would need this bit. This is also the
main issue of using such global SIDs in BIER-TE (where they are represented as forward_routed())
adjacencies.

When replicating to direct neighbors, SID lists may be efficient for sparse trees. In the
RTS encoding, up to 127 direct neighbors could be encoded in 8 bit for each SID, so it is
easy to compare the encoding efficiency to that of a bitstring. A router with 32
neighbors (assume leaf neighbors for simplicity) requires 32 bits to represent all possible neighbors,
if 4 or fewer neighbors need to receive a copy, a SID-list encoding requires equal or fewer
bytes to encode.

Use of the broadcast option is equally possible with SID-list or bitstrings. An
initial scalability test with such an option was shown in slide 6 of {{RBSatIETF115}}, but
not included in any prior proposed encoding option; a better analys of this option is
subject to future work.

With all these considerations, it seems prudent to not attempt to pursue different encoding
options such as recursive SID-lists and recursive bitstrings as separate experimental
protocol proposals, because that would result in too much systematic duplication of effort
across the whole stack. One may still arrive during the course of the experiment at a conclusion
that one of the two encodings suffices.

The current state of understanding of implementation on P4 Tofino for the proposed encoding is
primarily that it may or may not be possible to fit the whole encoding into the available
code space, whereas bitstring and SID-list encoding alone will work. Likewise, the 8/24 bit variable
length encoding feasibility for SID-list elements also needs to be verified.

If not all aspects of the encoding may fully work on Tofino or leave enough room for
other forwarding code (such as unicast) to fit, this may or may not be relevant to industry
target forwarding engines. If the encoding does show being feasible and beneficial,
especially if compared to BIER/BIER-TE also on the implementation side, then RTS may 
in return be a good example of requirements that should be supportable in better next-gen
low-cost / white box switches.

{::comment}
Compared to other proposed, more complex encodings, RTS specifically does not allow mixing
of bitstrings and SIDs in the same packet to keep the non-shared parts of the code path simple,
and to also allow the option of implementations to not necesarily instantiate
both options in parallel in deployment (aka: only compile one option for the running network based
on operator preference).
{:/comment}

## Discovering malformed RTS Headers

To determine whether the encoding of an RTS Header is correct,
a node MAY add up the RUlength fields and verify that it adds
up to the size of the RU list field as determined from the
Encap Header size field for the RTS Header - before starting to
replicate the packet.

If a node does not do this check before creating copies for neighbors,
then malformed headers may be discovered when an RUlength field would
indicate a packet offset exceeding the RTS Header size.

The size of the local bitstring headers is not encoded in the RTS
Header itself, so a malformed header can most easily be a result
of the encoding node using a different size than the processing node.
This should not happen when the controller-plane mechanism to
distribute SID space information is working correctly.

If this issue is considered to be important enough to spend further
encoding space on, then the size of the bitstring needs to be added
to the RU Params field. For example, the high-order bit of every
byte of the bitstring could be fixed to 1 to indicate another byte
of bitstring is following and 0 to indicate that this is the last
byte of the bitstring. The correct setting of these bits is easily
validated before creating copies, and independent of bitstring size
in bytes, this only adds 12.5% overhead per SID/bit. In this case
it might be better though to only allow 16-bit multiple of local
bitstring sizes to reduce the overhead to 6.25%.

## Differences over prior Recursive BitString (RBS) encodings proposal

The encoding for bitstrings proposed in this draft relies again on discarding of unnecessary RU
instead of using offset pointers in the header to allow parsing only the relevant RU.

Discarding unnecessary RU has the benefit, that the total size of the header
can be larger than if offset pointers where used. Forwarding engines have
a maximum amount of header that they can inspect. With offset pointers, the
furthest a node has to look into the RTS header is the actual size of the
RTS header. With discarding of unnecessary RU, this maximum size for inspection can
be significantly less than the maximum RTS header size. Consider the root of tree has two neighbors
to copy to and both have equal size RU, then this root of the tree only needs to
inspect up to the beginning of the second RU (the SID or bitstring in it). 

# Security considerations

TBD

# Acknowledgments

The local bitstrings part of this work is based on the design published by Sheng Jiang, Xu Bing, Yan Shen, Meng Rui, Wan Junjie and Wang Chuang \{jiangsheng\|bing.xu\|yanshen\|mengrui\|wanjunjie2\|wangchuang\}@huawei.com, see {{CGM2Design}}.  Many thanks for Bing Xu (bing.xu@huawei.com) for editorial work on the prior variation of that work {{I-D.xu-msr6-rbs}}.

# Changelog

00 - initial version for IETF118.

--- back

# Evolution to RTS

The following history review of RBS explains key aspects of the road towards RTS and
how prior document work is included (or not) in this RTS work.

## Research work on BIER

Initial experience implementation with implementation of BIER in PE was
gained through "P4-Based Implementation of BIER and BIER-FRR for Scalable and Resilient Multicast", {{Menth20h}},
from which experience was gained that processing of large BIER bitstring requires significantly
complex programming for efficient forwarding, as described in "Learning Multicast Patterns for Efficient BIER Forwarding
ith P4", {{Menth23f}}. Further evalutions where researched through 
"Hardware-based Evaluation of Scalable and Resilient Multicast with BIER in P4", {{Menth21}} and
"Efficiency of BIER Multicast in Large Networks", {{Menth23}}.

## Initial RBS from CGM2

The initial, 2021 {{I-D.eckert-bier-cgm2-rbs-00}} introduces the concept of Recursive Bitstring
Forwarding (RBS) in which a single bitstring in a source routing header for stateless multicast
replication as introduced by BIER and re-used by BIER-TE is replaced by a recursive structure
representing each node of a multicast tree and in each node the list of neighbors to which to
replicate to is represented by a bitstring.

Routers processing this recursive structure do not need to process the whole structure, instead,
they only need to examine their own local bitstring, and replicate copies to each of the neighbors
for which a bit is set in the bitstring for this node. For each copy the recursive structure
is rewritten so that only the remaining subtree behind the neighbor remains in the packet header.
By only having to examine a "local" (and hence short) bitstring, RBS processing can arguably be
simpler than that of BIER/BIER-TE. By discarding the parts of the tree structure not needed
anymore, there is also no need to change bits in the bitstring as done in BIER/BIER-TE to avoid
loops.

This initial version of RBS encoding is based on a design originally called "Carrier
Grade Minimalist Multicast" (CGM2), and which started as a research project whose design is
summarized in {{CGM2Design}}. A vendor high-speed router implementation proof-of-concept was
done, as well as a wide-area proof-of-concept research network deployment, which was
documented for the 2022 Nanjing "6th future Network Development Conference". An english translation
of the report can be found at {{CGM2report}}.

## RBS scalability compared to BIER

The 2022 {{I-D.eckert-bier-cgm2-rbs-01}} version of the document adds topology and testing
information about a simulation comparing RBS with BIER performance in a dense, high-speed network topology.
It is showing that the number of replications required to reach an increasing number of receivers does
grow slower with RBS than with BIER, because in BIER, it is necessary to send another packet copy from the
source whenever receivers in a different Set Identifier Bitstring (SI) are required, whereas
RBS requires to only create multiple copies of a packet at the source to reach more receivers
whenever the RBS packet header size for one packet is exhausted. The results of this simulation
are shown in slide 6 of {{RBSatIETF115}}.

While RBS with its explicit description of the whole multicast tree structure seems immediately
like (only) a replacement for BIER-TE, which does the same, but encodes it in a "flat"BIER
bitstring (and incurring more severe scalability limitations because of this), this simulation
shows that the RBS aproach may also compete with BIER itself, even though this may initially
look counter-intuitive because information not needed in the BIER encoding - intermediate hops -
is encoded in RBS. 

The scalability analysis also assumes one novel encoding optimization, indicating replication to
all leaf neighbors on a node. This allow to even further compact the RBS encoding for dense trees,
such as in aplications like IPTV. Note that this optimization was not included in any of the
RBS proposal specifications, but it is included in this RTS specification.This optimization leads
to the actual reduction in packet copies sent for denser trees in the simulation results.

## Discarding versus offset pointers

{{I-D.eckert-bier-rbs}} re-focusses the work of the prior {{I-D.eckert-bier-cgm2-rbs}} to focus
only on the forwarding plane aspects, removing simulation results and architectural considerations
beyond the forwarding plane.

It also proposes one then considered to be interesting alternative to the encoding. Instead of
discarding unnecessary parts of the tree structure for every copy of a packet made along the
tree, its forwarding machinery instead uses two offset pointers in the header to point to the
relevant sub-structure for the next-hop, so that only a rewrite of these two pointers is needed.
This replicates the offset-rewrite used in unicast source-routing headers such as in IP,
{{RFC791}}, or IPv6, {{RFC6554}} and {{RFC8754}}.

Discussions about discarding vs. changing of offset since then seems to indicate that changing
offsets may be beneficial for forwarders that can save memory bandwidth when not having to rewrite
complete packet headers, such as specifically systems with so-called scatter-gather I/O,
whereas discarding of data is more beneficial when forwards do have an equivalent of
scatter/gather I/O, something which all modern high-speed routers seem to have, including
the Tofino platform used for validation of the approach described in this document.

## Encapsulations for IPv6-only networks

Whereas all initial RBS proposal did either not propose specific encapsulations for
the RBS structure and/or discussed how to use RBS with the existing BIER encapsulation {{RFC8296}},
the 2022 {{I-D.xu-msr6-rbs}} describes the encapsulation of RBS into an IPv6 extension header,
in support of a forwarding plane where all packets on the wire are IPv6 packets, rewriting
per-RBS-hop the destination IPv6 address of the outer IPv6 header like pre-existing
unicast IPv6 stateless source routing solutions too ({{RFC6554}}, {{RFC8754}}).

This approach was based on the express preference desire of IPv6 operators to have a common
encapsulation of all packets on the wire for operation reasons ("IPv6 only network design") and to share
a common source-routing mechanism operating on the principle of per-steering-hop IPv6
destination address rewrite.

{{I-D.eckert-msr6-rbs}} extends this approach by adding the offset-pointer rewrite of
{{I-D.eckert-bier-rbs}} to the extension header to avoid any change in length of the
extension header, but it also includes another, RBS indepent field, the IPv6 multicast
destination address to the extension header. Only this aditional would allow for RBS
with a single extension header to be a complete IPv6 multicast source-routing solution.
BIER/BIER-TE or any encapsulation variations of RBS without such a header field would
always require to carry a full IPv6 header as a payload to provie end-to-end IPv6 multicast
service to applications.
