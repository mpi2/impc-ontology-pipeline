PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

DELETE {
  ?term <http://www.geneontology.org/formats/oboInOwl#id> ?curie .
}
INSERT {
  ?term <http://www.geneontology.org/formats/oboInOwl#id> ?replacement_acc .
}
WHERE {
  ?term a owl:Class .
  FILTER(isIRI(?term) && (regex(str(?term), "http[:][/][/]www[.]ebi[.]ac[.]uk[/]efo[/]EFO[_]") || regex(str(?term), "http[:][/][/]purl[.]obolibrary[.]org[/]obo[/]") || regex(str(?term), "http[:][/][/]www[.]orpha.net[/]ORDO[/]")))
  BIND(
    REPLACE(REPLACE(STR(?term), "http[:][/][/]purl[.]obolibrary[.]org[/]obo[/]|http[:][/][/]www[.]ebi[.]ac[.]uk[/]efo[/]|http[:][/][/]www[.]orpha.net[/]ORDO[/]", "", "i"),"[_]", ":", "i") AS ?replacement_acc)
}