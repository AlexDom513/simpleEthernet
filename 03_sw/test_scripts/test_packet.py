from scapy.all import Ether, IP, UDP, send

# Define the target MAC address and IP address
target_mac = "00:0e:c6:ba:95:36"  # The MAC address from your output
target_ip = "192.168.1.100"        # Replace with the target IP address
target_port = 12345                # Replace with the target port

# Create an Ethernet layer with the target MAC address
ether_layer = Ether(dst=target_mac)

# Create an IP layer with the target IP address
ip_layer = IP(dst=target_ip)

# Create a UDP layer with the target port
udp_layer = UDP(dport=target_port)

# Define the payload (data for the UDP packet)
payload = b"Hello"

# Combine all layers and the payload into a single packet
packet = ether_layer / ip_layer / udp_layer / payload

# Send the packet
send(packet)

print(f"UDP packet sent to {target_mac} ({target_ip}:{target_port}) with payload: {payload.decode()}")


