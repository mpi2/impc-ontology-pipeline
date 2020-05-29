# This Makefile encodes the entirety of IMPCs ontology dependencies

OBO=http://purl.obolibrary.org/obo
ROBOT=robot
SIMPLEOBO=mp
ONTOLOGIES=mp mp-ext-merged ma emapa uberon eco efo emap mp-hp mmusdv mpath pato uberon-ma mp-relation-augmented
TABLES=mp ma emapa uberon eco efo emap mmusdv mpath pato mp-relation-augmented
ONTOLOGY_FILES = $(patsubst %, ontologies/%.owl, $(ONTOLOGIES))
ONTOLOGY_SIMPLE_OBO_FILES = $(patsubst %, ontologies/%.obo, $(SIMPLEOBO))
TABLE_FILES = $(patsubst %, tables/%_metadata_table.csv, $(TABLES))
MIR=true
GIT_UPHENO=https://github.com/obophenotype/upheno.git
TODAY ?= $(shell date +%Y-%m-%d)

ontologies/%.owl:
	$(ROBOT) merge -I $(OBO)/$*.owl \
	query --update sparql/update_replacement_term_to_curie_syntax.ru \
	query --update sparql/update_consider_term_to_curie_syntax.ru \
	query --update sparql/update_alternate_id_to_curie_syntax.ru \
	query --update sparql/update_obo_ids.ru \
	annotate --ontology-iri $(OBO)/$*/$@ --version-iri $(OBO)/$*/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@

ontologies/%.obo: ontologies/%.owl
	wget $(OBO)/$*.obo -O $@

ontologies/efo.owl:
	$(ROBOT) merge -I http://www.ebi.ac.uk/efo/efo.owl \
	query --update sparql/update_replacement_term_to_curie_syntax.ru \
	query --update sparql/update_consider_term_to_curie_syntax.ru \
	query --update sparql/update_alternate_id_to_curie_syntax.ru \
	query --update sparql/update_obo_ids.ru \
	annotate --ontology-iri http://www.ebi.ac.uk/efo/efo.owl --output $@.tmp.owl && mv $@.tmp.owl $@
	
ontologies/efo2.owl:
	$(ROBOT) merge -I http://www.ebi.ac.uk/efo/efo.owl \
	annotate --ontology-iri http://www.ebi.ac.uk/efo/efo.owl --output $@.tmp.owl && mv $@.tmp.owl $@
	
check: ontologies/efo.owl ontologies/efo2.owl
	$(ROBOT) diff --left ontologies/efo2.owl --right ontologies/efo.owl -o $@.txt

ontologies/mp-ext-merged.owl:
	$(ROBOT) merge -I https://raw.githubusercontent.com/obophenotype/mammalian-phenotype-ontology/master/scratch/mp-ext-merged.owl -o $@

ontologies/uberon-ma.owl:
	$(ROBOT) merge -I http://purl.obolibrary.org/obo/uberon/bridge/uberon-bridge-to-ma.owl -o $@

ontologies/mp-relation-augmented.owl: ontologies/mp.owl ontologies/uberon-ma.owl scripts/role_chains.owl
	$(ROBOT) merge $(addprefix -i , $^) remove --axioms disjoint materialize --prefix "IMPC: http://mouse-phenotype.org/IMPC_" --reasoner ELK --term IMPC:0001 -o $@

.PRECIOUS: ontologies/*.owl

tmp/upheno:
	mkdir -p $@
	rm -rf $@
	mkdir -p $@
	git clone $(GIT_UPHENO) $@

tmp/upheno/mp-hp-view.owl: tmp/upheno
	cd  $< && make -B mp-hp-view.owl

ontologies/mp-hp.owl: tmp/upheno/mp-hp-view.owl
	cp $< $@

tables/%_metadata_table.csv: ontologies/%.owl
	$(ROBOT) query --use-graphs true -f csv -i $< --query sparql/$*_metadata_table.sparql $@

#######################################
#### Table for IMPC search index ######
# https://github.com/monarch-ebi-dev/impc-ontology-pipeline/issues/1

tables/mp_lexical.csv: ontologies/mp.owl
	$(ROBOT) query --use-graphs true -f csv -i $< --query sparql/mp_lexical.sparql $@
	
tables/hp_lexical.csv: ontologies/hp.owl
	$(ROBOT) query --use-graphs true -f csv -i $< --query sparql/hp_lexical.sparql $@
	
tables/mp_parentage.csv: ontologies/mp.owl
	$(ROBOT) query --use-graphs true -f csv -i $< --query sparql/mp_parentage.sparql $@

tables/mp_hp_matches.csv:
	wget http://purl.obolibrary.org/obo/upheno/mappings/mp-hp.csv -O $@

tables/impc_search_index.csv: tables/mp_lexical.csv tables/hp_lexical.csv tables/mp_parentage.csv tables/mp_hp_matches.csv
	python scripts/mp_search_indexing.py
	
tables/mp_parentage_top.csv: ontologies/mp.owl
	$(ROBOT) query --use-graphs true -f csv -i $< --query sparql/mp_parentage_top.sparql $@


dirs:
	mkdir -p tmp
	mkdir -p tables
	mkdir -p ontologies

clean: 
	rm -r tmp

impc_ontologies: dirs $(ONTOLOGY_FILES) $(ONTOLOGY_SIMPLE_OBO_FILES) $(TABLE_FILES) tables/impc_search_index.csv tables/mp_parentage_top.csv
	tar cvzf impc_ontologies.tar.gz $(ONTOLOGY_FILES) $(ONTOLOGY_SIMPLE_OBO_FILES) tables/*.csv