#!/bin/bash

conda create -n wesqc
conda activate wesqc
conda install pandas
conda install -c bioconda verifybamid2 mosdepth

