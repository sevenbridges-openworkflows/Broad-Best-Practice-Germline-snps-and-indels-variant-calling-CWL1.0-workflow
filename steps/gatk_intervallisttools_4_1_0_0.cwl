$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 0
  prefix: ''
  shellQuote: false
  valueFrom: /opt/gatk
- position: 1
  shellQuote: false
  valueFrom: --java-options
- position: 2
  prefix: ''
  shellQuote: false
  valueFrom: "${\n    if (inputs.memory_per_job) {\n        return '\\\"-Xmx'.concat(inputs.memory_per_job,\
    \ 'M') + '\\\"';\n    }\n    return '\\\"-Xms1g\\\"';\n}"
- position: 3
  shellQuote: false
  valueFrom: IntervalListTools
- position: 4
  prefix: ''
  shellQuote: false
  valueFrom: "${\n    var scatter_count = inputs.scatter_count ? inputs.scatter_count\
    \ : 1;\n    if (scatter_count > 1)\n    {\n        return \"--OUTPUT out\";\n\
    \    }\n    else\n    {\n        return \"--OUTPUT test.interval_list\";\n   \
    \ }\n    \n}"
- position: -1
  prefix: ''
  shellQuote: false
  valueFrom: "${\n    return \"mkdir out && \";\n}"
- position: 99
  prefix: '&& python'
  shellQuote: false
  valueFrom: rename_intervals.py
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: "This tool offers multiple interval list file manipulation capabilities including\
  \ sorting, merging, subtracting, padding, and other set-theoretic operations. \n\
  \nThe default action is to merge and sort genomic intervals provided as the input.\
  \ Compatible input files are INTERVAL_LIST and VCF files. **IntervalListTools**\
  \ can also \"scatter\" the output into many interval files. This can be useful for\
  \ creating multiple interval lists for scattering an analysis execution.\n\n###Common\
  \ Use Cases\n\n- Combine the intervals from two interval lists:\n```\njava -jar\
  \ picard.jar IntervalListTools \\\n      ACTION=CONCAT \\\n      I=input.interval_list\
  \ \\\n      I=input_2.interval_list \\\n      O=new.interval_list\n```\n- Combine\
  \ the intervals from two interval lists, sorting and merging overlapping and abutting\
  \ intervals:\n```\n java -jar picard.jar IntervalListTools \\\n       ACTION=CONCAT\
  \ \\\n       SORT=true \\\n       UNIQUE=true \\\n       I=input.interval_list \\\
  \n       I=input_2.interval_list \\\n       O=new.interval_list \n```\n- Subtract\
  \ the intervals in **second_input** (`SECOND_INPUT`) from those in **in_intervals**\
  \ (`INPUT`):\n```\n java -jar picard.jar IntervalListTools \\\n       ACTION=SUBTRACT\
  \ \\\n       I=input.interval_list \\\n       SI=input_2.interval_list \\\n    \
  \   O=new.interval_list \n```\n- Find bases that are in either *input1.interval_list*\
  \ or *input2.interval_list*, and also in *input3.interval_list*:\n```\n java -jar\
  \ picard.jar IntervalListTools \\\n       ACTION=INTERSECT \\\n       I=input1.interval_list\
  \ \\\n       I=input2.interval_list \\\n       SI=input3.interval_list \\\n    \
  \   O=new.interval_list \n```\n- Split intervals list file using * scatter_count*\
  \ (`SCATTER_COUNT`) option:\n```\n java -jar picard.jar IntervalListTools \\\n \
  \      I=input.interval_list \\\n       SCATTER_COUNT=2 \n```\n\n\n###Common Issues\
  \ and Important Notes\n\n- A SAM style header must be present at the top of the\
  \ *interval_list* file. After the header, the file then contains records, one per\
  \ line in text format with the following tab-separated values. Example of the *interval_list*\
  \ file: \n```\n@HD    VN:1.0\n@SQ    SN:chr1    LN:501\n@SQ    SN:chr2    LN:401\n\
  chr1    1    100    +    starts at the first base of the contig and covers 100 bases\n\
  chr2    100    100    +    interval with exactly one base\n```\n- The coordinate\
  \ system is 1-based, closed-ended so that the first base in a sequence has position\
  \ 1, and both the start and the end positions are included in an interval.\n-  The\
  \ **Interval list** input file should be denoted with the extension INTERVAL_LIST.\n\
  \n\n###Changes Introduced by Seven Bridges\n\nIf no additional parameter is set,\
  \ the app will output the INTERVAL_LIST file given on the input.\n\n\n###Performance\
  \ Benchmarking\nThe execution time takes several minutes on the default instance.\
  \ Unless specified otherwise, the default AWS instance used to run the **IntervalListTools**\
  \ will be c4.2xlarge (8CPUs and 16GB RAM)."
