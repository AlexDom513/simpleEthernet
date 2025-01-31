import zlib
import numpy as np
from scapy.all import Ether, IP, UDP, raw

def packet_gen(main=False):

    # create layers of packet
    eth_layer   = Ether(dst="ff:ff:ff:ff:ff:ff", src="02:00:00:00:00:01", type=0x0800)
    ip_layer = IP(dst="192.168.1.1", src="192.168.1.100")
    udp_layer = UDP(dport=12345, sport=54321)
    payload = "Hello, UDP! I'm working on this FPGA Ethernet project!"

    if (main):
        packet  = eth_layer / ip_layer / udp_layer / payload
    else:
        packet = ip_layer / udp_layer / payload
    return raw(packet)

if __name__ == "__main__":
    packet = packet_gen(True)

    # write packet bytes/info to file
    with open('0_packet_gen.txt', 'w') as file:
        bin_data = packet
        hex_data = bin_data.hex()
        for i in range(0, len(hex_data), 2):
            file.write(hex_data[i:i+2] + '\n')
        file.write('\n')
        file.write(str(hex(zlib.crc32(bin_data))))
