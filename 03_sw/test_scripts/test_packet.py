from scapy.all import Ether, sendp

# Define the Ethernet frame
frame = Ether(dst="ff:ff:ff:ff:ff:ff", src="00:0e:c6:ba:95:36", type=0x0800) / b"Hello, Ethernet!"

# Send the frame to the specific interface
sendp(frame, iface="enx000ec6ba9536")
