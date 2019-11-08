dct:creator:
  "@id": "sbg"
  foaf:name: SevenBridges
  foaf:mbox: "mailto:support@sbgenomics.com"
$namespaces:
  sbg: https://sevenbridges.com
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
class: Workflow
cwlVersion: v1.0
doc: "This workflow represents the GATK Best Practices for SNP and INDEL calling on\
  \ DNA data.\n\nStarting from a processed **BAM** file, the workflow performs variant\
  \ calling with respect to the reference genome. Depending on **HaplotypeCaller's**\
  \ output file type (**VCF** or **g.VCF**, the resulting file of this workflow can\
  \ be used as a stand alone result for single-sample analysis, or as one of the cohort\
  \ files downstream joint calling analysis. On the GATK website you can find more\
  \ detailed information about calling germline variants for single sample or joint\
  \ calling analysis [1].\n\n### Common Use Cases\n\n* The **haplotypecaller-gvcf-gatk4**\
  \ (original WDL name) workflow [1] runs the **HaplotypeCaller** tool from GATK4\
  \ in GVCF mode on a single sample according to GATK Best Practices. \n* To run HaplotypeCaller\
  \ in a mode appropriate for joint calling analysis, one needs to set (`--emit_ref_confidence`)\
  \ parameter to GVCF. \n* When executed, the workflow scatters the **HaplotypeCaller**\
  \ tool over the **Calling intervals** file (`--in_intervals`). \n* The resulting\
  \ g.VCF files are merged with **GATK MergeVCF**. \n* The output file produced will\
  \ be a single g.VCF file which can be further processed in joint-discovery workflow.\
  \ \n* By default, the output file is compressed with gzip, leading to a G.VCF.GZ\
  \ extension.\n\n* This workflow can also be used for single sample analysis. For\
  \ that purpose, it produces a VCF file which is obtained by setting (the `--emit_ref_confidence`)\
  \ parameter to NONE. \n\n\n### Changes Introduced by Seven Bridges\n\n* The original\
  \ **Generic germline variant per-sample calling** WDL implementation has a step\
  \ called **CramToBamTask** which accepts CRAM files and converts them to BAM files\
  \ with **samtools view**, while also indexing them. In this CWL implementation,\
  \ this step is skipped as **GATK HaplotypeCaller** has the option to work with CRAM\
  \ files. Keep in mind that CRAM files need to be indexed. \n\n* To enable scattering\
  \ of **GATK Haplotypecallier** tool, we have introduced the **GATK IntervalListTool**,\
  \ solution given in **GATK Production Germline short variant per-sample calling**\
  \ [2]. \n\n### Common Issues and Important Notes\n\n* The **HaplotypeCaller** app\
  \ uses **Intervals list** to restrict processing to specific genomic intervals.\
  \ You can set the **Scatter count** value in order to split **Intervals list** into\
  \ smaller intervals. **HaplotypeCaller** processes these intervals in parallel,\
  \ which can significantly reduce workflow execution time in some cases.\n\n* The\
  \ workflow accepts multiple flowcell BAMs on input, however, they must all share\
  \ the same sample ID. Otherwise, some GATK tools will fail.\n\n* Running a **batch\
  \ task**: Batching is performed by **Sample ID** metadata field on the **Aligned\
  \ and Processed BAM** input port. For running analyses in batches, it is necessary\
  \ to set **Sample ID** metadata for each **Processed and aligned BAM** file.\n\n\
  ### Performance Benchmarking\n                   \n|  BAM Input size | Experiment\
  \ type | Coverage | Duration | Cost | Instance |\n|-----------------------|-----------------\
  \       |------------   |-------------|--------|--------------|\n| 55.8GiB     \
  \         |  WGS           (scatter count = 20)     | ~50x            |  17h 35min\
  \   | $9.42           | c4.2xlarge |\n| 55.8GiB              |  WGS           (scatter\
  \ count = 80)     | ~50x            |  10h 32min   | $5.64           | c4.2xlarge\
  \ |\n| 24.6GiB              |  WGS           (scatter count = 80)     | ~10x   \
  \         |  4h 12min     | $2.25           | c4.2xlarge |\n| 3.5GiB           \
  \     |  WES            (scatter count = 1)    | ~70x             |  17min     \
  \     | $0.16           | c4.2xlarge |\n| 1.9GiB                |  WES         \
  \   (scatter count = 1)    | ~40x             |  11min          | $0.11        \
  \   | c4.2xlarge | \n| 1.1GiB                |  WES            (scatter count =\
  \ 1)    | ~20x             |  9min            | $0.08           | c4.2xlarge | \n\
  | 434MiB               |  WES            (scatter count = 1)    | ~10x         \
  \    |  6min            | $0.06           | c4.2xlarge | \n\n\n\n### API Python\
  \ Implementation\nThe app's draft task can also be submitted via the **API**. In\
  \ order to learn how to get your **Authentication token** and **API endpoint** for\
  \ corresponding platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).\n\
  \n```python\n# Initialize the SBG Python API\nfrom sevenbridges import Api\napi\
  \ = Api(token=\"enter_your_token\", url=\"enter_api_endpoint\")\nproject_id = \"\
  your_username/project\"\napp_id = \"your_username/project/app\"\n# Replace inputs\
  \ with appropriate values\ninputs = {\n        \"in_reference\": api.files.query(project=project_id,\
  \ names=[\"Homo_sapiens_assembly38.fasta\"])[0], \n\t\"in_alignments\": list(api.files.query(project=project_id,\
  \ names=[\"HCC1143BL_WES_1.processed.bam\"])), \n\t\"in_intervals\": list(api.files.query(project=project_id,\
  \ names=[\"wgs_calling_regions.hg38.interval_list\"]))}\n\n# Creates draft task\n\
  task = api.tasks.create(name=\"GATK Best Practice Germline snps and indels 4.1.0.0\
  \ - API Run\", project=project_id, app=app_id, inputs=inputs, run=False)\n```\n\n\
  Instructions for installing and configuring the API Python client, are provided\
  \ on [github](https://github.com/sbg/sevenbridges-python#installation). For more\
  \ information about using the API Python client, consult [the client documentation](http://sevenbridges-python.readthedocs.io/en/latest/).\
  \ **More examples** are available [here](https://github.com/sbg/okAPI).\n\nAdditionally,\
  \ [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java)\
  \ clients are available. To learn more about using these API clients please refer\
  \ to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and\
  \ [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).\n\
  \n### References\n\n[1] [Broad germline SNPS and INDELS](https://github.com/gatk-workflows/gatk4-germline-snps-indels)\n\
  \n[2] [Broad Producion WGS germline SNPs and INDELs](https://github.com/gatk-workflows/broad-prod-wgs-germline-snps-indels)"
