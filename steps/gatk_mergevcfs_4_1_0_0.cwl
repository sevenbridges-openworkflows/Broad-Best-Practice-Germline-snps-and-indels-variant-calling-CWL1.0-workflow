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
    \ 'M') + '\\\"';\n    }\n    return '\\\"-Xms2000m\\\"';\n}"
- position: 3
  shellQuote: false
  valueFrom: MergeVcfs
- position: 4
  prefix: ''
  shellQuote: false
  valueFrom: "${\n    var in_variants = [].concat(inputs.in_variants);\n    var output_prefix\
    \ = \"\";\n    \n    var vcf_count = 0;\n    var vcf_gz_count = 0;\n    var bcf_count\
    \ = 0;\n    var gvcf_count = 0;\n    var gvcf_gz_count = 0;\n    \n    for (var\
    \ i = 0; i < in_variants.length; i++)\n    {\n        if (in_variants[i].path.endsWith('vcf')\
    \ && !(in_variants[i].path.endsWith('g.vcf')) )\n            vcf_count += 1\n\
    \        else if (in_variants[i].path.endsWith('vcf.gz') && !(in_variants[i].path.endsWith('g.vcf.gz')))\n\
    \            vcf_gz_count += 1\n        else if (in_variants[i].path.endsWith('bcf'))\n\
    \            bcf_count += 1\n        else if (in_variants[i].path.endsWith('g.vcf'))\n\
    \            gvcf_count += 1\n        else if (in_variants[i].path.endsWith('g.vcf.gz'))\n\
    \            gvcf_gz_count += 1\n        \n    }\n    \n    var max_ext = Math.max(vcf_count,\
    \ vcf_gz_count, bcf_count, gvcf_count, gvcf_gz_count)\n    var most_frequent_ext\
    \ = (max_ext == vcf_count) ? \"vcf\" : (max_ext == vcf_gz_count) ? \"vcf.gz\"\
    \ : (max_ext == bcf_count) ? \"bcf\" : (max_ext == gvcf_count) ? \"g.vcf\" : \"\
    g.vcf.gz\";\n    var out_format = inputs.output_file_format;\n    var out_ext\
    \ = \"\";\n    if (out_format)\n    {\n        out_ext = ((most_frequent_ext ==\
    \ \"g.vcf\" || most_frequent_ext == \"g.vcf.gz\") && (out_format == \"vcf\" ||\
    \ out_format == \"vcf.gz\")) ? \"g.\" + out_format : ((most_frequent_ext == \"\
    g.vcf\" || most_frequent_ext == \"g.vcf.gz\") && (out_format == \"bcf\" )) ? most_frequent_ext\
    \ : out_format;\n    }\n    else\n    {\n        out_ext = most_frequent_ext;\n\
    \    }\n    \n    if (inputs.output_prefix)\n    {\n        output_prefix = inputs.output_prefix;\n\
    \    }\n    else\n    {\n        if (in_variants.length > 1)\n        {\n    \
    \        in_variants.sort(function(file1, file2) {\n                var file1_name\
    \ = file1.basename.toUpperCase();\n                var file2_name = file2.basename.toUpperCase();\n\
    \                if (file1_name < file2_name) {\n                    return -1;\n\
    \                }\n                if (file1_name > file2_name) {\n         \
    \           return 1;\n                }\n                // names must be equal\n\
    \                return 0;\n            });\n        }\n        \n        var\
    \ in_variants_first =  in_variants[0];\n        if (in_variants_first.metadata\
    \ && in_variants_first.metadata.sample_id)\n        {\n            output_prefix\
    \ = in_variants_first.metadata.sample_id;\n\n        }\n        else\n       \
    \ {\n            output_prefix = in_variants_first.basename.split('.')[0];\n \
    \       }\n        \n        if (in_variants.length > 1)\n        {\n        \
    \    output_prefix = output_prefix + \".\" + in_variants.length;\n        }\n\
    \    }\n    \n    return \"--OUTPUT \" + output_prefix + \".merged.\" + out_ext;\n\
    }"
