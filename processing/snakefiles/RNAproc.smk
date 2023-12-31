#!/usr/bin/env python3

rule catR1:
    input:
        lambda wildcards: read1.get(wildcards.group)
    output:
        "output/{group}/fastq/{group}_R1.fastq.gz"
    threads: 1
    log:
        err = "output/{group}/logs/{group}_catR1.err"
    shell:
        """
        mkdir -p output/{wildcards.group}/fastq
        cat {input} > {output} 2> {log.err}
        """

rule catR2:
    input:
        lambda wildcards: read2.get(wildcards.group)
    output:
        "output/{group}/fastq/{group}_R2.fastq.gz"
    threads: 1
    log:
        err = "output/{group}/logs/{group}_catR2.err"
    shell:
        """
        mkdir -p output/{wildcards.group}/fastq
        cat {input} > {output} 2> {log.err}
        """

rule qc:
    input:
        R1 = lambda wildcards: ['output/{group}/fastq/{group}_R1.fastq.gz'.format(group=wildcards.group)],
        R2 = lambda wildcards: ['output/{group}/fastq/{group}_R2.fastq.gz'.format(group=wildcards.group)]
    output:
        zips = expand('output/qc/{{group}}_{R}_fastqc.zip', R=['R1', 'R2']),
        html = expand('output/qc/{{group}}_{R}_fastqc.html',R=['R1', 'R2'])
    threads: 2
    params:
        version = config['fastqcVersion']
    log:
        err = "output/{group}/logs/{group}_qc.err"
    shell:
        """
        module load fastqc/{params.version}
        mkdir -p output/qc
        fastqc -t {threads} -o output/qc {input.R1} {input.R2} 2> {log.err}
        """

rule trim:
    input:
        R1 = lambda wildcards: ['output/{group}/fastq/{group}_R1.fastq.gz'.format(group=wildcards.group)],
        R2 = lambda wildcards: ['output/{group}/fastq/{group}_R2.fastq.gz'.format(group=wildcards.group)]
    output:
        trim1 = temp("output/{group}/trim/{group}_R1_val_1.fq.gz"),
        trim2 = temp("output/{group}/trim/{group}_R2_val_2.fq.gz"),
        report1 = temp("output/{group}/trim/{group}_R1.fastq.gz_trimming_report.txt"),
        report2 = temp("output/{group}/trim/{group}_R2.fastq.gz_trimming_report.txt")
    threads: 4
    params:
        version = config['trimgaloreVersion']
    log:
        err = "output/{group}/logs/{group}_trim.err"
    shell:
        """
        module load trim_galore/{params.version}
        module load python/3.6.6
        module load pigz
        mkdir -p output/{wildcards.group}/trim
        trim_galore -o output/{wildcards.group}/trim --cores {threads} --path_to_cutadapt /nas/longleaf/apps/cutadapt/2.9/venv/bin/cutadapt --paired {input.R1} {input.R2} 2> {log.err}
        """

rule align:
    input:
        R1 = rules.trim.output.trim1,
        R2 = rules.trim.output.trim2,
        vcf = 'output/vcf/' + vcf_prefix + '_nodups_biallelic.vcf.gz',
        i = 'output/vcf/' + vcf_prefix + '_nodups_biallelic.vcf.gz.tbi'
    output:
        "output/{group}/align/{group}.Aligned.sortedByCoord.out.bam"
    threads: 8
    log:
        out = "output/{group}/logs/{group}_align.out"
    params:
        genomeDir = config['genomeDir']
    shell:
        'module load star/2.7.10a &&'
        'mkdir -p output/{wildcards.group}/align &&'
        'star --runThreadN {threads} '
        '--genomeDir {params.genomeDir} '
        '--readFilesCommand zcat ' 
        '--readFilesIn {input.R1} {input.R2} '
        '--outFileNamePrefix output/{wildcards.group}/align/{wildcards.group}. ' 
        '--outSAMtype BAM SortedByCoordinate '
        '--outFilterType BySJout '
        '--outFilterMultimapNmax 20 ' 
        '--alignSJoverhangMin 8 ' 
        '--alignSJDBoverhangMin 1 '
        '--outFilterMismatchNmax 999 ' 
        '--outFilterMismatchNoverReadLmax 0.04 ' 
        '--alignIntronMin 20 ' 
        '--alignIntronMax 1000000 '
        '--alignMatesGapMax 1000000 '
        '--waspOutputMode SAMtag '
        '--varVCFfile <(zcat {input.vcf}) 1> {log.out}'

rule index:
    input:
        rules.align.output
    output:
        "output/{group}/align/{group}.Aligned.sortedByCoord.out.bam.bai"
    threads: 8
    log:
        err = "output/{group}/logs/{group}_index.err"
    shell:
        """
        module load samtools
        samtools index -@ {threads} {input} {output} 2> {log.err}
        """

rule assignGroups:
    input:
        R = rules.align.output,
        I = rules.index.output
    output:
        "output/{group}/grouped/{group}.grouped.sort.bam"
    threads: 1
    log:
        err = "output/{group}/logs/{group}_assignGroups.err"
    shell:
        """
        mkdir -p output/{wildcards.group}/grouped
        module load picard/2.2.4
        module load java/10.0.2
        java -jar /nas/longleaf/apps/picard/2.2.4/picard-tools-2.2.4/picard.jar AddOrReplaceReadGroups I={input.R} O={output} RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM={wildcards.group} SORT_ORDER=coordinate 2> {log.err}
        """

rule countReads:
    input:
        bam = rules.assignGroups.output,
        vcf = 'output/vcf/' + vcf_prefix + '_nodups_biallelic.vcf.gz',
        i = 'output/vcf/' + vcf_prefix + '_nodups_biallelic.vcf.gz.tbi'
    output:
        "output/{group}/alleleCounts/{group}_alleleCounts.csv"
    threads: 1
    log:
        err = "output/{group}/logs/{group}_countReads.err"
    params:
        sequence = config['sequence']
    shell:
        """
        mkdir -p output/{wildcards.group}/alleleCounts
        module load gatk/4.1.7.0
        module load python/3.6.6
        gatk ASEReadCounter --input {input.bam} --variant {input.vcf} --output {output} --output-format RTABLE --min-base-quality 20 --disable-read-filter NotDuplicateReadFilter --reference {params.sequence} 2> {log.err}
        """

rule editDonors:
    input:
        vcf = 'output/vcf/' + vcf_prefix + '_nodups_biallelic.vcf.gz'
    output:
        temp(touch('editDonors.done'))
    params:
        donors = ",".join(samples['Donor'].unique().tolist())
    shell:
        """
        module load samtools
        module load python/3.9.6
        bcftools query -l {input.vcf} > donors.txt

        python3 scripts/RNAproc/matchDonors.py donors.txt {params.donors}
        """