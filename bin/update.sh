#!/usr/bin/env bash
git add .
git status
git commit -m "chore: Updated on $(date +%Y-%m-%d\ %H:%M)"
git push origin master