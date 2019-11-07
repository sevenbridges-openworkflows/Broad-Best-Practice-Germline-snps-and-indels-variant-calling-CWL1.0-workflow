$namespaces:
  sbg: https://sevenbridges.com
arguments:
- position: 1
  shellQuote: false
  valueFrom: --java-options
- position: 2
  prefix: ''
  shellQuote: false
  valueFrom: "${\n    if (inputs.mem_per_job) {\n        return '\\\"-Xmx'.concat(inputs.mem_per_job,\
    \ 'M') + '\\\"'\n    } else {\n        // this is required for Best Practice GATK\
    \ RNA-seq workflow\n        return '\\\"-Xms6000m\\\"'\n    }\n}"
- position: 3
  shellQuote: false
  valueFrom: HaplotypeCaller
- position: 4
  prefix: --output
  shellQuote: false
  valueFrom: "${\n    // if output parameter is set, return output file name\n   \
    \ if(inputs.output_prefix && inputs.output_extension){\n        return inputs.output_prefix\
    \ + '.' + inputs.output_extension;\n    } else {\n        // determine output\
    \ file extenstion\n        var out_ext;\n        if(inputs.emit_ref_confidence\
    \ == 'GVCF' && inputs.output_extension){\n            out_ext = '.g.' + inputs.output_extension\n\
    \        } else {\n            out_ext = '.' + inputs.output_extension\n     \
    \   }\n        var in_prefix;\n        var in_num = [].concat(inputs.in_alignments).length;\n\
    \        // create output file name if there is one input file\n        if(in_num\
    \ == 1){\n            var in_align = [].concat(inputs.in_alignments)[0];\n   \
    \         // check if the sample_id metadata value is defined for the input file\n\
    \            if(in_align.metadata && in_align.metadata.sample_id){\n         \
    \       in_prefix = in_align.metadata.sample_id\n            // if sample_id is\
    \ not defined\n            } else {\n                in_prefix = [].concat(inputs.in_alignments)[0].nameroot\n\
    \            }\n            return in_prefix + out_ext\n        }\n        //\
    \ create output file name if there are more than one input files\n        else\
    \ if(in_num > 1){\n            var in_align = [].concat(inputs.in_alignments);\n\
    \            var in_sample_ids = [];\n            var in_align_names = [];\n \
    \           for (var i = 0; i < in_align.length; i++) {\n                // check\
    \ if the sample_id metadata value is defined for the input file\n            \
    \    if(in_align[i].metadata && in_align[i].metadata.sample_id){\n           \
    \         in_sample_ids.push(in_align[i].metadata.sample_id)\n               \
    \ }\n                in_align_names.push(in_align[i].nameroot)\n            }\n\
    \            if(in_sample_ids.length != 0){\n                in_prefix = in_sample_ids.sort()[0]\n\
    \            // if sample_id is not defined\n            } else {\n          \
    \      in_prefix = in_align_names.sort()[0]\n            }\n            return\
    \ in_prefix + '.' + in_num + out_ext\n        } else {\n            return null\n\
    \        }\n    }\n}"
baseCommand:
- /opt/gatk
class: CommandLineTool
cwlVersion: v1.0
doc: "Call germline single nucleotide polymorphisms (SNPs) and indels via local re-assembly\
  \ of haplotypes. To call SNPs and indels, **HaplotypeCaller** requires BAM file(s)\
  \ containing reads aligned to the reference genome.\n\n**HaplotypeCaller** is capable\
  \ of calling SNPs and indels simultaneously via local de-novo assembly of haplotypes\
  \ in an active region. In other words, whenever the program encounters a region\
  \ showing signs of variation, it discards the existing mapping information and completely\
  \ reassembles the reads in that region. Reassembled reads are realigned to the reference.\
  \ This allows **HaplotypeCaller** to be more accurate when calling regions that\
  \ are traditionally difficult to call, for example when they contain different types\
  \ of variants close to each other. It also makes **HaplotypeCaller** much better\
  \ at calling indels than position-based callers like UnifiedGenotyper.\n\nIn the\
  \ GVCF workflow used for scalable variant calling in DNA sequence data, **HaplotypeCaller**\
  \ runs per-sample to generate an intermediate GVCF (not to be used in final analysis),\
  \ which can then be used in GenotypeGVCFs for joint genotyping of multiple samples\
  \ in a very efficient way. The GVCF workflow enables rapid incremental processing\
  \ of samples as they roll off the sequencer, as well as scaling to very large cohort\
  \ sizes. \n\nIn addition, **HaplotypeCaller** is able to handle non-diploid organisms\
  \ as well as pooled experiment data. Note however that the algorithms used to calculate\
  \ variant likelihoods are not well suited to extreme allele frequencies (relative\
  \ to ploidy) so its use is not recommended for somatic (cancer) variant discovery.\
  \ For that purpose, use **Mutect2** instead.\n\nFinally, **HaplotypeCaller** is\
  \ also able to correctly handle splice junctions that make RNAseq a challenge for\
  \ most variant callers.\n\n*A list of **all inputs and parameters** with corresponding\
  \ descriptions can be found at the bottom of this page.*\n\n### Common Use Cases\n\
  \n- Call variants individually on each sample in GVCF mode\n\n```\n gatk --java-options\
  \ \"-Xmx4g\" HaplotypeCaller  \\\n   -R Homo_sapiens_assembly38.fasta \\\n   -I\
  \ input.bam \\\n   -O output.g.vcf.gz \\\n   -ERC GVCF\n```\n\n\n- Call variants\
  \ individually on each sample in GVCF mode with allele-specific annotations. [Here](https://software.broadinstitute.org/gatk/documentation/article?id=9622)\
  \ you can read more details about allele-specific annotation and filtering.\n\n\
  ```\ngatk --java-options \"-Xmx4g\" HaplotypeCaller  \\\n   -R Homo_sapiens_assembly38.fasta\
  \ \\\n   -I input.bam \\\n   -O output.g.vcf.gz \\\n   -ERC GVCF \\\n   -G Standard\
  \ \\\n   -G AS_Standard\n```\n\n\n- Call variants with [bamout](https://software.broadinstitute.org/gatk/documentation/article?id=5484)\
  \ to show realigned reads. After performing a local reassembly and realignment the\
  \ reads get moved to different mapping positions than what you can observe in the\
  \ original BAM file. This option could be used to visualize what rearrangements\
  \ **HaplotypeCaller** has made.\n\n```\n gatk --java-options \"-Xmx4g\" HaplotypeCaller\
  \  \\\n   -R Homo_sapiens_assembly38.fasta \\\n   -I input.bam \\\n   -O output.vcf.gz\
  \ \\\n   -bamout bamout.bam\n```\n\n\n### Common issues and important notes\n\n\
  - If **Read filter** (`--read-filter`) option is set to \"LibraryReadFilter\", **Library**\
  \ (`--library`) option must be set to some value.\n- If **Read filter** (`--read-filter`)\
  \ option is set to \"PlatformReadFilter\", **Platform filter name** (`--platform-filter-name`)\
  \ option must be set to some value.\n- If **Read filter** (`--read-filter`) option\
  \ is set to\"PlatformUnitReadFilter\", **Black listed lanes** (`--black-listed-lanes`)\
  \ option must be set to some value. \n- If **Read filter** (`--read-filter`) option\
  \ is set to \"ReadGroupBlackListReadFilter\", **Read group black list** (`--read-group-black-list`)\
  \ option must be set to some value.\n- If **Read filter** (`--read-filter`) option\
  \ is set to \"ReadGroupReadFilter\", **Keep read group** (`--keep-read-group`) option\
  \ must be set to some value.\n- If **Read filter** (`--read-filter`) option is set\
  \ to \"ReadLengthReadFilter\", **Max read length** (`--max-read-length`) option\
  \ must be set to some value.\n- If **Read filter** (`--read-filter`) option is set\
  \ to \"ReadNameReadFilter\", **Read name** (`--read-name`) option must be set to\
  \ some value.\n- If **Read filter** (`--read-filter`) option is set to \"ReadStrandFilter\"\
  , **Keep reverse strand only** (`--keep-reverse-strand-only`) option must be set\
  \ to some value.\n- If **Read filter** (`--read-filter`) option is set to \"SampleReadFilter\"\
  , **Sample** (`--sample`) option must be set to some value.\n- When working with\
  \ PCR-free data, be sure to set **PCR indel model** (`--pcr_indel_model`) to NONE.\n\
  - When running **Emit ref confidence** ( `--emit-ref-confidence`) in GVCF or in\
  \ BP_RESOLUTION mode, the confidence threshold is automatically set to 0. This cannot\
  \ be overridden by the command line. The threshold can be set manually to the desired\
  \ level when using **GenotypeGVCFs**.\n- It is recommended to use a list of intervals\
  \ to speed up the analysis. See [this document](https://software.broadinstitute.org/gatk/documentation/article?id=4133)\
  \ for details.\n\n### Changes Introduced by Seven Bridges\n\n- **Include intervals**\
  \ (`--intervals`) option is divided into **Include genomic intervals** and **Intervals\
  \ string values** options.\n- **Exclude intervals** (`--exclude-intervals`) option\
  \ is divided into **Exclude genomic intervals** and **Exclude intervals string values**\
  \ options.\n- Using the **Output prefix** parameter you can set the name of the\
  \ VCF output. If this value is not set the output name will be generated based on\
  \ **Sample ID** metadata value from one of the input BAM files. If **Sample ID**\
  \ value is not set the name will be inherited from one of the input BAM file names.\n\
  \n### Performance Benchmarking\n\nBelow is a table describing the runtimes and task\
  \ costs for a couple of samples with different file sizes.\n\n| Experiment type\
  \ |  Input size | Paired-end | # of reads | Read length | Duration |  Cost (spot)\
  \ | Cost (on-demand) | AWS instance type |\n|:--------------:|:------------:|:--------:|:-------:|:---------:|:----------:|:------:|:------:|:------:|\n\
  |     RNA-Seq     | 2.6 GB |     Yes    |     16M     |     101     |   50min  \
  \ | 0.22$ | 0.44$ | c4.2xlarge |\n|     RNA-Seq     | 7.7 GB |     Yes    |    \
  \ 50M     |     101     |   1h31min   | 0.40$ | 0.87$ | c4.2xlarge |\n|     RNA-Seq\
  \     | 12.7 GB |     Yes    |     82M    |     101     |  2h19min  | 0.61$ | 1.22$\
  \ | c4.2xlarge |\n|     RNA-Seq     | 25 GB |     Yes    |     164M    |     101\
  \     |  4h5min  | 1.07$ | 2.43 | c4.2xlarge |"
