#!/bin/sh
# properties = {"type": "single", "rule": "getLD_buddies", "local": false, "input": ["/work/users/n/e/nekramer/Data/CQTL/AI/freeze/AIsigFNF05variantIDs.txt"], "output": ["/work/users/n/e/nekramer/Data/CQTL/AI/freeze/LD_buddies/chr10:70871869:C:T_FNF_0.8.ld"], "wildcards": {"snp": "chr10:70871869:C:T", "condition": "FNF"}, "params": {"LDref": "/work/users/n/e/nekramer/Data/CQTL/geno/CQTL_COA_01_GDA8_COA2_01_COA3_01_GDA8_COA4_COA5_COA6_COA7_ALL_qc"}, "log": ["logs/getLD_buddies_FNF_chr10:70871869:C:T.out"], "threads": 1, "resources": {}, "jobid": 221, "cluster": {"name": "getLD_buddies", "partition": "general", "time": "10-00:00:00", "cpusPerTask": "1", "memPerCpu": "6G", "nodes": 1, "output": "logs/getLD_buddies.221.out", "error": "logs/getLD_buddies.221.err"}}
 cd /work/users/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis && \
/nas/longleaf/apps/python/3.6.6/bin/python3.6 \
-m snakemake /work/users/n/e/nekramer/Data/CQTL/AI/freeze/LD_buddies/chr10:70871869:C:T_FNF_0.8.ld --snakefile /work/users/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis/snakefiles/AI_LD_buddies.smk \
--force -j --keep-target-files --keep-remote \
--wait-for-files /work/users/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis/.snakemake/tmp.obbwyjuv /work/users/n/e/nekramer/Data/CQTL/AI/freeze/AIsigFNF05variantIDs.txt --latency-wait 5 \
 --attempt 1 --force-use-threads \
--wrapper-prefix https://github.com/snakemake/snakemake-wrappers/raw/ \
   --allowed-rules getLD_buddies --nocolor --notemp --no-hooks --nolock \
--mode 2  && exit 0 || exit 1

