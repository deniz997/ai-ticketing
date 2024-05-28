#!/bin/bash

original=$(find ./output_files -type f -name '*.yaml' | wc -l)
total=$(find ./kustomize -type f -name '*.yaml' | wc -l)
kustomization=$(find ./kustomize -type f -name 'kustomization.yaml' | wc -l)

# from original we deducted one file because it contains a header only
echo "Original Expected: $((original - 1)) vs Current: [kustomization: $kustomization, total: $total] => $(($total - $kustomization))"