# asynchronous_fifo
This is an initial file of asynchronous fifo; 
This is used to read and write the FIFO with seperate clocks in order to mitigate the CDC issues in our ASIC Design.

Pointers are synchronized using gray code synchronizers.

0.0.1 - Initial File - Just RTL is coded, not simulated yet




Finding the FIFO Depth : 

Eg : 
write freq = 200Mhz
read freq = 20Mhz
Burst Size = 100
Depth = ?

Time taken for 1 data to write = 1/200 = 5ns
Time taken to write 100 Data = 5*100 = 500ns
Time taken to read 1 data from FIFO = 1/20 = 50 ns

Data read during total writing = 500/50 = 10 Data
Data remaining on the FIFO after reading = Burst - ReadData = 100 - 10 = 90

Depth = 90 data;
