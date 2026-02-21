**Wireshark is a helpful platform for analyzing network traffic.**

We can analyze it in two ways: 1. live capturing traffic, 2. Opening saved capture files.

If one wants to see the information of the captured file, there are two ways:

1. Statistic --> Capture file properties
   
2. By clicking the pcap icon located on the left button

Packet Dissection is also known as protocol dissection. In the wireshark, when you click on a packet that will show you the information about it.

We can see seven distinct layers to the packet: frame/packet, source [MAC], source [IP], protocol, protocol errors, application protocol, and application data. 

# Packet Analysis – Group Detection Categories

This project classifies network packets into specific diagnostic groups based on analysis results.

## Groups Overview

| Group       | Info                          |
|------------|--------------------------------|
| Checksum   | Checksum errors detected       |
| Deprecated | Deprecated protocol usage      |
| Comment    | Packet comment detection       |
| Malformed  | Malformed packet detection     |

---

## Description

The system analyzes captured network traffic and categorizes packets into the following groups:

### 1. Checksum
Detects packets with invalid or incorrect checksum values.

### 2. Deprecated
Identifies usage of outdated or deprecated protocols.

### 3. Comment
Flags packets that contain embedded comments.

### 4. Malformed
Detects structurally invalid or corrupted packets.

---

## Purpose

The goal of this classification is to:
- Improve packet inspection clarity
- Identify potential security risks
- Detect protocol misuse
- Highlight corrupted traffic

---

## Usage

1. Capture or load a `.pcap` / `.pcapng` file.
2. Run the analysis tool.
3. Review packets grouped under the categories above.
4. Investigate flagged packets as needed.

---

## Example Output Structure



