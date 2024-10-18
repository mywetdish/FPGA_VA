
import re
import os
#Функция для поиска названия сигнала clock
def find_clk_signal(file_content):
    
    clk_pattern = r"input\s+logic\s+(\w*clk\w*)\s*,"
    
    match = re.search(clk_pattern, file_content)
    
    if match:
        clk_name = match.group(1)
        return clk_name
    else:
        return None

def delete_file(file_path):
    try:
        if os.path.isfile(file_path):
            os.remove(file_path)
            print(f"Файл {file_path} успешно удалён.")
        else:
            print(f"Файл {file_path} не существует.")
    except Exception as e:
        print(f"Ошибка при удалении файла: {e}")

#print("Enter design file name")
#file_name = input()
#with open(file_name, "r") as fd:
with open('a.sv', "r") as fd:
  file_content = fd.read()

  start_module_position = file_content.find("module ")
  end_module_position = file_content.find(");") + 2
  file_content = file_content[start_module_position:end_module_position]
  print(file_content)

  module_name = re.match("module\s+(\w+)\s*#?\(", file_content).group(1)
  print("Module name is '{}'\n".format(module_name))

  if "(" in file_content:
    

      clk_name = find_clk_signal(file_content)
      print(clk_name)
      
      # ПОИСК ВСЕХ ВХОДНЫХ СИГНАЛОВ 
       
      # Регулярное выражение для поиска input logic [X:Y] <signal_name>
      input_pattern_with_range = re.compile(r"input\s+logic\s+\[\s*(\d+)\s*:\s*(\d+)\s*\]\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*,?")
      # Регулярное выражение для поиска input logic <signal_name> без диапазона
      input_pattern_single = re.compile(r"input\s+logic\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*,?")
      # Регулярное выражение для остановки при нахождении output logic
      output_pattern = re.compile(r"output\s+logic")      

      signals_names_i = []
      signals_sizes_i = []
      position_i = 0      

      while True:

          input_match_single = input_pattern_single.search(file_content, position_i)

          input_match_range = input_pattern_with_range.search(file_content, position_i)
          
          output_match = output_pattern.search(file_content, position_i)

          if output_match and (input_match_single is None and input_match_range is None or output_match.start() < min(
              input_match_single.start() if input_match_single else float('inf'),
              input_match_range.start() if input_match_range else float('inf')
          )):
              print("Достигнут блок output logic. Остановка.")
              break      


          if input_match_single:
            if clk_name == None:
              signal_name = input_match_single.group(1)
              size_signal = 1 
              signals_names_i.append(signal_name)
              signals_sizes_i.append(size_signal)      

              position_i = input_match_single.end()
            else:
              if input_match_single.group(1) == clk_name:
                position_i = input_match_single.end()
              else:
                signal_name = input_match_single.group(1)
                size_signal = 1
                signals_names_i.append(signal_name)
                signals_sizes_i.append(size_signal)      

              position_i = input_match_single.end()
          
          elif input_match_range:
              X = int(input_match_range.group(1))
              Y = int(input_match_range.group(2))
              signal_name = input_match_range.group(3)
              size_signal = X - Y + 1
              signals_names_i.append(signal_name)
              signals_sizes_i.append(size_signal)     

              position_i = input_match_range.end()
          else:

              break      
      
      # ПОИСК ВСЕХ ВЫХОДНЫХ СИГНАЛОВ 

      output_pattern_with_range = re.compile(r"output\s+logic\s+\[\s*(\d+)\s*:\s*(\d+)\s*\]\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*,?")
      output_pattern_single = re.compile(r"output\s+logic\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*,?")
      end_pattern = re.compile(r"\);\s*")
      
      signals_names_o = []
      signals_sizes_o = []
      position_i = 0      

      while True:

        output_match_single = output_pattern_single.search(file_content, position_i)
          
        output_match_range = output_pattern_with_range.search(file_content, position_i)
          
        end_match = end_pattern.search(file_content, position_i)
          
        if end_match and (output_match_single is None and output_match_range is None or end_match.start() < min(
              output_match_single.start() if output_match_single else float('inf'),
              output_match_range.start() if output_match_range else float('inf')
          )):
          print("Достигнут блок output logic. Остановка.")
          break      

        if output_match_single:
          signal_name = output_match_single.group(1)
          size_signal = 1
          signals_names_o.append(signal_name)
          signals_sizes_o.append(size_signal)
          position_i = output_match_single.end()
          
        elif output_match_range:
              X = int(output_match_range.group(1))
              Y = int(output_match_range.group(2))
              signal_name = output_match_range.group(3)
              size_signal = X - Y + 1
              signals_names_o.append(signal_name)
              signals_sizes_o.append(size_signal)   

              position_i = output_match_range.end()
        else:
              
          break      
      ###########################################################

