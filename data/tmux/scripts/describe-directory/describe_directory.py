#!/usr/bin/python3

import functools
import os
import re
import subprocess
import yaml

@functools.lru_cache(0) # TODO: 0, 1 or None?
def load_config():
  with open(os.path.normpath(f'{os.path.dirname(__file__)}/../data.yml'), 'r') as stream:
    try:
      return yaml.load(stream)
    except yaml.YAMLError as err:
      print(err, file=sys.stderr)
      return {}

def substitute_home(path):
  home = os.environ['HOME']
  if path.startswith(home):
    path = '~' + path[len(home):]
  return path

def limit_path_length(path, config=load_config()):
  if len(path) > config['path-length-limit']:
    start = path.find(os.sep, 2, 2 + config['path-start-length']) + 1
    if start == 0:
      start = path.find(os.sep, 0, 2) + config['path-start-length'] + 1
    end = len(path) - config['path-length-limit'] + 1 + start
    path = f'{path[:start]}…{path[end:]}'
  return path

def git_description(path, config=load_config()):
  if os.path.isdir(path):
    head = subprocess.run(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if head.returncode == 0:
      head = head.stdout.decode('utf-8').splitlines()[0]
      flags = {
        'ahead': False,
        'behind': False,
        'staged': False,
        'unstaged': False,
        'untracked': False,
        'unmerged': False
      }
      if head == "HEAD":
        head = subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode('utf-8')[:7]
      else:
        base = subprocess.run(['git', 'merge-base', head, f'origin/{head}'], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if base.returncode == 0:
          base = base.stdout.decode('utf-8').splitlines()[0]
          local = subprocess.run(['git', 'rev-parse', '--verify', head], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode('utf-8').splitlines()[0]
          remote = subprocess.run(['git', 'rev-parse', '--verify', f'origin/{head}'], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode('utf-8').splitlines()[0]
          if base == local:
            if local == remote:
              pass # local branch is up to date with remote branch
            else:
              flags['behind'] = True
          elif base == remote:
            flags['ahead'] = True
          else:
            pass # local branch and remote branch have diverged
      porcelain = subprocess.run(['git', 'status', '--porcelain=2'], cwd=path, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
      if porcelain.returncode == 0:
        porcelain = porcelain.stdout.decode('utf-8')
        staged_regex = re.compile(r'D[\.M]|[MARC][\.MD]')
        unstaged_regex = re.compile(r'[\.MARC][MD]')
        for line in porcelain.splitlines():
          if not flags['untracked'] and line.startswith("?"):
            flags['untracked'] = True
          elif not flags['unmerged'] and line.startswith("u"):
            flags['unmerged'] = True
          elif line.startswith("1") or line.startswith("2"):
            xy = line[2:4]
            if not flags['staged'] and staged_regex.fullmatch(xy):
              flags['staged'] = True
            elif not flags['unstaged'] and unstaged_regex.fullmatch(xy):
              flags['unstaged'] = True
      desc = config['git-branch-color'] + head
      any_flag = False
      for flag, value in flags.items():
        if value:
          any_flag = True
          desc += config['set-git-flag-color'][flag] + config['git-flag-symbol'][flag]
      if any_flag:
        desc += config['set-default-color']
      return desc
  return ""

def describe(path):
  config = load_config()

  short_path = substitute_home(path)
  short_path = limit_path_length(short_path, config=config)

  git = git_description(path, config=config)
  if git:
    git = f' ({git})'

  return f"{short_path}{git}"

if __name__ == "__main__":
  import sys
  desc = describe(sys.argv[1] if len(sys.argv) > 1 else os.path.abspath(os.curdir))
  print(desc)