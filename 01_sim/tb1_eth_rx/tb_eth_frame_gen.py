import zlib
import numpy as np
from scapy.all import Ether, IP, UDP

# https://crccalc.com/?crc=123456789&method=&datatype=hex&outtype=hex

def frame_gen():

    # generate sample frame
    preamble    = np.tile([1,0,1,0,1,0,1,0], 7)
    sfd         = np.array([1, 0, 1, 0, 1, 0, 1, 1])
    eth_layer   = Ether(dst="f0:A0:ff:ff:ff:ff", src="00:00:00:00:00:00", type=0x0800)
    ip_layer    = IP(dst="192.168.1.1", src="192.168.1.100")
    udp_layer   = UDP(dport=12345, sport=54321)
    payload     = "Hello, UDP!"
    frame       = eth_layer / ip_layer / udp_layer / payload

    # write frame bytes/info to file
    # with open('expected.txt', 'w') as file:
    #     bin_data = raw(frame)
    #     hex_data = bin_data.hex()
    #     for i in range(0, len(hex_data), 2):
    #         file.write(hex_data[i:i+2] + '\n')
    #     file.write('\n')
    #     file.write(hex_data)
    #     file.write('\n')
    #     file.write(str(hex(zlib.crc32(bin_data))))

    # create crc, FCS is sent most significant bit first
    crc32_bytes = zlib.crc32(bin_data).to_bytes(4, byteorder='big')
    crc32_binary = np.unpackbits(np.frombuffer(crc32_bytes, dtype=np.uint8))
    crc32_binary = crc32_binary.reshape(-1, 8)[:, ::-1].flatten() # Reverse bits within each byte
    crc32_binary = crc32_binary.reshape(-1,8)[::-1].flatten() # Reverse byte order

    # create input vector
    frame_bytes = bytes(frame)
    frame_binary = np.unpackbits(np.frombuffer(frame_bytes, dtype=np.uint8))
    frame_binary = frame_binary.reshape(-1, 8)[:, ::-1].flatten() # LSBs of each byte are sent first
    frame_binary = np.concatenate((preamble, sfd, frame_binary, crc32_binary))
    frame_binary = frame_binary.reshape((-1, 2))

    return frame_binary

if __name__ == "__main__":
    frame_gen()
