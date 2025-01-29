import socket
import struct

# Set the MAC address you want to filter (e.g., "00:11:22:33:44:55")
target_mac = b'\x00\x0e\xc6\xba\x95\x36'  

# Create a raw socket
raw_socket = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.ntohs(0x0003))
raw_socket.bind(("enx000ec6ba9536", 0))  # Replace 'eth0' with your interface
print('socket bound!')

while True:
    packet, _ = raw_socket.recvfrom(65535)  # Capture the packet

    # Extract the source MAC address (bytes 6-11)
    src_mac = packet[6:12]

    print(packet.hex()) 
    if src_mac == target_mac:
        print("Packet from target MAC:", ':'.join(f'{b:02x}' for b in src_mac))
        print(packet.hex())  # Print raw packet data
