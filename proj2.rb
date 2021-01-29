# Dmytro Kuzmyk
# dkuzmy3
# priject 2

class ALI
  def dec(m,p,map)
    # store variable into memory
    temp = m[p]     # get full instruction
    temp = temp[4]  # get the symbol of the instruction
    m[p] = temp     # replace the instruction with the value
    map[temp] = 0   # map its value to the hash table
    puts temp       # debug
  end

  def lda(m,p,map)
    #Loads byte at data memory address of symbol into the accumulator.
    command = m[p]        # get instruction from memory
    symbol = command[4]   # get the symbol
    # have to find index at which the memory is symbol and get its value
    puts "A updated"
    map[symbol]
  end

  def ldb(m,p,map)
    #Loads byte at data memory address symbol into B.
    command = m[p]      # get instruction from memory
    symbol = command[4]   # get the symbol

    # have to find index at which the memory is symbol and get its value
    puts "B updated"
    map[symbol]
  end

  def ldi(m,p)
    #value Loads the integer value into the accumulator register. The value could be negative.
    temp = m[p]
    temp2 = temp[4..].to_i
    a = temp2
    puts "acc: " + a.to_s
    a
  end

  def str(a,m,p,map)
    #symbol Stores content of accumulator into data memory at address of symbol.
    command = m[p]
    symbol = command[4] # find the symbol to look for
    puts "symbol: " + symbol
    puts "replaced with: " + a.to_s
    map[symbol] = a
  end

  def jmp(m,p)
    #Transfers control to instruction at address number in program memory.
    command = m[p]
    new_command = command[4..].to_i
    puts "Jump to " + new_command.to_s
    new_command-1  # return -1 because the command will be increased by 1 at the end of the main loop
  end

  def jzs(m,p)
    #Transfers control to instruction at address number if the zero-result bit is set.
    command = m[p]
    new_command = command[4..].to_i
    puts "Jump to " + new_command.to_s + " ,zero-result set"
    new_command-1
  end

  def jvs(m,p)
    #Transfers control to instruction at address number if the overflow bit is set.
    command = m[p]
    new_command = command[4..].to_i
    puts "Jump to " + new_command.to_s + " overflow bit set"
    new_command-1
  end

  def add(a,b)
    puts "adding A + B"
    a + b
    #Adds the content of registers A and B. The sum is stored in A. The overflow and zero-result bits are set or cleared as needed.
  end

end

class MAIN < ALI
  valid_file = false      # bool for valid name of txt file
  halt = false            # bool to continue/interrupt computation
  input_file = "none"     # string to store name of file
  #input_line = "none"     # string to store command line
  input_command = "none"  # string to store user input
  automatic = false       # bool to start automatic computation

  memory = Array.new      # memory
  map_value = Hash.new    # map to store values at memory of variable
  ali = MAIN.new          # instance of self
  accumulator = 0         # registry A
  add_register = 0        # registry B
  program_counter = 0     # PC
  zero_result = 0         # zero_result bit
  overflow = 0            # overflow bit

  until valid_file # file input loop, loops until file is valid
    puts "Enter the name of the file (eg. text.txt) "
    name_file = gets.chomp

    begin
      # check if file is a valid file and if so open it
      input_file = File.open(name_file.to_s)
      valid_file = true
    rescue
      puts "Not a valid file."
      valid_file = false
    end

    if valid_file == true
      File.readlines(input_file).each do |c|
        #puts c
        memory << c # populate memory array with commands line per line
      end
    end

    if memory.size > 256
      memory.clear
      input_file.close
      puts "Memory Overflow"
      valid_file = false
    end
  end

  until halt # core execution loop
    unless automatic # if the command 'l' wasn't executed, it's not automatic
      puts "Enter command: "
      input_command = gets.chomp
    end

    if input_command == "l"
      # execute one line
      puts "l was pressed"
    elsif input_command == "a"
      # execute everything automatically
      input_command = "automaticRun"
      automatic = true
      puts "automatic was set"
    elsif input_command == "q"
      puts "Quitting.."
      halt = true
    elsif input_command == "automaticRun"
      puts "computing command " + program_counter.to_s
    else
      puts "No such command."
    end
    ############### EXECUTION ################

    local_command = memory[program_counter]

    if local_command[0..2] == "DEC"
      ali.dec(memory, program_counter, map_value)

    elsif local_command[0..2] == "LDA"
      accumulator = ali.lda(memory, program_counter, map_value)

    elsif local_command[0..2] == "LDB"
      add_register = ali.ldb(memory, program_counter, map_value)

    elsif local_command[0..2] == "LDI"
      accumulator = ali.ldi(memory, program_counter).to_i

    elsif local_command[0..2] == "STR"
      ali.str(accumulator, memory, program_counter, map_value)

    elsif local_command[0..2] == "XCH"
      puts "swapping A with B"
      temp = accumulator
      accumulator = add_register
      add_register = temp

    elsif local_command[0..2] == "JMP"
      program_counter = ali.jmp(memory, program_counter)

    elsif local_command[0..2] == "JZS"
      if zero_result > 0
        program_counter = ali.jmp(memory, program_counter)
      else
        puts "skip jzs"
      end

    elsif local_command[0..2] == "JVS"
      if overflow > 0
        program_counter = ali.jmp(memory, program_counter)
      else
        puts "skip jvs"
      end

    elsif local_command[0..2] == "ADD"
      accumulator = ali.add(accumulator, add_register)
      if accumulator > 2147483647 || -2147483647 > accumulator
        overflow = 1
      else
        overflow = 0
      end
      if accumulator == 0
        zero_result = 1
      else
        zero_result = 0
      end

    elsif local_command[0..2] == "HLT"
      puts "halt reached, end of the computing"
      halt = true
      input_file.close

    else
      puts "Attention! PC does not point to an operation, the program will close to prevent errors"
      halt = true
      input_file.close
    end

    ############### CHECKERS #################
    if accumulator > 2147483647 || -2147483647 > accumulator
      puts "Warning! accumulator has reached max memory, flushing the value"
      accumulator = accumulator%2147483647
    end
    temp = memory[program_counter]
    temp = temp[2..]
    map_value.each do |k,v|
      if v > 2147483647
        puts "Warning! value at " + k.to_s + " reached max memory, flushing the value"
        map_value[k] = v%2147483647
      end
    end
    if (add_register > 2147483647) || (-2147483647 > add_register)
      puts "Warning! additional registry has reached max memory, flushing the value"
      add_register = add_register%2147483647
    end
    if program_counter >= 255
      puts "Warning! program counter has reached max memory"
      puts "The program won't crash but it technically should"
    end

    program_counter += 1
  end
  ############ DEBUG #############
  puts "===================="
  puts "Memory: "
  puts memory
  puts "Accumulator: "
  puts accumulator
  puts "Add registry: "
  puts add_register
  puts "Overflow bit"
  puts overflow
  puts "Zero-result"
  puts zero_result
  puts "Map Memory: "
  map_value.each do |k,v|
    puts k.to_s + ":" + v.to_s
  end
  ################################
end