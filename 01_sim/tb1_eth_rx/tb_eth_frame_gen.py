
import numpy as np
from scapy.all import Ether, IP, UDP

def frame_gen():

    # generate sample frame
    preamble    = np.tile([1,0,1,0,1,0,1,0], 7)
    sfd         = np.array([1, 0, 1, 0, 1, 0, 1, 1])
    eth_layer   = Ether(dst="f0:A0:ff:ff:ff:ff", src="00:00:00:00:00:00", type=0x0800)
    ip_layer    = IP(dst="192.168.1.1", src="192.168.1.100")
    udp_layer   = UDP(dport=12345, sport=54321)
    payload     = "Hello, UDP!"
    frame       = eth_layer / ip_layer / udp_layer / payload

    # create input vector
    frame_bytes = bytes(frame)
    frame_binary = np.unpackbits(np.frombuffer(frame_bytes, dtype=np.uint8))
    frame_binary = frame_binary.reshape(-1, 8)[:, ::-1].flatten() # LSBs of each byte are sent first
    frame_binary = np.concatenate((preamble, sfd, frame_binary))
    frame_binary = frame_binary.reshape((-1, 2))

    return frame_binary
