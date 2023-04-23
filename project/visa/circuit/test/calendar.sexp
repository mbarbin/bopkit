((Comment
  (text
   "// A visa-assembly program to drive the display of a digital-calendar. This"))
 (Comment
  (text
   "// program was originally implemented by Mathieu Barbin & Ocan Sankur in 2007."))
 Newline (Comment (text "// GLOBAL VARIABLE DECLARATIONS (ADDRESSES)."))
 (Constant_definition (constant_name february)
  (constant_kind (Address (address 7))))
 (Constant_definition (constant_name year)
  (constant_kind (Address (address 5))))
 (Constant_definition (constant_name month)
  (constant_kind (Address (address 4))))
 (Constant_definition (constant_name day)
  (constant_kind (Address (address 3))))
 (Constant_definition (constant_name hour)
  (constant_kind (Address (address 2))))
 (Constant_definition (constant_name min)
  (constant_kind (Address (address 1))))
 (Constant_definition (constant_name sec)
  (constant_kind (Address (address 0))))
 (Constant_definition (constant_name days_in_current_month)
  (constant_kind (Address (address 8))))
 Newline
 (Comment (text "// For a constant [x], [minus x] stores [-x] into [R1]."))
 (Macro_definition (macro_name minus) (parameters (x))
  (body
   (((loc _) (operation_kind (Instruction (instruction_name LOAD)))
     (arguments
      ((Parameter (parameter_name x)) (Register (register_name R0)))))
    ((loc _) (operation_kind (Instruction (instruction_name NOT)))
     (arguments ((Register (register_name R0)))))
    ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
     (arguments ((Value (value 1)) (Register (register_name R1)))))
    ((loc _) (operation_kind (Instruction (instruction_name ADD)))
     (arguments ())))))
 Newline
 (Comment
  (text "// Increment [var] by 1. If it equals [modulo] goto [carry_label],"))
 (Comment (text "// otherwise goto [return_label]."))
 (Macro_definition (macro_name increment)
  (parameters (var modulo return_label carry_label))
  (body
   (((loc _) (operation_kind (Instruction (instruction_name LOAD)))
     (arguments
      ((Parameter (parameter_name var)) (Register (register_name R0)))))
    ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
     (arguments ((Value (value 1)) (Register (register_name R1)))))
    ((loc _) (operation_kind (Instruction (instruction_name ADD)))
     (arguments ()))
    ((loc _) (operation_kind (Instruction (instruction_name STORE)))
     (arguments
      ((Register (register_name R1)) (Parameter (parameter_name var)))))
    ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
     (arguments
      ((Parameter (parameter_name modulo)) (Register (register_name R0)))))
    ((loc _) (operation_kind (Instruction (instruction_name CMP)))
     (arguments ()))
    ((loc _) (operation_kind (Instruction (instruction_name JMN)))
     (arguments ((Parameter (parameter_name carry_label)))))
    ((loc _) (operation_kind (Instruction (instruction_name JMP)))
     (arguments ((Parameter (parameter_name return_label))))))))
 Newline
 (Macro_definition (macro_name write_to_device_out)
  (parameters (local_address device_address))
  (body
   (((loc _) (operation_kind (Instruction (instruction_name LOAD)))
     (arguments
      ((Parameter (parameter_name local_address))
       (Register (register_name R0)))))
    ((loc _) (operation_kind (Instruction (instruction_name WRITE)))
     (arguments
      ((Register (register_name R0))
       (Parameter (parameter_name device_address))))))))
 Newline (Comment (text "// Computing the number of days in february:"))
 (Label_introduction (label COMPUTE_FEBRUARY))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments
     ((Constant (constant_name year)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 3)) (Register (register_name R1)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name AND)))
    (arguments ()))))
 (Comment (text "// If it is divisible by 4"))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMZ)))
    (arguments ((Label (label 29)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMN)))
    (arguments ((Label (label 28)))))))
 (Label_introduction (label 29))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 29)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMP)))
    (arguments ((Label (label FEB_WRITE)))))))
 (Label_introduction (label 28))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 28)) (Register (register_name R0)))))))
 (Label_introduction (label FEB_WRITE))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0)) (Constant (constant_name february)))))))
 Newline (Comment (text "// MAIN PROGRAM"))
 (Label_introduction (label UPDATE_SEC))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name SLEEP)))
    (arguments ()))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name write_to_device_out)))
    (arguments ((Constant (constant_name sec)) (Address (address 0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name write_to_device_out)))
    (arguments ((Constant (constant_name min)) (Address (address 1)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name write_to_device_out)))
    (arguments ((Constant (constant_name hour)) (Address (address 2)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name write_to_device_out)))
    (arguments ((Constant (constant_name day)) (Address (address 4)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name write_to_device_out)))
    (arguments ((Constant (constant_name month)) (Address (address 5)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name write_to_device_out)))
    (arguments ((Constant (constant_name year)) (Address (address 6)))))))
 Newline (Comment (text "// COUNT_SEC"))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name increment)))
    (arguments
     ((Constant (constant_name sec)) (Value (value 60))
      (Label (label UPDATE_SEC)) (Label (label COUNT_MIN)))))))
 Newline (Label_introduction (label COUNT_MIN))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 0)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0)) (Constant (constant_name sec)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name increment)))
    (arguments
     ((Constant (constant_name min)) (Value (value 60))
      (Label (label UPDATE_SEC)) (Label (label COUNT_HOUR)))))))
 Newline (Label_introduction (label COUNT_HOUR))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 0)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0)) (Constant (constant_name min)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name increment)))
    (arguments
     ((Constant (constant_name hour)) (Value (value 24))
      (Label (label UPDATE_SEC)) (Label (label COUNT_DAY)))))))
 Newline (Label_introduction (label COUNT_DAY))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 0)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0)) (Constant (constant_name hour)))))))
 (Comment (text "// Calculate days_in_current_month"))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments
     ((Constant (constant_name month)) (Register (register_name R0)))))))
 Newline (Comment (text "// Is it February?"))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 1)) (Register (register_name R1)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name CMP)))
    (arguments ()))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMN)))
    (arguments ((Label (label FEBRUARY)))))))
 Newline (Comment (text "// Else: (month <= 6) ==> (even month <=> 31)"))
 (Comment (text "// and : (month >  6) ==> (even month <=> 30)"))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name minus)))
    (arguments ((Value (value 6)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments
     ((Constant (constant_name month)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name ADD)))
    (arguments ()))))
 (Comment (text "// If it's zero, then month == 6"))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMZ)))
    (arguments ((Label (label LE6)))))))
 (Comment
  (text
   "// Otherwise we check bit 2^7. If it's 1, this means the result was negative,"))
 (Comment (text "// thus month < 6"))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 128)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name AND)))
    (arguments ()))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name CMP)))
    (arguments ()))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMN)))
    (arguments ((Label (label LE6)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMP)))
    (arguments ((Label (label G6)))))))
 Newline (Label_introduction (label DONE))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name increment)))
    (arguments
     ((Constant (constant_name day))
      (Constant (constant_name days_in_current_month))
      (Label (label UPDATE_SEC)) (Label (label COUNT_MONTH)))))))
 Newline (Label_introduction (label COUNT_MONTH))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 0)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0)) (Constant (constant_name day)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name increment)))
    (arguments
     ((Constant (constant_name month)) (Value (value 12))
      (Label (label UPDATE_SEC)) (Label (label COUNT_YEAR)))))))
 Newline (Label_introduction (label COUNT_YEAR))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 0)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0)) (Constant (constant_name month)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Macro_call (macro_name increment)))
    (arguments
     ((Constant (constant_name year)) (Value (value 100))
      (Label (label COMPUTE_FEBRUARY)) (Label (label NEW_CENTURY)))))))
 Newline (Label_introduction (label NEW_CENTURY))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 0)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0)) (Constant (constant_name year)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMP)))
    (arguments ((Label (label UPDATE_SEC)))))))
 Newline
 (Comment
  (text
   "// Functions (with Labels) to compute the number of days in the current month:"))
 Newline (Label_introduction (label FEBRUARY))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments
     ((Constant (constant_name february)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0))
      (Constant (constant_name days_in_current_month)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMP)))
    (arguments ((Label (label DONE)))))))
 Newline (Comment (text "// Case if month > 6."))
 (Label_introduction (label G6))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments
     ((Constant (constant_name month)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 1)) (Register (register_name R1)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name AND)))
    (arguments ()))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMZ)))
    (arguments ((Label (label F30)))))))
 (Label_introduction (label F31))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 31)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMP)))
    (arguments ((Label (label W)))))))
 (Label_introduction (label F30))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 30)) (Register (register_name R0)))))))
 (Label_introduction (label W))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name STORE)))
    (arguments
     ((Register (register_name R0))
      (Constant (constant_name days_in_current_month)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMP)))
    (arguments ((Label (label DONE)))))))
 Newline (Comment (text "// Case if month <= 6."))
 (Label_introduction (label LE6))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments
     ((Constant (constant_name month)) (Register (register_name R0)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name LOAD)))
    (arguments ((Value (value 1)) (Register (register_name R1)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name AND)))
    (arguments ()))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMN)))
    (arguments ((Label (label F30)))))))
 (Assembly_instruction
  (assembly_instruction
   ((loc _) (operation_kind (Instruction (instruction_name JMP)))
    (arguments ((Label (label F31))))))))
