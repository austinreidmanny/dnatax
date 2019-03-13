#!/bin/bash

#!/bin/bash

################################################################################
# This script will read in the results from DIAMOND and translate the NCBI
# taxon ID into a meaningful taxonomic lineage (domain; kingdom; phylum; ...etc)
#
# The output format is tab delimited text file with the following fields:
# CONTIG-NAME EVALUE SUPERKINGOM KINGDOM PHYLUM CLASS ORDER FAMILY GENUS SPECIES
################################################################################

################################################################################
# Error checking
################################################################################
# If any step fails, the script will stop to prevent propogating errors
set -euo pipefail

# Check to make sure project and sample names are provided
if [[ -z "${PROJECT}" ]] || [[ -z "${SAMPLES}" ]] ;
  then echo "ERROR: Missing Project and/or Sample names." >&2
  exit 1
fi

# Check to make sure there is a DIAMOND results file to read from
if [[ ! -f analysis/diamond/${SAMPLES}.nr.diamond.txt ]] ;
  then echo -e "ERROR: No DIAMOND results file found. \nExiting..." >&2
  exit 5
fi
################################################################################

################################################################################
# Taxonomy log info
################################################################################
echo "Beginning taxonomy conversion:" >> analysis/timelogs/${SAMPLES}.log
date >> analysis/timelogs/${SAMPLES}.log
################################################################################

################################################################################
# Convert taxon IDs to full taxonomy strings
################################################################################
cd analysis/diamond/
../../scripts/diamondToTaxonomy.py ${SAMPLES}.nr.diamond.txt
mv ${SAMPLES}.nr.diamond.taxonomy.txt ../taxonomy/
cd ../../
################################################################################

################################################################################
# Viral sequences log info
################################################################################
echo "Beginning taxonomy conversion:" >> analysis/timelogs/${SAMPLES}.log
date >> analysis/timelogs/${SAMPLES}.log
################################################################################

################################################################################
# Extract viral sequences and save them to a new file
################################################################################
# Save the virus-specific taxonomy results
grep Viruses analysis/taxonomy/${SAMPLES}.nr.diamond.taxonomy.txt > \
analysis/viruses/${SAMPLES}.viruses.taxonomy.txt

# Retrieve the viral sequences and save them in a FASTA file
grep Viruses analysis/taxonomy/${SAMPLES}.nr.diamond.taxonomy.txt | \
cut -f 1 | \
seqtk subseq data/contigs/${SAMPLES}.contigs.fasta - > \
analysis/viruses/${SAMPLES}.viruses.fasta
################################################################################

################################################################################
# Print number of viral sequences
################################################################################
echo "Number of viral contigs in ${SAMPLES}:"
grep "^>" analysis/viruses/${SAMPLES}.viruses.fasta | \
wc -l
################################################################################
