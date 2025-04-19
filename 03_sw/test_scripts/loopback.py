#--------------------------------------------------------------------
# simpleEthernet
# loopback.py
# Loopback test script
# 3/22/25
#--------------------------------------------------------------------

# https://scapy.net/

# Notes:
# Ethernet frame: (Preamble)(SFD)(MAC dest)(MAC source)(EtherType)(Payload)(FCS)
# MAC is currently configured to only operate on incoming packets with EtherType 0xFFFF
# Wireshark filter: eth.type == 0xFFFF 
#                   eth.dst == FF:FF:FF:FF:FF:FF

from scapy.all import Ether, sendp

class Loopback_Handler:
    def __init__(self):
        self.mac_src  = "00:00:00:00:00:00"
        self.mac_dest = "ff:ff:ff:ff:ff:ff"
        self.len_type = 0xffff
        self.payload  = b"Test, ABCDEFGHIJKLMNOPQRSTUVWXYZ, Test for full loopback from PC --> FPGA --> PC"

    def send_packet(self, loopback_en=False):
        eth = Ether(dst=self.mac_dest, src=self.mac_src, type=self.len_type)
        frame = eth / self.payload
        if (loopback_en):
            sendp(frame, iface="lo")
        sendp(frame, iface="eno1")

    def listen(self):
        pass

if __name__ == "__main__":
    handler = Loopback_Handler()

    for i in range(10):
        handler.send_packet(True)