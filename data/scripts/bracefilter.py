#!/usr/bin/env python3

import sys


indentation = '\x1b[92m|\x1b[0m' if sys.stdout.isatty() else '|' + ' ' * 1
escape_char = '\\'
quotes = (
  "''",
  '""',
)
parentheses = (
  '()',
  '[]',
  '{}',
  # '<>',
)


def main():
    s = sys.stdin.read()
    closing_parentheses = []
    escape_next = False
    quote = None
    for c in s:
        suffix_line_break = False
        if not escape_next:
            if escape_char == c:
                escape_next = True
            elif quote == c:
                quote = None
            else:
                for q in quotes:
                    if c == q[0]:
                        quote = q[1]
                        break
                else:
                    if quote is None:
                        if len(closing_parentheses) > 0 and c == closing_parentheses[-1]:
                            closing_parentheses.pop()
                            sys.stdout.write(f"\n{indentation * len(closing_parentheses)}")
                        else:
                            for p in parentheses:
                                if c == p[0]:
                                    closing_parentheses.append(p[1])
                                    suffix_line_break = True
                                    break
        else:
            escape_next = False
        sys.stdout.write(c)
        if suffix_line_break:
            sys.stdout.write(f"\n{indentation * len(closing_parentheses)}")


if __name__ == '__main__':
    try:
        main()
    except BrokenPipeError:
        pass

