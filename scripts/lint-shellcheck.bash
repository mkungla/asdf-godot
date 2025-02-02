#!/usr/bin/env bash

find bin scripts lib -type f -exec shellcheck --shell=bash --external-sources --source-path=lib {} +
