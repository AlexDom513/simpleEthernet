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

from scapy.all import Ether, sendp
import threading

class Loopback_Handler:
    def __init__(self):
        self.mac_src  = "b4:2e:99:ee:a1:12"
        self.mac_dest = "ff:ff:ff:ff:ff:ff"
        self.len_type = 0xffff
        self.payload  = b"This is a test message for the loopback test!"

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

    for i in range(100):
        handler.send_packet(True)