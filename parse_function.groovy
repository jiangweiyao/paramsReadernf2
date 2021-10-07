def param_parse(parameters) {
    def samples = parameters.projects[0].samples
    def sampleList = []
    for (def sample : samples) {
        tupeJson = new Tuple(sample.sampleName, sample.groupId, file(sample.forwardFastq), sample.sampleOutputDir)
        sampleList.add(tupeJson)
    }

    return Channel.fromList(sampleList)
}
