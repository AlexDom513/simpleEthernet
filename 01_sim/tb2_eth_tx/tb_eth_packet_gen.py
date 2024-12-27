import zlib
import numpy as np
from scapy.all import IP, UDP, raw

def packet_gen():

    # create layers of packet
    ip_layer = IP(src="192.168.1.1", dst="192.168.1.2")  # Source and destination IP addresses
    udp_layer = UDP(sport=1234, dport=5678)              # Source and destination ports
    data = "Hello, this is a test UDP packet!"           # Payload (raw data)

    # Combine the layers
    udp_packet = ip_layer / udp_layer / data

    return raw(udp_packet)

if __name__ == "__main__":
    packet = packet_gen()

    for byte in packet:
        print(hex(byte))