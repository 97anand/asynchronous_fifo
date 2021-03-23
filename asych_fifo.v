module asych_fifo #(parameter      DATA_WIDTH = 4,
                                   ADDR_WIDTH = 4,
                                   DEPTH      = 1 << ADDR_WIDTH
                      )
  (
    input                         rd_clk    ,  //Clock to read data
    input                         wr_clk    ,  //Clock to write data
    input                         rd_en     ,  //Clock to read data
    input                         wr_en     ,  //Clock to write data
    input                         reset_n   ,  //Reset pin
    input      [DATA_WIDTH-1:0]   data_in   ,  //Fifo Data in          
    output                        fifo_full ,  //Full condition          
    output                        fifo_Mty  ,  //Empty Condition          
    output     [DATA_WIDTH-1:0]   data_out     //Fifo Data out          
  );


 //************************************************************
 // Intermediate Registers and wires
 //************************************************************

  //----read-pointer-regs-----
  reg  [ADDR_WIDTH:0]   rd_ptr         ;        
  wire [ADDR_WIDTH:0]   rd_ptr_gray    ;
  wire [ADDR_WIDTH:0]   rd_ptr_sync    ;
  reg  [ADDR_WIDTH:0]   rd_ptr_sync1   ;
  reg  [ADDR_WIDTH:0]   rd_ptr_sync2   ;

  //----write-pointer-regs-----
  reg  [ADDR_WIDTH:0]   wr_ptr         ;
  wire [ADDR_WIDTH:0]   wr_ptr_gray    ;
  wire [ADDR_WIDTH:0]   wr_ptr_sync    ;
  reg  [ADDR_WIDTH:0]   wr_ptr_sync1   ;
  reg  [ADDR_WIDTH:0]   wr_ptr_sync2   ;

  //----FIFO-memory-array-----
  reg  [DATA_WIDTH-1:0] mem [0:DEPTH-1] ;
  integer i;


 //************************************************************
 // Write logic to FIFO | Using Write Clock
 //************************************************************

  always @(posedge wr_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
          wr_ptr      <= 'b0;
          //--initializing memory with zeros --
          for(i = 0; i < DEPTH; i = i+1)
            begin
              mem[i] <= {(DATA_WIDTH-1){1'b0}};
            end
        end
      //-----Fifo is not full and write enable is high writing data into fifo------
      else if(fifo_full == 1'b0 && wr_en == 1'b1)
        begin
          mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
          wr_ptr                      <= wr_ptr + 'b1;
        end
      else
        begin
          wr_ptr <= wr_ptr;
        end
    end

 //************************************************************
 // Read Pointer Synchronizer | Multi-flop bit synchronizer
 //************************************************************

  always @(posedge wr_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
          rd_ptr_sync1 <= 'b0;
          rd_ptr_sync2 <= 'b0;
        end
      else
        begin
          rd_ptr_sync1 <= rd_ptr_gray;
          rd_ptr_sync2 <= rd_ptr_sync1;
        end
    end

 //************************************************************
 // Read logic to FIFO | Using Read Clock
 //************************************************************

  always @(posedge rd_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
          rd_ptr <= 'b0;
        end
      //------FIFO is not empty Reading data when read enable is high--------
      else if(fifo_Mty == 1'b0 && rd_en == 1'b1)
        begin
          rd_ptr      <= rd_ptr + 'b1;
        end
      else
        begin
          rd_ptr <= rd_ptr;
        end
    end

 //************************************************************
 // Write Pointer Synchronizer | Multi-flop bit synchronizer
 //************************************************************

  always @(posedge rd_clk or negedge reset_n)
    begin
      if(!reset_n)
        begin
          wr_ptr_sync1 <= 'b0;
          wr_ptr_sync2 <= 'b0;
        end
      else
        begin
          wr_ptr_sync1 <= wr_ptr_gray;
          wr_ptr_sync2 <= wr_ptr_sync1;
        end
    end

 //************************************************************
 // Assign Statements
 //************************************************************

  //Binary 2 gray converter
   assign wr_ptr_gray = wr_ptr ^ (wr_ptr >> 1);
   assign rd_ptr_gray = rd_ptr ^ (rd_ptr >> 1);

  //Gray 2 Binary converter
  // assign wr_ptr_sync = wr_ptr_sync2 ^ (wr_ptr_sync2 >> 1) ^ (wr_ptr_sync2 >> 2) ^ (wr_ptr_sync2 >> 3);
  // assign rd_ptr_sync = rd_ptr_sync2 ^ (rd_ptr_sync2 >> 1) ^ (rd_ptr_sync2 >> 2) ^ (rd_ptr_sync2 >> 3);

  //Empty and Full Generation
   assign fifo_Mty    = (((wr_ptr_sync2 == 'b0) && (rd_ptr_gray == 'b0)) || (rd_ptr_gray == wr_ptr_sync2)) ? 1'b1 : 1'b0;
   assign fifo_full   = ({~wr_ptr_gray[ADDR_WIDTH-1],wr_ptr_gray[ADDR_WIDTH-1:0]} == {~rd_ptr_sync2[ADDR_WIDTH-1],rd_ptr_sync2[ADDR_WIDTH-1:0]}) && 
	                 (wr_ptr_gray[ADDR_WIDTH] != rd_ptr_sync2[ADDR_WIDTH]);

  //Data-out
   assign data_out    = (rd_en) ? mem[rd_ptr[ADDR_WIDTH-1:0]] : 'b0;

endmodule