id: uros_sipetic/gatk-4-1-0-0-demo/gatk-haplotypecaller-4-1-0-0/7
inputs:
- doc: Minimum probability for a locus to be considered active.
  id: active_probability_threshold
  inputBinding:
    position: 4
    prefix: --active-probability-threshold
    shellQuote: false
  label: Active probability threshold
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '0.002'
  type: float?
- doc: Output the raw activity profile results in IGV format.
  id: activity_profile_out
  inputBinding:
    position: 4
    prefix: --activity-profile-out
    shellQuote: false
  label: Activity profile output
  sbg:category: Optional Arguments
  type: string?
- doc: Use Mutect2's adaptive graph pruning algorithm.
  id: adaptive_pruning
  inputBinding:
    position: 4
    prefix: --adaptive-pruning
    shellQuote: false
  label: Adaptive pruning
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Initial base error rate estimate for adaptive pruning.
  id: adaptive_pruning_initial_error_rate
  inputBinding:
    position: 4
    prefix: --adaptive-pruning-initial-error-rate
    shellQuote: false
  label: Adaptive pruning initial error rate
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '0.001'
  type: float?
- doc: If true, adds a pg tag to created SAM/BAM/CRAM files.
  id: add_output_sam_program_record
  inputBinding:
    position: 4
    prefix: --add-output-sam-program-record
    shellQuote: false
  label: Add output SAM program record
  sbg:altPrefix: -add-output-sam-program-record
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'true'
  type:
  - 'null'
  - name: add_output_sam_program_record
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: If true, adds a command line header line to created VCF files.
  id: add_output_vcf_command_line
  inputBinding:
    position: 4
    prefix: --add-output-vcf-command-line
    shellQuote: false
  label: Add output VCF command line
  sbg:altPrefix: -add-output-vcf-command-line
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'true'
  type:
  - 'null'
  - name: add_output_vcf_command_line
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: Annotate all sites with PLs.
  id: all_site_pls
  inputBinding:
    position: 4
    prefix: --all-site-pls
    shellQuote: false
  label: Annotate all sites with PLs
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: The set of alleles at which to genotype when --genotyping_mode is genotype_given_alleles.
  id: alleles
  inputBinding:
    position: 4
    prefix: --alleles
    shellQuote: false
  label: Alleles
  sbg:category: Optional Arguments
  sbg:fileTypes: BCF2, VCF, VCF3
  sbg:toolDefaultValue: 'null'
  secondaryFiles:
  - .idx
  type: File?
- doc: Allow graphs that have non-unique kmers in the reference.
  id: allow_non_unique_kmers_in_ref
  inputBinding:
    position: 4
    prefix: --allow-non-unique-kmers-in-ref
    shellQuote: false
  label: Allow non unique kmers in ref
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: If provided, we will annotate records with the number of alternate alleles
    that were discovered (but not necessarily genotyped) at a given site.
  id: annotate_with_num_discovered_alleles
  inputBinding:
    position: 4
    prefix: --annotate-with-num-discovered-alleles
    shellQuote: false
  label: Annotate with num discovered alleles
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: One or more specific annotations to add to variant calls.
  id: annotation
  inputBinding:
    itemSeparator: 'null'
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--annotation ' + self.join('\
      \ --annotation ')\n    } else {\n        return null\n    }\n}"
  label: Annotation
  sbg:altPrefix: -A
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type:
  - 'null'
  - items:
      name: annotation
      symbols:
      - AlleleFraction
      - AS_BaseQualityRankSumTest
      - AS_FisherStrand
      - AS_InbreedingCoeff
      - AS_MappingQualityRankSumTest
      - AS_QualByDepth
      - AS_ReadPosRankSumTest
      - AS_RMSMappingQuality
      - AS_StrandOddsRatio
      - BaseQuality
      - BaseQualityRankSumTest
      - ChromosomeCounts
      - ClippingRankSumTest
      - CountNs
      - Coverage
      - DepthPerAlleleBySample
      - DepthPerSampleHC
      - ExcessHet
      - FisherStrand
      - FragmentLength
      - GenotypeSummaries
      - InbreedingCoeff
      - LikelihoodRankSumTest
      - MappingQuality
      - MappingQualityRankSumTest
      - MappingQualityZero
      - OriginalAlignment
      - OxoGReadCounts
      - PolymorphicNuMT
      - PossibleDeNovo
      - QualByDepth
      - ReadOrientationArtifact
      - ReadPosition
      - ReadPosRankSumTest
      - ReferenceBases
      - RMSMappingQuality
      - SampleList
      - StrandArtifact
      - StrandBiasBySample
      - StrandOddsRatio
      - TandemRepeat
      - UniqueAltReadCount
      type: enum
    type: array
- doc: One or more groups of annotations to apply to variant calls.
  id: annotation_group
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--annotation-group ' + self.join('\
      \ --annotation-group ')\n    } else {\n        return null\n    }\n}"
  label: Annotation group
  sbg:altPrefix: -G
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type:
  - 'null'
  - items:
      name: annotation_group
      symbols:
      - AS_StandardAnnotation
      - OrientationBiasMixtureModelAnnotation
      - ReducibleAnnotation
      - StandardAnnotation
      - StandardHCAnnotation
      - StandardMutectAnnotation
      type: enum
    type: array