id: uros_sipetic/gatk-4-1-0-0-demo/gatk-intervallisttools-4-1-0-0/4
inputs:
- doc: 'Action to take on inputs. Possible values: { CONCAT (the concatenation of
    all the intervals in all the inputs, no sorting or merging of overlapping/abutting
    intervals implied. Will result in a possibly unsorted list unless requested otherwise.)
    UNION (like concatenate but with UNIQUE and SORT implied, the result being the
    set-wise union of all inputs, with overlapping and abutting intervals merged into
    one.) INTERSECT (the sorted and merged set of all loci that are contained in all
    of the inputs.) SUBTRACT (subtracts the intervals in second_input from those in
    input. The resulting loci are those in input that are not in second_input.) symdiff
    (results in loci that are in input or second_input but are not in both.) overlaps
    (outputs the entire intervals from input that have bases which overlap any interval
    from second_input. Note that this is different than intersect in that each original
    interval is either emitted in its entirety, or not at all.) }.'
  id: action
  inputBinding:
    position: 4
    prefix: --ACTION
    shellQuote: false
  label: Action
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: CONCAT
  type:
  - 'null'
  - name: action
    symbols:
    - CONCAT
    - UNION
    - INTERSECT
    - SUBTRACT
    - SYMDIFF
    - OVERLAPS
    type: enum
- doc: If set to a positive value will create a new interval list with the original
    intervals broken up at integer multiples of this value. Set to 0 to not break
    up intervals.
  id: break_bands_at_multiples_of
  inputBinding:
    position: 4
    prefix: --BREAK_BANDS_AT_MULTIPLES_OF
    shellQuote: false
  label: Break bands at multiples of
  sbg:altPrefix: -BRK
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: One or more lines of comment to add to the header of the output file (as @CO
    lines in the SAM header).  This argument may be specified 0 or more times.
  id: comment
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self)\n    {\n        var cmd = [];\n        for (var\
      \ i = 0; i < self.length; i++) \n        {\n            cmd.push('--COMMENT',\
      \ self[i]);\n        }\n        return cmd.join(' ');\n    }\n    \n}"
  label: Comment
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type: string[]?
- doc: Compression level for all compressed files created (e.g. BAM and VCF).
  id: compression_level
  inputBinding:
    position: 4
    prefix: --COMPRESSION_LEVEL
    shellQuote: false
  label: Compression level
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '2'
  type: int?
- doc: Number of CPUs to be used per job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Platform options
  sbg:toolDefaultValue: '1'
  type: int?
- doc: Whether to include filtered variants in the VCF when generating an interval
    list from VCF.
  id: include_filtered
  inputBinding:
    position: 4
    prefix: --INCLUDE_FILTERED
    shellQuote: false
  label: Include filtered
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: One or more interval lists. If multiple interval lists are provided the output
    is the result of merging the inputs. Supported formats are interval_list and VCF.
    This argument must be specified at least once.
  id: in_intervals
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self)\n    {\n        var cmd = [];\n        for (var\
      \ i = 0; i < self.length; i++) \n        {\n            cmd.push('--INPUT',\
      \ self[i].path);\n        }\n        return cmd.join(' ');\n    }\n    \n}"
  label: Interval list
  sbg:altPrefix: -I
  sbg:category: Required Arguments
  sbg:fileTypes: VCF, INTERVAL_LIST
  type: File[]
