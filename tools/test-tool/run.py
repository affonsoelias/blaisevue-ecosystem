#!/usr/bin/env python3
import sys

print("[test-tool] Running test-tool CLI verification...")
if len(sys.argv) > 1:
    print(f"Arguments: {sys.argv[1:]}")
