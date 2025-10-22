# i2c_address_translator
This project implements an FPGA-based I²C address translator, designed to solve the problem of multiple I²C devices with the same default address on one bus. The translator dynamically remaps the I²C address for one device, making the system flexible and scalable without hardware changes.

Protocols Supported: Standard I²C timing (100 kHz / 400 kHz)
Design Style: Uses clean synchronous design with state machines, counters, and shift registers
Simulation: Includes functional simulation and testbench
High-Level Architecture: I²C Slave Module: Listens to the master on the main bus, detects start/stop, reads incoming address/data requests, and sends ACKs.
Address Translation Logic: Matches the received address and, if matched, starts a new master transaction using a new (translated) address.

I²C Master Module: Initiates a downstream transaction to the actual device using the remapped address and handles read/write data accordingly.

Shift Registers: Used for serial-to-parallel and parallel-to-serial data handling across both master and slave directions.

Counters: Track transfer bits and ensure protocol byte/acknowledge timing.
Start/Stop Detector: Ensures correct recognition of I²C frame edges for FIFO integrity.

Working Principle: The master (host controller) initiates an I²C transaction with a desired (possibly virtual) device address.
The I²C slave module inside the FPGA listens for all bus activity; if it recognizes a transaction for the remapped address, it acknowledges and captures the data.
After address recognition, the address translation logic bridges the transaction to the true physical address required by the actual target device.
The I²C master module then acts as a new bus master, issuing the proper (remapped) address and forwarding all data/reply bytes, maintaining full protocol transparency.
All transitions and acknowledgments are handled as required by I²C specification.

Explanation of Each Verilog Module:
1.	i2c_Slave Role: Listens to the main I²C bus as a slave, detects bus start/stop, receives the master's address/data, and issues ACKs. Importance: Acts as the bus entry point for all incoming I²C requests; initiates the internal transaction if address matches.
2.	i2c_master Role: After the slave triggers it, this module acts as a master towards the downstream device, providing start/stop, address, data send/receive, and protocol-compliant acknowledgments. Importance: Drives the real external device, ensuring that the desired remapped address is used transparently.
3.	Shift_register Role: Converts serial data on the I²C data line (SDA) to parallel bytes (and vice versa). Importance: Essential in both transmitting and receiving, as I²C is a serial bus and all data must pass bit-by-bit through the protocol.
4.	I2C_counter Role: Counts the number of bits sent or received per byte. Used to identify full byte boundaries (address, data, and ACK). Importance: Keeps protocol timing correct and helps FSMs know when each stage of the transfer is complete.
5.	start_stop_detector Role: Monitors the I²C lines to spot correct start and stop conditions (required for both master and slave modules). Importance: Ensures compliant I²C frame detection, preventing protocol confusion and ensuring the state machine always synchronizes with the bus.
6.	Top_module Role: The main integration point, wires together the above modules, coordinating the flow of signals and ensuring safe tri-state operation of the SDA line. Importance: Glues all functionality into a working, testable project and prepares the system for synthesis and simulation.

