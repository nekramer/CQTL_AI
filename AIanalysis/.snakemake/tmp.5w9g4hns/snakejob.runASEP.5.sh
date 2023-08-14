#!/bin/sh
# properties = {"type": "single", "rule": "runASEP", "local": false, "input": ["../processing/output/AI/chr4_ASEPfinal.txt"], "output": ["data/chr4_ASEP.rda"], "wildcards": {"chrom": "4"}, "params": {"chrom": "4"}, "log": ["logs/runASEP_chr4.out"], "threads": 8, "resources": {}, "jobid": 5, "cluster": {"name": "runASEP", "partition": "general", "time": 4320, "cpusPerTask": "8", "memPerCpu": "4G", "nodes": 1, "output": "logs/runASEP.5.out", "error": "logs/runASEP.5.err"}}
 cd /pine/scr/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis && \
/pine/scr/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis/env/bin/python3 \
-m snakemake data/chr4_ASEP.rda --snakefile /pine/scr/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis/snakefiles/runASEP.smk \
--force -j --keep-target-files --keep-remote \
--wait-for-files /pine/scr/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis/.snakemake/tmp.5w9g4hns ../processing/output/AI/chr4_ASEPfinal.txt --latency-wait 5 \
 --attempt 1 --force-use-threads \
--wrapper-prefix https://github.com/snakemake/snakemake-wrappers/raw/ \
   --allowed-rules runASEP --nocolor --notemp --no-hooks --nolock \
--mode 2  && touch "/pine/scr/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis/.snakemake/tmp.5w9g4hns/5.jobfinished" || (touch "/pine/scr/n/e/nekramer/CQTL_GIT/CQTL/AllelicImbalance/AIanalysis/.snakemake/tmp.5w9g4hns/5.jobfailed"; exit 1)