- doc: One or more specific annotations to exclude from variant calls.
  id: annotations_to_exclude
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--annotations-to-exclude ' +\
      \ self.join(' --annotations-to-exclude ')\n    } else {\n        return null\n\
      \    }\n}"
  label: Annotations to exclude
  sbg:altPrefix: -AX
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type:
  - 'null'
  - items:
      name: annotations_to_exclude
      symbols:
      - BaseQualityRankSumTest
      - ChromosomeCounts
      - Coverage
      - DepthPerAlleleBySample
      - DepthPerSampleHC
      - ExcessHet
      - FisherStrand
      - InbreedingCoeff
      - MappingQualityRankSumTest
      - QualByDepth
      - ReadPosRankSumTest
      - RMSMappingQuality
      - StrandOddsRatio
      type: enum
    type: array
- doc: Read one or more arguments files and add them to the command line.
  id: arguments_file
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        var cmd = '';\n        for (var i=0;\
      \ i<self.length; i++) {\n            cmd += ' --arguments_file ' + self[i].path\n\
      \        }\n        return cmd\n    } else {\n        return null\n    }\n}"
  label: Arguments
  sbg:category: Optional Arguments
  sbg:fileTypes: TXT
  sbg:toolDefaultValue: 'null'
  type: File[]?
- doc: Output the assembly region to this IGV formatted file.
  id: assembly_region_out
  inputBinding:
    position: 4
    prefix: --assembly-region-out
    shellQuote: false
  label: Assembly region output
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type: string?
- doc: Number of additional bases of context to include around each assembly region.
  id: assembly_region_padding
  inputBinding:
    position: 4
    prefix: --assembly-region-padding
    shellQuote: false
  label: Assembly region padding
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '100'
  type: int?
- doc: File to which assembled haplotypes should be written.
  id: bam_output
  inputBinding:
    position: 4
    prefix: --bam-output
    shellQuote: false
  label: BAM output
  sbg:altPrefix: -bamout
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'null'
  type: string?
- doc: Which haplotypes should be written to the BAM.
  id: bam_writer_type
  inputBinding:
    position: 4
    prefix: --bam-writer-type
    shellQuote: false
  label: BAM writer type
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: CALLED_HAPLOTYPES
  type:
  - 'null'
  - name: bam_writer_type
    symbols:
    - ALL_POSSIBLE_HAPLOTYPES
    - CALLED_HAPLOTYPES
    type: enum
- doc: Base qualities below this threshold will be reduced to the minimum (6).
  id: base_quality_score_threshold
  inputBinding:
    position: 4
    prefix: --base-quality-score-threshold
    shellQuote: false
  label: Base quality score threshold
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '18'
  type: int?
- doc: Comparison vcf file(s).
  id: comp
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        var cmd = '';\n        for (var i=0;\
      \ i<self.length; i++) {\n            cmd += ' --comp ' + self[i].path\n    \
      \    }\n        return cmd\n    } else {\n        return null\n    }\n}"
  label: Comparison VCF
  sbg:altPrefix: -comp
  sbg:category: Advanced Arguments
  sbg:fileTypes: VCF
  sbg:toolDefaultValue: 'null'
  type: File[]?
- doc: 1000g consensus mode.
  id: consensus
  inputBinding:
    position: 4
    prefix: --consensus
    shellQuote: false
  label: Consensus
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Tab-separated file containing fraction of contamination in sequencing data
    (per sample) to aggressively remove. Format should be ".
  id: contamination_fraction_per_sample_file
  inputBinding:
    position: 4
    prefix: --contamination-fraction-per-sample-file
    shellQuote: false
  label: Contamination fraction per sample
  sbg:altPrefix: -contamination-file
  sbg:category: Advanced Arguments
  sbg:fileTypes: TSV
  type: File?
- doc: Fraction of contamination in sequencing data (for all samples) to aggressively
    remove 0.
  id: contamination_fraction_to_filter
  inputBinding:
    position: 4
    prefix: --contamination-fraction-to-filter
    shellQuote: false
  label: Contamination fraction to filter
  sbg:altPrefix: -contamination
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: float?
- doc: Undocumented option.
  id: correct_overlapping_quality
  inputBinding:
    position: 4
    prefix: --correct-overlapping-quality
    shellQuote: false
  label: Correct overlapping quality
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: If true, create a BAM/CRAM index when writing a coordinate-sorted BAM/CRAM
    file.
  id: create_output_bam_index
  inputBinding:
    position: 4
    prefix: --create-output-bam-index
    shellQuote: false
  label: Create output BAM index
  sbg:altPrefix: -OBI
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'true'
  type:
  - 'null'
  - name: create_output_bam_index
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: If true, create a md5 digest for any BAM/SAM/CRAM file created.
  id: create_output_bam_md5
  inputBinding:
    position: 4
    prefix: --create-output-bam-md5
    shellQuote: false
  label: Create output BAM md5
  sbg:altPrefix: -OBM
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: If true, create a vcf index when writing a coordinate-sorted VCF file.
  id: create_output_variant_index
  inputBinding:
    position: 4
    prefix: --create-output-variant-index
    shellQuote: false
  label: Create output variant index
  sbg:altPrefix: -OVI
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'true'
  type:
  - 'null'
  - name: create_output_variant_index
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: If true, create a a md5 digest any VCF file created.
  id: create_output_variant_md5
  inputBinding:
    position: 4
    prefix: --create-output-variant-md5
    shellQuote: false
  label: Create output variant md5
  sbg:altPrefix: -OVM
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: dbSNP file.
  id: dbsnp
  inputBinding:
    position: 4
    prefix: --dbsnp
    shellQuote: false
  label: dbSNP
  sbg:altPrefix: -D
  sbg:category: Optional Arguments
  sbg:fileTypes: VCF
  sbg:toolDefaultValue: 'null'
  secondaryFiles:
  - .idx
  type: File?
- doc: Print out very verbose debug information about each triggering active region.
  id: debug
  inputBinding:
    position: 4
    prefix: --debug
    shellQuote: false
  label: Debug
  sbg:altPrefix: -debug
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: If true, don't cache BAM indexes, this will reduce memory requirements but
    may harm performance if many intervals are specified. Caching is automatically
    disabled if there are no intervals specified.
  id: disable_bam_index_caching
  inputBinding:
    position: 4
    prefix: --disable-bam-index-caching
    shellQuote: false
  label: Disable BAM index caching
  sbg:altPrefix: -DBIC
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Don't skip calculations in activeregions with no variants.
  id: disable_optimizations
  inputBinding:
    position: 4
    prefix: --disable-optimizations
    shellQuote: false
  label: Disable optimizations
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Read filters to be disabled before analysis.
  id: disable_read_filter
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--disable-read-filter ' + self.join('\
      \ --disable-read-filter ')\n    } else {\n        return null\n    }\n}"
  label: Disable read filter
  sbg:altPrefix: -DF
  sbg:category: Optional Arguments
  type:
  - 'null'
  - items:
      name: disable_read_filter
      symbols:
      - GoodCigarReadFilter
      - MappedReadFilter
      - MappingQualityAvailableReadFilter
      - MappingQualityReadFilter
      - NonZeroReferenceLengthAlignmentReadFilter
      - NotDuplicateReadFilter
      - NotSecondaryAlignmentReadFilter
      - PassesVendorQualityCheckReadFilter
      - WellformedReadFilter
      type: enum
    type: array
