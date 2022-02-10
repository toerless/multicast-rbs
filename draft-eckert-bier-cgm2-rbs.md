---
coding: utf-8

title: Carrier Grade Minimalist Multicast (CGM2) using Bit Index Explicit Replication (BIER) with Recursive BitString Structure (RBS) Addresses
abbrev: bier-cgm2-rbs
docname: draft-eckert-bier-cgm2-rbs-01
wg: BIER
category: exp
ipr: trust200902

stand_alone: yes
pi: [toc, sortrefs, symrefs, comments]

author:
  -
       name: Toerless Eckert
       org: Futurewei Technologies USA
       street: 2220 Central Expressway
       city: Santa Clara
       code: CA 95050
       country: USA
       email: tte@cs.fau.de

normative:
  RFC791:
  RFC1112:
  RFC8279:
  RFC8296:
  I-D.ietf-bier-te-arch:

informative:
  CGM2Design:
    title: Novel Multicast Protocol Proposal Introduction
    date: 2021-10-10
    target: https://github.com/BingXu1112/CGMM/blob/main/Novel%20Multicast%20Protocol%20Proposal%20Introduction.pptx
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

--- abstract

This memo introduces the architecture of a multicast
architecture derived from BIER-TE, which this memo calls
Carrier Grade Minimalist Multicast (CGM2). It reduces
limitations and complexities of BIER-TE by replacing
the representation of the in-packet-header delivery tree
of packets through a "flat" BitString of adjacencies
with a hierarchical structure of BFR-local BitStrings 
called the Recursive BitString Structure (RBS) Address. 

Benefits of CGM2 with RBS addresses include smaller/fewer BIFT in BFR,
less complexity for the network architect and in the CGM2
controller (compared to a BIER-TE controller) and fewer packet
copies to reach a larger set of BFER.

The additional cost of forwarding with RBS addresses is
a slightly more complex processing of the RBS address
in BFR compared to a flat BitString and the novel per-hop rewrite of
the RBS address as opposed to bit-reset rewrite in BIER/BIER-TE.

CGM2 can support the traditional deployment model of BIER/BIER-TE
with the BIER/BIER-TE domain terminating at service provider
PE routers as BFIR/BFER, but it is also the intention of this document to
expand CGM2 domains all the way into hosts, and therefore
eliminating the need for an IP Multicast flow overlay,
further reducing the complexity of Multicast services using
CGM2. Note that this is not fully detailed in this version
of the document.

This document does not specify an encapsulation for CGM2/RBS
addresses. It could use existing encapsulations such as {{RFC8296}},
but also other encapsulations such as IPv6 extension headers.

--- middle

# Overview

## Introduction

Carrier Grade Minimalist Multicast (CGM2) is an architecture
derived from the BIER-TE architecture {{I-D.ietf-bier-te-arch}} with the following
changes/improvements.

CGM2 forwarding is based on the principles of BIER-TE forwarding:
It is based on an explicit, in-packet, "source routed" tree indicated
through bits for each adjacency that the packet has to
traverse. Like in BIER-TE, adjacencies can be L2 to a subnet
local neighbor in support of "native" deployment of CGM2
and/or L3, so-called "routed" adjacencies to support
incremental or partial deployment of CGM2 as needed.

The address used to replicate packets in the network is
not a flat network wide BitString as in BIER-TE, but a
hierarchical structure of BitStrings called a Recursive BitString Structure (RBS)
Address. The significance of the BitPositions (BP)
in each BitString is only local to the BIFT of the router/BFR
that is processing this specific BitString.

RBS addressing allows for a more compact representation of
a large set of adjacencies especially in the common case
of sparse set of receivers in large Service Provider Networks (SP).

CGM2 thereby eliminates the challenges in BIER {{RFC8279}} and BIER-TE having to
send multiple copies of the same packet in large SP
networks and the complexities especially for BIER-TE
(but also BIER) to engineer multiple set identifier (SI) and/or
sub-domains (SD) BIER-TE topologies for limited size BitStrings
(e.g.: 265) to cover large network topologies.

Like BIER-TE, CGM2 is intended to leverage a Controller
to minimize the control plane complexity in the network to
only a simple unicast routing underlay required only for
routed adjacencies.

The controller centric architecture
provides most easily any type of required traffic optimization
for its multicast traffic due to their need to perform
often NP-complete calculations across the whole topology:
reservation of bandwidth to support CIR/PIR traffic buffer/latency
to support Deterministic Network (DetNet) traffic, cost optimized
Steiner trees, failure point disjoint trees for higher resilience including
DetNet deterministic services.

CGM2 can be deployed as BIER/BIER-TE are specified today,
by encapsulating IP Multicast traffic at Provider Edge (PE)
routers, but it is also considered to be highly desirable
to extend CGM2 all the way into Multicast Sender/Receivers
to eliminate the overhead of an Overlay Control plane for
that (legacy) IP Multicast layer and the need to deal with
yet another IP multicast group addressing space. In this deployment option
Controller signaling extends directly (or indirectly via BFIR) into
senders.

## Encapsulation Considerations

This document does not define a specific BIER-RBS encapsulation
nor does it preclude that multiple different encapsulations
may be beneficial to better support different use-cases
or operator/user technology preferences. Instead, it discusses
considerations for specific choices.