- doc: Produce the inverse list of intervals, that is, the regions in the genome that
    are not covered by any of the input intervals. Will merge abutting intervals first.
    Output will be sorted.
  id: invert
  inputBinding:
    position: 4
    prefix: --INVERT
    shellQuote: false
  label: Invert
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: When writing files that need to be sorted, this will specify the number of
    records stored in RAM before spilling to disk. Increasing this number reduces
    the number of file handles needed to sort the file, and increases the amount of
    RAM needed.
  id: max_records_in_ram
  inputBinding:
    position: 4
    prefix: --MAX_RECORDS_IN_RAM
    shellQuote: false
  label: Max records in ram
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '500000'
  type: int?
- doc: This input allows a user to set the desired overhead memory when running a
    tool or adding it to a workflow. This amount will be added to the Memory per job
    in the Memory requirements section but it will not be added to the -Xmx parameter
    leaving some memory not occupied which can be used as stack memory (-Xmx parameter
    defines heap memory). This input should be defined in MB (for both the platform
    part and the -Xmx part if Java tool is wrapped).
  id: memory_overhead_per_job
  label: Memory overhead per job
  sbg:category: Platform Options
  sbg:toolDefaultValue: '7'
  type: int?
- doc: This input allows a user to set the desired memory requirement when running
    a tool or adding it to a workflow. This value should be propagated to the -Xmx
    parameter too.This input should be defined in MB (for both the platform part and
    the -Xmx part if Java tool is wrapped).
  id: memory_per_job
  label: Memory per job
  sbg:category: Platform options
  sbg:toolDefaultValue: '2048'
  type: int?
- doc: What value (if anything) to output to stdout (for scripting).
  id: output_value
  inputBinding:
    position: 4
    prefix: --OUTPUT_VALUE
    shellQuote: false
  label: Output value
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: NONE
  type:
  - 'null'
  - name: output_value
    symbols:
    - NONE
    - BASES
    - INTERVALS
    type: enum
- doc: The amount to pad each end of the intervals by before other operations are
    undertaken. Negative numbers are allowed and indicate intervals should be shrunk.
    Resulting intervals < 0 bases long will be removed. Padding is applied to the
    interval lists (both INPUT and SECOND_INPUT, if provided) before the ACTION is
    performed.
  id: padding
  inputBinding:
    position: 4
    prefix: --PADDING
    shellQuote: false
  label: Padding
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Reference sequence file.
  id: in_reference
  inputBinding:
    position: 4
    prefix: --REFERENCE_SEQUENCE
    shellQuote: false
  label: Reference sequence
  sbg:altPrefix: -R
  sbg:category: Optional Arguments
  sbg:fileTypes: FASTA, FA
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: When scattering with this argument, each of the resultant files will (ideally)
    have this amount of 'content', which means either base-counts or interval-counts
    depending on SUBDIVISION_MODE. When provided, overrides SCATTER_COUNT.
  id: scatter_content
  inputBinding:
    position: 4
    prefix: --SCATTER_CONTENT
    shellQuote: false
  label: Scatter content
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type: int?
- doc: The number of files into which to scatter the resulting list by locus; in some
    situations, fewer intervals may be emitted.
  id: scatter_count
  inputBinding:
    position: 4
    prefix: --SCATTER_COUNT
    shellQuote: false
  label: Scatter count
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '1'
  type: int?
- doc: Second set of intervals for SUBTRACT and DIFFERENCE operations. This argument
    may be specified 0 or more times.
  id: second_input
  inputBinding:
    position: 4
    prefix: --SECOND_INPUT
    shellQuote: false
  label: Second input
  sbg:altPrefix: -SI
  sbg:category: Optional Arguments
  sbg:fileTypes: VCF, INTERVAL_LIST
  sbg:toolDefaultValue: 'null'
  type: File[]?