- doc: If specified, do not check the sequence dictionaries from our inputs for compatibility.
    Use at your own risk!
  id: disable_sequence_dictionary_validation
  inputBinding:
    position: 4
    prefix: --disable-sequence-dictionary-validation
    shellQuote: false
  label: Disable sequence dictionary validation
  sbg:altPrefix: -disable-sequence-dictionary-validation
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Disable all tool default annotations.
  id: disable_tool_default_annotations
  inputBinding:
    position: 4
    prefix: --disable-tool-default-annotations
    shellQuote: false
  label: Disable tool default annotations
  sbg:altPrefix: -disable-tool-default-annotations
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: 'Disable all tool default read filters (warning: many tools will not function
    correctly without their default read filters on).'
  id: disable_tool_default_read_filters
  inputBinding:
    position: 4
    prefix: --disable-tool-default-read-filters
    shellQuote: false
  label: Disable tool default read filters
  sbg:altPrefix: -disable-tool-default-read-filters
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Disable physical phasing.
  id: do_not_run_physical_phasing
  inputBinding:
    position: 4
    prefix: --do-not-run-physical-phasing
    shellQuote: false
  label: Do not run physical phasing
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Disable iterating over kmer sizes when graph cycles are detected.
  id: dont_increase_kmer_sizes_for_cycles
  inputBinding:
    position: 4
    prefix: --dont-increase-kmer-sizes-for-cycles
    shellQuote: false
  label: Dont increase kmer sizes for cycles
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: If specified, we will not trim down the active region from the full region
    (active + extension) to just the active interval for genotyping.
  id: dont_trim_active_regions
  inputBinding:
    position: 4
    prefix: --dont-trim-active-regions
    shellQuote: false
  label: Dont trim active regions
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Do not analyze soft clipped bases in the reads.
  id: dont_use_soft_clipped_bases
  inputBinding:
    position: 4
    prefix: --dont-use-soft-clipped-bases
    shellQuote: false
  label: Do not use soft clipped bases
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Mode for emitting reference confidence scores.
  id: emit_ref_confidence
  inputBinding:
    position: 4
    prefix: --emit-ref-confidence
    shellQuote: false
  label: Emit ref confidence
  sbg:altPrefix: -ERC
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: NONE
  type:
  - 'null'
  - name: emit_ref_confidence
    symbols:
    - NONE
    - BP_RESOLUTION
    - GVCF
    type: enum
- doc: Use all possible annotations (not for the faint of heart).
  id: enable_all_annotations
  inputBinding:
    position: 4
    prefix: --enable-all-annotations
    shellQuote: false
  label: Enable all annotations
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: One or more genomic intervals to exclude from processing.
  id: exclude_intervals_string
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--exclude-intervals ' + self.join('\
      \ --exclude-intervals ')\n    } else {\n        return null\n    }\n}"
  label: Exclude intervals string values
  sbg:altPrefix: -XL
  sbg:category: Optional Arguments
  type: string[]?
- doc: Samples representing the population "founders".
  id: founder_id
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--founder-id ' + self.join('\
      \ --founder-id ')\n    } else {\n        return null\n    }\n}"
  label: Founder id
  sbg:altPrefix: -founder-id
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type: string[]?
- doc: A configuration file to use with the GATK.
  id: gatk_config_file
  inputBinding:
    position: 4
    prefix: --gatk-config-file
    shellQuote: false
  label: GATK config
  sbg:category: Optional Arguments
  sbg:fileTypes: TXT
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: If the GCS bucket channel errors out, how many times it will attempt to re-initiate
    the connection.
  id: gcs_max_retries
  inputBinding:
    position: 4
    prefix: --gcs-max-retries
    shellQuote: false
  label: GCS max retries
  sbg:altPrefix: -gcs-retries
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '20'
  type: int?
- doc: 'Project to bill when accessing "requester pays" buckets. If unset, these buckets
    cannot be accessed. Default value: .'
  id: gcs_project_for_requester_pays
  inputBinding:
    position: 4
    prefix: --gcs-project-for-requester-pays
    shellQuote: false
  label: GCS project for requester pays
  sbg:category: Optional Arguments
  type: string?
- doc: Whether to genotype all given alleles, even filtered ones, --genotyping_mode
    is genotype_given_alleles.
  id: genotype_filtered_alleles
  inputBinding:
    position: 4
    prefix: --genotype-filtered-alleles
    shellQuote: false
  label: Genotype filtered alleles
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Specifies how to determine the alternate alleles to use for genotyping.
  id: genotyping_mode
  inputBinding:
    position: 4
    prefix: --genotyping-mode
    shellQuote: false
  label: Genotyping mode
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: DISCOVERY
  type:
  - 'null'
  - name: genotyping_mode
    symbols:
    - DISCOVERY
    - GENOTYPE_GIVEN_ALLELES
    type: enum
- doc: Write debug assembly graph information to this file.
  id: graph_output
  inputBinding:
    position: 4
    prefix: --graph-output
    shellQuote: false
  label: Graph output
  sbg:altPrefix: -graph
  sbg:category: Optional Arguments
  type: string?
- doc: Exclusive upper bounds for reference confidence GQ bands (must be value from
    1 to 100 and specified in increasing order).
  id: gvcf_gq_bands
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--gvcf-gq-bands ' + self.join('\
      \ --gvcf-gq-bands ')\n    } else {\n        return null\n    }\n}"
  label: GVCF GQ bands
  sbg:altPrefix: -GQB
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37,
    38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
    58, 59, 60, 70, 80, 90, 99
  type: int[]?
- doc: Heterozygosity value used to compute prior likelihoods for any locus. See the
    gatkdocs for full details on the meaning of this population genetics concept.
  id: heterozygosity
  inputBinding:
    position: 4
    prefix: --heterozygosity
    shellQuote: false
  label: Heterozygosity
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0.001'
  type: float?
- doc: Standard deviation of heterozygosity for SNP and indel calling.
  id: heterozygosity_stdev
  inputBinding:
    position: 4
    prefix: --heterozygosity-stdev
    shellQuote: false
  label: Heterozygosity stdev
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0.01'
  type: float?
- doc: Heterozygosity for indel calling. See the gatkdocs for heterozygosity for full
    details on the meaning of this population genetics concept.
  id: indel_heterozygosity
  inputBinding:
    position: 4
    prefix: --indel-heterozygosity
    shellQuote: false
  label: Indel heterozygosity
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '1.25E-4'
  type: float?
- doc: The size of an indel to check for in the reference model.
  id: indel_size_to_eliminate_in_ref_model
  inputBinding:
    position: 4
    prefix: --indel-size-to-eliminate-in-ref-model
    shellQuote: false
  label: Indel size to eliminate in ref model
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '10'
  type: int?
- doc: BAM/SAM/CRAM file containing reads this argument must be specified at least
    once.
  id: in_alignments
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    var in_files = [].concat(inputs.in_alignments);\n    if (in_files)\
      \ {\n        var cmd = '';\n        for (var i=0; i<in_files.length; i++) {\n\
      \            cmd += ' --input ' + in_files[i].path\n        }\n        return\
      \ cmd\n    } else {\n        return null\n    }\n}"
  label: Input alignments
  sbg:altPrefix: -I
  sbg:category: Required Arguments
  sbg:fileTypes: BAM, SAM, CRAM
  secondaryFiles:
  - "${ \n    if(self.nameext == '.bam'){\n    return self.nameroot + \".bai\";\n\
    \    }\n    else if(self.nameext == '.cram'){\n    return self.nameroot + \".crai\"\
    ;\n    } else {\n    return null;\n    }\n}"
  type: File[]
- doc: Input prior for calls.
  id: input_prior
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--input-prior ' + self.join('\
      \ --input-prior ')\n    } else {\n        return null\n    }\n}"
  label: Input prior
  sbg:category: Advanced Arguments
  type: float[]?
- doc: Amount of padding (in bp) to add to each interval you are excluding.
  id: interval_exclusion_padding
  inputBinding:
    position: 4
    prefix: --interval-exclusion-padding
    shellQuote: false
  label: Interval exclusion padding
  sbg:altPrefix: -ixp
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Interval merging rule for abutting intervals.
  id: interval_merging_rule
  inputBinding:
    position: 4
    prefix: --interval-merging-rule
    shellQuote: false
  label: Interval merging rule
  sbg:altPrefix: -imr
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: ALL
  type:
  - 'null'
  - name: interval_merging_rule
    symbols:
    - ALL
    - OVERLAPPING_ONLY
    type: enum
- doc: Amount of padding (in bp) to add to each interval you are including.
  id: interval_padding
  inputBinding:
    position: 4
    prefix: --interval-padding
    shellQuote: false
  label: Interval padding
  sbg:altPrefix: -ip
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Set merging approach to use for combining interval inputs.
  id: interval_set_rule
  inputBinding:
    position: 4
    prefix: --interval-set-rule
    shellQuote: false
  label: Interval set rule
  sbg:altPrefix: -isr
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: UNION
  type:
  - 'null'
  - name: interval_set_rule
    symbols:
    - UNION
    - INTERSECTION
    type: enum
