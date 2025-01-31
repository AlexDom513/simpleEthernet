#====================================================================
# simpleEthernet
# tb_eth_capture_analysis.py
# Verify transmit of Tx module
# 1/30/25
#====================================================================

with open('1_bit_capture.txt', 'r') as f:
    data = f.read().splitlines()
    capture = [int(x) for x in data]

    byte_list = []
    for i in range(0, len(capture), 8):
        byte_group = capture[i:i+8]
        val = 0
        for j in range(8):
            val += (2**j) * byte_group[j]
        byte_list.append(val)

    with open('2_packet_recover.txt', 'w') as f:
        for byte in byte_list:
            f.write(hex(byte) + '\n')

    # **in Ethernet, LSB is transmitted first!
    # 0x55 --> 0101_0101 --> 01_01_01_01
    # 0x57 --> 0101_0111 --> 01_01_01_11 --> transmitted as 11_10_10_10
    # 0xD5 --> 1101_0101 --> 11_01_01_01 --> transmitted as 10_10_10_11
