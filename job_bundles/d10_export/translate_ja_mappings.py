import json
import os

from System.Text.RegularExpressions import Regex


def __main__(ja_mappings_path: str, output_path: str):
    """
    Translates a JSON file containing JobAttachment mappings
    into a JSON file containing matching Deadline10 Path Mapping rules.
    """

    ja_mappings = {}
    with open(ja_mappings_path, "r") as input_file:
        ja_mappings = json.load(input_file)

    
    path_mapping_rules = []
    for ja_entry in ja_mappings['path_mapping_rules']:
        source_path = ja_entry['source_path']
        dest_path = ja_entry['destination_path']

        # Make sure dest_path ends with a single dir separator
        dest_path = dest_path.rstrip(os.sep) + os.sep

        # Job Attachment asset roots should always be at the beginning of a path
        source_regex = "^" + Regex.Escape(source_path)

        if dest_path.startswith(source_path):
            # We want to make sure the rule isn't recursively applied in cases where
            # the destination path contains the source path (e.g., '/' -> '/tmp/assets/...' ).
            # A source asset root of '/' is a notably common case here.
            added_part = Regex.Escape(dest_path[len(source_path):])
            source_regex += f'(?!{added_part})'

        path_mapping_rules.append({
            'CaseSensitive': True,
            'RegularExpression': True,
            'Path': source_regex,
            # Since these settings are only used locally, just set dest path for all platforms.
            'LinuxPath': dest_path,
            'MacPath': dest_path,
            'WindowsPath': dest_path,
        })

    repo_settings = {
        'MappedOSPath': path_mapping_rules
    }
    with open(output_path, "w") as output_file:
        json.dump(repo_settings, output_file, indent=4)