BIER-RBS can easily re-use {{RFC8296}} encapsulation. The
RBS address is inserted into the {{RFC8296}}  BitString
field. The BFR forwarding plane needs to be configured 
(from Controller or control plane) that the BIFT-id(s) used
with RBS addresses are mapped to BIFT and forwarding
rules with RBS semantic.

SI/SD fields of {{RFC8296}} may be used as in BIER-TE,
but given that CGM2 is designed (as described in the Overview
section) to simplify multicast services, a likely and
desirable configuration would be to only use a single 
BIFT in each BFR for RBS addresses, and mapping these to
a single SD and SI 0.

IP Multicast {{RFC1112}} was defined as an extension
of IP {{RFC791}}, reusing the same network header, and
IPv6 multicast inherits the same approach. In comparison,
{{RFC8296}} defines BIER encapsulation as a
completely separate (from IP) layer 3 protocol,
and duplicates both IP and MPLS header elements into the
{{RFC8296}} header. This not only results in always
unused, duplicate header parameters (such as TC vs. DSCP), but
it also foregoes the option to use any non-considered
IPv6 extension headers with BIER and would require the
introduction of a whole new BIER specific socket API
into host operating systems if it was to be supported 
natively in hosts.

Therefore an encapsulation of RBS addresses using an
IP and/or IPv6 extension header may be more desirable
in otherwise IP and/or IPv6 only deployments, for example
when CGM2 is extended into hosts, because it would allow
to support CGM2 via existing IP/IPv6 socket APIs as long as
they support extension headers, which the most important
host stacks do today. 

# CGM2/RBS Architecture

