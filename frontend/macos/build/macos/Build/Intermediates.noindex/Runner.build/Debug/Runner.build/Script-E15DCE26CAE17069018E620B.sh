#!/bin/sh
xattr -cr "${CODESIGNING_FOLDER_PATH}" 2>/dev/null || true
