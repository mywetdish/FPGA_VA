import re
import os
#Функция , для получения имени файла
def extract_module_name(file_content):
    pattern = r'module\s+(\w+)\s*(?:#?\s*\(.*?\))?\s*(?:import\s+\w+::\w+;)?\s*(?:\(\s*)?'

    match = re.match(pattern, file_content)
    
    if match:
        return match.group(1)
    else:
        return None

#Функция, которя удаляет комментарии
def remove_single_line_comments(file_content):
    pattern = r'//.*?$'
    
    cleaned_content = re.sub(pattern, '', file_content, flags=re.MULTILINE)
    
    return cleaned_content

#Фунция рассчета десятичного значения параметра
def binary_to_decimal(binary_str):
    # Удаляем префикс 'b', если он присутствует
    if "b" in binary_str:
      binary_str = binary_str.split('b')[1]
      decimal_value = int(binary_str, 2)
    elif "h" in binary_str:
      binary_str = binary_str.split('h')[1]
      decimal_value = int(binary_str, 16)
    elif "d" in binary_str:
      binary_str = binary_str.split('d')[1]
      decimal_value = int(binary_str, 10)
    else:
        decimal_value = int(binary_str)
      
    return decimal_value

#функция для удаления парамеров в заголовке модуля
def extract_content_between_parentheses(file_content):
    # Регулярное выражение для поиска содержимого между ")(" и ");"
    pattern = r'\)\s*\(\s*(.*?)\s*\);'
    
    matches = re.findall(pattern, file_content, re.DOTALL)
    
    file_content_without_params = ' '.join(matches)
    
    return file_content_without_params

#Функция, которая подставляет десятичные значения параметров вместо имен
def replace_parameters_with_values(file_content_without_params, parameter_names, decimal_values):
    for name, value in zip(parameter_names, decimal_values):

        pattern = r'(\[.*?)(\b' + re.escape(name) + r'\b)(.*?\])'
        
        def replace_match(match):
            before_param = match.group(1)
            after_param = match.group(3)
            return f'{before_param}{value}{after_param}'

        file_content_without_params = re.sub(pattern, replace_match, file_content_without_params)

    return file_content_without_params

#Функция , которая ставит сигналы в нужном порядке
def reorder_signals(file_content):

    single_bit_input = r'input\s+logic\s+\w+\s*'
    
    single_bit_output = r'output\s+logic\s+\w+\s*'
    
    # Многобитные входы и выходы:
    multi_bit_input = r'input\s+logic\s*\[[^\]]+\]\s*\w+\s*'
    multi_bit_output = r'output\s+logic\s*\[[^\]]+\]\s*\w+\s*'

    inputs_single = []
    inputs_multi = []
    outputs_single = []
    outputs_multi = []

    for line in file_content.split(','):
        line = line.strip() 
        if re.match(single_bit_input, line):
            inputs_single.append(line)
        elif re.match(multi_bit_input, line):
            inputs_multi.append(line)
        elif re.match(single_bit_output, line):
            outputs_single.append(line)
        elif re.match(multi_bit_output, line):
            outputs_multi.append(line)

    ordered_signals = inputs_single + inputs_multi + outputs_single + outputs_multi
    print("inputs_single")
    print(inputs_single)
    print("ordered_signals")
    print(ordered_signals)

    return ',\n'.join(ordered_signals)

#Функция, которая отбрпсывает module и :) ( нужна для случая, когда входных параметров нет)
def extract_signals(file_content):
 
    pattern = r'module\s+\w+\s*\(\s*([^;]*?)\);'

    match = re.search(pattern, file_content, re.DOTALL)
    
    if match:
        content = match.group(1).strip()
        return content
    else:
        return ""

#Функция для вычисления математических операций
def calculate_expressions(file_content):

    pattern = r'(\d+\s*[\+\-\*/]\s*\d+)'

    # Функция для вычисления выражения
    def eval_expression(match):
        expression = match.group(0)
        try:
            expression = expression.replace('/', '//')
            result = eval(expression)
            return str(int(result))
        except Exception:
            return expression

    new_content = re.sub(pattern, eval_expression, file_content)
    return new_content

#Функция , которая объединяет параметры в один массив 
def extract_parameters(parameter_values_in_header, parameter_values_in_include):
  for param in parameter_values_in_include:
    parameter_values_in_header.append(param)
  return parameter_values_in_header

