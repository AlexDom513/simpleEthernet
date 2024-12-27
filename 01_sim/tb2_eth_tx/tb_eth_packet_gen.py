import zlib
import numpy as np
from scapy.all import Ether, IP, UDP, raw

def packet_gen():

    # create layers of packet
    ip_layer = IP(dst="192.168.1.1", src="192.168.1.100")
    udp_layer = UDP(dport=12345, sport=54321)
    payload = "Hello, UDP!"

    # combine the layers
    udp_packet = ip_layer / udp_layer / payload

    return raw(udp_packet)

if __name__ == "__main__":
    packet = packet_gen()

    for byte in packet:
        print(hex(byte))