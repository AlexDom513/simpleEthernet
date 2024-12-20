from scapy.all import Ether, IP, sendp

# Craft an IPv4 packet
ip_packet = IP(dst="192.168.1.1", src="192.168.1.100") / b"Hello, IP Packet! I need to form an ethernet packet of at least 64 bytes."

# Craft the Ethernet frame containing the IPv4 packet
frame = Ether(dst="ff:ff:ff:ff:ff:ff", src="00:0e:c6:ba:95:36", type=0x0800) / ip_packet

# Send the frame to the specific interface
sendp(frame, iface="enx000ec6ba9536")

# Print the raw bytes being sent
raw_bytes = bytes(frame)
print("Raw bytes being sent:")
print(" ".join(f"{byte:02x}" for byte in raw_bytes))