- doc: One or more genomic intervals over which to operate.
  id: include_intervals
  inputBinding:
    position: 4
    prefix: --intervals
    shellQuote: false
  label: Include genomic intervals
  sbg:altPrefix: -L
  sbg:category: Optional Arguments
  sbg:fileTypes: INTERVAL_LIST
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: One or more genomic intervals over which to operate.
  id: include_intervals_string
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--intervals ' + self.join(' --intervals\
      \ ')\n    } else {\n        return null\n    }\n}"
  label: Intervals string values
  sbg:altPrefix: -L
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'null'
  type: string[]?
- doc: Kmer size to use in the read threading assembler.
  id: kmer_size
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--kmer-size ' + self.join(' --kmer-size\
      \ ')\n    } else {\n        return null\n    }\n}"
  label: Kmer size
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 10, 25
  type: int[]?
- doc: Lenient processing of VCF files.
  id: lenient
  inputBinding:
    position: 4
    prefix: --lenient
    shellQuote: false
  label: Lenient
  sbg:altPrefix: -LE
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Maximum number of alternate alleles to genotype.
  id: max_alternate_alleles
  inputBinding:
    position: 4
    prefix: --max-alternate-alleles
    shellQuote: false
  label: Max alternate alleles
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '6'
  type: int?
- doc: Maximum size of an assembly region.
  id: max_assembly_region_size
  inputBinding:
    position: 4
    prefix: --max-assembly-region-size
    shellQuote: false
  label: Max assembly region size
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '300'
  type: int?
- doc: Maximum number of genotypes to consider at any site.
  id: max_genotype_count
  inputBinding:
    position: 4
    prefix: --max-genotype-count
    shellQuote: false
  label: Max genotype count
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '1024'
  type: int?
- doc: 'Two or more phased substitutions separated by this distance or less are merged
    into MNPs. Warning: when used in GVCF mode, resulting GVCFs cannot be joint-genotyped.'
  id: max_mnp_distance
  inputBinding:
    position: 4
    prefix: --max-mnp-distance
    shellQuote: false
  label: Max MNP distance
  sbg:altPrefix: -mnp-dist
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Maximum number of haplotypes to consider for your population.
  id: max_num_haplotypes_in_population
  inputBinding:
    position: 4
    prefix: --max-num-haplotypes-in-population
    shellQuote: false
  label: Max num haplotypes in population
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '128'
  type: int?
- doc: Upper limit on how many bases away probability mass can be moved around when
    calculating the boundaries between active and inactive assembly regions.
  id: max_prob_propagation_distance
  inputBinding:
    position: 4
    prefix: --max-prob-propagation-distance
    shellQuote: false
  label: Max prob propagation distance
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '50'
  type: int?
- doc: Maximum number of reads to retain per alignment start position. Reads above
    this threshold will be downsampled. Set to 0 to disable.
  id: max_reads_per_alignment_start
  inputBinding:
    position: 4
    prefix: --max-reads-per-alignment-start
    shellQuote: false
  label: Max reads per alignment start
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '50'
  type: int?
- doc: Maximum number of variants in graph the adaptive pruner will allow.
  id: max_unpruned_variants
  inputBinding:
    position: 4
    prefix: --max-unpruned-variants
    shellQuote: false
  label: Max unpruned variants
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '100'
  type: int?
- doc: 'Valid only if "MappingQualityReadFilter" is specified:

    Maximum mapping quality to keep (inclusive).'
  id: maximum_mapping_quality
  inputBinding:
    position: 5
    prefix: --maximum-mapping-quality
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      MappingQualityReadFilter\") != -1){\n            return self\n        }\n  \
      \  }\n}"
  label: Maximum mapping quality
  sbg:category: Conditional Arguments for read-filter option
  type: int?
- doc: Memory overhead per job. By default this parameter value is set to '0' (zero
    megabytes). This parameter value is added to the Memory per job parameter value.
    This results in the allocation of the sum total (Memory per job and Memory overhead
    per job) amount of memory per job. By default the memory per job parameter value
    is set to 2048 megabytes, unless specified otherwise.
  id: mem_overhead_per_job
  label: Memory overhead per job
  sbg:category: Platform options
  type: int?
- doc: Amount of RAM memory to be used per job. Defaults to 2048MB for Single threaded
    jobs,and all of the available memory on the instance for multi-threaded jobs.
  id: mem_per_job
  label: Memory per job
  sbg:category: Platform options
  sbg:toolDefaultValue: '2048'
  type: int?
- doc: Minimum size of an assembly region.
  id: min_assembly_region_size
  inputBinding:
    position: 4
    prefix: --min-assembly-region-size
    shellQuote: false
  label: Min assembly region size
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '50'
  type: int?
- doc: Minimum base quality required to consider a base for calling.
  id: min_base_quality_score
  inputBinding:
    position: 4
    prefix: --min-base-quality-score
    shellQuote: false
  label: Min base quality score
  sbg:altPrefix: -mbq
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '10'
  type: int?
- doc: Minimum length of a dangling branch to attempt recovery.
  id: min_dangling_branch_length
  inputBinding:
    position: 4
    prefix: --min-dangling-branch-length
    shellQuote: false
  label: Min dangling branch length
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '4'
  type: int?
- doc: Minimum support to not prune paths in the graph.
  id: min_pruning
  inputBinding:
    position: 4
    prefix: --min-pruning
    shellQuote: false
  label: Min pruning
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '2'
  type: int?
- doc: 'Valid only if "MappingQualityReadFilter" is specified:

    Minimum mapping quality to keep (inclusive).'
  id: minimum_mapping_quality
  inputBinding:
    position: 5
    prefix: --minimum-mapping-quality
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      MappingQualityReadFilter\") != -1){\n            return self\n        }\n  \
      \  }\n}"
  label: Minimum mapping quality
  sbg:category: Conditional Arguments
  sbg:toolDefaultValue: '20'
  type: int?
- doc: How many threads should a native pairHMM implementation use.
  id: native_pair_hmm_threads
  inputBinding:
    position: 4
    prefix: --native-pair-hmm-threads
    shellQuote: false
  label: Native pairHMM threads
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '4'
  type: int?
- doc: Use double precision in the native pairHMM. This is slower but matches the
    java implementation better.
  id: native_pair_hmm_use_double_precision
  inputBinding:
    position: 4
    prefix: --native-pair-hmm-use-double-precision
    shellQuote: false
  label: Native pairHMM use double precision
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Number of samples that must pass the minPruning threshold.
  id: num_pruning_samples
  inputBinding:
    position: 4
    prefix: --num-pruning-samples
    shellQuote: false
  label: Num pruning samples
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '1'
  type: int?
- doc: Number of hom-ref genotypes to infer at sites not present in a panel.
  id: num_reference_samples_if_no_call
  inputBinding:
    position: 4
    prefix: --num-reference-samples-if-no-call
    shellQuote: false
  label: Num reference samples if no call
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '0'
  type: int?
- doc: Output prefix.
  id: output_prefix
  label: Output prefix
  sbg:altPrefix: -O
  sbg:category: Required Arguments
  type: string?
- doc: Specifies which type of calls are contained output.
  id: output_mode
  inputBinding:
    position: 4
    prefix: --output-mode
    shellQuote: false
  label: Output mode
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: EMIT_VARIANTS_ONLY
  type:
  - 'null'
  - name: output_mode
    symbols:
    - EMIT_VARIANTS_ONLY
    - EMIT_ALL_CONFIDENT_SITES
    - EMIT_ALL_SITES
    type: enum
- doc: Flat gap continuation penalty for use in the pairHMM.
  id: pair_hmm_gap_continuation_penalty
  inputBinding:
    position: 4
    prefix: --pair-hmm-gap-continuation-penalty
    shellQuote: false
  label: Pair HMM gap continuation penalty
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '10'
  type: int?