with open('../rtl/src/qdma/dut_wrapper.sv', "w") as file:

    file.write(
"""`timescale 1ns / 1ps
module dut_wrapper #(
parameter IN_BUS_WIDTH = 256,
parameter OUT_BUS_WIDTH = 256
)(
    input logic     [IN_BUS_WIDTH-1:0] in,
    input logic     clk,
    input logic     rst_n,
    output logic    [OUT_BUS_WIDTH-1:0] out
);
""")
    a=0
    
    file.write(f"{module_name} ")
    file.write("""DUT""")
    file.write("""(\n""")
  
    if ( clk_name != None):
      file.write("""                 .""")
      file.write(str(clk_name))
      file.write("""       """)
      file.write("""(     clk       ),\n""")
      for name, size in zip(signals_names_i, signals_sizes_i):
        file.write("""                 .""")
        file.write(str(name))
        file.write("""            (  """)
        file.write("""in[""")
        a += size
        if size == 1:
          file.write(str(a))
          file.write("""]   ),\n""")
        else:
          file.write(str(a))
          file.write(""":""")
          file.write(str(a-size+1))
          file.write("""]     ),\n""")
      b =0
      for name, size in zip(signals_names_o[:-1], signals_sizes_o[:-1]):
        b += size
        file.write("""                 .""")
        file.write(str(name)   )
        file.write("""            (  """)
        file.write("""out[""")
        if size == 1:
          file.write(str(b))
          file.write("""]   ),\n""")
        else:
          file.write(str(b))
          file.write(""":""")
          file.write(str(b-size+1))
          file.write("""]     ),\n""")
      
      b += signals_sizes_o[-1]
      file.write("""                 .""")
      file.write(str(signals_names_o[-1])   )
      file.write("""            (  """)
      file.write("""out[""")

      if signals_sizes_o[-1] == 1:
        file.write(str(b))
        file.write("""]   )\n""")
      else:
        file.write(str(b))
        file.write(""":""")
        file.write(str(b-signals_sizes_o[-1]+1))
        file.write("""]     )\n""")
      
      file.write(""");\n""")
    
      file.write("""endmodule""")
      

    else:
      a = 0

      for name, size in zip(signals_names_i, signals_sizes_i):
        file.write("""                 .""")
        file.write(str(name))
        file.write("""            (  """)
        file.write("""in[""")
        a += size
        if size == 1:
          file.write(str(a))
          file.write("""]   ),\n""")
        else:
          file.write(str(a))
          file.write(""":""")
          file.write(str(a-size+1))
          file.write("""]     ),\n""")
      b =0
      for name, size in zip(signals_names_o[:-1], signals_sizes_o[:-1]):
        b += size
        file.write("""                 .""")
        file.write(str(name)   )
        file.write("""            (  """)
        file.write("""out[""")
        if size == 1:
          file.write(str(b))
          file.write("""]   ),\n""")
        else:
          file.write(str(b))
          file.write(""":""")
          file.write(str(b-size+1))
          file.write("""]     ),\n""")
      
      b += signals_sizes_o[-1]
      file.write("""                 .""")
      file.write(str(signals_names_o[-1])   )
      file.write("""            (  """)
      file.write("""out[""")
      if signals_sizes_o[-1] == 1:
        file.write(str(b))
        
        file.write("""]   ),\n""")
      else:
        
        file.write(str(b))
        file.write(""":""")
        file.write(str(b-signals_sizes_o[-1]+1))
        file.write("""]     )\n""")
      
      file.write(""");\n""")
    
      file.write("""endmodule""")
