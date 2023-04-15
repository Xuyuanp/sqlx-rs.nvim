import json
import sys

import sqlparse


def main():
    kwargs = json.load(sys.stdin)

    for i in range(10):
        kwargs["sql"] = kwargs["sql"].replace(f"?{i}", f"__id_{i}")

    result = sqlparse.format(**kwargs)

    for i in range(10):
        result = result.replace(f"__id_{i}", f"?{i}")

    print(result)


if __name__ == "__main__":
    main()
