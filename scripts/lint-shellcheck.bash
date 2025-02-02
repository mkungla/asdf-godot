#!/usr/bin/env bash

shellcheck --shell=bash --external-sources \
	bin/* --source-path=template/lib/ \
	lib/* \
	scripts/*