id: nens/gatk-best-practice-generic-germline-short-variant-per-sample-calling-4-1-0-0-demo/gatk-best-practice-generic-germline-short-variant-per-sample-cal/6
inputs:
- doc: Reference FASTA file.
  id: in_reference
  label: Reference
  sbg:fileTypes: FASTA, FA
  sbg:x: -566.26904296875
  sbg:y: -155.61929321289062
  secondaryFiles:
  - .fai
  - ^.dict
  type: File
- doc: Aligned and processed BAM that has to match reference file provided on the
    *Reference* input.
  id: in_alignments
  label: Aligned and Processed BAM
  sbg:fileTypes: BAM, SAM, CRAM
  sbg:x: -553.3858032226562
  sbg:y: 29.294416427612305
  secondaryFiles:
  - ^.bai
  type: File[]
- doc: Fraction of contamination to aggressively remove.
  id: contamination_fraction_to_filter
  label: Fraction of contamination
  sbg:exposed: true
  type: float?
- doc: Mode for emitting reference confidence scores.
  id: emit_ref_confidence
  label: Emitting reference confidence scores
  sbg:exposed: true
  type:
  - 'null'
  - name: emit_ref_confidence
    symbols:
    - NONE
    - BP_RESOLUTION
    - GVCF
    type: enum
