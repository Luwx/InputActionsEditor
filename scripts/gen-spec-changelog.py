#!/usr/bin/env python3
"""Generate an RPM %changelog block from CHANGELOG.md.

Usage:
    gen-spec-changelog.py CHANGELOG.md VERSION [RELEASE]

The top-most section is treated as the release currently being built:
  - if it is `[Unreleased]` (or matches VERSION) it is emitted with the given
    VERSION-RELEASE and today's date;
  - every older `[X.Y.Z] - DATE` section is emitted verbatim with release 1.

Output goes to stdout, newest entry first, ready to drop in after `%changelog`.
"""
import datetime
import re
import sys

PACKAGER = "Luwx <mail@luwx.dev>"


def parse(path):
    sections = []
    name = None
    date = None
    bullets = []
    header = re.compile(r"^##\s+\[([^\]]+)\](?:\s*-\s*(\d{4}-\d{2}-\d{2}))?")
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            m = header.match(line)
            if m:
                if name is not None:
                    sections.append((name, date, bullets))
                name, date, bullets = m.group(1), m.group(2), []
            elif name is not None and line.lstrip().startswith("- "):
                bullets.append(line.lstrip()[2:].rstrip())
    if name is not None:
        sections.append((name, date, bullets))
    return sections


def rpm_date(iso):
    d = datetime.date.fromisoformat(iso) if iso else datetime.date.today()
    return d.strftime("%a %b %d %Y")


def main():
    if len(sys.argv) < 3:
        sys.exit("usage: gen-spec-changelog.py CHANGELOG.md VERSION [RELEASE]")
    path, version = sys.argv[1], sys.argv[2]
    release = sys.argv[3] if len(sys.argv) > 3 else "1"

    out = []
    for i, (name, date, bullets) in enumerate(parse(path)):
        if not bullets:
            continue
        if i == 0 and (name.lower() == "unreleased" or name == version):
            evr, when = f"{version}-{release}", rpm_date(None)
        elif name.lower() == "unreleased":
            continue  # an unreleased section that isn't the current build
        else:
            evr, when = f"{name}-1", rpm_date(date)
        out.append(f"* {when} {PACKAGER} - {evr}")
        out.extend(f"- {b}" for b in bullets)
        out.append("")

    sys.stdout.write("\n".join(out).rstrip() + "\n")


if __name__ == "__main__":
    main()
