PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

DELETE {
  ?term <http://www.geneontology.org/formats/oboInOwl#hasAlternativeId> ?replacement .
}
INSERT {
  ?term <http://www.geneontology.org/formats/oboInOwl#hasAlternativeId> ?replacement_acc .
}
WHERE {
  ?term <http://www.geneontology.org/formats/oboInOwl#hasAlternativeId> ?replacement .
  FILTER(isIRI(?term))
  BIND(
    IF(	
      regex(str(?replacement), "http[:][/][/]www[.]ebi[.]ac[.]uk[/]efo[/]EFO[_]")
      || regex(str(?replacement), "http[:][/][/]purl[.]obolibrary[.]org[/]obo[/]")
      || regex(str(?replacement), "http[:][/][/]www[.]orpha.net[/]ORDO[/]"),
      REPLACE(
      REPLACE(STR(?replacement), "http[:][/][/]purl[.]obolibrary[.]org[/]obo[/]|http[:][/][/]www[.]ebi[.]ac[.]uk[/]efo[/]|http[:][/][/]www[.]orpha.net[/]ORDO[/]", "", "i"),
      "[_]", ":", "i")
      ,?replacement) 
    AS ?replacement_acc)
}