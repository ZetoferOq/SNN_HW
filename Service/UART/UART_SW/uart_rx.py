import serial
import serial.tools.list_ports


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


if __name__ == '__main__':
    list_ports()

    ser = serial.Serial('COM7', 115200, timeout=1)

    print("\nListening...")
    while True:
        data = read_bytes(ser, 4)

        value = int.from_bytes(data, byteorder='little')

        print(f"{value}, {hex(value)}")