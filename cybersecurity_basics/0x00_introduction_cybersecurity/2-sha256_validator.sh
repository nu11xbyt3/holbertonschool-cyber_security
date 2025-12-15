#!/bin/bash
sha256sum $1 > $1.sha256  # Generate the checksum file
sha256sum -c $1.sha256    # Validate the file's checksum
