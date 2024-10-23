import os
import glob
import openbabel

# 设置输入和输出文件夹
input_folder = 'C:\\Users\\10042\\Desktop\\TNF'
output_folder = 'C:\\Users\\10042\\Desktop\\TNFPDB'

# 创建输出文件夹（如果不存在）
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

# 获取所有 .ent 文件
ent_files = glob.glob(os.path.join(input_folder, '*.ent'))

# 初始化 OpenBabel
ob_conversion = openbabel.OBConversion()
ob_conversion.SetInAndOutFormats('ent', 'pdb')

# 遍历所有 .ent 文件并转换为 .pdb
for ent_file in ent_files:
    # 获取文件名（不带路径和扩展名）
    base_name = os.path.basename(ent_file).split('.')[0]
    # 设置输出文件路径
    pdb_file = os.path.join(output_folder, f'{base_name}.pdb')
    
    # 读取 .ent 文件
    mol = openbabel.OBMol()
    ob_conversion.ReadFile(mol, ent_file)
    
    # 写入 .pdb 文件
    ob_conversion.WriteFile(mol, pdb_file)
    
    print(f'Converted {ent_file} to {pdb_file}')

print('All files converted successfully.')