#!/bin/bash
# config.sh - Shared configuration for activity summary scripts

# Repository list - used for fetching activity and validating links
REPOS=(
  "libp2p/libp2p"
  "libp2p/go-libp2p"
  "libp2p/rust-libp2p"
  "libp2p/js-libp2p"
  "libp2p/py-libp2p"
  "libp2p/jvm-libp2p"
  "vacp2p/nim-libp2p"
  "zen-eth/zig-libp2p"
  "NethermindEth/dotnet-libp2p"
  "Pier-Two/c-libp2p"
  "paritytech/litep2p"
  "libp2p/specs"
  "libp2p/test-plans"
  "libp2p/universal-connectivity"
  "libp2p/workshop"
  "swift-libp2p/swift-libp2p"
)

# Prohibited word patterns (case-insensitive regex)
# Note: Using patterns to catch variations
PROHIBITED_PATTERNS=(
  # Common profanity
  'f[u\*@]ck'
  'sh[i\*@]t'
  'damn'
  'crap'
  '\bass\b'
  'bitch'
  'bastard'
  '\bhell\b'
  # Slurs and offensive terms
  'retard'
  '\bidiot\b'
  '\bstupid\b'
  '\bmoron\b'
  # Disparaging phrases about the project
  'libp2p sucks'
  'libp2p is (bad|terrible|awful|broken|garbage|trash|dead)'
  'waste of time'
  'poorly (designed|implemented|written)'
  'incompetent'
  '\buseless\b'
)

# Negative sentiment patterns (warning level, non-blocking)
NEGATIVE_SENTIMENT_PATTERNS=(
  'unfortunately'
  'sadly'
  'regrettably'
  'failed to'
  'still broken'
  'still not working'
  'no progress'
  '\babandoned\b'
  'dead project'
)
