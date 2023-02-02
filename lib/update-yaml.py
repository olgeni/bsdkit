#!/usr/bin/env python3

import os
import sys
import getopt
import yaml


def str_presenter(dumper, data):
    """configures yaml for dumping multiline strings
    Ref: https://stackoverflow.com/questions/8640959/how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data"""
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)
yaml.representer.SafeRepresenter.add_representer(str, str_presenter)

KEY_SEPARATOR = "."

if "KEY_SEPARATOR" in os.environ:
    KEY_SEPARATOR = os.environ["KEY_SEPARATOR"]


def set_data_value(data, key, value):
    key_list = key.split(KEY_SEPARATOR)

    p = None
    d = data

    for k in key_list[:-1]:
        if k not in d or not isinstance(d[k], dict):
            d[k] = {}

        p = d
        d = d[k]

    if isinstance(d, dict):
        d[key_list[-1]] = value
    else:
        p[key_list[-2]] = {key_list[-1]: value}


def set_file_value(yaml_file, key, value):
    try:
        with open(yaml_file) as f:
            data = yaml.load(f, Loader=yaml.SafeLoader)
    except FileNotFoundError:
        data = {}

    set_data_value(data, key, value)
    yaml.safe_dump(data, open(yaml_file, "w"), default_flow_style=False, indent=4)


def get_data_value(data, key):
    key_list = key.split(KEY_SEPARATOR)

    d = data

    for k in key_list:
        if k not in d:
            return ""

        if isinstance(d, list):
            return ""

        d = d[k]

    if isinstance(d, dict):
        return yaml.dump(d, default_flow_style=False, indent=4)
    elif isinstance(d, list):
        result = ""
        for item in d:
            result += "%s\n" % item
        return result.strip()
    elif isinstance(d, bool):
        return str(d).lower()
    elif d is None:
        return ""
    else:
        return d


def get_file_value(yaml_file, key):
    with open(yaml_file) as f:
        data = yaml.load(f, Loader=yaml.SafeLoader)
        return get_data_value(data, key)


def delete_data_value(data, key):
    key_list = key.split(KEY_SEPARATOR)

    d = data

    for k in key_list[:-1]:
        if k not in d:
            return

        d = d[k]

    if key_list[-1] in d:
        del d[key_list[-1]]


def delete_file_value(yaml_file, key):
    with open(yaml_file) as f:
        data = yaml.load(f, Loader=yaml.SafeLoader)
        delete_data_value(data, key)
        yaml.dump(data, open(yaml_file, "w"), default_flow_style=False, indent=4)


def list_data_keys(data, path):
    def f(__data, __keys, __path):
        if isinstance(__data, dict):
            for k, v in __data.items():
                if isinstance(v, dict):
                    f(v, __keys, __path + [k])
                else:
                    if path is not None:
                        if len(__path) > 0 and __path == path[: len(__path)]:
                            __keys.append(KEY_SEPARATOR.join(__path[len(path) :] + [k]))
                    else:
                        __keys.append(KEY_SEPARATOR.join(__path + [k]))
        else:
            if path is not None:
                if __path == path[: len(__path)]:
                    __keys.append(KEY_SEPARATOR.join(__path))
            else:
                __keys.append(KEY_SEPARATOR.join(__path))

        return __keys

    return list(sorted(f(data, [], []), key=lambda x: (x.split(KEY_SEPARATOR)[0], len(x))))


def list_file_keys(yaml_file, path):
    with open(yaml_file) as f:
        data = yaml.load(f, Loader=yaml.SafeLoader)
        return list_data_keys(data, path)


if __name__ == "__main__":
    args = sys.argv[1:]

    try:
        opts, args = getopt.getopt(args, "s:")
    except getopt.GetoptError as err:
        print(err)
        sys.exit(2)

    for o, a in opts:
        if o == "-s":
            KEY_SEPARATOR = a

    get_action = lambda: args[0]
    get_filepath = lambda: args[1]
    get_key = lambda: args[2]
    get_value = lambda: args[3]

    try:
        action = get_action()
    except IndexError:
        sys.exit(1)

    try:
        if action == "set":
            value = get_value()
            if value == "-":
                value = sys.stdin.read()
            value = "\n".join([line.rstrip() for line in value.splitlines()])
            set_file_value(get_filepath(), get_key(), value)
        elif action == "get":
            print(get_file_value(get_filepath(), get_key()).rstrip())
        elif action == "del":
            delete_file_value(get_filepath(), get_key())
        elif action == "list":
            try:
                key_list = list_file_keys(get_filepath(), get_key().split(KEY_SEPARATOR))
            except IndexError:
                key_list = list_file_keys(get_filepath(), None)

            for key in key_list:
                print(key)
    except IndexError:
        print("Usage: %s <set|get|delete|get-keys> <file> <key> [value]" % sys.argv[0], file=sys.stderr)
        sys.exit(1)