baseCommand: []
class: CommandLineTool
cwlVersion: v1.0
doc: "The **GATK MergeVcfs** tool combines multiple variant files into a single variant\
  \ file. \n\n*A list of **all inputs and parameters** with corresponding descriptions\
  \ can be found at the bottom of the page.*\n\n###Common Use Cases\n\n* The **MergeVcfs**\
  \ tool requires one or more input files in VCF format on its **Input variant files**\
  \ (`--INPUT`) input. The input files can be in VCF format (can be gzipped, i.e.\
  \ ending in \".vcf.gz\", or binary compressed, i.e. ending in \".bcf\"). The tool\
  \ generates a VCF file on its **Output merged VCF or BCF file** output.\n\n* The\
  \ **MergeVcfs** tool supports a sequence dictionary file (typically name ending\
  \ in .dict) on its **Sequence dictionary** (`--SEQUENCE_DICTIONARY`) input if the\
  \ input VCF does not contain a complete contig list and if the output index is to\
  \ be created (true by default).\n\n* The output file is sorted (i) according to\
  \ the dictionary and (ii) by coordinate.\n\n* Usage example:\n\n```\ngatk MergeVcfs\
  \ \\\n          --INPUT input_variants.01.vcf \\\n          --INPUT input_variants.02.vcf.gz\
  \ \\\n          --OUTPUT output_variants.vcf.gz\n```\n\n###Changes Introduced by\
  \ Seven Bridges\n\n* The output file will be prefixed using the **Output prefix**\
  \ parameter. In case **Output prefix** is not provided, the input files provided\
  \ on the **Input variant files** input will be alphabetically sorted by name and\
  \  output prefix will be equal to the Sample ID metadata from the first element\
  \ from that list, if the Sample ID metadata exists. Otherwise, output prefix will\
  \ be inferred from the filename of the first element from this list. Moreover, the\
  \ number of input files will be added after the output prefix as well as the tool\
  \ specific extension which is **merged**. This way, having identical names of the\
  \ output files between runs is avoided.\n\n* The user has a possibility to specify\
  \ the output file format using the **Output file format** argument. The default\
  \ output format is \"vcf.gz\".\n\n###Common Issues and Important Notes\n\n* Note\
  \ 1: If running this tool on multi-sample input files (originating from e.g. some\
  \ scatter-gather runs), the input files must contain the same sample names in the\
  \ same column order. \n\n* Note 2: Input file headers must contain compatible declarations\
  \ for common annotations (INFO, FORMAT fields) and filters.\n\n* Note 3: Input files\
  \ variant records must be sorted by their contig and position following the sequence\
  \ dictionary provided or the header contig list.\n\n###Performance Benchmarking\n\
  \nThis tool is ultra fast, with a running time less than a minute on the default\
  \ AWS c4.2xlarge instance.\n\n###References\n\n[1] [GATK MergeVcfs](https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/picard_vcf_MergeVcfs.php)"
id: uros_sipetic/gatk-4-1-0-0-demo/gatk-mergevcfs-4-1-0-0/7
inputs:
- doc: VCF or BCF input files (file format is determined by file extension).
  id: in_variants
  inputBinding:
    position: 4
    shellQuote: false
    valueFrom: "${\n    if (self)\n    {\n        var cmd = [];\n        for (var\
      \ i = 0; i < self.length; i++) \n        {\n            cmd.push('--INPUT',\
      \ self[i].path);\n            \n        }\n        return cmd.join(' ');\n \
      \   }\n}"
  label: Input variants file
  sbg:altPrefix: -I
  sbg:category: Required Arguments
  sbg:fileTypes: VCF, VCF.GZ, BCF
  secondaryFiles:
  - "${\n    if (self.nameext == \".vcf\")\n    {\n        return self.basename +\
    \ \".idx\";\n    }\n    else\n    {\n        return self.basename + \".tbi\";\n\
    \    }\n}"
  type: File[]
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
- doc: When writing files that need to be sorted, this will specify the number of
    records stored in RAM before spilling to disk. Increasing this number reduces
    the number of file handles needed to sort the file, and increases the amount of
    RAM needed.
  id: max_records_in_ram
  inputBinding:
    position: 4
    prefix: --MAX_RECORDS_IN_RAM
    shellQuote: false
  label: Max records in RAM
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
  type: int?
- doc: This input allows a user to set the desired memory requirement when running
    a tool or adding it to a workflow. This value should be propagated to the -Xmx
    parameter too.This input should be defined in MB (for both the platform part and
    the -Xmx part if Java tool is wrapped).
  id: memory_per_job
  label: Memory per job
  sbg:category: Platform Options
  sbg:toolDefaultValue: 2048 MB
  type: int?
- doc: The index sequence dictionary to use instead of the sequence dictionary in
    the input files.
  id: sequence_dictionary
  inputBinding:
    position: 4
    prefix: --SEQUENCE_DICTIONARY
    shellQuote: false
  label: Sequence dictionary
  sbg:altPrefix: -D
  sbg:category: Optional Arguments
  sbg:fileTypes: DICT
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: This input allows a user to set the desired CPU requirement when running a
    tool or adding it to a workflow.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Platform options
  sbg:toolDefaultValue: '1'
  type: int?
- doc: Output file format.
  id: output_file_format
  label: Output file format
  sbg:category: Optional Arguments
  type:
  - 'null'
  - name: output_file_format
    symbols:
    - vcf
    - bcf
    - vcf.gz
    type: enum
- doc: Output file name prefix.
  id: output_prefix
  label: Output prefix
  sbg:category: Optional Arguments
  type: string?