- doc: If true, sort the resulting interval list by coordinate.
  id: sort
  inputBinding:
    position: 4
    prefix: --SORT
    shellQuote: false
  label: Sort
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'true'
  type: boolean?
- doc: 'The mode used to scatter the interval list. Possible values: { INTERVAL_SUBDIVISION
    (scatter the interval list into similarly sized interval lists (by base count),
    breaking up intervals as needed.) BALANCING_WITHOUT_INTERVAL_SUBDIVISION (scatter
    the interval list into similarly sized interval lists (by base count), but without
    breaking up intervals.) BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW (scatter
    the interval list into similarly sized interval lists (by base count), but without
    breaking up intervals. Will overflow current interval list so that the remaining
    lists will not have too many bases to deal with.) interval_count (scatter the
    interval list into similarly sized interval lists (by interval count, not by base
    count). Resulting interval lists will contain similar number of intervals.) }.'
  id: subdivision_mode
  inputBinding:
    position: 4
    prefix: --SUBDIVISION_MODE
    shellQuote: false
  label: Subdivision mode
  sbg:altPrefix: -M
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: INTERVAL_SUBDIVISION
  type:
  - 'null'
  - name: subdivision_mode
    symbols:
    - INTERVAL_SUBDIVISION
    - BALANCING_WITHOUT_INTERVAL_SUBDIVISION
    - BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW
    - INTERVAL_COUNT
    type: enum
- doc: If true, merge overlapping and adjacent intervals to create a list of unique
    intervals. Implies SORT=true.
  id: unique
  inputBinding:
    position: 4
    prefix: --UNIQUE
    shellQuote: false
  label: Unique
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Validation stringency for all SAM files read by this program. Setting stringency
    to silent can improve performance when processing a bam file in which variable-length
    data (read, qualities, tags) do not otherwise need to be decoded.
  id: validation_stringency
  inputBinding:
    position: 4
    prefix: --VALIDATION_STRINGENCY
    shellQuote: false
  label: Validation stringency
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: STRICT
  type:
  - 'null'
  - name: validation_stringency
    symbols:
    - STRICT
    - LENIENT
    - SILENT
    type: enum
label: GATK IntervalListTools
outputs:
- doc: Output list of intervals, processed per the tool's specifications (union, intersection,
    split list... ).
  id: output_interval_list
  label: Output interval list
  outputBinding:
    glob: "${\n    var scatter_count = inputs.scatter_count ? inputs.scatter_count\
      \ : 1;\n    if (scatter_count > 1)\n    {\n        return \"out/*/*.interval_list\"\
      ;\n    }\n    else\n    {\n        return \"test.interval_list\";\n    }\n}"
    outputEval: $(inheritMetadata(self, inputs.in_intervals))
  sbg:fileTypes: INTERVAL_LIST
  type: File[]?
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: "${\n    return inputs.cpu_per_job ? inputs.cpu_per_job : 1\n}"
  ramMin: "${\n    var memory = 2048;\n    if (inputs.memory_per_job) \n    {\n  \
    \      memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job)\n\
    \    {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n\
    }"
- class: DockerRequirement
  dockerPull: images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0
- class: InitialWorkDirRequirement
  listing:
  - entry: "import glob, os\n# Works around a JES limitation where multiples files\
      \ with the same name overwrite each other when globbed\nintervals = sorted(glob.glob(\"\
      out/*/*.interval_list\"))\nfor i, interval in enumerate(intervals):\n    (directory,\
      \ filename) = os.path.split(interval)\n    newName = os.path.join(directory,\
      \ str(i + 1) + filename)\n    os.rename(interval, newName)\nprint(len(intervals))"
    entryname: rename_intervals.py
    writable: false
