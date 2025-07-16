# Copyright (c) 2025 Konvt
# This file is licensed under the Mozilla Public License 2.0.
# See the LICENSE file in the project root for license terms.
import os
import re
import textwrap

def read_utf8(path: str) -> str:
  with open(path, 'r', encoding='utf-8') as f:
    return f.read()

def to_mod_str(modfpath: str) -> str:
  normalpath = os.path.normpath(modfpath)
  if normalpath == '.':
    return ''
  normalpath = os.path.normpath(
    normalpath.removesuffix('init.lua').removesuffix('.lua'))
  return normalpath.replace(os.sep, '.')

def to_path_str(reqstr: str) -> str:
  return reqstr.replace('.', os.sep)

def find_module_file(candidates: set[str], reqpath: str) -> tuple[str, bool]:
  '''
  Args:
    candidates: 备选搜索路径集合
    reqpath: 模块路径，可能对应 {reqpath}.lua 或 {reqpath}/init.lua

  Returns:
    (找到的路径, 是否为 init.lua)

  Raises:
    FileNotFoundError: 未找到匹配文件
  '''
  for path in candidates:
    fileprefix = os.path.join(path, reqpath)
    filepath = f'{fileprefix}.lua'
    if os.path.isfile(filepath):
      return filepath, False
    filepath = os.path.join(fileprefix, 'init.lua')
    if os.path.isfile(filepath):
      return filepath, True
  raise FileNotFoundError(f'files not found in "{reqpath}"')

class LuaLinker:
  RE_REQUIRE = re.compile(r'require\s*\(?\s*[\'"]([\w\.]+)[\'"]\s*\)?')
  RE_STR = re.compile(r'''(['"])(?:\\.|(?!\1).)*\1''')
  RE_LINE = re.compile(r'--[^\[].*?(?=\n|$)')
  RE_BLOCK = re.compile(r'--\[\[.*?\]\]', re.S)
  RE_HEAD_WS = re.compile(r'^[ \t]+', re.M)
  RE_INNER_WS = re.compile(r'(?<=\S)[ \t]{2,}(?=\S)')
  RE_SYM_WS = re.compile(r'([^\w\s<>])\s+([^\w\s<>])')
  RE_EDGE_WS = re.compile(r'\s*([^\w\s<>])\s*')

  @classmethod
  def clean_lua(cls, content: str) -> str:
    strings = []
    def repl(m):
      strings.append(m.group())
      return f'__STR_{len(strings)-1}__'
    content = cls.RE_STR.sub(repl, content)
    content = cls.RE_BLOCK.sub('', content)
    content = cls.RE_LINE.sub('', content)
    content = cls.RE_HEAD_WS.sub('', content)
    content = cls.RE_INNER_WS.sub(' ', content)
    content = cls.RE_SYM_WS.sub(r'\1\2', content)
    content = cls.RE_EDGE_WS.sub(r'\1', content)
    for i, s in enumerate(strings):
      content = content.replace(f'__STR_{i}__', s)
    return ' '.join(line for line in content.splitlines() if line.strip())

  @classmethod
  def find_require_modules(cls, content: str) -> set[str]:
    return set(cls.RE_REQUIRE.findall(content))

  def __init__(self, entry: str, output: str):
    if not os.path.isfile(entry):
      raise ValueError(f'Expected a file, got: {entry}')
    self._basepath = os.path.abspath(os.path.dirname(entry))
    self._entry = os.path.basename(entry)
    self._output = output

  def pack(self):
    self._searchpaths = {self._basepath}
    self._visited: set[str] = set()
    # self._modules = {'modname': 'content'}
    self._modules: dict[str, str] = {}
    entry_content = read_utf8(os.path.join(self._basepath, self._entry))

    for reqmod in self.find_require_modules(entry_content):
      reqpath = to_path_str(reqmod)
      filepath, is_init_lua = find_module_file(self._searchpaths, reqpath)
      if is_init_lua:
        parentdir = os.path.dirname(filepath)
        self._searchpaths.update([parentdir, os.path.dirname(parentdir)])
      self._scan_module(filepath)
    self._write_out(entry_content)

  def _replace_requires_abs(self, content: str) -> str:
    def repl(m: re.Match) -> str:
      requiredfile = to_path_str(m.group(1))
      for path in self._searchpaths:
        targetpath = os.path.join(path, requiredfile)

        if (os.path.isfile(f'{targetpath}.lua')
            or os.path.isfile(os.path.join(targetpath, 'init.lua'))):
          modpath = to_mod_str(os.path.relpath(path, self._basepath))
          return f"require( '{'.'.join([modpath, m.group(1)] if modpath else [m.group(1)])}' )"
      raise FileNotFoundError(f'required file "{requiredfile}" not found')

    return re.sub(self.RE_REQUIRE, repl, content)

  def _scan_module(self, scannedfile: str):
    '''
    Args:
      scannedfile: 被扫描文件路径
    '''
    if scannedfile in self._visited:
      return
    self._visited.add(scannedfile)

    content = self._replace_requires_abs(read_utf8(scannedfile))
    for reqmod in self.find_require_modules(content):
      reqpath = to_path_str(reqmod)
      filepath, is_init_lua = find_module_file(self._searchpaths, reqpath)
      if is_init_lua:
        parentdir = os.path.dirname(filepath)
        self._searchpaths.update([parentdir, os.path.dirname(parentdir)])
      self._scan_module(filepath)

    modname = to_mod_str(os.path.relpath(scannedfile, self._basepath))
    self._modules[modname] = content

  def _write_out(self, entry_content: str):
    with open(self._output, 'w', encoding='utf-8') as f:
      f.write(textwrap.dedent(f'''\
        --- Copyright (c) 2025 Konvt
        --- This mod is licensed under the Mozilla Public License 2.0.
        --- See the LICENSE file in the project root for license terms.
        --- Project page: https://github.com/Konvt/teardown_gunship

        --- This file is automatically generated by the lua linker.
        --- Please do not modify it manually.
        if package == nil then package = {{}} end
        if package.loaded == nil then package.loaded = {{}} end
        if package.preload == nil then package.preload = {{}} end
        if require == nil then
          require = function( name )
            if package.loaded[name] then
              return package.loaded[name]
            end
            local loader = package.preload[name]
            if not loader then
              error( 'module "' .. name .. '" not found' )
            end
            local mod = loader()
            package.loaded[name] = mod
            return mod
          end
        end\n'''))
      # TODO: 引入静态分析器，分析引用关系并剔除所有未使用子模块
      for mod, func in self._modules.items():
        f.write(f'package.loaded[\'{mod}\'] = nil\n'
                f'package.preload[\'{mod}\'] = function(...)\n'
                f'{self.clean_lua(func)}\nend\n\n')
      f.write(self.clean_lua(entry_content))

if __name__ == '__main__':
  import sys
  if len(sys.argv) != 3:
    print("Usage: python linker.py <input_file> <output_file>")
    sys.exit(1)

  LuaLinker(sys.argv[1], sys.argv[2]).pack()