label: GATK MergeVcfs
outputs:
- doc: The merged VCF or BCF file. File format is determined by file extension.
  id: out_variants
  label: Output merged VCF or BCF file
  outputBinding:
    glob: "${\n    var in_variants = [].concat(inputs.in_variants);\n    \n    var\
      \ vcf_count = 0;\n    var vcf_gz_count = 0;\n    var bcf_count = 0;\n    var\
      \ gvcf_count = 0;\n    var gvcf_gz_count = 0;\n    \n    for (var i = 0; i <\
      \ in_variants.length; i++)\n    {\n        if (in_variants[i].path.endsWith('vcf')\
      \ && !(in_variants[i].path.endsWith('g.vcf')) )\n            vcf_count += 1\n\
      \        else if (in_variants[i].path.endsWith('vcf.gz') && !(in_variants[i].path.endsWith('g.vcf.gz')))\n\
      \            vcf_gz_count += 1\n        else if (in_variants[i].path.endsWith('bcf'))\n\
      \            bcf_count += 1\n        else if (in_variants[i].path.endsWith('g.vcf'))\n\
      \            gvcf_count += 1\n        else if (in_variants[i].path.endsWith('g.vcf.gz'))\n\
      \            gvcf_gz_count += 1\n        \n    }\n    \n    var max_ext = Math.max(vcf_count,\
      \ vcf_gz_count, bcf_count, gvcf_count, gvcf_gz_count)\n    var most_frequent_ext\
      \ = (max_ext == vcf_count) ? \"vcf\" : (max_ext == vcf_gz_count) ? \"vcf.gz\"\
      \ : (max_ext == bcf_count) ? \"bcf\" : (max_ext == gvcf_count) ? \"g.vcf\" :\
      \ \"g.vcf.gz\";\n    var out_format = inputs.output_file_format;\n    var out_ext\
      \ = \"\";\n    if (out_format)\n    {\n        out_ext = ((most_frequent_ext\
      \ == \"g.vcf\" || most_frequent_ext == \"g.vcf.gz\") && (out_format == \"vcf\"\
      \ || out_format == \"vcf.gz\")) ? \"g.\" + out_format : ((most_frequent_ext\
      \ == \"g.vcf\" || most_frequent_ext == \"g.vcf.gz\") && (out_format == \"bcf\"\
      \ )) ? most_frequent_ext : out_format;   \n    }\n    else\n    {\n        out_ext\
      \ = most_frequent_ext;\n    }\n    return \"*\" + out_ext;\n    \n}"
    outputEval: $(inheritMetadata(self, inputs.in_variants))
  sbg:fileTypes: VCF, VCF.GZ, BCF
  secondaryFiles:
  - "${\n    return self.basename + \".tbi\";\n}\n"
  type: File?
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: "${\n    return inputs.cpu_per_job ? inputs.cpu_per_job : 1\n}"
  ramMin: "${\n    var memory = 3500;\n    if (inputs.memory_per_job) \n    {\n  \
    \      memory = inputs.memory_per_job;\n    }\n    if (inputs.memory_overhead_per_job)\n\
    \    {\n        memory += inputs.memory_overhead_per_job;\n    }\n    return memory;\n\
    }"
- class: DockerRequirement
  dockerPull: images.sbgenomics.com/stefan_stojanovic/gatk:4.1.0.0
- class: InitialWorkDirRequirement
  listing: []
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
- VCF Processing
sbg:content_hash: a3c47ffaf0fdf430a864f2f88573d1a01b163f5034538733a26e02980d05f2acd
sbg:contributors:
- nemanja.vucic
- veliborka_josipovic
- uros_sipetic
- nens
sbg:copyOf: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/26
sbg:createdBy: uros_sipetic
sbg:createdOn: 1552929960
sbg:id: uros_sipetic/gatk-4-1-0-0-demo/gatk-mergevcfs-4-1-0-0/7
sbg:image_url: null
sbg:latestRevision: 7
sbg:license: Open source BSD (3-clause) license
sbg:links:
- id: https://software.broadinstitute.org/gatk/
  label: Homepage
- id: https://github.com/broadinstitute/gatk/
  label: Source Code
- id: https://github.com/broadinstitute/gatk/releases/download/4.1.0.0/gatk-4.1.0.0.zip
  label: Download
- id: https://www.ncbi.nlm.nih.gov/pubmed?term=20644199
  label: Publications
- id: https://software.broadinstitute.org/gatk/documentation/tooldocs/4.1.0.0/picard_vcf_MergeVcfs.php
  label: Documentation
sbg:modifiedBy: nens
sbg:modifiedOn: 1565776372
sbg:project: uros_sipetic/gatk-4-1-0-0-demo
sbg:projectName: GATK 4.1.0.0 - Demo
sbg:publisher: sbg
sbg:revision: 7
sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/26
sbg:revisionsInfo:
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1552929960
  sbg:revision: 0
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/7
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554493122
  sbg:revision: 1
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/14
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554720843
  sbg:revision: 2
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/15
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554999276
  sbg:revision: 3
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/16
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1559740771
  sbg:revision: 4
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/18
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1559746042
  sbg:revision: 5
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/19
- sbg:modifiedBy: nemanja.vucic
  sbg:modifiedOn: 1559750444
  sbg:revision: 6
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/20
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1565776372
  sbg:revision: 7
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-mergevcfs-4-1-0-0/26
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.0.12.0
sbg:validationErrors: []
