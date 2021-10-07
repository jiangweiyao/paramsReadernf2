#!/usr/bin/env nextflow

nextflow.enable.dsl=2

//fastq_file = Channel.fromPath(params.in, type: 'file')

process validatefastq {
    cpus 1
    memory 1.GB
    errorStrategy 'ignore'
    //publishDir params.out, mode: 'copy', overwrite: true

    //Note to self: specifying the file name literally coerces the input file into that name. It doesn't select files matching pattern of the literal.
    input:
    file(fastq)

    output:
    tuple val(true), file(fastq)
    """
    fastq_info ${fastq}
    """
}


process fastqc {

    cpus 1
    memory 1.GB
    errorStrategy 'ignore'
    publishDir "${params.publish_dir}", mode: "copy", overwrite: true, enabled: params.publish_dir
    //publishDir params.out, mode: 'copy', overwrite: true

    //Note to self: specifying the file name literally coerces the input file into that name. It doesn't select files matching pattern of the literal.
    input:
    tuple val(state), file(fastq) 

    output:
    file "*_fastqc.{zip,html}" 
    """
    fastqc ${fastq}
    """
}


process multiqc {
    cpus 2
    memory 2.GB
    publishDir "${params.publish_dir}", mode: "copy", overwrite: true, enabled: params.publish_dir
    //publishDir params.out, mode: 'copy', overwrite: true

    input:
    file(reports)

    output:
    file "multiqc_report.html"

    """
    multiqc $reports
    """
}

workflow validate_fastqc_multiqc_pipeline {
    take: fastq_file
    main:
        //fastq_file = Channel.fromPath(params.in, type: 'file')
        validatefastq(fastq_file)
        fastqc(validatefastq.out)
        multiqc(fastqc.out.collect())
    emit:
        fastqc.out 
}

workflow {
    //fastq_file = Channel.fromPath(params.in, type: 'file')
    validate_fastqc_multiqc_pipeline(fastq_file)
}