- doc: File format of the resulting VCF file.
  id: output_file_format
  label: File format
  sbg:exposed: true
  type:
  - 'null'
  - name: output_file_format
    symbols:
    - vcf
    - bcf
    - vcf.gz
    type: enum
- doc: Which type of calls we should output.
  id: output_mode
  label: Output mode
  sbg:exposed: true
  type:
  - 'null'
  - name: output_mode
    symbols:
    - EMIT_VARIANTS_ONLY
    - EMIT_ALL_CONFIDENT_SITES
    - EMIT_ALL_SITES
    type: enum
- doc: Extension of the HaplotypeCaller's resulting VCF file - gzipped or not.
  id: output_extension
  label: HaplotypeCaller's resulting VCF file extension
  sbg:exposed: true
  type:
  - 'null'
  - name: output_extension
    symbols:
    - vcf
    - vcf.gz
    type: enum
- doc: File with intervals that should be considered for variant calling. This file
    can be obtained from BED file using GATK BedToIntervalList.
  id: in_intervals
  label: Calling intervals
  sbg:fileTypes: VCF, INTERVAL_LIST
  sbg:x: -743
  sbg:y: -345
  type: File[]
- doc: Interval list naming - unique or not
  id: unique
  label: Interval list naming options
  sbg:exposed: true
  type: boolean?
- doc: Mode for scattering of the interval-list.
  id: subdivision_mode
  label: Scattering mode
  sbg:exposed: true
  type:
  - 'null'
  - name: subdivision_mode
    symbols:
    - INTERVAL_SUBDIVISION
    - BALANCING_WITHOUT_INTERVAL_SUBDIVISION
    - BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW
    - INTERVAL_COUNT
    type: enum
- doc: Sort the resulting interval list by coordinate.
  id: sort
  label: Sort interval list by coordinate
  sbg:exposed: true
  type: boolean?
- doc: The number of files into which to scatter the resulting list by locus.
  id: scatter_count
  label: Scatter count
  sbg:exposed: true
  type: int?
- doc: Create a new interval list with the original intervals broken up at integer
    multiples of this value.
  id: break_bands_at_multiples_of
  label: Redefine scatter intervals
  sbg:exposed: true
  type: int?
- doc: CPU per job.
  id: cpu_per_job
  label: CPU per job
  sbg:exposed: true
  type: int?
- doc: Memory per job.
  id: mem_per_job
  label: Memory per job
  sbg:exposed: true
  type: int?
label: Broad Best Practice Germline snps and indels variant calling 4.1.0.0
outputs:
- doc: Merged VCF file.
  id: out_variants
  label: VCF file
  outputSource:
  - gatk_mergevcfs_4_1_0_0/out_variants
  sbg:fileTypes: VCF, VCF.GZ, BCF
  sbg:x: 17
  sbg:y: -190
  type: File?
requirements:
- class: StepInputExpressionRequirement
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
sbg:appVersion:
- v1.0
sbg:categories:
- Genomics
- Variant Calling
sbg:content_hash: a5b1fadf1920aae9697b44426ded316b073abd70545438658ba98bf40eeb95582
sbg:contributors:
- nens
sbg:createdBy: nens
sbg:createdOn: 1565797611
sbg:id: nens/gatk-best-practice-generic-germline-short-variant-per-sample-calling-4-1-0-0-demo/gatk-best-practice-generic-germline-short-variant-per-sample-cal/6
sbg:image_url: https://igor.sbgenomics.com/ns/brood/images/nens/gatk-best-practice-generic-germline-short-variant-per-sample-calling-4-1-0-0-demo/gatk-best-practice-generic-germline-short-variant-per-sample-cal/6.png
sbg:latestRevision: 6
sbg:license: BSD 3-Clause License
sbg:links:
- id: https://github.com/gatk-workflows/gatk4-germline-snps-indels
  label: Homepage
