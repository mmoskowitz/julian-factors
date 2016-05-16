# http://downloads.dbpedia.org/2015-10/core-i18n/en/persondata_en.tql.bz2, grep birthDate
# http://pantheon.media.mit.edu/pantheon.tsv
./convert_dates.pl source_data/infobox_full_birthdates_en.tql > source_data/dates.tsv
./trim_dates.pl source_data/pantheon.tsv source_data/dates.tsv > source_data/dates_trimmed.tsv
for i in 0 1 2 3 4 5 6 7 8 9; do for j in 0 1 2 3 4 5 6 7 8 9; do mkdir output-data/$i$j; done; done
./split_dates_to_factors.pl source_data/dates_trimmed.tsv output-data/