- doc: The pairHMM implementation to use for genotype likelihood calculations.
  id: pair_hmm_implementation
  inputBinding:
    position: 4
    prefix: --pair-hmm-implementation
    shellQuote: false
  label: Pair HMM implementation
  sbg:altPrefix: -pairHMM
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: FASTEST_AVAILABLE
  type:
  - 'null'
  - name: pair_hmm_implementation
    symbols:
    - EXACT
    - ORIGINAL
    - LOGLESS_CACHING
    - AVX_LOGLESS_CACHING
    - AVX_LOGLESS_CACHING_OMP
    - EXPERIMENTAL_FPGA_LOGLESS_CACHING
    - FASTEST_AVAILABLE
    type: enum
- doc: The PCR indel model to use.
  id: pcr_indel_model
  inputBinding:
    position: 4
    prefix: --pcr-indel-model
    shellQuote: false
  label: PCR indel model
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: CONSERVATIVE
  type:
  - 'null'
  - name: pcr_indel_model
    symbols:
    - NONE
    - HOSTILE
    - AGGRESSIVE
    - CONSERVATIVE
    type: enum
- doc: Pedigree file for determining the population "founders".
  id: pedigree
  inputBinding:
    position: 4
    prefix: --pedigree
    shellQuote: false
  label: Pedigree
  sbg:altPrefix: -ped
  sbg:category: Optional Arguments
  sbg:fileTypes: PED
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: The global assumed mismapping rate for reads.
  id: phred_scaled_global_read_mismapping_rate
  inputBinding:
    position: 4
    prefix: --phred-scaled-global-read-mismapping-rate
    shellQuote: false
  label: Phred scaled global read mismapping rate
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '45'
  type: int?
- doc: Callset to use in calculating genotype priors.
  id: population_callset
  inputBinding:
    position: 4
    prefix: --population-callset
    shellQuote: false
  label: Population callset
  sbg:altPrefix: -population
  sbg:category: Optional Arguments
  sbg:fileTypes: VCF
  sbg:toolDefaultValue: 'null'
  type: File?
- doc: Log-10 likelihood ratio threshold for adaptive pruning algorithm.
  id: pruning_lod_threshold
  inputBinding:
    position: 4
    prefix: --pruning-lod-threshold
    shellQuote: false
  label: Pruning lod threshold
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: '1.0'
  type: float?
- doc: Read filters to be applied before analysis.
  id: read_filter
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--read-filter ' + self.join('\
      \ --read-filter ')\n    } else {\n        return null\n    }\n}"
  label: Read filter
  sbg:altPrefix: -RF
  sbg:category: Optional Arguments
  type:
  - 'null'
  - items:
      name: read_filter
      symbols:
      - AlignmentAgreesWithHeaderReadFilter
      - AllowAllReadsReadFilter
      - AmbiguousBaseReadFilter
      - CigarContainsNoNOperator
      - FirstOfPairReadFilter
      - FragmentLengthReadFilter
      - GoodCigarReadFilter
      - HasReadGroupReadFilter
      - LibraryReadFilter
      - MappedReadFilter
      - MappingQualityAvailableReadFilter
      - MappingQualityNotZeroReadFilter
      - MappingQualityReadFilter
      - MatchingBasesAndQualsReadFilter
      - MateDifferentStrandReadFilter
      - MateOnSameContigOrNoMappedMateReadFilter
      - MetricsReadFilter
      - NonChimericOriginalAlignmentReadFilter
      - NonZeroFragmentLengthReadFilter
      - NonZeroReferenceLengthAlignmentReadFilter
      - NotDuplicateReadFilter
      - NotOpticalDuplicateReadFilter
      - NotSecondaryAlignmentReadFilter
      - NotSupplementaryAlignmentReadFilter
      - OverclippedReadFilter
      - PairedReadFilter
      - PassesVendorQualityCheckReadFilter
      - PlatformReadFilter
      - PlatformUnitReadFilter
      - PrimaryLineReadFilter
      - ProperlyPairedReadFilter
      - ReadGroupBlackListReadFilter
      - ReadGroupReadFilter
      - ReadLengthEqualsCigarLengthReadFilter
      - ReadLengthReadFilter
      - ReadNameReadFilter
      - ReadStrandFilter
      - SampleReadFilter
      - SecondOfPairReadFilter
      - SeqIsStoredReadFilter
      - ValidAlignmentEndReadFilter
      - ValidAlignmentStartReadFilter
      - WellformedReadFilter
      type: enum
    type: array
- doc: Indices to use for the read inputs. If specified, an index must be provided
    for every read input and in the same order as the read inputs. If this argument
    is not specified, the path to the index for each input will be inferred automatically.
  id: read_index
  inputBinding:
    position: 4
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if (self) {\n        return '--read-index ' + self.join('\
      \ --read-index ')\n    } else {\n        return null\n    }\n}"
  label: Read index
  sbg:altPrefix: -read-index
  sbg:category: Optional Arguments
  type: string[]?
- doc: Validation stringency for all SAM/BAM/CRAM/SRA files read by this program.
    The default stringency value silent can improve performance when processing a
    bam file in which variable-length data (read, qualities, tags) do not otherwise
    need to be decoded.
  id: read_validation_stringency
  inputBinding:
    position: 4
    prefix: --read-validation-stringency
    shellQuote: false
  label: Read validation stringency
  sbg:altPrefix: -VS
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: SILENT
  type:
  - 'null'
  - name: read_validation_stringency
    symbols:
    - STRICT
    - LENIENT
    - SILENT
    type: enum
- doc: This argument is deprecated since version 3.3.
  id: recover_dangling_heads
  inputBinding:
    position: 4
    prefix: --recover-dangling-heads
    shellQuote: false
  label: Recover dangling heads
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Reference sequence file.
  id: in_reference
  inputBinding:
    position: 4
    prefix: --reference
    shellQuote: false
  label: Reference
  sbg:altPrefix: -R
  sbg:category: Required Arguments
  sbg:fileTypes: FASTA, FA
  sbg:toolDefaultValue: FASTA, FA
  secondaryFiles:
  - .fai
  - ^.dict
  type: File
- doc: Name of single sample to use from a multi-sample bam.
  id: sample_name
  inputBinding:
    position: 4
    prefix: --sample-name
    shellQuote: false
  label: Sample name
  sbg:altPrefix: -ALIAS
  sbg:category: Optional Arguments
  type: string?
- doc: Ploidy (number of chromosomes) per sample. For pooled data, set to (number
    of samples in each pool x Sample Ploidy).
  id: sample_ploidy
  inputBinding:
    position: 4
    prefix: --sample-ploidy
    shellQuote: false
  label: Sample ploidy
  sbg:altPrefix: -ploidy
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '2'
  type: int?
- doc: Output traversal statistics every time this many seconds elapse.
  id: seconds_between_progress_updates
  inputBinding:
    position: 4
    prefix: --seconds-between-progress-updates
    shellQuote: false
  label: Seconds between progress updates
  sbg:altPrefix: -seconds-between-progress-updates
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '10.0'
  type: float?
- doc: Use the given sequence dictionary as the master/canonical sequence dictionary.
    Must be a .dict file.
  id: sequence_dictionary
  inputBinding:
    position: 4
    prefix: --sequence-dictionary
    shellQuote: false
  label: Sequence dictionary
  sbg:altPrefix: -sequence-dictionary
  sbg:category: Optional Arguments
  type: string?
- doc: If true, don't emit genotype fields when writing VCF file output.
  id: sites_only_vcf_output
  inputBinding:
    position: 4
    prefix: --sites-only-vcf-output
    shellQuote: false
  label: Sites only VCF output
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Which Smith-Waterman implementation to use, generally FASTEST_AVAILABLE is
    the right choice.
  id: smith_waterman
  inputBinding:
    position: 4
    prefix: --smith-waterman
    shellQuote: false
  label: Smith waterman
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: JAVA
  type:
  - 'null'
  - name: smith_waterman
    symbols:
    - FASTEST_AVAILABLE
    - AVX_ENABLED
    - JAVA
    type: enum
