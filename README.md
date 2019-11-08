### Description

This workflow represents the GATK Best Practices for SNP and INDEL calling on DNA data.

Starting from a processed **BAM** file, the workflow performs variant calling with respect to the reference genome. Depending on **HaplotypeCaller's** output file type (**VCF** or **g.VCF**, the resulting file of this workflow can be used as a stand alone result for single-sample analysis, or as one of the cohort files downstream joint calling analysis. On the GATK website you can find more detailed information about calling germline variants for single sample or joint calling analysis [1].

### Common Use Cases

* The **haplotypecaller-gvcf-gatk4** (original WDL name) workflow [1] runs the **HaplotypeCaller** tool from GATK4 in GVCF mode on a single sample according to GATK Best Practices. 
* To run HaplotypeCaller in a mode appropriate for joint calling analysis, one needs to set (`--emit_ref_confidence`) parameter to GVCF. 
* When executed, the workflow scatters the **HaplotypeCaller** tool over the **Calling intervals** file (`--in_intervals`). 
* The resulting g.VCF files are merged with **GATK MergeVCF**. 
* The output file produced will be a single g.VCF file which can be further processed in joint-discovery workflow. 
* By default, the output file is compressed with gzip, leading to a G.VCF.GZ extension.

* This workflow can also be used for single sample analysis. For that purpose, it produces a VCF file which is obtained by setting (the `--emit_ref_confidence`) parameter to NONE. 


### Changes Introduced by Seven Bridges

* The original **Generic germline variant per-sample calling** WDL implementation has a step called **CramToBamTask** which accepts CRAM files and converts them to BAM files with **samtools view**, while also indexing them. In this CWL implementation, this step is skipped as **GATK HaplotypeCaller** has the option to work with CRAM files. Keep in mind that CRAM files need to be indexed. 

* To enable scattering of **GATK Haplotypecallier** tool, we have introduced the **GATK IntervalListTool**, solution given in **GATK Production Germline short variant per-sample calling** [2]. 

### Common Issues and Important Notes

* The **HaplotypeCaller** app uses **Intervals list** to restrict processing to specific genomic intervals. You can set the **Scatter count** value in order to split **Intervals list** into smaller intervals. **HaplotypeCaller** processes these intervals in parallel, which can significantly reduce workflow execution time in some cases.

* The workflow accepts multiple flowcell BAMs on input, however, they must all share the same sample ID. Otherwise, some GATK tools will fail.

* Running a **batch task**: Batching is performed by **Sample ID** metadata field on the **Aligned and Processed BAM** input port. For running analyses in batches, it is necessary to set **Sample ID** metadata for each **Processed and aligned BAM** file.

### Performance Benchmarking
                   
|  BAM Input size | Experiment type | Coverage | Duration | Cost | Instance |
|-----------------------|-----------------       |------------   |-------------|--------|--------------|
| 55.8GiB              |  WGS           (scatter count = 20)     | ~50x            |  17h 35min   | $9.42           | c4.2xlarge |
| 55.8GiB              |  WGS           (scatter count = 80)     | ~50x            |  10h 32min   | $5.64           | c4.2xlarge |
| 24.6GiB              |  WGS           (scatter count = 80)     | ~10x            |  4h 12min     | $2.25           | c4.2xlarge |
| 3.5GiB                |  WES            (scatter count = 1)    | ~70x             |  17min          | $0.16           | c4.2xlarge |
| 1.9GiB                |  WES            (scatter count = 1)    | ~40x             |  11min          | $0.11           | c4.2xlarge | 
| 1.1GiB                |  WES            (scatter count = 1)    | ~20x             |  9min            | $0.08           | c4.2xlarge | 
| 434MiB               |  WES            (scatter count = 1)    | ~10x             |  6min            | $0.06           | c4.2xlarge | 



### API Python Implementation
The app's draft task can also be submitted via the **API**. In order to learn how to get your **Authentication token** and **API endpoint** for corresponding platform visit our [documentation](https://github.com/sbg/sevenbridges-python#authentication-and-configuration).

```python
# Initialize the SBG Python API
from sevenbridges import Api
api = Api(token="enter_your_token", url="enter_api_endpoint")
project_id = "your_username/project"
app_id = "your_username/project/app"
# Replace inputs with appropriate values
inputs = {
        "in_reference": api.files.query(project=project_id, names=["Homo_sapiens_assembly38.fasta"])[0], 
	"in_alignments": list(api.files.query(project=project_id, names=["HCC1143BL_WES_1.processed.bam"])), 
	"in_intervals": list(api.files.query(project=project_id, names=["wgs_calling_regions.hg38.interval_list"]))}

# Creates draft task
task = api.tasks.create(name="GATK Best Practice Germline snps and indels 4.1.0.0 - API Run", project=project_id, app=app_id, inputs=inputs, run=False)
```

Instructions for installing and configuring the API Python client, are provided on [github](https://github.com/sbg/sevenbridges-python#installation). For more information about using the API Python client, consult [the client documentation](http://sevenbridges-python.readthedocs.io/en/latest/). **More examples** are available [here](https://github.com/sbg/okAPI).

Additionally, [API R](https://github.com/sbg/sevenbridges-r) and [API Java](https://github.com/sbg/sevenbridges-java) clients are available. To learn more about using these API clients please refer to the [API R client documentation](https://sbg.github.io/sevenbridges-r/), and [API Java client documentation](https://docs.sevenbridges.com/docs/java-library-quickstart).

### References.

[1] [Broad germline SNPS and INDELS](https://github.com/gatk-workflows/gatk4-germline-snps-indels)

[2] [Broad Producion WGS germline SNPs and INDELs](https://github.com/gatk-workflows/broad-prod-wgs-germline-snps-indels)# Broad-Best-Practice-Germline-snps-and-indels-variant-calling-CWL1.0-workflow-GATK-4.1.0.0
