---
layout: default
title: LongTermStorageaDNA
---

# LongTermStorageaDNA Pipeline (ongoing Project) 🔬

LongTermstoragePipeline is a pipeline that I am currently developing with the aim to create, 
from the scripts I developed to analyse the data from my master's thesis into a reproducible (and easy to use) pipeline.

This Pipeline will enable the user (once it is finalised) to analyse following characteristics of aDNA samples:
Preprocessing of samples with aDNAPrePro: finished v1.1 (programs: Cutadapt, SAMtools, bwa), 
authentication and deamination rates (program: MapDamage), contamination kinship analysis (program: TKGWV2),
Read length calculation (program: Amber ).

A bioinformatics pipeline for the analysis of ancient DNA (aDNA) samples.

This pipeline contains a set of scripts and customized code, 
which were originally developed for the analysis of ancient human genomic data generated for the project:
"The effect of long-term storage on ancient DNA samples" (Master's thesis).


**Thesis available here: https://utheses.univie.ac.at/detail/74668**

**As of now (March 2026) I have finished the first module (aDNAPrePro).**

# aDNAPrePro (first finished and available module):

The first part of the pipeline, aDNAPrePro (v1.1), is now available. The pipeline aDNAPrePro (V1.1) preprocesses aDNA samples.

## Installation

Instructions on Installation are available on the README at the GitHub project website:

`https://github.com/raimo-al/LongTermStorageaDNA`

# Citation:

**Please cite https://utheses.univie.ac.at/detail/74668 if you use this pipeline.**

LongTermStorageaDNA-Scripts is available under the terms of the MIT license.

The computational results of this work have been achieved using the University of Vienna`s Life Science Compute Cluster (LiSC).

# Additional references include:

Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet. journal, 17(1), 10-12.

bwa Li, H., & Durbin, R. (2009). Fast and accurate short read alignment with Burrows-Wheeler transform. Bioinformatics , 25(14), 1754–1760. https://doi.org/10.1093/bioinformatics/btp324. Download: http://bio-bwa.sourceforge.net/bwa.shtml

SAMtools Li, H., Handsaker, B., Wysoker, A., Fennell, T., Ruan, J., Homer, N., … 1000 Genome Project Data Processing Subgroup. (2009). The Sequence Alignment/Map format and SAMtools. Bioinformatics , 25(16), 2078–2079. https://doi.org/10.1093/bioinformatics/btp352. Download: http://www.htslib.org/

Fernandes, DM, Cheronet, O, Gelabert, P, Pinhasi, R. TKGWV2: an ancient DNA relatedness pipeline for ultra-low coverage whole genome shotgun data. Sci Rep 11, 21262 (2021). https://doi.org/10.1038/s41598-021-00581-3

Dolenz, S., van der Valk, T., Jin, C., Oppenheimer, J., Sharif, M. B., Orlando, L., ... & Heintzman, P. D. (2024). Unravelling reference bias in ancient DNA datasets. Bioinformatics, 40(7), btae436.

Ginolhac, A., Rasmussen, M., Gilbert, M. T. P., Willerslev, E., & Orlando, L. (2011). mapDamage: testing for damage patterns in ancient DNA sequences. Bioinformatics, 27(15), 2153-2155.

Briggs, A. W., Stenzel, U., Johnson, P. L., Green, R. E., Kelso, J., Prüfer, K., ... & Pääbo, S. (2007). Patterns of damage in genomic DNA sequences from a Neandertal. Proceedings of the National Academy of Sciences, 104(37), 14616-14621.

## Contact:
If you have any question about my research or the project please feel free to contact me at:
alexandra.raimo@protonmail.com
or
alexandra.raimo@univie.ac.at .