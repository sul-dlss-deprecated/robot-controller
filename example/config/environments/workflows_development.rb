# will spawn worker(s) for each of the given workflows (fully qualified as "repo:wf:robot")
WORKFLOW_STEPS = %w{
  dor:accessionWF:start-accession
  dor:accessionWF:descriptive-metadata
  dor:accessionWF:rights-metadata
  dor:accessionWF:content-metadata
  dor:accessionWF:technical-metadata
  dor:accessionWF:remediate-object
  dor:accessionWF:shelve
  dor:accessionWF:publish
  dor:accessionWF:provenance-metadata
  dor:accessionWF:sdr-ingest-transfer
  dor:accessionWF:sdr-ingest-received
  dor:accessionWF:end-accession
  dor:assemblyWF:start-assembly
  dor:assemblyWF:jp2-create
  dor:assemblyWF:checksum-compute
  dor:assemblyWF:exif-collect
  dor:assemblyWF:accessioning-initiate
}

# number of workers for the given workflows
WORKFLOW_N = Hash[*%w{
  dor:assemblyWF:checksum-compute     3
}]

# starts up 2 workers -- one for this priority and another for all
# XXX: not implemented
WORKFLOW_PRIORITIES = Hash[*%w{
  dor:assemblyWF:checksum-compute     critical,high
}]