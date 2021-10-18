#!/usr/bin/env bash

function usage() {
  if [ -n "$1" ]; then
    echo -e "Error: $1\n";
  fi
  echo "run picard CollectHsMetrics"
  echo "Usage: $0 [-i input] [-r reference] [-t target] [-b bait]"
  echo "  -i, --input        Input bam or cram file"
  echo "  -r, --reference    Reference fasta"
  echo "  -t, --target       Targets file [interval format]"
  echo "  -b, --bait         Baits file [interval format]"
  echo ""
  exit 1
}

# parse params
while [[ "$#" > 0 ]]; do case $1 in
  -i|--input) INPUT="$2"; shift;shift;;
  -r|--reference) REF="$2";shift;shift;;
  -t|--target) TARGET="$2";shift;shift;;
  -b|--bait) BAIT="$2";shift;shift;;
  *) usage "Unknown parameter passed: $1"; shift; shift;;
esac; done

# verify params
if [ -z "$INPUT" ]; then usage "Input file not provided"; fi;
if [ -z "$REF" ]; then usage "Reference file not provided."; fi;
if [ -z "$TARGET" ]; then usage "Targets file not provided."; fi;
if [ -z "$BAIT" ]; then usage "Baits file not provided."; fi;

# verify input files

if [ ! -f "$INPUT" ]; then usage "Input file $INPUT does not exist"; fi;
if [ ! -f "$REF" ]; then usage "Reference file $REF does not exist."; fi;
if [ ! -f "$REF.fai" ]; then usage "Index file $REF.fai does not exist."; fi;
if [ ! -f "$TARGET" ]; then usage "Targets file $TARGET does not exist."; fi;
if [ ! -f "$BAIT" ]; then usage "Baits file $BAIT does not exist."; fi;

# run picard
outfile=$(basename -s .cram $(basename -s .bam $INPUT)).hs_metrics.txt
java -jar /picard.jar CollectHsMetrics --VALIDATION_STRINGENCY LENIENT --INPUT $INPUT --REFERENCE_SEQUENCE $REF --TARGET_INTERVALS $TARGET --BAIT_INTERVALS $BAIT --OUTPUT $outfile 

# make json report
echo "{
  \"tool\": {
    \"name\": \"Picard:CollectHsMetrics\",
    \"version\": \"$(java -jar /picard.jar CollectHsMetrics --version 2>&1 | sed 's/Version.//')\"
  },
  \"metrics\": {" > hs_metrics.json

# fetch hs_metrics stats within the output file (grep -A1 header & 1 row), transpose (awk), omit entries that are usually empty, or contain the bait name (grep -w -v), and covert to json format (sed -E), and convert the trailing comma from the last line into closing curly brackets (sed):
grep -A1 "^BAIT_SET" $outfile | awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str"\t"a[i,j];
        }
        print str
    }
}' | grep -w -v -e BAIT_SET -e SAMPLE -e LIBRARY -e READ_GROUP | sed -E 's/(.+)\t(.+)/    "\1": \2,/g' | sed '$ s/,$/\n  }\n}/' >> hs_metrics.json


# make tar_content.json
echo "{
  \"hs_metrics\": \"hs_metrics.json\",
  \"original_output\": \"$outfile\"
}" > tar_content.json

# tar the results
tar -czf $(basename -s .txt $outfile).tgz hs_metrics.json $outfile tar_content.json