- class: InlineJavascriptRequirement
  expressionLib:
  - "var updateMetadata = function(file, key, value) {\n    file['metadata'][key]\
    \ = value;\n    return file;\n};\n\n\nvar setMetadata = function(file, metadata)\
    \ {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n  \
    \  else {\n        for (var key in metadata) {\n            file['metadata'][key]\
    \ = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata\
    \ = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2))\
    \ {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n   \
    \     var example = o2[i]['metadata'];\n        for (var key in example) {\n \
    \           if (i == 0)\n                commonMetadata[key] = example[key];\n\
    \            else {\n                if (!(commonMetadata[key] == example[key]))\
    \ {\n                    delete commonMetadata[key]\n                }\n     \
    \       }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1,\
    \ commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n\
    \            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n  \
    \  return o1;\n};\n\nvar toArray = function(file) {\n    return [].concat(file);\n\
    };\n\nvar groupBy = function(files, key) {\n    var groupedFiles = [];\n    var\
    \ tempDict = {};\n    for (var i = 0; i < files.length; i++) {\n        var value\
    \ = files[i]['metadata'][key];\n        if (value in tempDict)\n            tempDict[value].push(files[i]);\n\
    \        else tempDict[value] = [files[i]];\n    }\n    for (var key in tempDict)\
    \ {\n        groupedFiles.push(tempDict[key]);\n    }\n    return groupedFiles;\n\
    };\n\nvar orderBy = function(files, key, order) {\n    var compareFunction = function(a,\
    \ b) {\n        if (a['metadata'][key].constructor === Number) {\n           \
    \ return a['metadata'][key] - b['metadata'][key];\n        } else {\n        \
    \    var nameA = a['metadata'][key].toUpperCase();\n            var nameB = b['metadata'][key].toUpperCase();\n\
    \            if (nameA < nameB) {\n                return -1;\n            }\n\
    \            if (nameA > nameB) {\n                return 1;\n            }\n\
    \            return 0;\n        }\n    };\n\n    files = files.sort(compareFunction);\n\
    \    if (order == undefined || order == \"asc\")\n        return files;\n    else\n\
    \        return files.reverse();\n};"
  - "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n\
    \        file['metadata'] = metadata;\n    else {\n        for (var key in metadata)\
    \ {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n  \
    \  return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata\
    \ = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var\
    \ i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n   \
    \     for (var key in example) {\n            if (i == 0)\n                commonMetadata[key]\
    \ = example[key];\n            else {\n                if (!(commonMetadata[key]\
    \ == example[key])) {\n                    delete commonMetadata[key]\n      \
    \          }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n\
    \        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var\
    \ i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n\
    \        }\n    }\n    return o1;\n};"
sbg:appVersion:
- v1.0
sbg:categories:
- Utilities
- BED Processing
sbg:content_hash: ad8098a8ef53e9c95647c2c4b16fb6e2616f49f3b2589d1241f7c1a034153332b
sbg:contributors:
- uros_sipetic
- veliborka_josipovic
sbg:copyOf: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-intervallisttools-4-1-0-0/19
sbg:createdBy: uros_sipetic
sbg:createdOn: 1553015434
sbg:id: uros_sipetic/gatk-4-1-0-0-demo/gatk-intervallisttools-4-1-0-0/4
sbg:image_url: null
sbg:latestRevision: 4
sbg:license: Open source BSD (3-clause) license
sbg:links:
- id: https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/picard_util_IntervalListTools.php
  label: Homepage
sbg:modifiedBy: veliborka_josipovic
sbg:modifiedOn: 1559740786
sbg:project: uros_sipetic/gatk-4-1-0-0-demo
sbg:projectName: GATK 4.1.0.0 - Demo
sbg:publisher: sbg
sbg:revision: 4
sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-intervallisttools-4-1-0-0/19
sbg:revisionsInfo:
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553015434
  sbg:revision: 0
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-intervallisttools-4-1-0-0/14
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553023178
  sbg:revision: 1
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-intervallisttools-4-1-0-0/16
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554720910
  sbg:revision: 2
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-intervallisttools-4-1-0-0/17
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554999245
  sbg:revision: 3
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-intervallisttools-4-1-0-0/18
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1559740786
  sbg:revision: 4
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-intervallisttools-4-1-0-0/19
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
sbg:wrapperAuthor: nemanja.vucic, veliborka_josipovic