- doc: The minimum phred-scaled confidence threshold at which variants should be called.
  id: standard_min_confidence_threshold_for_calling
  inputBinding:
    position: 4
    prefix: --standard-min-confidence-threshold-for-calling
    shellQuote: false
  label: Standard min confidence threshold for calling
  sbg:altPrefix: -stand-call-conf
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: '30.0'
  type: float?
- doc: Temporary directory to use.
  id: tmp_dir
  inputBinding:
    position: 4
    prefix: --tmp-dir
    shellQuote: false
  label: Tmp dir
  sbg:category: Optional Arguments
  type: string?
- doc: Use additional trigger on variants found in an external alleles file.
  id: use_alleles_trigger
  inputBinding:
    position: 4
    prefix: --use-alleles-trigger
    shellQuote: false
  label: Use alleles trigger
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Use the contamination-filtered read maps for the purposes of annotating variants.
  id: use_filtered_reads_for_annotations
  inputBinding:
    position: 4
    prefix: --use-filtered-reads-for-annotations
    shellQuote: false
  label: Use filtered reads for annotations
  sbg:category: Advanced Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Whether to use the JdkDeflater (as opposed to IntelDeflater).
  id: use_jdk_deflater
  inputBinding:
    position: 4
    prefix: --use-jdk-deflater
    shellQuote: false
  label: Use JdkDeflater
  sbg:altPrefix: -jdk-deflater
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Whether to use the jdkinflater (as opposed to IntelInflater).
  id: use_jdk_inflater
  inputBinding:
    position: 4
    prefix: --use-jdk-inflater
    shellQuote: false
  label: Use JdkInflater
  sbg:altPrefix: -jdk-inflater
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Use the new AF model instead of the so-called exact model.
  id: use_new_qual_calculator
  inputBinding:
    position: 4
    prefix: --use-new-qual-calculator
    shellQuote: false
  label: Use new qual calculator
  sbg:altPrefix: -new-qual
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'true'
  type:
  - 'null'
  - name: use_new_qual_calculator
    symbols:
    - 'true'
    - 'false'
    type: enum
- doc: Use the old AF model.
  id: use_old_qual_calculator
  inputBinding:
    position: 4
    prefix: --use-old-qual-calculator
    shellQuote: false
  label: Use old qual calculator
  sbg:altPrefix: -old-qual
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: Control verbosity of logging.
  id: verbosity
  inputBinding:
    position: 4
    prefix: --verbosity
    shellQuote: false
  label: Verbosity
  sbg:altPrefix: -verbosity
  sbg:category: Optional Arguments
  sbg:toolDefaultValue: INFO
  type:
  - 'null'
  - name: verbosity
    symbols:
    - ERROR
    - WARNING
    - INFO
    - DEBUG
    type: enum
- doc: One or more genomic intervals to exclude from processing.
  id: exclude_intervals_file
  inputBinding:
    position: 4
    prefix: --exclude-intervals
    shellQuote: false
  label: Exclude genomic intervals
  sbg:altPrefix: -XL
  sbg:category: Optional Arguments
  sbg:fileTypes: INTERVAL_LIST
  type: File?
- doc: Number of CPUs to be used per job.
  id: cpu_per_job
  label: CPU per job
  sbg:category: Platform options
  sbg:toolDefaultValue: '1'
  type: int?
- doc: 'Valid only if "AmbiguousBaseReadFilter" is specified:

    Threshold number of ambiguous bases. If null, uses threshold fraction; otherwise,
    overrides threshold fraction. Cannot be used in conjuction with argument(s) maxAmbiguousBaseFraction.'
  id: ambig_filter_bases
  inputBinding:
    position: 5
    prefix: --ambig-filter-bases
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      AmbiguousBaseReadFilter\") != -1 &&\n        inputs.read_filter.indexOf(\"maxAmbiguousBaseFraction\"\
      ) == -1){\n            return self\n        }\n    }\n}\n"
  label: Ambig filter bases
  sbg:category: Conditional Arguments for read-filter option
  type: int?
- doc: 'Valid only if "AmbiguousBaseReadFilter" is specified:

    Threshold fraction of ambiguous bases. Cannot be used in conjuction with argument(s)
    maxAmbiguousBases.'
  id: ambig_filter_frac
  inputBinding:
    position: 5
    prefix: --ambig-filter-frac
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      AmbiguousBaseReadFilter\") != -1 &&\n        inputs.read_filter.indexOf(\"maxAmbiguousBases\"\
      ) == -1){\n            return self\n        }\n    }\n}\n"
  label: Ambig filter frac
  sbg:category: Conditional Arguments for read-filter option
  sbg:toolDefaultValue: '0.05'
  type: float?
- doc: 'Valid only if "FragmentLengthReadFilter" is specified:

    Maximum length of fragment (insert size).'
  id: max_fragment_length
  inputBinding:
    position: 5
    prefix: --max-fragment-length
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      FragmentLengthReadFilter\") != -1){\n            return self\n        }\n  \
      \  }\n}\n"
  label: Max fragment length
  sbg:category: Conditional Arguments for read-filter option
  sbg:toolDefaultValue: '1000000'
  type: int?
