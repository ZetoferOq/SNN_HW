import serial
import serial.tools.list_ports

import matplotlib.pyplot as plt

VALUES_CNT = 500


def read_bytes(ser, n_bytes):
    buf = b''
    while len(buf) < n_bytes:
        chunk = ser.read(n_bytes - len(buf))
        if not chunk:
            continue
        buf += chunk
    return buf

def list_ports():
    ports = serial.tools.list_ports.comports()
    print("==== Detected ports ====")
    for p in ports:
        print("[-]", p.device, p.description)
    print("=" * 24)

def q15_17_to_float(val):
    return val / (1 << 17)



if __name__ == '__main__':
    list_ports()

    ser = serial.Serial('COM7', 115200, timeout=1)

    print("\nListening...")

    values_fixp = []
    while len(values_fixp) < VALUES_CNT:
        data32 = read_bytes(ser, 4)
        values_fixp.append(int.from_bytes(data32, byteorder='little', signed=True))

    print("Done")

    x = range(len(values_fixp))
    values_float = [q15_17_to_float(v) for v in values_fixp]

    plt.figure(figsize=(12, 6), dpi=600)
    plt.plot(values_float,
             linestyle='-',
             color='black',
             marker='o',
             markersize=2,
             markerfacecolor='red',
             markeredgecolor="red")
    plt.show()
