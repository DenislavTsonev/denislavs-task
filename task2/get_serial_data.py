import serial
import argparse


parser = argparse.ArgumentParser(description="Log collector from serial devices")
parser.add_argument('-f', '--output_file', required=True, help="File name to store collected data")
parser.add_argument('-p', '--serial_port', required=True, help="Serial port name, e.g. /dev/ttys003")
parser.add_argument('-b', '--baud_rate', required=True, help="Serial port baud rate, e.g 115200")

args = parser.parse_args()

# In my understanding we should have a some stop sequence in order to close the connection
stop_sequence = b'STOP\n'

ser = serial.Serial(args.serial_port, args.baud_rate, timeout=1)

with open(args.file_name, 'wb') as f:
    try:
        while True:
            data = ser.readline()
            f.write(data)
            decoded_data = data.decode('utf-8').strip()
            print(decoded_data)
            
            if data == stop_sequence:
                print("Stop sequence received. Closing serial port.")
                break 
    finally:
        ser.close()