This section describes the basic CGM2 architecture
via {{FIG-ARCH}} through its key differences over the BIER-TE
architecture.

                        Optional
       |<-IGMP/PIM->  multicast flow   <-PIM/IGMP->|
                         overlay
    
           CGM2      [CGM2  Controller] 
    control plane   .  ^      ^     ^   
                   .  /       |      \     BIFT configuration
         ..........  |        |       |    per-flow RBS setup
        .            |        |       |   
       .             v        v       v
    Src (-> ... ) -> BFIR-----BFR-----BFER -> (... ->) Rcvr
    
                    |<----------------->|
              CGM2 with RBS-address forwarding plane
    
     |<.............. <- CGM domain ---> ...............|
    
                  |<--------------------->|
                  Routing underlay (optional)
{: #FIG-ARCH title="CGM2/RBS Architecture"}


In the "traditional" option, when deployed with a domain
spanning from BFIR to BFER, the CGM2 architecture is very
much like the BIER-TE architecture, in which the BIER-TE forwarding rules
for (BitString,SI,SD) addresses are replaced by the
RBS address forwarding rules.

The CGM2 Controller replaces the BIER-TE controller,
populating during network configuration the BIFT,
which are very much like BIER-TE BIFT, except that
they do not cover a network-wide BP address space, but
instead each BFR BIFT only needs as many BP in its BIFT
as it has link-local adjacencies, and in partial deployments
also additional L3 adjacencies to tunnel across non-CGM
capable routers.

Per-flow operations in this "traditional" option is very much as in
BIER/BIER-TE, with the CGM2 controller determining the
RBS address (instead of the BIER-TE (BitString,SI,SD)) to be
imposed as part of the RBS address header (compared
to the BIER encapsulation {{RFC8296}}) on the BFIR. 

To eliminate the need for an IP Multicast flow overlays,
a CGM2 domain may extend all the way into Sender/Receiver
hosts. This is called "end-to-end" deployment model.
In that case, the sender host and CGM2 controller
collaborate to determine the desired receivers for
a packet as well as desired path policy/requirements,
the controller indicates to the sender of the packet
the necessary RBS address and address of the BFIR,
and the Sender imposes an appropriate RBS address header
together with a unicast encapsulation towards the BFIR.

CGM2 is also intended so especially simplify
controller operations that also instantiate QoS policies
for multicast traffic flows, such as bandwidth and
latency reservations (e.g.: DetNet). As in BIER-TE, this
is orthogonal to the operations of the CGM2/RBS address
forwarding operations and will be covered in separate documents.

# CGM2/RBS forwarding plane

Instead of a (flat) BitString as in BIER-TE
that use a network wide shared BP address space for
adjacencies across multiple BFR, CGM2 uses a structured
address built from so-called RecursiveUnits (RU) that contain BitStrings,
each of which is to be parsed by exactly one BFR along the delivery
tree of the packet.

The equivalent to a BIER/BIER-TE BitString is
therefore called the RecursiveUnit BitString Structure (RBS) Address.
Forwarding for CGMP2 is therefore also called RBS forwarding.

## RBS BIFT

RBS BIFT as shown in {{FIG-RBS-BIFT}} are, like BIER-TE BIFT, tables that are indexed by
BP, containing for each BP an adjacency.  The core difference over BIER-TE
BIFT is that the BP of the BIFT are all local to the BFR,
whereas in BIER-TE, the BP are shared across a BIER-TE domain,
each BFR can only use a subset the BP for its own adjacencies,
and only in some cases can BP be shared for adjacencies across
two (or more) BFR.  Because of this difference, most of the complexities
of BIER-TE BIFT are not required with BIER-RBS BIFT, see {{complexities}}.

    +--+---------+-------------+
    |BP|Recursive|    Adjacency|
    +--+---------+-------------+
    | 1|        1|adjacenct BFR|
    +--+---------+-------------+
    | 2|        0|    punt/host|
    +--+---------+-------------+
    |     .....    ...         |
    +--+---------+-------------+
    | N|      ...|         ... |
    +--+---------+-------------+
{: #FIG-RBS-BIFT title="RBS BIFT"}


An RBS BIFT has a configured number of N addressable BP entries.
When a BFR receives a packet with an RBS address,
it expects that the BitString inside the RBS address that
needs to be parsed by the BFR (see {{RBS-address}} has a length that matches N
according to the encapsulation used for the RBS address.
Therefore, N MUST support configuration in increments of the supported size
of the BitString in the encapsulation of the RBS Address.
In the reference encoding (see {{RBS-address}}), the increment for N is 1 (bit).
If an encapsulation would call for a byte accurate encoding of the
BitString, N would have to be configurable in increments of 8.

BFR MUST support a value of N larger than the maximum number of adjacencies
through which RBS forwarding/replication of a single packet is required,
such as the number of physical interfaces on BFR that are intended to be
deployed as a Provider Core (P) routers.

RBS BIFT introduce a new "Recursive" flag for each BP. These
are used for adjacencies to other BFR to indicate that the
BFR processing the packet RBS address BitString also has to
expect for every BP with the recursive flag set another
RU inside the RBS address.

## Reference encoding of RBS addresses {#encoding}

Structure elements of the RBS Address and its components
are parameterized according to a specific encapsulation
for RBS addresses, such as the total size of the TotalLen
field and the unit in which it is counted (see {{RBS-address}}).
These parameters are outside the scope of this document. Instead,
this document defines example parameters that together form the 
so called "Reference encoding of RBS addresses". This encoding 
may or may not be adopted for any particular encapsulation
of RBS addresses.

## RBS Address {#RBS-address}

An RBS address is structured as shown in {{FIG-RBS}}.

    +----------+-----+---------------+---------+
    | TotalLen | Rsv | RecursiveUnit | Padding |
    +----------+-----+---------------+---------+
               .                     .
                .... TotalLen .......
{: #FIG-RBS title="RBS Address"}


TotalLen counts in some unit, such as bits, nibbles or
bytes the length of the RBS Address excluding
itself and Padding. For the reference encoding, TotalLen
is an 8-bit field that counts the size of the RBS address
in bits, permitting for up to 256 bit long RBS addresses.

In case additional, non-recursive flags/fields are determined
to be required in the RBS Address, they should be encoded
in a field between TotalLen and RecursiveUnit, which is
called Rsv. In the reference encoding, this field has a length
of 0.

Padding is used to align the RBS address as required
by the encapsulation. In the reference encoding, this alignment
is to 8 bits (byte boundaries).
Therefore, Padding (bits) = (8 - TotalLen % 8).

### RecursiveUnit

The RecursiveUnit field is structured as shown in {{FIG-RBS-RU}}.

    +-+-+-+-+-+  -+-+-+-+-+-+-+-+-+  -+-+-+-+-+-+-+-+     -+
    | BitString...| AddressingField...| RecursiveUnit 1...M|
    +-+-+-+-+-+  -+-+-+-+-+-+-+-+-+  -+-+-+-+-+-+-+-+-    -+
{: #FIG-RBS-RU title="RBS RecursiveUnit"}


The BitString field indicates the bit positions (BPs) 
to which the packet is to be replicated using the
BIFT of the BFR that is processing the Recursive unit. 

For each of M BP set in the BitString of the RecursiveUnit for
which the Recursive flag is set in the BIFT of the BFR, the
RecursiveUnit contains a RecursiveUnit i, i=1...M, in order of increasing BP index.

If adjacencies between BFR are not configured as recursive in the BIFT,
this recursive extraction does not happen for an adjacency, no
RecursiveUnit i has to be encoded for the BP,
and BFRs across such adjacencies would have to share the
BP of a common BIFT as in BIER-TE. This option is not further
discussed in this version of the document.

### AddressingField

The AddressingField of an RBS address is structured as shown in
{{FIG-RBS-AF}}.

    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+   +-+-+-+-+-+-+-+-+
    |      L1       |     L2        |...|      L(M-1)   |
    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+   +-+-+-+-+-+-+-+-+
{: #FIG-RBS-AF title="RBS AddressingField"}

The AddressingField consists of one or more fields Li,
i=1...(M-1).  Li is the length of RecursiveUnit i for the
i'th recursive bit set in the BitString preceding it. 

In the reference encoding, the lengths are
8-bit fields indicating the length of RecursiveUnits in bits.

The length of the M'th RecursiveUnit is not explicitly
encoded but has to be calculated from TotalLen.

# BIER-RBS Example

{{FIG-E-TOPO}} shows an example for RBS forwarding.


                   +-+     +-+      +-+
                   | |-----| |------|C|-=> Client2
                   +-+     +-+      +-+
                  /   \      \   /=>/ \
                 /     \      \ /     |
                +-+    +-+    +-+    +-+    
     Client1 =>-|B|-=>-|R|-=>-|S|-=>-|D|-=> Client3
                +-+    +-+    +-+    +-+
                          \         /
                           \     +-+
                            \-=>-|E|-=> Client4
                                 +-+
{: #FIG-E-TOPO title="Example Network Topology"}


A packet from Client1 connected to BFIR B is intended to be
replicated to Client2,3,4. The example initially assumes
the traditional option of the architecture, in which the imposition of the 
header for the RBS address happens on BFIR B, for example
based on functions of an IP multicast flow overlay. 

A controller determines that the packet should be forwarded
hop-by-hop across the network as shown in {{FIG-E-TREE}}.

    Client 1 ->B(impose BIER-RBS)
                =>R(
                   => E (dispose BIER-RBS)
                        => Client4
                   => S(
                       =>C (dispose BIER-RBS)
                           => Client2
                       =>D (dispose BIER-RBS)
                           => Client3
                        )
                   )
{: #FIG-E-TREE title="Desired example forwarding tree"}


## BFR B

The 34 bit long (without padding) RBS address shown in {{FIG-E-B}}
is constructed to represent the desired tree from {{FIG-E-TREE}} and is
imposed at B onto the packet through an appropriate header supporting the
reference encoding of RBS addresses.

             .............. RecursiveUnit .................
            .                                              .
    +-------+----+-----+-----+-----+----+-----+------+-----+-----+
    |Tlen:34|B:01|R:011|L1:10|S:011|L1:3|C:001|D:0001|E:001|Pad:6|
    +-------+----+-----+-----+-----+----+-----+------+-----+-----+
      8bit   2bit  3bit 8bit  3bit  8bit 3bit  4bit   3bit  6bit
{: #FIG-E-B title="RBS Address imposed at BFIR-B"}


In {{FIG-E-B}} and further the illustrations of RBS addresses, BitStrings are
preceded by the name of the BFR for whom they are destined
and their values are shown as binary with the lowest BP 1
starting on the left. TotalLength (Tlen:),
AddressingField (L1:) and Padding (Pad:) fields are shown
with decimal values.

RBS forwarding on B examines this address based 
on its RBS BIFT with N=2 BP entries, which is shown in
{{FIG-E-B-BIFT}}.

    +--+---------+---------+
    |BP|Recursive|Adjacency|
    +--+---------+---------+
    | 1|        0| client1 |
    +--+---------+---------+
    | 2|        1|       R |
    +--+---------+---------+
{: #FIG-E-B-BIFT title="BIER-RBS BIFT on B"}


This results in the parsing of the RBS address as shown in
{{FIG-E-B2}}, which shows that B does not need (nor can)
parse all structural elements, but only those relevant
to its own RBS forwarding procedure.

             ......... RecursiveUnit ...............
            .                                       .
            .     ......,.. RecursiveUnit 1 .........
            .    .                                  .
    +-------+----+----------------------------------+-----+
    |Tlen:34|B:01|R:01100001010011000000110010001001|Pad:6|
    +-------+----+----------------------------------+-----+
      8bit   2bit  32bit                             6bit
{: #FIG-E-B2 title="RBS Address as processed by BFIR-B"}


There is only one BP towards BFR R set in the BitString B:01,
so the RecursiveUnit 1 follows directly after the end
of the BitString B:01 and it covers the whole Tlen - length
of BitString (34 - 2 = 32 bit). 

B rewrites the RBS address by replacing the RecursiveUnit with RecursiveUnit 1
and adjusts the Padding to zero bits. The resulting RBS address
is shown in {{FIG-E-R}}. It then sends
the packet copy with that rewritten RBS address to BFR R.

## BFR R

BFR R receives from BFR B the packet with that RBS address
shown in {{FIG-E-R}}.

             .............. RecursiveUnit ............
            .                                         .
    +-------+-----+-----+-----+----+-----+------+-----+
    |Tlen:32|R:011|L1:18|S:011|L1:3|C:001|D:0001|E:001|
    +-------+-----+-----+-----+----+-----+------+-----+
      8bit    3bit  8bit  3bit 8bit 3bit  4bit   3bit    
                        .                       .     .
                         . RecursiveUnit 1...... .....
                                                   .
                                RecursiveUnit 2 ...
{: #FIG-E-R title="RBS Address processed by BFR-R"}


BFR R parses the RBS Address as shown in {{FIG-E-R2}} using its
RBS BIFT of N=3 BP entries shown in {{FIG-E-R-BIFT}}.

             .............. RecursiveUnit ............
            .                                         .
    +-------+-----+-----+--------------------+-----+
    |Tlen:32|R:011|L1:18|S:011000000110010001|E:001|
    +-------+-----+-----+--------------------+-----+
      8bit    3bit  8bit  18bit               3bit    
                        .                    .     .
                         . RecursiveUnit 1... .....
                                                .
                             RecursiveUnit 2 ...
{: #FIG-E-R2 title="RBS Address processed by BFR-R"}

Because there are two recursive BP set in the BitString for R,
one for BFR S and one for BFR E, one Length field L1 is required in
the AddressingField, indicating the length of the
RecursiveUnit 1 for BFR S, followed by the remainder of
the RBS address being the RecursiveUnit 2 for BFR E.

    +--+---------+---------+
    |BP|Recursive|Adjacency|
    +--+---------+---------+
    | 1|        1|       B |
    +--+---------+---------+
    | 2|        1|       S |
    +--+---------+---------+
    | 3|        1|       E |
    +--+---------+---------+
{: #FIG-E-R-BIFT title="RBS BIFT on BFR R"}

                                       
BFR R accordingly creates one copy for BFR S using
RecursiveUnit 1, and only copy for BFR E using
RecursiveUnit 2, updating Padding accordingly for each
copy.

## BFR S

BFR S receives from BFR B the packet and parses the
RBS address as shown in {{FIG-E-S}} using its RBS BIFT
of N=3 BP shown in {{FIG-E-S-BIFT}}.

             .... RecursiveUnit ....
            .                       .
    +-------+-----+----+-----+------+-----+
    |Tlen:18|S:011|L1:3|C:001|D:0001|Pad:6|
    +-------+-----+----+-----+------+-----+
      8bit    3bit 8bit  3bit   4bit  3bit 
                       .    . .      .
                        ....   ......
         RecursiveUnit 1 .      .
                                .
         RecursiveUnit 2 .......
{: #FIG-E-S title="RBS Address processed by BFR-S"}


    +--+---------+---------+
    |BP|Recursive|Adjacency|
    +--+---------+---------+
    | 1|        1|       R |
    +--+---------+---------+
    | 2|        1|       C |
    +--+---------+---------+
    | 3|        1|       D |
    +--+---------+---------+
{: #FIG-E-S-BIFT title="RBS BIFT on BFR-S"}

BFR S accordingly sends one packet copy with RecursiveUnit 1
in the RBS address to BFR C and a second packet copy with
RecursiveUnit 2 to BFR D.

## BFR C

BFR C receives from BFR S the packet and parses the
RBS address according to its N=3 BP entries BIFT (shown in
{{FIG-E-C-BIFT}}) as shown in {{FIG-E-C}}.

    +-------+-----+-----+
    |Tlen:3 |C:001|Pad:5|
    +-------+-----+-----+
      8bit    3bit 5bi
{: #FIG-E-C title="RBS Address processed by BFR-C"}


    +--+---------+-------------+
    |BP|Recursive|    Adjacency|
    +--+---------+-------------+
    | 1|        1|           S |
    +--+---------+-------------+
    | 2|        1|           D |
    +--+---------+-------------+
    | 3|        0|  local_decap|
    +--+---------+-------------+
{: #FIG-E-C-BIFT title="RBS BIFT on BFR-C"}

BFR S accordingly creates one packet copy for BP 3
where the RBS address encapsulation is disposed of,
and the packet is ultimately forwarded to Client 2,
for example because of an IP multicast payload
for which the multicast flow overlay identifies
Client 2 as an interested receiver, as in BIER/BIER-TE.

To avoid having to use an IP flow overlay, the BIFT
could instead have one BP allocated for every non-RBS
destination, in this example BP 3 would then explicitly
be allocated for Client 2, and instead of disposing
of the RBS address encapsulation, BFR C would
impose or rewrite a unicast encapsulation to make the packet
become a unicast packet directed to Client 2. This option
is not further detailed in this version of the document.

## BFR D

The procedures for processing of the packet on BFR D
are very much the same as on BFR C.  {{FIG-E-D}} shows
the RBS address at BFR D, {{FIG-E-D-BIFT}} shows
the N=4 bit RBS BIFT of BFR D.

    +-------+------+-----+
    |Tlen:4 |D:0001|Pad:4|
    +-------+------+-----+
      8bit    4bit   4bit
{: #FIG-E-D title="RBS Address processed by BFR-D"}


    +--+---------+-------------+
    |BP|Recursive|    Adjacency|
    +--+---------+-------------+
    | 1|        1|           S |
    +--+---------+-------------+
    | 2|        1|           C |
    +--+---------+-------------+
    | 3|        1|           E |
    +--+---------+-------------+
    | 4|        0|  local_decap|
    +--+---------+-------------+
{: #FIG-E-D-BIFT title="RBS BIFT on BFR-D"}


## BFR E

The procedures for processing of the packet on BFR E
are very much the same as on BFR C and D.  {{FIG-E-E}} shows
the RBS address at BFR D, {{FIG-E-E-BIFT}} shows
the N=E bit RBS BIFT of BFR E.

    +-------+-----+-----+
    |Tlen:3 |E:001|Pad:5|
    +-------+-----+-----+
      8bit    3bit   5bit
{: #FIG-E-E title="RBS Address processed by BFR-E"}


    +--+---------+-------------+
    |BP|Recursive|    Adjacency|
    +--+---------+-------------+
    | 1|        1|           R |
    +--+---------+-------------+
    | 2|        1|           D |
    +--+---------+-------------+
    | 3|        0|  local_decap|
    +--+---------+-------------+
{: #FIG-E-E-BIFT title="RBS BIFT on BFR-E"}


# RBS forwarding Pseudocode

The following example RBS forwarding Pseudocode assumes
the reference encoding of bit-accurate length of BitStrings
and RecursiveUnits as well as 8-bit long TotalLen and AddressingField
Lengths. All packet field addressing and address/offset calculations
is therefore bit-accurate instead of byte accurate (which is what most
CPU memory access today is).

    void ForwardRBSPacket (Packet)
    {
      RBS = GetPacketMulticastAddr(Packet); 
      Total_len = RBS;
      Rsv = Total_len + length(Total_Len);
      BitStringA = Rsv + length(Rsv);
      AddressingField =  BitStringA + BIFT.entries;
    
      // [1] calculate number of recursive bits set in BitString
      CopyBitString(*BitStringA, *RecursiveBits, BIFT.entries);
      And(*RecursiveBits,*BIFTRecursiveBits, BIFT.entries);
      N = CountBits(*RecursiveBits, BIFT.entries);
    
      // Start of first RecursiveUnit in RBS address
      // After AddressingField array with 8-bit length fields
      RecursiveUnit = AddressingField + (N - 1) * 8;
    
      RemainLength = *Total_len - length(Rsv)
                     - BIFT.entries;
    
      Index = GetFirstBitPosition(*BitStringA);
      while (Index) {
        PacketCopy = Copy(Packet);
    
        if (BIFT.BP[Index].recursive) {
          if(N == 1) {
            RecursiveUnitLength = RemainLength;
          } else {
            RecursiveUnitLength = *AddressingField;
            N--;
            AddressingField += 8;
            RemainLength -= RecursiveUnitLength;
            RemainLength -= 8; // 8 bit of AddressingField
          }
          RewriteRBS(PacketCopy, RecursiveUnit, RecursiveUnitLength);
          SendTo(PacketCopy, BIFT.BP[Index].adjacency);
    
          RecursiveUnit += RecursiveUnitLength;
        } else {
          DisposeRBSheader(PacketCopy);
          SendTo(PacketCopy, BIFT.BP[Index].adjacency);
        }
        Index = GetNextBitPosition(*BitStringA, Index);
      }
{: #FIG-PSEUDOCODE title="RBS address forwarding Pseudocode"}

    
Explanations for {{FIG-PSEUDOCODE}}.

RBS is the (bit accurate) address of the RBS address in packet
header memory.  BitStringA is the address of the RBS address
BitString in memory.  length(Total_Len) and length(Rsv) are the bit length of the two RBS 
address fields, e.g.: 8 bit and 0 bit for the reference encoding.

The BFR local BIFT has a total number of BIFT.entries
addressable BP 1...BIFTentries. The BitString therefore
has BIFT.entries bits.

BIFT.RecursiveBits is a BitString pre-filled by the control
plane with all the BP with the recursive flag set. This is constructed
from the Recursive flag setting of the BP of the BIFT. The
code starting at \[1] therefore counts the number of
recursive BP in the packets BitString.

Because the AddressingField does not have an entry for the
last (or only) RecursiveUnit, its length has to be calculated
by taking TotalLen into account. 

RewriteRBS needs to replace RBS address with the
RecursiveUnit address, keeping only Rsv, recalculating
TotalLen and adding appropriate Padding.

For non-recursive BP, the Pseudocode assumes disposition of the
RBSheader. This is not strictly necessary but non-disposing
cases are outside of scope of this version of the document.

# Operational and design considerations (informational)

## Comparison with  BIER-TE / BIER {#comparison}

This section discusses informationally, how and where 
CGM2 can avoid different complexities of BIER/BIER-TE,
and where it introduces new complexities.

### Eliminating the need for large BIFT

In a BIER domain with M BFER, every BFR requires M
BIFT entries. If the supported BSL is N and M > 2 ^ N,
then S = (M / 2 ^ N) set indices (SI) are required,
and S copies of the packet have to be sent by the BFIR
to reach all targeted BFER.

In CGM2, the number of BIFT entries does not need
to scale with the number of BFER or paths through
the network, but can be limited to only the number
of L2 adjacencies of the BFR. Therefore CGM2 requires
minimum state maintenance on each BFR, and multiple
SI are not required.

### Reducing number of duplicate packet copies across BFR

If the total size of an RBS encoded delivery tree is
larger than a supported maximum RBS header size, then
the CGM2 controller simply needs to divide the tree
into multiple subtrees, each only addressing a part
of the BFER (leaves) of the target tree and pruning
any unnecessary branches. 

                 B1
                /  \
          B2    B3
            /   \  /  \
           /     \/    \
         B4      B5     B6
       /..|     /  \    |..\
    B7..B99  B100..B200 B201...B300
{: #FIG-SMPLT title="Simple Topology Example"}


Consider the simple topology in {{FIG-SMPLT}} and a multicast packet
that needs to reach all BFER B7...B300. Assume that
the desired maximum RBM header size is such that a
RBS address size of <= 256 bits is desired. The CGM2
controller could create an RBS address
B1=>B2=>B4=>(B7..B99), for a first packet, an
RBS address B1=>B3=>B5=>(B100..B200) for a second
packet and a third RBS address B1=>B3=>B6=>B201...B300.

The elimination of larger BIFT state in BFR
through multiple SI in BIER/BIER-TE does come at
the expense of replicating initial hops of a tree
in RBS addresses, such as in the example the encoding
of B1=>B3 in the example. 

Consider that the assignment of BFIR-ids with BIER
in the above example is not carefully engineered. It is
then easily possible that the BFR-ids for B7..B99 are not
sequentially, but split over a larger BFIR-id space.
If the same is true for all BFER, then it is possible
that each of the three BFR B4,B5 and B6 has attached
BFER from three different SI and one may need to send
for example three multiple packets to B7 to
address all BFER B7..B99 or to B5 to address all
B100..B200 or B6 to address all B201...B300. These
unnecessary duplicate packets across B4, B5 or B6 are
because of the addressing principle in BIER and are not
necessary in CGM2, as long as the total length of an RBS
address does not require it.

For more analysis, see {{analysis}}.

### BIER-TE forwarding plane complexities {#complexities}

BIER-TE introduces  forwarding plane complexities to allow
reducing the BSL required. While all of these
could be supported / implemented with CGM2, this
document contends that they are not necessary, therefore
providing significant overall simplifications.
 
+ BIER-TE supports multiple adjacencies in a single BIFT Index
  to allow compressing multiple adjacencies into a single Index
  for traffic that is known to always require replications
  to all those adjacencies (such as when flooding TV traffic).

+ BIER-TE support ECMP adjacencies which
  have to calculate which out of 2 or more possible adjacencies
  a packet should be forwarded to.

+ BIER-TE supports special Do-Not-Clear (DNC) behavior of
  adjacencies to permit reuse of such a bit for adjacencies
  on multiple consecutive BFR. This behavior specifically
  also raises the risk of looping packets.

### BIER-TE controller complexities

BIER-TE introduces BIER-TE controller plane mechanisms
that allow to reuse bits of the flat BIER-TE BitStrings
across multiple BFR solely to reduce the number of BP
required but without introducing additional complexities
for the BIER-TE forwarding plane.

+ Shared BP for all Leaf BFR.

+ Shared BP for both Interfaces of p2p links.

+ Shared bits for multi-access subnets (LANs).

These bit-sharing mechanisms are unnecessary
and inapplicable to CGM2 because there is no need to
share BP across the BIFT of multiple BFR.

### BIER-TE specification complexities

The BIER-TE specification distinguishes between forward (link scope)
and routed (underlay routed) adjacencies to highlight, explain
and emphasize on the ability of BIER-TE to be deployed in an overlay fashion
especially also to reduce the necessary BSL, even
when all routers in the domain could or do support BIER-TE.

In CGM2, routed adjacencies are considered to be only
required in partial deployments to forward across non-CGM2
enabled routers. This specification does therefore not
highlight link scope vs. routed adjacencies as core
distinct features. 

### Forwarding plane complexity

CGM2 introduces some more processing calculation steps to extract
the BitString that needs to be examined by a BFR from
the RBS address. These additional steps are considered
to be non-problematic for todays programmable
forwarding planes such as P4. 

Whereas BIER-TE clears bit on each hops processing,
CGM2 rewrites the address on every hop by extracting the recursive
unit for the next hop and make it become the packet copies
address. This rewrite shortens the RBS address. This hopefully
has only the same complexity as (tunnel) encapsulations/decapsulations
in existing forwarding planes.


## CGM2 / RBS controller considerations

TBD. Any aspects not covered in {{comparison}}.

## Analysis of performance gain with CGM2 {#analysis}

TBD: Comparison of number of packets/header sizes required
in large real-world operator topology between BIER/BIER-TE and CGM2.
Analysis: Gain in dense topology

Topology description:
1. Typical topology of Beijing Mobile in China.
2. All zones dual homing access to backbone.
3. Core layer: 4 nodes full mesh connected
4. Aggregation layer: 8 nodes are divided into two layers, with full interconnection between the layers and dual homing access to the core layer on the upper layer.
5. Aggregation rings: 8 rings, 6 nodes per ring
6. Access rings: 3600 nodes, 18 nodes per ring

                                        ┌──────┐          ┌──────┐
                                        │      ├──────────┤      │
                                       /└──────┘\        /└──────┘\   Interconnected
                                      /   / | \  \      /  / | \   \   BackBone
                             ┌──────┐/   /  |  \  \    /  /  |  \   \┌──────┐
                             │      │   /   |   \  \  /  /   |   \   │      │
                             └───┬──┘  /    |    \  \/  /    |    \  └─┬────┘
                                 │    /     |     \ /\ /     |     \   │
                              ┌──┴───┐      |      /  \      |      ┌──┴───┐
                              │      │------------+ \/ +------------│      │
                              └──────┘\     |       /\       |     /└──────┘
                                       \    |      /  \      |    /
                                        \ ┌──────┐/    \┌──────┐ /
                                         \│      ├──────┤      │/
                                          └───┬──┘      └───┬──┘
                                              │   \     /   │  Dual Return Access
                                              │    \   /    │
                                              │     \ /     │
                                              │      /      │
                                              │     / \     │
                                            ┌─┴───┐/   \┌───┴─┐
                                            │     ├─────┤     │
                                            └─┬───┘\   /└───┬─┘
                                              │     \ /     │  Core Layer
                                              │      /      │
                                              │     / \     │
                                            ┌─┴───┐/   \┌───┴─┐
                                           /│     ├─────┤     │\
                                          / └──┬──┘\   /└──┬──┘ \
                                         /     │\   \ /   /│     \   Zone1
                                        /      │ \   \   / │      \
                                       /       │  \ / \ /  │       \
                                      /   +----│---+   +---│----+   \
                                     /   /     │    \ /    │     \   \
                                    /   /      │     +     │      \   \
                                   /   /       │    / \    │       \   \
                                 ┌───┐/       ┌┴──┐/   \┌──┴┐       \┌───┐
                                 │   │\      /│   │     │   │\      /│   │
                                 └─┬─┘ \    / └─┬─┘\   /└─┬─┘ \    / └─┬─┘  Aggregation Layer
                                   │    \  /    │   \ /   │    \  /    │
                                   │     \/     │    /    │     \/     │
                                   │     /\     │   / \   │     /\     │
                                 ┌─┴─┐  /  \  ┌─┴─┐/   \┌─┴─┐  /  \  ┌─┴─┐
                                 │   │--    --│   │     │   │--    --│   │
                                 └───┘        └───┘\   /└───┘\       └───┘
                                              / | \ \ /  / |  \
                                             /  |  \ \  /  |   \
                                            /   |   / \/   |    \
                                           / +--|--+ \/+---|---+ \
                                          / /   |    /\    |    \ \
                                       ┌───┐   ┌┴──┐/  \┌───┐   ┌───┐   ASBR
                                       │   │   │   │    │   │   │   │
                                       └─┬─┘   └─┬─┘    └─┬─┘   └─┬─┘
                                         │       │        │       │  
                                         │       │        │       │  
                                       ┌─┴─┐   ┌─┴─┐    ┌─┴─┐   ┌─┴─┐
                                       │   │   │   │    │   │   │   │
                                       └─┬─┘   └─┬─┘    └─┬─┘   └─┬─┘
                                         │       │        │       │  
                                         │       │ 8Rings │       │  
                                       ┌─┴─┐   ┌─┴─┐ ...┌─┴─┐   ┌─┴─┐
                                       │   │---│   │    │   │---│   │
                                   ----└───┘   └───┘    └───┘\  └───┘
                                  /   /   \  \   |  \       \ \    |  \
                                /    /     \  \  |   \       \ +---|-+ \
                               /    /       \  +-|---+\       \    |  \ \   
                             /     /         \   |    \\       \   |   \ \   
                            /     /           \  |     \\       \  |    \ \  
                           /     /             \ |      \\       \ |     \ \ 
                      ┌───┐   ┌───┐           ┌───┐   ┌───┐       ┌───┐   ┌───┐ CSBR
                      │   │   │   │           │   │   │   │       │   │   │   │ 
                      └─┬─┘   └─┬─┘           └─┬─┘   └─┬─┘       └─┬─┘   └─┬─┘ 
                        │       │    Access     │       │           │       │   
                        │       │    Rings      │       │           │       │   
                      ┌─┴─┐   ┌─┴─┐  ...      ┌─┴─┐   ┌─┴─┐       ┌─┴─┐   ┌─┴─┐ 
                      │   │   │   │           │   │   │   │       │   │   │   │ 
                      └─┬─┘   └─┬─┘           └─┬─┘   └─┬─┘       └─┬─┘   └─┬─┘ 
                        │       │               │       │           │       │   
                        │       │               │       │           │       │   
                      ┌─┴─┐   ┌─┴─┐           ┌─┴─┐   ┌─┴─┐       ┌─┴─┐   ┌─┴─┐ 
                      │   │   │   │           │   │   │   │       │   │   │   │ 
                      └───┘...└───┘           └───┘...└───┘       └───┘...└───┘ 

Comparison notes:
1. CGM2: We randomly select egress points as group members, with the total number ranging from 10 to 28800 (for sake of simplicity, we assume merely one client per egress point). The egress points are randomly distributed in the topology with 10 runs for each value, showing the average result in our graphs（as below）. The total number of samples is 60
2. BIER: We divide the overall topology into 160 BIER domains, each of which includes 180 egress points, providing the total of 28000 egress points.
3. Simulation: In order to compare the BIER against the in-packet tree encoding mechanism, we limit the size of the header to 256 bits (the typical size of a BIER header).

![image](https://user-images.githubusercontent.com/92767820/153325850-8a4d5887-98ea-45fc-bd66-a279da65fba7.png)



Conclusion: 
1. BIER reaches its 160 packet replication limit at about 500 users, while the in-packet tree encoding reaching its limit of 125 replications at about 12000 users. And the following decrease of replications is caused by the use of node-local broadcast as a further optimization.
2. For the sake of comparison, the same 256-bit encapsulation limit is imposed on CGM2, but we can completely break the 256-bit encapsulation limit, thus allowing the source to send fewer multicast streams.
3. CCGM2 encoding performs significantly better than BIER in that it requires less packet replications and network bandwidth.


## Example use case scenarios

TBD.

# Acknowledgements

This work is based on the design published by Sheng Jiang, Xu Bing, Yan Shen, Meng Rui, Wan Junjie and Wang Chuang \{jiangsheng\|bing.xu\|yanshen\|mengrui\|wanjunjie2\|wangchuang\}@huawei.com, see {{CGM2Design}}.

# Security considerations

TBD.

# Changelog

\[RFC-Editor: please remove this section].

This document is written in https://github.com/cabo/kramdown-rfc2629 markup language.
This documents source is maintained at https://github.com/toerless/bier-cgm2-rbs,
please provide feedback to the appropriate IETF mailing list and submit an Issue
to the GitHub.

00 - Initial version from {{CGM2Design}}.

