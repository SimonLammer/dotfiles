#!/bin/python3

"""
Renders jinja2 templates in the context of variables loaded from yaml files.

Templates and variables passed with '-v' or '-t' will be processed in the order they were passed.
Templates passed as positional arguments will always be parsed at the end (after any '-v' and '-t' arguments).
There may be multiple '-v' and '-t' argument groups.

The topmost file extension is removed from template files upon rendering.

Files that have already been processed will be ignored in further blobs.
(This holds for both variable and template files.)

Let's take a look at a few examples to understand this.

1. Arguments: `file.j2`

  1. Render template 'file.j2' to 'file'.

2. Arguments: `file.j2 -v vars.yml` (equivalent to `-v vars.yml -t file.j2`)

  1. Load variables from 'vars.yml'.
  2. Render template 'file.j2' to 'file'.

3. Arguments: `file.j2 -t vars.yml.j2 -v vars.yml` (equivalent to `-t vars.yml.j2 -v vars.yml -t file.j2`)

  1. Render template 'vars.yml.j2' to 'vars.yml'.
  2. Load variables from 'vars.yml' (that has just been rendered).
  3. Render template 'file.j2' to 'file'.

4. Arguments: `file.j2 -v vars.yml.j2.yml -t vars.yml.j2 -v vars.yml`
   (Equivalent to `file.j2 -v '*.j2.yml' -t '*.yml.j2' -v '*.yml'` assuming those are the only file in the directory.)

  1. Load variables from 'vars.yml.j2.yml'.
  2. Render template 'vars.yml.j2' to 'vars.yml'.
  3. Load variables from 'vars.yml' (that has just been rendered).
  4. Render template 'file.j2' to 'file'.

Variable and template file arguments are interpreted as globs by python's 'glob' package: https://docs.python.org/3/library/glob.html

"""

LOGLEVEL_DEFAULT = 'INFO' # can be overwritten via environment variable 'LOGLEVEL'
TEMPLATE_EXTENSION = '.j2'


import difflib
import logging
import os
import shutil
import yaml
from jinja2 import Environment, FileSystemLoader
from jinja2_ansible_filters import AnsibleCoreFiltersExtension
from glob import glob
from tempfile import TemporaryDirectory
from typing import List, Dict


LOGGER = logging.getLogger(__name__)
logging.basicConfig(format="[%(asctime)s %(levelname)8s] %(message)s   (L%(lineno)s)")
LOGGER.setLevel(level=os.getenv('LOGLEVEL', LOGLEVEL_DEFAULT).upper())

CONFIG = None

def main(commands) -> None:
  environment = create_template_environment()
  variables = {}

  processed_files = set()
  for command, files_globs in commands:
    files = []
    for files_glob in files_globs:
      LOGGER.debug(f"Expanding glob '{files_glob}'.")
      for f in glob(files_glob, recursive=True):
        if f in processed_files:
          LOGGER.debug(f"Skipping already processed '{f}'.")
          continue
        processed_files.add(f)
        files.append(f)
    if not files:
      LOGGER.warning(f"No files found for glob '{files_glob}'.")
      continue
    if command in ('-v', '--variables'):
      variables = merge_dicts(load_variables_files(files), variables)
    else:
      render_templates(environment, files, variables)

def create_template_environment() -> Environment:
  env = Environment(
    autoescape=False,
    extensions=[AnsibleCoreFiltersExtension],
    loader=FileSystemLoader(
      os.path.dirname('.')
    ),
    trim_blocks=True,
  )
  return env

def load_variables_file(yaml_file: str) -> Dict:
  LOGGER.debug(f"Loading variable file '{yaml_file}'")
  with open(yaml_file, 'r') as f:
    data = yaml.safe_load(f) # TODO: cache?
    if type(data) is not dict:
      msg = f"The variable file '{yaml_file}' did not load as a dictionary."
      raise RuntimeError(msg)
    return data

def load_variables_files(files: List[str]) -> Dict:
  if type(files) is not list:
    files = list(files)
  LOGGER.info(f"Loading variables from files {files}")
  return merge_dicts(*map(load_variables_file, files))

def merge_dicts(*dicts: List[Dict]) -> Dict:
  if not dicts:
    return dict()
  elif len(dicts) == 1:
    return dicts[0]
  elif len(dicts) == 2:
    merged = dicts[0].copy()
    merged.update(dicts[1])
    return merged
  else:
    pivot = len(dicts) // 2
    return merge_dicts(merge_dicts(*dicts[:pivot]), merge_dicts(*dicts[pivot:]))

def render_templates(environment: Environment, files: List[str], variables: Dict) -> None:
  if type(files) is not list:
    files = list(files)
  LOGGER.info(f"Rendering templates {files}")
  with TemporaryDirectory() as tmpdir:
    for f in files:
      target = '.'.join(f.split('.')[:-1])
      assert target != ''
      target_tmp = os.path.join(tmpdir, target.replace('/', '\x1a'))
      LOGGER.debug(f"Rendering template '{f}' to '{target_tmp}'")
      environment \
        .get_template(f) \
        .stream(variables) \
        .dump(target_tmp)
      if CONFIG.diff:
        try:
          with open(target, 'r') as render_old:
            old = render_old.readlines()
        except FileNotFoundError:
          old = ''
        with open(target_tmp, 'r') as render_new:
          diff = difflib.context_diff(
            old,
            render_new.readlines(),
            fromfile=target,
          )
          print(''.join(diff), end='')
      if not CONFIG.dry_run:
        try:
          shutil.copystat(target, target_tmp)
        except FileNotFoundError:
          pass
        shutil.move(target_tmp, target)


def parse_cli_config():
  import argparse
  parser = argparse.ArgumentParser(
    description="Renders (Jinja2-)templated files",
    epilog=__doc__,
    formatter_class=argparse.RawTextHelpFormatter,
  )

  class StoreOrderedAction(argparse.Action):
      """
      A custom action to store (action_name, values) in a list,
      preserving the order in which actions appear.
      """
      def __call__(self, parser, namespace, values, option_string=None):
          store = getattr(namespace, self.dest)
          if not store:
            store = []
          store.append((option_string, values))
          setattr(namespace, self.dest, store)
  ag_operational = parser.add_argument_group("operational")
  ag_operational.add_argument(
    '--diff',
    help="Show differences between old and new rendered templates.",
    action='store_true',
  )
  ag_operational.add_argument(
    '--dry-run',
    help="Don't actually render the templates. (Useful in combination with --diff.)",
    action='store_true',
  )

  ag_commands = parser.add_argument_group("commands")
  ag_commands.add_argument(
      '-t', '--templates',
      help="Globs of template files to render.",
      metavar="TEMPLATE_GLOB",
      nargs='+',
      action=StoreOrderedAction,
      dest='commands',
  )
  ag_commands.add_argument(
      '-v', '--variables',
      help="Globs of variable files to load.",
      metavar="VARIABLE_GLOB",
      nargs='+',
      action=StoreOrderedAction,
      dest='commands',
  )
  ag_commands.add_argument(
      'pos_templates',
      metavar="TEMPLATE_GLOB",
      help="Globs of template files to render.",
      nargs='*',
      action='append',
      default=[],
  )
  config = parser.parse_args()
  if not config.commands:
    config.commands = []
  if config.pos_templates[0]:
    config.commands.extend((None, t) for t in config.pos_templates)
  del config.pos_templates
  # LOGGER.debug(f"{config=}")
  return config

if __name__ == '__main__':
  CONFIG = parse_cli_config()
  main(CONFIG.commands)

