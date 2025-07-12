# Copyright (c) 2025 Konvt
# This file is licensed under the Mozilla Public License 2.0.
# See the LICENSE file in the project root for license terms.
import os
import tempfile
import shutil
import zipfile
import linker

PackagedFiles = ['images/', 'sounds/', 'vox/',
           'info.txt', 'LICENSE', 'README.md',
           'preview.jpg']

if __name__ == '__main__':
  base_dir = os.path.abspath(os.path.dirname(__file__))
  tmpdir = tempfile.mkdtemp(dir=base_dir)
  try:
    linked_main = os.path.join(tmpdir, 'main.lua')
    linked_options = os.path.join(tmpdir, 'options.lua')
    linker.LuaLinker('main.lua', linked_main).pack()
    linker.LuaLinker('options.lua', linked_options).pack()
    PackagedFiles.extend([linked_main, linked_options])

    with zipfile.ZipFile(os.path.join(base_dir, 'GunshipAirstrike.zip'),
                         'w', zipfile.ZIP_DEFLATED) as zipf:
      for item in PackagedFiles:
        abs_item = os.path.join(base_dir, item) if not os.path.isabs(item) else item
        if os.path.isdir(abs_item):
          for root, _, files in os.walk(abs_item):
            for file in files:
              rel = os.path.relpath(os.path.join(root, file), base_dir)
              zipf.write(os.path.join(root, file), rel)
        elif os.path.isfile(abs_item):
          if abs_item.startswith(tmpdir):
            zipf.write(abs_item, os.path.basename(abs_item))
          else:
            rel = os.path.relpath(abs_item, base_dir)
            zipf.write(abs_item, rel)
  finally:
    shutil.rmtree(tmpdir)