- doc: 'Valid only if "LibraryReadFilter" is specified:

    Name of the library to keep. This argument must be specified at least once.'
  id: library
  inputBinding:
    position: 5
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter && inputs.read_filter.indexOf(\"\
      LibraryReadFilter\") != -1){\n            return '--library ' + self.join('\
      \ --library ')\n        } else {\n            return null\n        }\n}\n\n"
  label: Library
  sbg:category: Conditional Arguments for read-filter option
  type: string[]?
- doc: 'Valid only if "OverclippedReadFilter" is specified:

    Allow a read to be filtered out based on having only 1 soft-clipped block. By
    default, both ends must have a soft-clipped block, setting this flag requires
    only 1 soft-clipped block.'
  id: dont_require_soft_clips_both_ends
  inputBinding:
    position: 5
    prefix: --dont-require-soft-clips-both-ends
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      OverclippedReadFilter\") != -1){\n            return self\n        }\n    }\n\
      }"
  label: Do not require soft clips
  sbg:category: Conditional Arguments for read-filter option
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: 'Valid only if "OverclippedReadFilter" is specified:

    Minimum number of aligned bases.'
  id: filter_too_short
  inputBinding:
    position: 5
    prefix: --filter-too-short
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      OverclippedReadFilter\") != -1){\n            return self\n        }\n    }\n\
      }"
  label: Filter too short
  sbg:category: Conditional Arguments for read-filter option
  sbg:toolDefaultValue: '30'
  type: int?
- doc: 'Valid only if "PlatformReadFilter" is specified:

    Platform attribute (PL) to match.  This argument must be specified at least once.'
  id: platform_filter_name
  inputBinding:
    position: 5
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter && inputs.read_filter.indexOf(\"\
      PlatformReadFilter\") != -1){\n        return \"--platform-filter-name \" +\
      \ self.join(' --platform-filter-name ')\n    } else {\n        return null\n\
      \    }\n}\n\n"
  label: Platform filter name
  sbg:category: Conditional Arguments for read-filter option
  type: string[]?
- doc: 'Valid only if "PlatformUnitReadFilter" is specified:

    Platform unit (PU) to filter out. This argument must be specified at least once.'
  id: black_listed_lanes
  inputBinding:
    position: 5
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter && inputs.read_filter.indexOf(\"\
      PlatformUnitReadFilter\") != -1){\n            return \"--black-listed-lanes\
      \ \" + self.join(' --black-listed-lanes ')\n    } else {\n        return null\n\
      \    }\n}\n\n"
  label: Black listed lanes
  sbg:category: Conditional Arguments for read-filter option
  type: string[]?
- doc: 'Valid only if "ReadGroupBlackListReadFilter" is specified:

    The name of the read group to filter out. This argument must be specified at least
    once.'
  id: read_group_black_list
  inputBinding:
    position: 5
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter && inputs.read_filter.indexOf(\"\
      ReadGroupBlackListReadFilter\") != -1){\n            return \"--read-group-black-list\
      \ \" + self.join(' --read-group-black-list ')\n    } else {\n        return\
      \ null\n    }\n}\n\n"
  label: Read group black list
  sbg:category: Conditional Arguments for read-filter option
  type: string[]?
- doc: 'Valid only if "ReadGroupReadFilter" is specified:

    The name of the read group to keep.'
  id: keep_read_group
  inputBinding:
    position: 5
    prefix: --keep-read-group
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      ReadGroupReadFilter\") != -1){\n            return self\n        }\n    }\n}"
  label: Keep read group
  sbg:category: Conditional Arguments for read-filter option
  type: string?
- doc: 'Valid only if "ReadLengthReadFilter" is specified:

    Keep only reads with length at most equal to the specified value.'
  id: max_read_length
  inputBinding:
    position: 5
    prefix: --max-read-length
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      ReadLengthReadFilter\") != -1){\n            return self\n        }\n    }\n\
      }"
  label: Max read length
  sbg:category: Conditional Arguments for read-filter option
  type: int?
- doc: 'Valid only if "ReadLengthReadFilter" is specified:

    Keep only reads with length at least equal to the specified value.'
  id: min_read_length
  inputBinding:
    position: 5
    prefix: --min-read-length
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      ReadLengthReadFilter\") != -1){\n            return self\n        }\n    }\n\
      }"
  label: Min read length
  sbg:category: Conditional Arguments for read-filter option
  sbg:toolDefaultValue: '1'
  type: int?
- doc: 'Valid only if "ReadNameReadFilter" is specified:

    Keep only reads with this read name.'
  id: read_name
  inputBinding:
    position: 5
    prefix: --read-name
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      ReadNameReadFilter\") != -1){\n            return self\n        }\n    }\n}"
  label: Read name
  sbg:category: Conditional Arguments for read-filter option
  type: string?
- doc: 'Valid only if "ReadStrandFilter" is specified:

    Keep only reads on the reverse strand.'
  id: keep_reverse_strand_only
  inputBinding:
    position: 5
    prefix: --keep-reverse-strand-only
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter){\n        if(inputs.read_filter.indexOf(\"\
      ReadStrandFilter\") != -1){\n            return self\n        }\n    }\n}"
  label: Keep reverse strand only
  sbg:category: Conditional Arguments for read-filter option
  sbg:toolDefaultValue: 'false'
  type: boolean?
- doc: 'Valid only if "SampleReadFilter" is specified:

    The name of the sample(s) to keep, filtering out all others  This argument must
    be specified at least once.'
  id: sample
  inputBinding:
    position: 5
    prefix: ''
    shellQuote: false
    valueFrom: "${\n    if(self && inputs.read_filter && inputs.read_filter.indexOf(\"\
      SampleReadFilter\") != -1){\n            return \"--sample \" + self.join('\
      \ --sample ')\n    } else {\n        return null\n    }\n}\n\n"
  label: Sample
  sbg:category: Conditional Arguments for read-filter option
  type: string[]?
- default: vcf
  doc: Output VCF extension.
  id: output_extension
  label: Output VCF extension
  sbg:category: Required Arguments
  sbg:toolDefaultValue: vcf
  type:
  - 'null'
  - name: output_extension
    symbols:
    - vcf
    - vcf.gz
    type: enum
label: GATK HaplotypeCaller
outputs:
- doc: A raw, unfiltered, highly specific callset in VCF format.
  id: out_variants
  label: VCF output
  outputBinding:
    glob: "${ \n    if (inputs.output_extension == \"vcf\")\n    {\n        return\
      \ \"*.vcf\";\n    }\n    else if (inputs.output_extension == \"vcf.gz\")\n \
      \   {\n        return \"*.vcf.gz\";\n    }\n    else\n    {\n        return\
      \ ''\n    }\n}"
    outputEval: $(inheritMetadata(self, inputs.in_alignments))
  sbg:fileTypes: VCF
  secondaryFiles:
  - "${ \n    if(inputs.output_extension == 'vcf'){\n        return self.basename\
    \ + \".idx\";\n    } \n    else if (inputs.output_extension == 'vcf.gz'){\n  \
    \      return self.basename + \".tbi\";\n    } else {\n        return null;\n\
    \    }\n}"
  type: File?
- doc: Assembled haplotypes.
  id: out_alignments
  label: BAM output
  outputBinding:
    glob: "${\n    if(inputs.bam_output){\n        return inputs.bam_output\n    }\
      \ else {\n        return null\n    }\n}"
    outputEval: $(inheritMetadata(self, inputs.in_alignments))
  sbg:fileTypes: BAM
  secondaryFiles:
  - "${ \n    return self.nameroot + \".bai\";\n}"
  type: File?
- doc: Assembly graph information.
  id: out_graph
  label: Graph output
  outputBinding:
    glob: "${\n    if(inputs.graph_output){\n        return inputs.graph_output\n\
      \    } else {\n        return null\n    }\n}"
    outputEval: $(inheritMetadata(self, inputs.in_alignments))
  type: File?
requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: "${\n    if(inputs.cpu_per_job){\n        return inputs.cpu_per_job;\n\
    \    } else {\n        return 1;\n    }\n}"
  ramMin: "${\n  var memory = 6500;\n  \n  if(inputs.mem_per_job){\n  \t memory =\
    \ inputs.mem_per_job\n  }\n  if(inputs.mem_overhead_per_job){\n\treturn memory\
    \ + inputs.mem_overhead_per_job; \n  }\n  else{\n  \treturn memory;\n  }\n}"
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
- Genomics
- Variant Calling
sbg:content_hash: aad5a3e87aca93b604708277a3ea29a56b099eb4bb91277df56f7585612fb1a54
sbg:contributors:
- uros_sipetic
- veliborka_josipovic
- nemanja.vucic
sbg:copyOf: veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/19
sbg:createdBy: uros_sipetic
sbg:createdOn: 1553086627
sbg:id: uros_sipetic/gatk-4-1-0-0-demo/gatk-haplotypecaller-4-1-0-0/7
sbg:image_url: null
sbg:latestRevision: 7
sbg:license: Open source BSD (3-clause) license
sbg:links:
- id: https://www.broadinstitute.org/gatk/index.php
  label: Homepage
- id: https://github.com/broadinstitute/gatk
  label: Source Code
- id: https://github.com/broadinstitute/gatk/releases/download/4.0.12.0/gatk-4.0.12.0.zip
  label: Download
- id: https://www.biorxiv.org/content/10.1101/201178v3
  label: Publication
- id: https://software.broadinstitute.org/gatk/documentation/tooldocs/current/org_broadinstitute_hellbender_tools_walkers_haplotypecaller_HaplotypeCaller.php
  label: Documentation
sbg:modifiedBy: nemanja.vucic
sbg:modifiedOn: 1559750439
sbg:project: uros_sipetic/gatk-4-1-0-0-demo
sbg:projectName: GATK 4.1.0.0 - Demo
sbg:publisher: sbg
sbg:revision: 7
sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/19
sbg:revisionsInfo:
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553086627
  sbg:revision: 0
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/4
- sbg:modifiedBy: uros_sipetic
  sbg:modifiedOn: 1553105347
  sbg:revision: 1
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/8
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554720901
  sbg:revision: 2
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/13
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554730721
  sbg:revision: 3
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/14
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1554999234
  sbg:revision: 4
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/15
- sbg:modifiedBy: nemanja.vucic
  sbg:modifiedOn: 1559736399
  sbg:revision: 5
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/17
- sbg:modifiedBy: veliborka_josipovic
  sbg:modifiedOn: 1559746054
  sbg:revision: 6
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/18
- sbg:modifiedBy: nemanja.vucic
  sbg:modifiedOn: 1559750439
  sbg:revision: 7
  sbg:revisionNotes: Copy of veliborka_josipovic/gatk-4-1-0-0-toolkit-dev/gatk-haplotypecaller-4-1-0-0/19
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:toolkit: GATK
sbg:toolkitVersion: 4.1.0.0
sbg:validationErrors: []