file_name  = '../tb/' + module_name + ".sv"
with open(file_name, "w") as file:
  file.write(
"""`timescale 1ns / 1ps
`define IN_BUS_LEN 256
`define OUT_BUS_LEN 256
module """
  )
  file.write(module_name)
  file.write("(\n")
  file.write("input  logic")
  file.write("""            """)
  file.write("clk")
  file.write(",\n")
  for name, size in zip(signals_names_i, signals_sizes_i):
    file.write("input  logic")
    if size == 1:
      file.write("""          """)
      file.write(str(name))
      file.write(",\n")
    else:
        file.write("""   """)
        file.write("[")
        file.write(str(size-1))
        file.write(":0]")
        file.write("""   """)
        file.write(str(name))
        file.write(",\n")
  for name, size in zip(signals_names_o[:-1], signals_sizes_o[:-1]):
    file.write("output  logic")
    if size == 1:
      file.write("""          """)
      file.write(str(name))
      file.write(",\n")
    else:
        file.write("""   """)
        file.write("[")
        file.write(str(size-1))
        file.write(":0]")
        file.write("""   """)
        file.write(str(name))
        file.write(",\n")
  if(signals_sizes_o[-1] == 1):
    file.write("output  logic")
    file.write("""          """)
    file.write(str(name))
    file.write("\n")
    file.write(");")
  else:
      file.write("output  logic")
      file.write("""   """)
      file.write("[")
      file.write(str(size-1))
      file.write(":0]")
      file.write("""   """)
      file.write(str(name))
      file.write("\n")
      file.write(");\n")

  file.write("   bit  [`IN_BUS_LEN-1:0]  in_bus;\n")
  file.write("   bit  [`IN_BUS_LEN-1:0]  out_bus;\n")
  file.write("\n")
  file.write("\n")
  c = 0
  for name, size in zip(signals_names_i, signals_sizes_i):
    c += size
    if (size == 1):
      file.write("assign in_bus[")
      file.write(str(c))
      file.write("] = ")
      file.write(name)
      file.write(";\n")
    else:
      file.write("assign in_bus[")
      file.write(str(c))
      file.write(":")
      file.write(str(c-size+1))
      file.write("] = ")
      file.write(name)
      file.write(";\n")
  d = 0
  for name, size in zip(signals_names_o, signals_sizes_o):
    d += size
    if (size == 1):
      file.write("assign ")
      file.write(name)
      file.write(" = out_bus[")
      file.write(str(d))
      file.write("];\n")

    else:
      file.write("assign ")
      file.write(name)
      file.write(" = out_bus[")
      file.write(str(d))
      file.write(":")
      file.write(str(d-size+1))
      file.write("];\n")
  file.write("\n")
  file.write(
"""    import "DPI-C" function void dpi_va_dev_step(
        input bit [`IN_BUS_LEN-1:0] data_in,
        input int unsigned data_in_size, 
        input int unsigned data_out_size,
        output bit [`OUT_BUS_LEN-1:0] data_out
    );

    initial begin
        forever begin
    	    @(posedge clk);
            dpi_va_dev_step(
                in_bus, 
                `IN_BUS_LEN/8, 
                `OUT_BUS_LEN/8, 
                out_bus
            );
        end
    end

endmodule
"""
  )

delete_file("a.sv")


