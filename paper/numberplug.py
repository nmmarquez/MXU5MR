from string import Formatter
import os
import json


def load_paper():
    base = os.environ["HOME"]
    with open(base + '/Documents/MXU5MR/paper/outline.md', 'r') as myfile:
        data = myfile.read()
    return data


def get_keys():
    string = load_paper()
    brackets = ["", ""]
    if len(brackets) != 2:
        raise ValueError('Expected two brackets. Got {}.'.format(len(brackets)))
    padded = string.replace('{', '{{').replace('}', '}}')
    substituted = padded.replace(brackets[0], '{').replace(brackets[1], '}')
    plugs_ = {k[1]: "PLUG ME" for k in Formatter().parse(substituted) if
              k[1] is not None}
    return plugs_


def rebase_plugs():
    keys = get_keys()
    base = os.environ["HOME"]
    plug_json = base + "/Documents/MXU5MR/paper/plugs.json"
    if os.path.isfile(plug_json):
        with open(plug_json, 'r') as infile:
            curdata = json.load(in_file)
        keys.update(curdata)
    with open(plug_json, 'w') as outfile:
        json.dump(keys, outfile)


def plug_paper():
    base = os.environ["HOME"]
    f_ = base + "/Documents/MXU5MR/paper/thesisplugged.md"
    string = load_paper()
    keys = get_keys()
    padded = string.replace('{', '{{').replace('}', '}}')
    substituted = padded.replace(brackets[0], '{').replace(brackets[1], '}')
    formatted = substituted.format(*args, **kwargs)
    with open(f_, "w") as text_file:
        text_file.write(formatted)