#Фунция, которая убирает importЫ (нужна для случая , когда нет параметров , но етсь import)
def extract_signals_import(file_content):

    pattern = r'\(\s*([^;]*?)\);\s*'
  
    match = re.search(pattern, file_content, re.DOTALL)
    
    if match:

        new_file_content = match.group(1).strip()
        return new_file_content
    else:
        return ""

#Функция , которая ищет параметры в хедере 
def extract_header_parameter_names(file_content):

    pattern = r'logic\s*\[\s*([A-Z_]+)\b'
    
    matches = re.findall(pattern, file_content)

    parameter_names_in_header = []
    
    for name in matches:
        if name not in parameter_names_in_header:
            parameter_names_in_header.append(name)
    
    return parameter_names_in_header

#Функция , которая создает массив значений параметров из хэдара 
def extract_header_parameter_values(parameter_names, file_content):

    parameter_values_in_header = []

    for param in parameter_names:
        pattern = rf'{param}\s*=\s*([^,\)]+)'
        match = re.search(pattern, file_content)

        if match:
            parameter_value = match.group(1).strip()
            parameter_values_in_header.append(parameter_value)

    return parameter_values_in_header

#Функция , которая ищет один параметер из хэддера
def extract_header_one_parameter_value(name, file_content):

    pattern = rf'{name}\s*=\s*([^,\)]+)'
    match = re.search(pattern, file_content)
        
    if match:
        parameter_value_one = match.group(1).strip()
    else:
        parameter_value_one = None

    return parameter_value_one

#Функция , которая создает масиив параметров из импорта
def extract_parameter_from_imports(parameter_names, file_content, base_path="include"):

    parameter_values_in_header_include = []

    import_pattern = r'import\s+([^\s:]+)\s*::'
    
    imported_files = re.findall(import_pattern, file_content)
    print("импортные файлы")
    print(imported_files)

    for param in parameter_names:
        param_value = None 

        for imported_file in imported_files:

            imported_file_path = os.path.join(base_path, f"{imported_file}.sv")
            print("Путь до файла")
            print(imported_file_path)
            
            if not os.path.exists(imported_file_path):
                continue
            
            with open(imported_file_path, 'r') as f:
                imported_file_content = f.read()

            pattern = rf'{param}\s*=\s*([^;]+);'
            match = re.search(pattern, imported_file_content)
            
            if match:
                param_value = match.group(1).strip() 
                break

        if(param_value != None):
          parameter_values_in_header_include.append(param_value)

    return parameter_values_in_header_include

#Функция , которая ищет одно слово  из импорта
def extract_one_parameter_from_imports(name, file_content, base_path="include"):

    import_pattern = r'import\s+([^\s:]+)\s*::'
    
    imported_files = re.findall(import_pattern, file_content)
    print("импортные файлы")
    print(imported_files)


    param_value = None 

    for imported_file in imported_files:
        imported_file_path = os.path.join(base_path, f"{imported_file}.sv")
        print("Путь до файла")
        print(imported_file_path)
    
        if not os.path.exists(imported_file_path):
          continue
            
        with open(imported_file_path, 'r') as f:
            imported_file_content = f.read()

        pattern = rf'{name}\s*=\s*([^;]+);'
        match = re.search(pattern, imported_file_content)
            
        if match:
            param_value = match.group(1).strip()
            break

    return param_value

