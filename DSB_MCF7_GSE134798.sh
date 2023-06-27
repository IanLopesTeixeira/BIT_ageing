#!/bin/bash

cut -d$'\t' -f1,2,3 ./MCF7/GSM4520693_REP1_0NAC_0Gy.clean.umi_dedup.aggregated.bed > ./MCF7/GSM4520693_REP1_0NAC_0Gy.bed

cut -d$'\t' -f1,2,3 ./MCF7/GSM4520697_REP2_0NAC_0Gy.clean.umi_dedup.aggregated.bed > ./MCF7/GSM4520697_REP2_0NAC_0Gy.bed

cut -d$'\t' -f1,2,3 ./MCF7/GSM4520701_REP3_0NAC_0Gy.clean.umi_dedup.aggregated.bed > ./MCF7/GSM4520701_REP3_0NAC_0Gy.bed

cat ./MCF7/GSM4520693_REP1_0NAC_0Gy.bed ./MCF7/GSM4520697_REP2_0NAC_0Gy.bed ./MCF7/GSM4520701_REP3_0NAC_0Gy.bed | sort -k1,1 -k2,2n -k3,3n | uniq > ./MCF7/DSB_MCF7_single.bed

grep -i '^chr' ./MCF7/DSB_MCF7_single.bed > ./MCF7/DSB_MCF7_single.chr_trimming.bed

grep -v '^chrM' ./MCF7/DSB_MCF7_single.chr_trimming.bed > ./MCF7/DSB_MCF7_single.chr_trimming.chrM_removal.bed