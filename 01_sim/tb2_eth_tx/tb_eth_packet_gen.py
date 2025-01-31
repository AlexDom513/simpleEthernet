import zlib
import numpy as np
from scapy.all import Ether, IP, UDP, raw

def packet_gen():

    # create layers of packet
    eth_layer   = Ether(dst="ff:ff:ff:ff:ff:ff", src="02:00:00:00:00:01", type=0x0800)
    ip_layer = IP(dst="192.168.1.1", src="192.168.1.100")
    udp_layer = UDP(dport=12345, sport=54321)
    payload = "Hello, UDP!"
    frame       = eth_layer / ip_layer / udp_layer / payload

    return raw(frame)

if __name__ == "__main__":
    packet = packet_gen()

    with open('tx_expected.txt', 'w') as f:
        for byte in packet:
            f.write(hex(byte) + '\n')