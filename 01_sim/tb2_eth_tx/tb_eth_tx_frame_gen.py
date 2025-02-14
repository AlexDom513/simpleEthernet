#--------------------------------------------------------------------
# simpleEthernet
# tb_eth_tx_frame_gen.py
# Generate Ethernet frame for transmit testbench
# 1/30/25
#--------------------------------------------------------------------

import zlib
from scapy.all import Ether, IP, UDP, raw

def frame_gen(main=False):

    # create layers of frame
    eth_layer   = Ether(dst="ff:ff:ff:ff:ff:ff", src="02:00:00:00:00:01", type=0xFFFF)
    ip_layer = IP(dst="192.168.1.1", src="192.168.1.100")
    udp_layer = UDP(dport=12345, sport=54321)
    payload = "Hello, UDP! I'm working on this FPGA Ethernet project!"

    if (main):
        frame  = eth_layer / ip_layer / udp_layer / payload
    else:
        frame = ip_layer / udp_layer / payload
    return raw(frame)

if __name__ == "__main__":
    frame = frame_gen(True)

    # write frame bytes/info to file
    with open('0_frame_gen.txt', 'w') as file:
        bin_data = frame
        hex_data = bin_data.hex()
        for i in range(0, len(hex_data), 2):
            file.write(hex_data[i:i+2] + '\n')
        file.write('\n')
        file.write(str(hex(zlib.crc32(bin_data))))