parameter_flag = 0
print("Enter design file name")
file_name = input()
with open(file_name, "r") as fd:
#with open('rtl/miriscv_core.sv', "r") as fd:
  file_content_with_comments = fd.read()
  start_module_position = file_content_with_comments.find("module ")
  end_module_position = file_content_with_comments.find(");") + 2
  file_content_with_comments = file_content_with_comments[start_module_position:end_module_position]
  print("Рабочая область")
  print(file_content_with_comments)
  file_content = remove_single_line_comments(file_content_with_comments)
  print("Рабочая область без комментариев")
  print(file_content)
  
  module_name = extract_module_name(file_content)
  print("Имя модуля:", module_name)
  
  # Случай, когда есть параметры и importы
  if 'import' in file_content and '#' in file_content:
      parameter_flag = 1
      parameter_names = extract_header_parameter_names(file_content)
      print("Параметры в хэдере")
      print(parameter_names)

      parameter_values_in_header = extract_header_parameter_values(parameter_names, file_content)
      print("Значения параметров в хэдере")
      print(parameter_values_in_header)

      parameter_values_in_include = extract_parameter_from_imports(parameter_names, file_content)
      print("Значения параметров в хэдере из iclude")
      print(parameter_values_in_include)
 
      parameter_values = []
      for name in parameter_names:
        param_value = extract_header_one_parameter_value(name, file_content)
        print(param_value)
        if param_value == None:
            param_value = extract_one_parameter_from_imports(name, file_content, base_path="include")
            parameter_values.append(param_value)
        else:
            parameter_values.append(param_value)
      print("Объединенные параметры")
      print(parameter_values)
      
      decimal_values = [binary_to_decimal(size) for size in parameter_values]
      print(" Десятичные Значения параметров")
      print(decimal_values)

      file_content_without_params = extract_content_between_parentheses(file_content)
      print("Заголовок модуля без входных параметров:")
      print(file_content_without_params)

      file_content_new = replace_parameters_with_values(file_content_without_params, parameter_names, decimal_values)
      print("Подставленные десятичные значения параметров ")
      print(file_content_new)

      sorted_signals = reorder_signals(file_content_new)
      print("Отсортированные данные ")
      print(sorted_signals)

      dut_wrapper_first_stage = calculate_expressions(sorted_signals)
      print("final_text")
      print(dut_wrapper_first_stage)

      dut_wrapper = calculate_expressions(dut_wrapper_first_stage)
      print("final_text")
      print(dut_wrapper)

  # Случай, когда есть только importы
  elif "import" in file_content:
      parameter_flag = 1
      parameter_names = []
      parameter_values = []
      
      parameter_names = extract_header_parameter_names(file_content)
      print("Параметры в хэдере")
      print(parameter_names)

      parameter_values = extract_parameter_from_imports(parameter_names, file_content)
      print("Значения параметров в хэдере из iclude")
      print(parameter_values)

      decimal_values = [binary_to_decimal(size) for size in parameter_values]
      print(" Десятичные Значения параметров")
      print(decimal_values)

      file_content_without_imports = extract_signals_import(file_content)
      print("Заголовок модуля без входных параметров:")
      print(file_content_without_imports)

      file_content_new = replace_parameters_with_values(file_content_without_imports, parameter_names, decimal_values)
      print("Подставленные десятичные значения параметров ")
      print(file_content_new)

      sorted_signals = reorder_signals(file_content_new)
      print("Отсортированные данные ")
      print(sorted_signals)

      dut_wrapper_first_stage = calculate_expressions(sorted_signals)
      print("final_text")
      print(dut_wrapper_first_stage)

      dut_wrapper = calculate_expressions(dut_wrapper_first_stage)
      print("final_text")
      print(dut_wrapper)
  
  #Случай, когда есть только параметры
  elif "#" in file_content:
      parameter_flag = 1
      parameter_names = []
      parameter_names = extract_header_parameter_names(file_content)
      print("Имена параметров в хэдере")
      print(parameter_names)
 
      parameter_values = extract_header_parameter_values(parameter_names, file_content)
      print("Значения параметров в хэдере")
      print(parameter_values)

      decimal_values = [binary_to_decimal(size) for size in parameter_values]
      print(" Десятичные Значения параметров")
      print(decimal_values)

      file_content_without_params = extract_content_between_parentheses(file_content)
      print("Заголовок модуля без входных параметров:")
      print(file_content_without_params)

      file_content_new = replace_parameters_with_values(file_content_without_params, parameter_names, decimal_values)
      print("Подставленные десятичные значения параметров ")
      print(file_content_new)

      sorted_signals = reorder_signals(file_content_new)
      print("Отсортированные данные ")
      print(sorted_signals)

      dut_wrapper_first_stage = calculate_expressions(sorted_signals)
      print("final_text")
      print(dut_wrapper_first_stage)

      dut_wrapper = calculate_expressions(dut_wrapper_first_stage)
      print("final_text")
      print(dut_wrapper)

  #Случай, когда нет ни того, ни другого
  else:
    content = extract_signals(file_content)
    sorted_signals = reorder_signals(content)
    dut_wrapper = calculate_expressions(sorted_signals)
    print(dut_wrapper)


if parameter_flag:
  with open('a.sv', "w") as file:
    file.write("module ")
    file.write(f"{module_name} ")
    file.write("""(\n""")
    file.write(dut_wrapper)
    file.write("""\n""")
    file.write(""");\n""")
else:
    with open('a.sv', "w") as file:
      file.write("module ")
      file.write(f"{module_name} ")
      file.write("""(\n""")
      file.write(dut_wrapper)
      file.write("""\n""")
      file.write(""");\n""")
