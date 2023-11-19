# SexDetermineOar.R

## Overview
`SexDetermineOar.R` is an R script designed for the sex identification of modern/ancient sheep genomes. It utilizes the Rx metric, which measures coverage differences between autosomes and the X chromosome (Mittnik et al., 2016), with the optimization of thresholds specifically for sheep.
## Prerequisites
- R programming environment
- Samtools installed and accessible from your system's PATH

## Installation
No additional installation is required beyond R and Samtools.

## Compatibility
Reference Genomes: SexDetermineOar.R has been tested with the reference genomes Oar_v3.1 and Oar_v4.0. It is expected to be compatible with other reference genomes, unless the assemblies differ significantly. In that case, the thresholds may require further adjustments.

## Usage
This script processes genomic data in BAM or Samtools idxstats format to determine the sex of the sheep based on the Rx value.

### Command Line Arguments
- `InputFileType`: Specify the input file type (`-bam` for BAM files or `-idx` for samtools idxstats files).
- `Input_Location`: Provide the path to your input file.
- `ApplyQF`: Enter `1` to apply a quality filter if your BAM file hasn't been filtered. If your file is already filtered, omit this parameter.

### Running the Script
Run the script from the command line by passing the appropriate arguments. For example:
```bash
Rscript SexDetermineOar.R -bam /path/to/file.bam
```
Alternatively:
```bash
Rscript SexDetermineOar.R -idx /path/to/file.idxstats
```
Or, to include quality filter:
```bash
Rscript SexDetermineOar.R -bam /path/to/file.bam 1
```

## Output
The script outputs the following information:
- Sample name
- Total reads
- Number of reads on X-chromosome 
- Rx value
- Rx 95% confidence interval
- Inferred sex (XX, XY, XX?, XY?, or NA)

## Configuration
- `Samtools_Location`: Define the installation path of Samtools if it's not set in your system's PATH.
- `numthreads`: Specify the number of threads to utilize during the quality filter process.

## Limitations
This script is specifically for sheep samples and its accuracy depends on data coverage, reference genome quality, and potential contamination.

## Citation
Please cite this paper when using SexDetermineOar.R for your publications. (Atag et al., 2023) 