- id: https://github.com/gatk-workflows/gatk4-germline-snps-indels/blob/master/haplotypecaller-gvcf-gatk4.wdl
  label: Source Code
- id: https://github.com/broadinstitute/gatk/releases/download/4.1.0.0/gatk-4.1.0.0.zip
  label: Download
- id: https://www.ncbi.nlm.nih.gov/pubmed?term=20644199
  label: Publication
- id: https://software.broadinstitute.org/gatk/documentation/tooldocs/current/
  label: Documentation
sbg:modifiedBy: nens
sbg:modifiedOn: 1573052212
sbg:project: nens/gatk-best-practice-generic-germline-short-variant-per-sample-calling-4-1-0-0-demo
sbg:projectName: GATK Best Practice Generic germline short variant per-sample calling
  4.1.0.0 - DEMO
sbg:publisher: sbg
sbg:revision: 6
sbg:revisionNotes: dev v36 - with requirements for cwltool
sbg:revisionsInfo:
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1565797611
  sbg:revision: 0
  sbg:revisionNotes: null
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1565797659
  sbg:revision: 1
  sbg:revisionNotes: v25 dev
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1568624787
  sbg:revision: 2
  sbg:revisionNotes: v32 - dev
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1570714260
  sbg:revision: 3
  sbg:revisionNotes: secondary files added
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1570806429
  sbg:revision: 4
  sbg:revisionNotes: Description update
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1570807662
  sbg:revision: 5
  sbg:revisionNotes: Description improved - performance benchmarking results addd
- sbg:modifiedBy: nens
  sbg:modifiedOn: 1573052212
  sbg:revision: 6
  sbg:revisionNotes: dev v36 - with requirements for cwltool
sbg:sbgMaintained: false
sbg:toolAuthor: Broad Institute
sbg:validationErrors: []
sbg:wrapperAuthor: nevena.ilic.raicevic@sbgenomics.com
steps:
  gatk_haplotypecaller_4_1_0_0:
    in:
    - id: contamination_fraction_to_filter
      source: contamination_fraction_to_filter
    - id: emit_ref_confidence
      source: emit_ref_confidence
    - id: in_alignments
      source:
      - in_alignments
    - id: include_intervals
      source: gatk_intervallisttools_4_1_0_0/output_interval_list
    - id: mem_per_job
      source: mem_per_job
    - id: output_mode
      source: output_mode
    - id: in_reference
      source: in_reference
    - id: cpu_per_job
      source: cpu_per_job
    - id: output_extension
      source: output_extension
    label: GATK HaplotypeCaller
    out:
    - id: out_variants
    - id: out_alignments
    - id: out_graph
    run: steps/gatk_haplotypecaller_4_1_0_0.cwl
    sbg:x: -349
    sbg:y: -162
    scatter:
    - include_intervals
    scatterMethod: dotproduct
  gatk_intervallisttools_4_1_0_0:
    in:
    - id: break_bands_at_multiples_of
      source: break_bands_at_multiples_of
    - id: in_intervals
      source:
      - in_intervals
    - id: scatter_count
      source: scatter_count
    - id: sort
      source: sort
    - id: subdivision_mode
      source: subdivision_mode
    - default: false
      id: unique
      source: unique
    label: GATK IntervalListTools
    out:
    - id: output_interval_list
    run: steps/gatk_intervallisttools_4_1_0_0.cwl
    sbg:x: -584
    sbg:y: -342
  gatk_mergevcfs_4_1_0_0:
    in:
    - id: in_variants
      source:
      - gatk_haplotypecaller_4_1_0_0/out_variants
    - id: output_file_format
      source: output_file_format
    label: GATK MergeVcfs
    out:
    - id: out_variants
    run: steps/gatk_mergevcfs_4_1_0_0.cwl
    sbg:x: -156
    sbg:y: -192
