import csv

def convert_csv_to_custom(input_csv: str, output_file: str):
  with open(input_csv, newline='') as f_in, open(output_file, 'w') as f_out:
    reader = csv.DictReader(f_in)
    f_out.write('{\n')
    for row in reader:
      r = row['radius']
      x = row['x']
      y = row['y']
      z = row['z']
      line = f'  {{ {r}, Vec( {x}, {y}, {z} ) }},\n'
      f_out.write(line)
    f_out.write('}\n')

  print(f'已生成文件 {output_file}')

if __name__ == '__main__':
  convert_csv_to_custom('spheres.csv', 'spheres_formatted.txt')
