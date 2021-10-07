#!/usr/bin/env nextflow

nextflow.enable.dsl=2

println(params.analysisId)
println(params.analysisId.getClass())

println("")
println(params.projects)
println(params.projects.getClass())

println("")
println(params.projects[0].samples)
println(params.projects[0].samples.getClass())


//println("")
//ch = Channel.fromList(params.projects[0].samples)
//ch.subscribe { println "value: $it" }


workflow {
    include {param_parse} from './parse_function.groovy'
    input_fasta_ch = param_parse(params)
    validatefastq(input_fasta_ch)
    fastqc(validatefastq.out)
    multiqc(fastqc.out.collect())
}


process validatefastq {
    cpus 1
    memory 1.GB
    //errorStrategy 'ignore'
    //publishDir params.out, mode: 'copy', overwrite: true

    input:
    tuple val(sampleName), val(groupID), file(fastq), val(sampleOutputDir) 

    output:
    tuple val(sampleName), file(fastq)
    """
    fastq_info ${fastq}
    """
}


process fastqc {

    cpus 1
    memory 1.GB
    //errorStrategy 'ignore'
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
