# Data Visualization

Process data is stored in Turtle-star (`.ttl`) format. You can visualize this data in several ways within these docs.

## Integrated Process Flows
Since the parser extracts Mermaid diagrams directly from the source Markdown, they are automatically rendered if you include the `.md` content or copy the blocks.

### Example: Phase 1 Flow
This diagram was extracted from the factory specification.

```{mermaid}
graph TD
    P1["Phase 1: Heat Treatment"] --> P2["Phase 2: Stretching"]
    P2 --> P3["Phase 3: Final"]
```

## Exploring Turtle-star Data
RDF-star adds reification to triples. Here is how a typical process entry looks in our exported data.

### Turtle Snippet
```turtle
@prefix ex: <http://westurner.github.io/sustainablefactory/process/#> .
@prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .

ex:Step_1 a iof:PlannedProcess ;
    rdfs:label "Heat Treatment" ;
    ex:temp "500C" .

# RDF-star metadata
<< ex:Step_1 ex:temp "500C" >> ex:confidence 0.8 ;
    ex:extractionSource "MyST-Parser-Regex" .
```

## Large Scale Visualization
For the full `full_export.ttl` (3,000+ nodes), we recommend:
1. **GraphDB / Neosemantics**: For interactive exploration.
2. **Gephi**: For network analysis.
3. **Pylode**: To generate a browseable HTML catalog of the exported entities.





















































## Schema: Local Process Ontology
Defined in `schema/sustainable-factory.ttl`.

```turtle
@prefix iof: <https://spec.industrialontologies.org/ontology/core/Core/> .
@prefix sf: <https://westurner.github.io/sustainablefactory/process/#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .

sf:SustainableProcessSchema a owl:Ontology ;
    rdfs:label "Sustainable Factory Process Schema" ;
    rdfs:comment "A schema for modeling sustainable production processes using IOF-aligned entities and RDF-star for metadata." .

# Classes
sf:Process a owl:Class ;
    rdfs:subClassOf iof:PlannedProcess ;
    rdfs:label "Process" .

sf:MaterialResource a owl:Class ;
    rdfs:subClassOf iof:MaterialResource ;
    rdfs:label "Material Resource" .

sf:Product a owl:Class ;
    rdfs:subClassOf iof:Product ;
    rdfs:label "Product" .

# Relationships
sf:participates_in a owl:ObjectProperty ;
    rdfs:subPropertyOf iof:participates_in_at_some_time ;
    rdfs:label "participates in" .

sf:is_output_of a owl:ObjectProperty ;
    rdfs:subPropertyOf iof:is_output_of ;
    rdfs:label "is output of" .

# Metadata Properties (to be used on triples)
sf:temperature a owl:DatatypeProperty ;
    rdfs:label "temperature" ;
    rdfs:range xsd:decimal .

sf:entryTime a owl:DatatypeProperty ;
    rdfs:label "entry time" ;
    rdfs:range xsd:dateTime .

sf:flowRate a owl:DatatypeProperty ;
    rdfs:label "flow rate" ;
    rdfs:range xsd:string .

sf:confidence a owl:DatatypeProperty ;
    rdfs:label "extraction confidence" ;
    rdfs:range xsd:decimal .

sf:extractionSource a owl:DatatypeProperty ;
    rdfs:label "extraction source" ;
    rdfs:range xsd:string .

```
## Schema: Industrial Ontologies Foundry (IOF) Core
Loaded from local path: `schema/iof-core/iof-core.ttl`

```turtle
@prefix bfo: <http://purl.obolibrary.org/obo/> .
@prefix dcterms: <http://purl.org/dc/terms/> .
@prefix iof-av: <https://spec.industrialontologies.org/ontology/annotation/> .
@prefix iof-constr: <https://spec.industrialontologies.org/ontology/construct/> .
@prefix iof-ind: <https://spec.industrialontologies.org/ontology/individual/> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

iof-constr:Customer a owl:Class ;
    rdfs:label "customer"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Agent ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( [ a owl:Class ;
                        owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:CustomerRole ] ) ] ;
    skos:example "GE aviation subsidiary and GE Transportation subsidiary when they utilize the steel bought for them by the GE Conglomerate; a person when they utilize a lap top that they bought from Target; a person when they subscribe for a phone plan"@en-US ;
    iof-av:explanatoryNote "See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience." ;
    iof-av:firstOrderLogicDefinition "Customer(x) ↔ (Person(x) ∨ Organization(x)) ∧ ∃r(CustomerRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "person or organization which has a customer role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'customer' is defined as exactly an instance of 'person' or 'organization' that 'has role' some 'customer role'" .

iof-constr:DescriptiveInformationContentEntity a owl:Class ;
    rdfs:label "descriptive information content entity"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                        owl:onProperty iof-constr:describes ;
                        owl:someValuesFrom bfo:BFO_0000001 ] ) ] ;
    skos:example "a description of a product in a product catalogue, the wheelbase of this car is 3m, digital copy of a Mona Lisa drawing"@en-US ;
    iof-av:abbreviation "descriptive ICE"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:explanatoryNote "This class is intended to be a defined class used for axiomatization and assertion convenience. It is not expected nor recommended that entities will be asserted as a subclass of this class."@en-US ;
    iof-av:firstOrderLogicDefinition "DescriptiveInformationContentEntity(x) ↔ InformationContentEntity(x) ∧ ∃e(Entity(e) ∧ describes(x,e))" ;
    iof-av:naturalLanguageDefinition "information content entity that characterizes (gives a description of) an entity"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'descriptive information content entity ' is defined as exactly an instance of 'information content entity' that 'describes' some 'entity'" .

iof-constr:DesignativeInformationContentEntity a owl:Class ;
    rdfs:label "designative information content entity"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                        owl:onProperty iof-constr:designates ;
                        owl:someValuesFrom bfo:BFO_0000001 ] ) ] ;
    skos:example "uri of a website, social security number of a person, lot number of a batch of products, a serial number on a machine, a credit card number, a combination of data in a database table uniquely identify each record in the table"@en-US ;
    iof-av:abbreviation "designative ICE"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:explanatoryNote """1. This class is intended to be a defined class used for axiomatization and assertion convenience. It is not expected nor recommended that entities will be asserted as a subclass of this class.

2. Since the relation 'designates' is defined as a functional property, uniqueness is enforced in the term's formalization.""" ;
    iof-av:firstOrderLogicDefinition "DesignativeInformationContentEntity(x) ↔ InformationContentEntity(x) ∧ ∃e(Entity(e) ∧ designates(x,e))" ;
    iof-av:naturalLanguageDefinition "information content entity that uniquely identifies an entity"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'designative information content entity' is defined as exactly an instance of 'information content entity' that 'designates' some 'entity'" .

iof-constr:Event a owl:Class ;
    rdfs:label "event"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:recognizedByAtSomeTime ;
            owl:someValuesFrom iof-constr:Agent ],
        [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000035 ) ],
        bfo:BFO_0000003 ;
    skos:example "a machine failure event, the amount of cells in a bioreactor reaches a certain threshold"@en-US ;
    iof-av:adaptedFrom "Oxford Languages, term by the same name" ;
    iof-av:counterExample "an event in discrete event simulation is too generic and that notion of event is just BFO:Occurrent" ;
    iof-av:firstOrderLogicAxiom "Event(x) → (Process(x) ∨ ProcessBoundary(x)) ∧ ∃y(Agent(y) ∧ recognizedByAtSomeTime(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "phenomena (process or process boundary) that is recognized by an agent and typically recorded"@en-US ;
    iof-av:primitiveRationale "More conditions (differentia) need to be agreed upon by the domain experts as not all occurrents recognized by an agent are events." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'event' then x is a 'process' or 'process boundary' and there is some 'agent' that 'recognizes at some time' x" .

iof-constr:GainOfRole a owl:Class ;
    rdfs:label "gain of role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000015 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000015 [ a owl:Class ;
                        owl:intersectionOf ( [ a owl:Restriction ;
                                    owl:onProperty bfo:BFO_0000199 ;
                                    owl:someValuesFrom [ a owl:Class ;
                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Class ;
                                                        owl:unionOf ( [ a owl:Restriction ;
                                                                    owl:onProperty iof-constr:meets ;
                                                                    owl:someValuesFrom [ a owl:Class ;
                                                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Restriction ;
                                                                                        owl:onProperty [ owl:inverseOf bfo:BFO_0000108 ] ;
                                                                                        owl:someValuesFrom bfo:BFO_0000023 ] ) ] ] [ a owl:Restriction ;
                                                                    owl:onProperty iof-constr:temporallyOverlaps ;
                                                                    owl:someValuesFrom [ a owl:Class ;
                                                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Restriction ;
                                                                                        owl:onProperty [ owl:inverseOf bfo:BFO_0000108 ] ;
                                                                                        owl:someValuesFrom bfo:BFO_0000023 ] ) ] ] [ a owl:Restriction ;
                                                                    owl:onProperty iof-constr:temporallyStarts ;
                                                                    owl:someValuesFrom [ a owl:Class ;
                                                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Restriction ;
                                                                                        owl:onProperty [ owl:inverseOf bfo:BFO_0000108 ] ;
                                                                                        owl:someValuesFrom bfo:BFO_0000023 ] ) ] ] ) ] ) ] ] [ a owl:Restriction ;
                                    owl:onProperty iof-constr:hasOutput ;
                                    owl:someValuesFrom bfo:BFO_0000023 ] ) ] [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000167 ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:intersectionOf ( bfo:BFO_0000004 [ a owl:Class ;
                                            owl:complementOf bfo:BFO_0000006 ] ) ] ] ) ] ;
    skos:example "the process of gaining an operator role when someone is assigned in that position" ;
    iof-av:adaptedFrom "CCO" ;
    iof-av:explanatoryNote "1. If only one date-time is available for some gain of role processes due to lack of data or an interval being smaller than the tick time (the smallest duration by which the time progresses) then the date-time should be asserted either only for first instant or only for last instant of every interval, for which a gain of role process occurs, uniformly for the entire knowledge base. For example, Barack Obama gained the role of presidency on 20 January 2009 should be modeled as the process p of type ‘gain of role’ ‘occupies temporal region’ r (a ‘temporal interval’) which ‘has last instant’ i (a ‘temporal instant’) which ‘has value expression at all times’ v (a ‘temporal instant value expression’) which ‘has data-time value’ 2009-01-20T00:00:00Z."@en-US ;
    iof-av:firstOrderLogicDefinition "GainOfRole(p) ↔ Process(p) ∧ ∃t∃t1∃r∃y(TemporalInterval(t) ∧ TemporalInterval(t1) ∧ Role(r)∧ (IndependentContinuant(y) ∧ ¬SpatialRegion(y)) ∧ occupiesTemporalRegion(p,t) ∧ (temporallyOverlaps(t,t1) ∨ temporallyStarts(t,t1) ∨ meets(t,t1)) ∧ hasOutput(p,r) ∧ existsAt(r,t1) ∧ hasRole(y,r) ∧ hasParticipantAtAllTimes(p,y) ∧ ∀t2(TemporalRegion(t2) ∧ existsAt(r,t2) → (occurrentPartOf(t2,t1) ∨ t2 = t1)))" ;
    iof-av:naturalLanguageDefinition "process in which someone or something (independent continuant that is not a spatial region) becomes the bearer of a role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of ‘gain of role’ is defined exactly as an instance of a ‘process’ p that 'occupies temporal region' some 'temporal interval' t that ‘temporally starts’ or ‘temporally overlaps’ or 'meets' some 'temporal interval' t1, and p ‘has participant at all times’ some 'independent continuant' that is not a 'spatial region' y and p ‘has output’ some ‘role’ r that only ‘exists at’ t1 and y 'has role' r" .

iof-constr:GroupOfPersons a owl:Class ;
    rdfs:label "group of persons"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000027 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000027 [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000115 ;
                        owl:someValuesFrom iof-constr:Person ] [ a owl:Restriction ;
                        owl:allValuesFrom iof-constr:Person ;
                        owl:onProperty bfo:BFO_0000115 ] ) ] ;
    skos:example "The band, called The Beatles, survived the change in drummer from Pete Best to Ringo Starr"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/AgentOntology"@en-US ;
    iof-av:firstOrderLogicDefinition "GroupOfPersons(x) ↔ ObjectAggregate(x) ∧ ∃y(Person(y) ∧ hasMemberPartAtSomeTime(x, y)) ∧ ∀z(hasMemberPartAtSomelTime(x, z) → Person(z))" ;
    iof-av:naturalLanguageDefinition "group (object aggregate) that has one or more persons as members"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'group of persons' is defined as exactly an instance of 'object aggregate' that 'has member part at some time' some 'person' and 'has member part at some time' only 'person'" .

iof-constr:LossOfRole a owl:Class ;
    rdfs:label "loss of role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000015 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000015 [ a owl:Class ;
                        owl:intersectionOf ( [ a owl:Restriction ;
                                    owl:onProperty bfo:BFO_0000199 ;
                                    owl:someValuesFrom [ a owl:Class ;
                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Class ;
                                                        owl:unionOf ( [ a owl:Restriction ;
                                                                    owl:onProperty iof-constr:isTemporallyOverlappedBy ;
                                                                    owl:someValuesFrom [ a owl:Class ;
                                                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Restriction ;
                                                                                        owl:onProperty [ owl:inverseOf bfo:BFO_0000108 ] ;
                                                                                        owl:someValuesFrom bfo:BFO_0000023 ] ) ] ] [ a owl:Restriction ;
                                                                    owl:onProperty iof-constr:metBy ;
                                                                    owl:someValuesFrom [ a owl:Class ;
                                                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Restriction ;
                                                                                        owl:onProperty [ owl:inverseOf bfo:BFO_0000108 ] ;
                                                                                        owl:someValuesFrom bfo:BFO_0000023 ] ) ] ] [ a owl:Restriction ;
                                                                    owl:onProperty iof-constr:temporallyFinishes ;
                                                                    owl:someValuesFrom [ a owl:Class ;
                                                                            owl:intersectionOf ( bfo:BFO_0000202 [ a owl:Restriction ;
                                                                                        owl:onProperty [ owl:inverseOf bfo:BFO_0000108 ] ;
                                                                                        owl:someValuesFrom bfo:BFO_0000023 ] ) ] ] ) ] ) ] ] [ a owl:Restriction ;
                                    owl:onProperty iof-constr:hasInput ;
                                    owl:someValuesFrom bfo:BFO_0000023 ] ) ] [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000167 ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:intersectionOf ( bfo:BFO_0000004 [ a owl:Class ;
                                            owl:complementOf bfo:BFO_0000006 ] ) ] ] ) ] ;
    skos:example "the process of losing a student role when a student graduates" ;
    iof-av:adaptedFrom "CCO" ;
    iof-av:explanatoryNote "1. If only one date-time is available for some loss of role processes due to lack of data or an interval being smaller than the tick time (the smallest duration by which the time progresses) then the date-time should be asserted either only for first instant or only for last instant of every interval, for which a loss of role process occurs, uniformly for the entire knowledge base. For example, Bill Clinton lost the role of presidency on 19 December 1998 should be modeled as the process p of type ‘loss of role’ ‘occupies temporal region’ r (a ‘temporal interval’) which ‘has first instant’ i (a ‘temporal instant’) which ‘has value expression at all times’ v (a ‘temporal instant value expression’) which ‘has data-time value’ 1998-12-19T00:00:00Z."@en-US ;
    iof-av:firstOrderLogicDefinition "LossOfRole(p) ↔ Process(p) ∧ ∃t∃t1∃r∃y(TemporalInterval(t) ∧ TemporalInterval(t1) ∧ Role(r) ∧ (IndependentContinuant(y) ∧ ¬SpatialRegion(y)) ∧ occupiesTemporalRegion(p,t) ∧ (isTemporallyOverlappedBy(t,t1) ∨ temporallyFinishes(t,t1) ∨ metBy(t,t1)) ∧ hasInput(p,r) ∧ existsAt(r,t1) ∧ hasRole(y,r) ∧ hasParticipantAtAllTimes(p,y) ∧ ∀t2(TemporalRegion(t2) ∧ existsAt(r,t2) → (occurrentPartOf(t2,t1) ∨ t2 = t1)))" ;
    iof-av:naturalLanguageDefinition "process in which someone or something (independent continuant that is not a spatial region) ceases to be the bearer of a role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of ‘loss of role’ is defined exactly as an instance of a ‘process’ p that 'occupies temporal region' some 'temporal interval' t that ‘temporally finishes’ or 'is temporally overlapped by’ or is 'met by' some 'temporal interval' t1 and p ‘has participant at all times’ some 'independent continuant' that is not a 'spatial region' y, and p ‘has input’ some ‘role’ r that only ‘exists at’ t1 and y 'has role' r" .

iof-constr:MaintainableMaterialItem a owl:Class ;
    rdfs:label "maintainable material item"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000040 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( [ a owl:Class ;
                        owl:unionOf ( iof-constr:EngineeredSystem iof-constr:MaterialArtifact ) ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:MaintainableMaterialItemRole ] ) ] ;
    skos:example "CNC machine on which routine maintenance is performed"@en-US ;
    iof-av:explanatoryNote "See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience." ;
    iof-av:firstOrderLogicDefinition "MaintainableMaterialItem(x) ↔ (MaterialArtifact(x) ∨ EngineeredSystem(x)) ∧ ∃r (MaintainableMaterialItemRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "material artifact or engineered system which has the maintainable material item role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'maintainable material item' is defined as exactly an instance of 'material artifact' or an 'engineered system' which 'has role' some 'maintainable material item role'" .

iof-constr:Manufacturer a owl:Class ;
    rdfs:label "manufacturer"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Agent ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:Organization [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:ManufacturerRole ] ) ] ;
    skos:example "MiliporeSigma is a manufacturer of single-use bioreactors; Boeing is a manufacturer of airplanes; dell is a manufacturer of lap-tops"@en-US ;
    iof-av:explanatoryNote "See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience." ;
    iof-av:firstOrderLogicDefinition "Manufacturer(x) ↔ Organization(x) ∧ ∃r(ManufacturerRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "organization which has a manufacturer role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'manufacturer' is defined as exactly an instance of 'organization' that 'has role' some 'manufacturer role'" .

iof-constr:MaterialLocationChangeProcess a owl:Class ;
    rdfs:label "material location change process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                                owl:onProperty [ owl:inverseOf bfo:BFO_0000170 ] ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:intersectionOf ( bfo:BFO_0000004 [ a owl:Restriction ;
                                                    owl:onProperty bfo:BFO_0000082 ;
                                                    owl:someValuesFrom bfo:BFO_0000029 ] [ a owl:Restriction ;
                                                    owl:onProperty bfo:BFO_0000108 ;
                                                    owl:someValuesFrom [ a owl:Class ;
                                                            owl:intersectionOf ( bfo:BFO_0000203 [ a owl:Class ;
                                                                        owl:intersectionOf ( [ a owl:Restriction ;
                                                                                    owl:onProperty bfo:BFO_0000221 ;
                                                                                    owl:someValuesFrom bfo:BFO_0000008 ] [ a owl:Restriction ;
                                                                                    owl:onProperty [ owl:inverseOf bfo:BFO_0000199 ] ;
                                                                                    owl:someValuesFrom iof-constr:PlannedProcess ] ) ] ) ] ] ) ] ] [ a owl:Restriction ;
                                owl:onProperty [ owl:inverseOf bfo:BFO_0000170 ] ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:intersectionOf ( bfo:BFO_0000004 [ a owl:Restriction ;
                                                    owl:onProperty bfo:BFO_0000082 ;
                                                    owl:someValuesFrom bfo:BFO_0000029 ] [ a owl:Restriction ;
                                                    owl:onProperty bfo:BFO_0000108 ;
                                                    owl:someValuesFrom [ a owl:Class ;
                                                            owl:intersectionOf ( bfo:BFO_0000203 [ a owl:Restriction ;
                                                                        owl:onProperty bfo:BFO_0000223 ;
                                                                        owl:someValuesFrom [ a owl:Class ;
                                                                                owl:intersectionOf ( bfo:BFO_0000008 [ a owl:Restriction ;
                                                                                            owl:onProperty [ owl:inverseOf bfo:BFO_0000199 ] ;
                                                                                            owl:someValuesFrom iof-constr:PlannedProcess ] ) ] ] ) ] ] ) ] ] ) ] ],
        iof-constr:PlannedProcess ;
    skos:example "Shipping goods from a warehouse to a customer; moving a tool from one location (work center) to another within the factory; transporting finished goods from one warehouse to another; pumping portions of crude oil through a pipeline; transferring a load of apples from a bin to a container; picking an apple; transporting passengers on a bus;"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/EventOntology and https://www.merriam-webster.com/dictionary/motion" ;
    iof-av:counterExample "A specific type of material handling: E.g., changing only the orientation of the object within the same site (this does not change the site from t to t'); throwing waste into a garbage bin; removing a wing nut from a fixture in preparation for inserting a workpiece into the fixture." ;
    iof-av:explanatoryNote """1. Material transfer process includes both the internal (e.g., inside a factory) and external (e.g., between factories) movement of an object

2. BFO:Site is the synonym for physical location which is why Site is used in the axioms""" ;
    iof-av:firstOrderLogicAxiom """MaterialLocationChangeProcess(​x​) → PlannedProcess(​x)​ ∧ ​∃​y∃​​t∃​​t​1∃​​t2∃​s∃​s1∃​z∃​z1(MaterialEntity(​y​) ∧ TemporalInstant(t) ∧ TemporalInstant(t1) ∧ TemporalRegion(t2) ∧ IndependentContinuant(s) ∧ IndependentContinuant(s1) ∧ Site(z) ∧ Site(z1) ∧ hasParticipantAtSomeTime(x,y)
∧ firstInstantOf(​t​, ​t2) ∧ lastInstantOf(​t1​, ​t2​) ∧ occupiesTemporalRegion(​x,​t2)​ ∧ existsAt(s,t) ∧ existsAt(s1,t1) ∧ locatedInAtalltimes(s,z) ∧ locatedInAtAlltimes(s1,z1) ∧ locationOfAtAlltimes(s,y) ∧ locationOfAtAllTimes(s1,y))""" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "planned process that results in a material entity moving from one physical location to another"@en-US ;
    iof-av:primitiveRationale "Patterns for adequate reification of the n-ary pattern that is change of location need further refinement and testing." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'material location change process' then x is a 'planned process' in which a 'material entity' is moved from one 'site' to another" .

iof-constr:MaterialResource a owl:Class ;
    rdfs:label "material resource"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000040 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:MaterialResourceRole ] ) ] ;
    skos:example "factory available to be used for producing a product; a body of water available to cool a reactor; money available to a person to buy an item; a portion of raw material available to produce a good or service"@en-US ;
    iof-av:counterExample "(ambiguous/undesirable): a portion of water on my factory floor that formed after a recent rainshower." ;
    iof-av:explanatoryNote """1. This defined class is designed to group material entities according to a very broad criterion and is not intended to be used as a parent class for resource types that can be more specifically asserted under another class.

2. Skills and capabilities or other entities in the SDC branch are not resources but they can be considered resources indirectly through their bearer

3. See expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience.""" ;
    iof-av:firstOrderLogicDefinition "MaterialResource(x) ↔ MaterialEntity(x) ∧ ∃r(MaterialResourceRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "material entity which has the material resource role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'material resource' is defined as exactly an instance of 'material entity' that 'has role' some 'material resource role'" .

iof-constr:MaterialState a owl:Class ;
    rdfs:label "material state"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000015 ;
    skos:example "the lightswitch in the off state from 9 PM to 8 AM; the machine in fail state from 4 PM to 5 PM; perfusion bioreactor was run in steady state for two days, a truck is in a stop state because its position has been unchanged"@en-US ;
    iof-av:adaptedFrom "Oxford Languages, term by the name ‘state’" ;
    iof-av:explanatoryNote """1. Although the notion of "particular condition"; has not been introduced in this release, the IOF's approach will be to model this as a dependent entity such that at any timeframe during which it exists, it depends on some material entity -- meaning a material state will necessarily "be focused on" a particular condition of some material entity for which the state is ascribed. Condition here would encompass BFO: specifically-dependent continuants (qualities, dispositions and other realizable entities types) as well as site (the absolute or relative location of a material entity). In the future, the coverage will be expanded to include some currently "missing dependent entity types"; including orientation, and cases wherein a material entity is in a particular condition because it has or is in particular composition or configuration (e.g. the setup action of a machine and jig is complete and it is not in a setup/ready-for-run state).

2. Unchanging, is intended to encompass not just having a particular condition for the duration of the state, but potentially being value-bound to some constant or even within a given range as prescribed by some design or requirement specification. Specialized sub-types may be introduced to handle such value-based constant and range-bound states and conditions.

3. The term as introduced here is not intended to be used for modeling what we might call the "state of a process" (e.g., equilibrium state for chemical, physical and biological processes or steady-state or discrete or continuous production processes), nor for modeling the states of non-real entities (e.g., virtual entities participating in virtual simulation program and any other informational or abstract entities, when they are considered to be in a particular condition). Extensions to the BFO framework as well as further work on 'process characteristic' may be first needed to handle these use cases and such specialized state classes will be introduced in a future release.""" ;
    iof-av:firstOrderLogicAxiom "MaterialState(x) → Process(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "process in which a material entity that participates in the process has a condition that remains unchanged"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs to formalize range,limits and constant values over a period of time are still lacking." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'material state' then x is a 'process'" ;
    iof-av:synonym "stasis"@en-US .

iof-constr:PhysicalLocationIdentifier a owl:Class ;
    rdfs:label "physical location identifier"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Identifier ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:Identifier [ a owl:Restriction ;
                        owl:onProperty iof-constr:designates ;
                        owl:someValuesFrom bfo:BFO_0000029 ] ) ] ;
    skos:example "postal address, GPS coordinate, GS1 global location number (GLN) for physical and digital location, 42.8864° N, 78.8784° W, London, the factory floor"@en-US ;
    iof-av:explanatoryNote """1. Physical location is a synonym for BFO:Site and hence the usage of BFO:Site within the axioms should be interpreted as physical location

2. As introduced here, the IOF ontology is only dealing with physical locations. Identifiers for other kinds of location designators (e.g., virtual locations) will be considered in a future version.

3. More classes need to be introduced to represent coordinates in 3D space. For this, the OGC specification may be utilized:
http://docs.opengeospatial.org/is/18-010r7/18-010r7.html#106""" ;
    iof-av:firstOrderLogicDefinition "PhysicalLocationIdentifier(x) ↔ Identifier(x) ∧ ∃l(Site(l) ∧ designates(x,l))" ;
    iof-av:naturalLanguageDefinition "identifier that identifies a physical location (site)"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'physical location identifier' is defined as exactly an instance of 'identifier' that 'designates' a 'site'"@en-US ;
    iof-av:synonym "site identifier, site designator"@en-US .

iof-constr:PieceOfEquipment a owl:Class ;
    rdfs:label "piece of equipment"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000040 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( [ a owl:Class ;
                        owl:unionOf ( iof-constr:EngineeredSystem iof-constr:MaterialArtifact ) ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:EquipmentRole ] ) ] ;
    skos:example "wrench when it is used in the maintenance process of a car; chromatography column that is planned to be used in a protein purification process; r truck that is used to transport goods to the buyer; single-use bioreactor when it is planned to be used in the upstream phase of a biomanufacturing process"@en-US ;
    iof-av:counterExample "buffer designed to keep pH in a bioreactor constant" ;
    iof-av:explanatoryNote "See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience. Therefore, specific kinds of equipment such as machines, devices, and tools should be asserted under 'material artifact' or 'engineered system' as appropriate and not directly under 'piece of equipment'." ;
    iof-av:firstOrderLogicDefinition "PieceOfEquipment(x) ↔  (MaterialArtifact(x) ∨ EngineeredSystem(x)) ∧ ∃r(EquipmentRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "material artifact or engineered system with an equipment role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'piece of equipment' is defined as exactly an instance of 'material artifact' or 'engineered system' that 'has role' some 'equipment role'" .

iof-constr:ProcuringBusinessProcess a owl:Class ;
    rdfs:label "procuring business process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:BusinessProcess ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:BusinessProcess [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000117 ;
                        owl:someValuesFrom iof-constr:BuyingBusinessProcess ] [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000117 ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:unionOf ( iof-constr:SellingBusinessProcess iof-constr:SupplyingBusinessProcess ) ] ] ) ] ;
    skos:example "AstraZeneca buying and being supplied with a bulk of raw materials from MiliPoreSigma; buying and being supplied with a shipment of office supplies"@en-US ;
    iof-av:adaptedFrom "ISO 6707-2:2017, 3.5.18" ;
    iof-av:explanatoryNote """1. The procurement process considers the whole cycle from identification of needs through to the end of a services contract or the end of the life of goods, including disposal.

2. Sourcing is a part of the procurement process that includes planning, defining specifications (3.26) and selecting suppliers. [Source: ISO 20400:2017]

3. It should be noted that we consciously exclude the person-to-person transactions, but person-to-business is not excluded.""" ;
    iof-av:firstOrderLogicDefinition "ProcuringBusinessProcess(x) ↔ BusinessProcess(x) ∧ ∃b∃s(BuyingBusinessProcess(b) ∧ SupplyingBusinessProcess(s) ∧ hasOccurrentPart(x,b) ∧ hasOccurrentPart(x,s))" ;
    iof-av:naturalLanguageDefinition "business process that consists of buying and ensuring the supply of products or services"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'procuring business process' is defined as exactly an instance of 'business process' that has some 'buying business process' and 'supplying business process' as 'occurent parts'" .

iof-constr:RawMaterial a owl:Class ;
    rdfs:label "raw material"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000040 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:RawMaterialRole ] ) ] ;
    skos:example "rolls of aluminum a manufacturer purchases to be consumed on its bottling lines to produce aluminum cans to package its product, crude oil that is converted into gasoline in a refining process; wheels an automobile manufacturer purchases to assemble into a car"@en-US ;
    iof-av:counterExample "oil used to power the refining process" ;
    iof-av:explanatoryNote "This class is very general and it is intended to be used for grouping inputs to the product production process external to the bussiness organization. But, things like material artifacts should not be asserted as subclasses of this class" ;
    iof-av:firstOrderLogicDefinition "RawMaterial(x) ↔ MaterialEntity(x) ∧ ∃r(RawMaterialRole(x) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "material entity which has the raw material role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'raw material' is defined as exactly an instance of 'material entity' that 'has role' some 'raw material role'" .

iof-constr:TemporalDurationValueExpression a owl:Class ;
    rdfs:label "temporal duration value expression"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Class ;
            owl:intersectionOf ( iof-constr:ValueExpression [ a owl:Restriction ;
                        owl:onProperty iof-constr:isValueExpressionOfAtAllTimes ;
                        owl:someValuesFrom bfo:BFO_0000202 ] ) ] ;
    owl:disjointWith iof-constr:TemporalInstantValueExpression ;
    skos:example "the expression of the duration of the temporal interval that corresponds to the time during which a worker sewed a particular garment."@en-US ;
    iof-av:explanatoryNote "1. This class was introduced as a helper class to map OWL time to IOF Core. For detailed expression of a duration of a ‘temporal interval’, use a suitable subclass of TemporalDuration class from Time ontology (https://www.w3.org/TR/owl-time/) instead of ‘temporal duration value expression’ (see mapping file https://spec.industrialontologies.org/ontology/core/commonstocoremapping/MappingOWLTimeToIOF/)"@en-US ;
    iof-av:firstOrderLogicAxiom "TemporalDurationValueExpression(x) → ValueExpression(x) ∧ ∃y(TimeInterval(y) ∧ isValueExpressionOfAtAllTimes(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "value expression that describes the duration of some temporal interval"@en-US ;
    iof-av:primitiveRationale "The definition of this class is weakened to only necessary condition because the current formal conditions do not specify which characteristic of the temporal interval is being expressed; without a mechanism to formally distinguish duration from other temporal qualities (e.g., temporal position), the construct cannot be given a necessary-and-sufficient definition. Until such representational machinery exists—i.e., a property or formal device that links a value expression specifically to the duration quality of a temporal interval—the conditions can function only as necessary, not necessary and sufficient, making this class primitive." ;
    iof-av:semiFormalNaturalLanguageAxiom "every instance of 'temporal duration value expression' is an instance of 'value expression' that 'is value expression of at all times' some 'temporal interval'" .

iof-constr:after a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "after"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000062 ;
    owl:inverseOf iof-constr:before ;
    skos:example "A metal surface is polished after the surface is cleaned to make it free from dust or grease; a product is manufactured after it is designed; March comes after January."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "after(x,y) ↔ before(y,x)" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the last instant of the temporal extent of i is later than the first instant of the temporal extent of j"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "'before' and 'after' are inverse relations" .

iof-constr:containsOccurrenceOf a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "contains occurence of"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:occursDuring ;
    skos:example "The grinding of metal contains occurrence of sparking; a storm contains occurrences of lightning."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "containsOccurrenceOf(x,y) ↔ occursDuring(y,x)" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the first instant of the temporal extent of j is later than the first instant of the temporal extent of i and the last instant of the temporal extent of j is earlier than the last instant of the temporal extent of i"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "'contains occurrence of' and 'occurs during' are inverse relations" .

iof-constr:dispositionOf a owl:ObjectProperty ;
    rdfs:label "disposition of"@en-US ;
    rdfs:domain bfo:BFO_0000016 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000004 ;
    rdfs:subPropertyOf bfo:BFO_0000197 ;
    owl:inverseOf iof-constr:hasDisposition ;
    skos:example "the disposition to decay to an atom of element Y is the disposition of an atom of element X; the disposition to break apart is the disposition of a poorly assembled item"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000092" ;
    iof-av:firstOrderLogicAxiom "dispositionOf(x,y) → Disposition(x) ∧ IndependentContinuant(y) ∧ inheresIn(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a disposition to an independent continuant (the bearer), in which the disposition specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x disposition of y holds when x is a 'disposition' and y is a 'independent continuant' and x is 'inheres in' y" .

iof-constr:hasDateTimeInstantValue a owl:DatatypeProperty ;
    rdfs:label "has date-time instant value"@en-US ;
    rdfs:domain iof-constr:TemporalInstantValueExpression ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range xsd:dateTime ;
    rdfs:subPropertyOf iof-constr:hasSimpleExpressionValue ;
    skos:example "The time point at 16:30pm at UTC on 3rd March 2023 is asserted by the associated (‘is value expression of at all times’) ‘temporal instant value expression’ having date-time value (‘has date-time instant value’) 2023-03-03T16:30:00Z."@en-US ;
    iof-av:explanatoryNote """1. This data property may be used to specify a ‘temporal instant value expression’ in XSD date-time format (e.g., 2002-10-10T17:00:00Z). For a detailed description of xsd:DateTime, see https://www.w3.org/TR/xmlschema-2/#dateTime.
2. While comparing two ‘temporal instant value expression’, it is important to make sure that their date-time expressions are given in the same calendar and clock system.
3. For detailed expression of date and time in a specific calendar system, use a suitable subclass of TemporalPosition class from Time ontology (https://www.w3.org/TR/owl-time/) instead of ‘temporal instant value expression’ (see mapping file https://spec.industrialontologies.org/ontology/core/commonstocoremapping/MappingOWLTimeToIOF/)."""@en-US ;
    iof-av:naturalLanguageDefinition "data property that relates a time instance value to a XSD date-time"@en-US .

iof-constr:hasMeasuredValueAtSomeTime a owl:ObjectProperty ;
    rdfs:label "has measured value at some time"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:ValueExpression ;
    rdfs:subPropertyOf iof-constr:hasValueExpressionAtSomeTime ;
    owl:inverseOf iof-constr:isMeasuredValueOfAtSomeTime ;
    skos:example "'80kg' is the value of the weight of a male human on the 5th of October 2022; '37C' is the temperature inside a bioreactor in the 30th min from the process start"@en-US ;
    iof-av:naturalLanguageDefinition "relation from an entity to a value expression that contains the value of the entity measured at some time t"@en-US .

iof-constr:hasProcessCharacteristic a owl:ObjectProperty ;
    rdfs:label "has process characteristic"@en-US ;
    rdfs:domain bfo:BFO_0000015 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:ProcessCharacteristic ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:processCharacteristicOf ;
    skos:example "product production process has process characteristic constant production rate; heating process has process characteristic temperature change of 5F/min"@en-US ;
    iof-av:naturalLanguageDefinition "relation between a process and its characteristic"@en-US .

iof-constr:hasQuality a owl:ObjectProperty ;
    rdfs:label "has quality"@en-US ;
    rdfs:domain bfo:BFO_0000004 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000019 ;
    rdfs:subPropertyOf bfo:BFO_0000196 ;
    owl:inverseOf iof-constr:qualityOf ;
    skos:example "this apple has quality this red color"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000086" ;
    iof-av:explanatoryNote "A bearer can have many qualities, and its qualities can exist for different periods of time, but none of its qualities can exist when the bearer does not exist."@en-US ;
    iof-av:firstOrderLogicAxiom "hasQuality(x,y) → IndependentContinuant(x) ∧ Quality(y) ∧ bearerOf(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from an independent continuant (the bearer) to a quality, in which the quality specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x has function y holds when x is a 'independent continuant' and y is a 'quality' and x is 'bearer of' y" .

iof-constr:hasValueExpressionAtAllTimes a owl:ObjectProperty ;
    rdfs:label "has value expression at all times"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:ValueExpression ;
    rdfs:subPropertyOf iof-constr:hasValueExpressionAtSomeTime ;
    owl:inverseOf iof-constr:isValueExpressionOfAtAllTimes ;
    skos:example "speed of light in a vacuum has value expression 3×10^8 m/s ; electric charge carried by a single proton has the value expression 1.602176634×10−19 coulombs"@en-US ;
    iof-av:naturalLanguageDefinition "relation from an entity to a value expression that contains the value of the entity which does not change during the entire existence of the entity"@en-US .

iof-constr:measuredByAtSomeTime a owl:ObjectProperty ;
    rdfs:label "measured by at some time"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000040 ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:measuresAtSomeTime ;
    skos:example "the temperature within a production vessel is measured by a temperature sensor at certain points in time during a chemical production process; the weight of a material bulk is measured by a scale"@en-US ;
    iof-av:naturalLanguageDefinition "relation from an entity to a material entity with a measurement capability that got realized to determine the value of the entity, at some time"@en-US .

iof-constr:observedByAtSomeTime a owl:ObjectProperty ;
    rdfs:label "observed by at some time"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:Agent ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:observesAtSomeTime ;
    skos:example "a chemical reaction in an experiment is observed by a scientist, a machining process is observed by an operator, a group of COVID patients are observed by a doctor"@en-US ;
    iof-av:firstOrderLogicAxiom "observedByAtSomeTime (y, x) → Agent(x) ∧ Entity(y) ∧ ∃p∃i(Process(p) ∧ InformationContentEntity(i) ∧ participatesInAtSomeTime(x,p) ∧ hasOutput(p,i) ∧ isAbout(i,y))" ;
    iof-av:naturalLanguageDefinition "relation from an entity to an agent indicating that the agent participates in some process that outputs information about the entity, at some time"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "p is observed by b at some time t holds when p is an 'entity' and b is an 'agent' and there is a 'process' in which b 'participates in at some time' and that 'has output' some 'information content entity' that 'is about' p" .

iof-constr:occursSimultaneouslyWith a owl:ObjectProperty,
        owl:SymmetricProperty,
        owl:TransitiveProperty ;
    rdfs:label "occurs simultaneously with"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000035 bfo:BFO_0000202 bfo:BFO_0000203 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000035 bfo:BFO_0000202 bfo:BFO_0000203 ) ] ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    skos:example "The rotation of the chuck in a lathe occurs simultaneously with the running of the motor."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "LA1: occursSimultaneouslyWith(i,j) → (TemporalInstant(i) ∧ TemporalInstant(j)) ∨ (TemporalInterval(i) ∧ TemporalInterval(j)) ∨ (Process(i) ∧ Process(j)) ∧ (ProcessBoundary(i) ∧ ProcessBoundary(j))",
        "LA2: TemporalInstant(i) ∧ TemporalInstant(j) ∧ occursSimultaneouslyWith(i,j) → ∃k∃l(TemporalInstantValueExpression(k) ∧ TemporalInstantValueExpression(l) ∧ hasValueExpressionAtAllTimes(i,k) ∧ hasValueExpressionAtAllTimes(j,l) ∧ ∃v1∃v2(hasDateTimeInstantValue(k,v1) ∧ hasDateTimeInstantValue(l,v2) ∧ (v1 = v2)))",
        "LA3: TemporalInterval(i) ∧ TemporalInterval(j) ∧ occursSimultaneouslyWith(i,j) → ∃i1∃i2∃j1∃j2(TemporalInstant(i1) ∧ TemporalInstant(j1) ∧ TemporalInstant(i2) ∧ TemporalInstant(j2) ∧ hasFirstInstant(i,i1) ∧ hasLastInstant(i,i2) ∧ hasFirstInstant(j,j1) ∧ hasLastInstant(j,j2) ∧ occursSimultaneouslyWith(i1,j1) ∧ occursSimultaneouslyWith(i2,j2))",
        "LA4: Process(i) ∧ Process(j) ∧ occursSimultaneouslyWith(i,j) → ∃i1∃j1(TemporalInterval(i1) ∧ TemporalInterval(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ occursSimultaneouslyWith(i1,j1))",
        "LA5: ProcessBoundary(i) ∧ ProcessBoundary(j) ∧ occursSimultaneouslyWith(i,j) → ∃i1∃j1(TemporalInstant(i1) ∧ TemporalInstant(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ occursSimultaneouslyWith(i1,j1))" ;
    iof-av:naturalLanguageDefinition "relation that holds between two time instants when they are simultaneous or between two intervals when they have same first and last instants or between two processes or two process boundaries when their temporal extents are the same"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: if i 'occurs simultaneously with' j then either i and j are both ‘temporal instant’, or both are ‘temporal interval’ or both are ‘process’ or both are ‘process boundary’",
        "LA2: If both i and j are both ‘temporal instant’ and i 'occurs simoultaneously with' j then 'temporal instant value expression' of i is equal to the 'temporal instant value expression' of j",
        "LA3: If i and j are both ‘temporal interval’ and i 'occurs simoultaneously with' j then the 'first instant of' i 'occurs simoultaneously with' the 'first instant of' j and the 'last instant of' i 'occurs simoultaneously with' the 'last instant of' j",
        "LA4: If both i and j are ‘process’ and i 'occurs simoultaneously with' j then the ‘temporal interval’ occupied by i ‘occurs simoultaneously with’ the ‘temporal interval’ occupied by j",
        "LA5: If i and j are both ‘process boundary’ and i 'occurs simoultaneously with' j then the ‘temporal instant’ that i occupies 'occurs simoultaneously with' ‘temporal instant’ that j occupies" .

iof-constr:temporallyFinishedBy a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "temporally finished by"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:temporallyFinishes ;
    skos:example "A delivery process is temporally finished by the generation of “proof of delivery”; a football match is temporally finished by the Referee’s final whistle; every week is temporally finished by a Sunday."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "temporallyFinishedBy(x,y) ↔ temporallyFinishes(y,x)" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the last instant of the temporal extent of j is the same as the last instant of the temporal extent of i and the first instant of i is precedes the first instant of j"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "'temporally finished by' and 'temporally finishes' are inverse relations" .

iof-constr:temporallyStartedBy a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "temporally started by"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:temporallyStarts ;
    skos:example "An internal combustion engine is temporally started (running) by the process of cranking; some machine is temporally started (running) by pressing a switch; every year is temporally started by the New Year’s Day."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "temporallyStartedBy(x,y) ↔ temporallyStarts(y,x)" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the first instant of the temporal extent of j is the same as first the instant of the temporal extent of i and the last instant of j precedes the last instant of i"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "'temporally started by' and 'temporally starts' are inverse relations" .

<https://spec.industrialontologies.org/ontology/core/Core/> a owl:Ontology ;
    rdfs:label "Core Ontology"@en-US ;
    dcterms:abstract "The IOF Core Ontology contains notions found to be common across multiple manufacturing domains. This file is an RDF implementation of these notions. The ontology utilizes the Basic Formal Ontology or BFO as a top-level ontology but also borrows terms from various domain-independent or mid-level ontologies. The purpose of the ontology is to serve as a foundation for ensuring consistency and interoperability across various domain-specific reference ontologies the IOF publishes." ;
    dcterms:contributor "Ana Teresa Correia, Institut fuer angewandte Systemtechnik Bremen GmbH (ATB-Bremen)"@en-US,
        "Arkopaul Sarkar, Ecole Nationale d'Ingénieurs de Tarbes (ENIT)"@en-US,
        "Barry Smith, University at Buffalo"@en-US,
        "Boonserm Kulvatunyou, National Institute of Standards and Technology (NIST)"@en-US,
        "Chris Will, National Center for Ontological Research (NCOR)"@en-US,
        "Dusan Sormaz, Ohio University"@en-US,
        "Elisa Kendall, Thematix Partners LLC"@en-US,
        "Farhad Ameri, Texas State University"@en-US,
        "Jim Logan, Dassault Systèmes"@en-US,
        "Melinda Hodkiewicz, University of Western Australia"@en-US,
        "Milos Drobnjakovic, National Institute of Standards and Technology (NIST)"@en-US,
        "Will Sobel, W. V. Sobel LLC"@en-US ;
    dcterms:creator "IOF Core Working Group"@en-US ;
    dcterms:license "http://opensource.org/licenses/MIT"^^xsd:anyURI ;
    dcterms:publisher "Industrial Ontology Foundry"@en-US ;
    dcterms:title "Industrial Ontology Foundry (IOF) Core Ontology" ;
    owl:imports <http://purl.obolibrary.org/obo/bfo/2020/bfo.owl>,
        <https://spec.industrialontologies.org/ontology/202502/core/meta/AnnotationVocabulary/> ;
    owl:versionIRI <https://spec.industrialontologies.org/ontology/202502/core/Core/> ;
    iof-av:copyright "Copyright (c) 2022, 2023, 2024, 2025 Open Applications Group" ;
    iof-av:maturity iof-ind:Released .

iof-constr:AssemblyProcess a owl:Class ;
    rdfs:label "assembly process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:hasInput ;
            owl:someValuesFrom iof-constr:MaterialComponent ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:hasSpecifiedOutput ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( iof-constr:Assembly [ a owl:Restriction ;
                                owl:onProperty iof-constr:hasComponentPartAtAllTimes ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:intersectionOf ( iof-constr:MaterialComponent [ a owl:Restriction ;
                                                    owl:onProperty iof-constr:isInputOf ;
                                                    owl:someValuesFrom iof-constr:ManufacturingProcess ] ) ] ] ) ] ],
        iof-constr:ManufacturingProcess ;
    skos:example "Driving a lug nut to hold the wheel of a car in place; welding two metal parts into a single object; automated drilling and riveting of a skin panel operation during fuselage assembly;"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/EventOntology" ;
    iof-av:counterExample "3D printing on an existing part (existing part + a pool of printing material -> new part) -- Note that the pool of material is an object before the process but becomes liquid (there is physical state change) during the \"assembly\" process." ;
    iof-av:firstOrderLogicAxiom "AssemblyProcess(x) → ManufacturingProcess(x) ∧ ∃a∃c (Assembly(a) ∧ MaterialComponent(c) ∧ isInputOf(c,x) ∧ hasComponentPartAtAllTimes(a,c) ∧ hasSpecifiedOutput(x,a))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "manufacturing process in which a number of material components are physically connected to each other to form an assembly"@en-US ;
    iof-av:primitiveRationale "More conditions (differentia) need to be agreed upon by the domain experts as processes like 3D printing can also produce an assembly." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'assembly process' x then x is a 'manufacturing process' that 'has specified output' some 'assembly' which 'has component part at all times' some 'material component' that 'is input of' x" .

iof-constr:Buyer a owl:Class ;
    rdfs:label "buyer"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Agent ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( [ a owl:Class ;
                        owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:BuyerRole ] ) ] ;
    skos:example "Pfizer when it buys a bulk of chemicals from MiliporeSigma; a person is when they buy groceries at the supermarket; a manufacturing enterprise when they hire an external organization to do some manufacturing process (manufacturing as a service); a person when they hire someone to repair a broken pipe"@en-US ;
    iof-av:explanatoryNote "See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience." ;
    iof-av:firstOrderLogicDefinition "Buyer(x) ↔ Person(x) ∨ Organization(x) ∧ ∃r(BuyerRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "person or organization which has a buyer role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'buyer' is defined as exactly an instance of 'person' or 'organization' that 'has role' some 'buyer role'" .

iof-constr:ComputingProcess a owl:Class ;
    rdfs:label "computing process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:allValuesFrom iof-constr:InformationContentEntity ;
            owl:onProperty iof-constr:hasSpecifiedOutput ],
        [ a owl:Restriction ;
            owl:allValuesFrom iof-constr:InformationContentEntity ;
            owl:onProperty iof-constr:hasInput ],
        iof-constr:PlannedProcess ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:PlannedProcess [ a owl:Class ;
                        owl:unionOf ( [ a owl:Restriction ;
                                    owl:onProperty iof-constr:achievesAtSomeTime ;
                                    owl:someValuesFrom [ a owl:Class ;
                                            owl:intersectionOf ( iof-constr:ObjectiveSpecification [ a owl:Restriction ;
                                                        owl:onProperty bfo:BFO_0000177 ;
                                                        owl:someValuesFrom [ a owl:Class ;
                                                                owl:unionOf ( iof-constr:Algorithm iof-constr:EncodedAlgorithm ) ] ] ) ] ] [ a owl:Restriction ;
                                    owl:onProperty iof-constr:hasSpecifiedOutput ;
                                    owl:someValuesFrom iof-constr:InformationContentEntity ] ) ] [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000057 ;
                        owl:someValuesFrom iof-constr:Agent ] [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000059 ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:intersectionOf ( [ a owl:Class ;
                                            owl:unionOf ( iof-constr:Algorithm iof-constr:EncodedAlgorithm ) ] [ a owl:Restriction ;
                                            owl:onProperty bfo:BFO_0000084 ;
                                            owl:someValuesFrom iof-constr:Agent ] ) ] ] ) ] ;
    skos:example "execution of a neural network implemented in tensorflow to classify a set of images on a specific cluster; running of the MPC algorithm to control pressure during the production process"@en-US ;
    iof-av:adaptedFrom "https://en.wikipedia.org/wiki/Process_(computing) and https://en.wikipedia.org/wiki/Execution_(computing)" ;
    iof-av:explanatoryNote """1. The inputs and specified outputs of 'computing process' are strictly limited to information content entities.
2. While it is true that algorithms can result in an action by an agent that concretizes it (e.g. controller changes the pressure of a valve), the intermediate step is still an information content entity (e.g. action specification) that is 'concretized' in a separate process that results in the action.""" ;
    iof-av:firstOrderLogicAxiom "ComputingProcess(x) → ∀y((hasInput(x,y) ∨ hasSpecifiedOutput(x,y)) → InformationContentEntity(y))" ;
    iof-av:firstOrderLogicDefinition """ComputingProcess(x) ↔ PlannedProcess(x) ∧ ∃y∃a(Agent(y) ∧ (Algorithm(a) ∨ EncodedAlgorithm(a)) ∧ hasParticipantAtSomeTIme(x,y) ∧ genericallyDependsOnAtSomeTime(a,y) ∧ concretizesAtSomeTime(x,a) ∧ (∃o(ObjectiveSpecification(o) ∧ continuantPartOfAtAllTimes(o,a) ∧ achievesAtSomeTIme(x,o)) ∨
∃i(InformationContentEntity(i) ∧ hasSpecifiedOutput(x,i))))""" ;
    iof-av:naturalLanguageDefinition "planned process in which an algorithm or an encoded algorithm is realized by an agent"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'computing process' then whenever x 'has input' or 'has specified output' y that y must be an 'information content entity'" ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'computing process' is defined as exactly an instance of 'planned process' that 'concretizes at some time' an 'encoded algorithm' or 'algorithm' y which 'generically depends on at some time' some 'agent' which 'participates in at some time' the 'computing process' and the 'computing process' either 'achieves at some time' some 'objective specification' that is 'continuant part of at all times y or it 'has specified output' some 'information content entity'" .

iof-constr:DirectiveInformationContentEntity a owl:Class ;
    rdfs:label "directive information content entity"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                        owl:onProperty iof-constr:prescribes ;
                        owl:someValuesFrom bfo:BFO_0000001 ] ) ] ;
    skos:example "blueprint of a building, process plan, software functional requirement"@en-US ;
    iof-av:abbreviation "directive ICE"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:explanatoryNote "This class is intended to be a defined class used for axiomatization and assertion convenience. It is not expected nor recommended that entities will be asserted as a subclass of this class." ;
    iof-av:firstOrderLogicDefinition "DirectiveInformationContentEntity(x) ↔ InformationContentEntity(x) ∧ ∃e(Entity(e) ∧ prescribes(x,e))" ;
    iof-av:naturalLanguageDefinition "information content entity that prescribes a set of rules or guidelines for a process or a model of something man-made"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'directive information content entity' is defined as exactly an instance of 'information content entity' that 'prescribes' some 'entity'" .

iof-constr:EquipmentRole a owl:Class ;
    rdfs:label "equipment role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( [ a owl:Class ;
                                owl:unionOf ( iof-constr:EngineeredSystem iof-constr:MaterialArtifact ) ] [ a owl:Restriction ;
                                owl:onProperty iof-constr:prescribedBy ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:unionOf ( iof-constr:PlanSpecification [ a owl:Restriction ;
                                                    owl:onProperty bfo:BFO_0000177 ;
                                                    owl:someValuesFrom iof-constr:PlanSpecification ] ) ] ] ) ] ],
        [ a owl:Restriction ;
            owl:allValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( iof-constr:PlannedProcess [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000055 ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:intersectionOf ( bfo:BFO_0000034 [ a owl:Restriction ;
                                                    owl:onProperty iof-constr:functionOf ;
                                                    owl:someValuesFrom [ a owl:Class ;
                                                            owl:unionOf ( iof-constr:EngineeredSystem iof-constr:MaterialArtifact ) ] ] ) ] ] ) ] ;
            owl:onProperty bfo:BFO_0000054 ],
        [ a owl:Restriction ;
            owl:allValuesFrom [ a owl:Class ;
                    owl:unionOf ( iof-constr:EngineeredSystem iof-constr:MaterialArtifact ) ] ;
            owl:onProperty iof-constr:roleOf ],
        bfo:BFO_0000023 ;
    skos:example "role of a wrench when it is used in the maintenance process of a car; role of a chromatography column that is planned to be used in a protein purification process; role of a truck that is used to transport goods to the buyer; role of a single-use bioreactor when it is planned to be used in the upstream phase of a biomanufacturing process"@en-US ;
    iof-av:adaptedFrom "adapted from Oxford Languages, term by the name ‘equipment’" ;
    iof-av:explanatoryNote """1. By including in the definition that the material artifact or engineered system is not consumed in the process, the equipment role intentionally excludes entities such as consumables and reagents, which should be modeled separately.

2. In the definition, "utilized for carrying out" implies that the function of the given material artifact or the engineered system needs to be realized in the process. That is, entities with the equipment role should not passively participate in the prescribed process. This differentiates 'material entities with the equipment role' (a piece of equipment) from material entities that are acted upon (transformed or modified) in the given process.""" ;
    iof-av:firstOrderLogicAxiom "LA1: EquipmentRole(x) → ∀y (hasRealization(x,y) → (PlannedProcess(y) ∧ ∃f (Function(f) ∧ realizes(y,f) ∧ ∃z ((EngineeredSystem(z) ∨ MaterialArtifact(z)) ∧ functionOf(f,z)))))",
        "LA2: EquipmentRole(x) → ∀y (roleOf(x,y) → (EngineeredSystem(y) ∨ MaterialArtifact(y)))",
        "LA3: EquipmentRole(x) → ∃y ( roleOf(x,y) ∧ (EngineeredSystem(y) ∨ MaterialArtifact(y)) ∧ ∃z ( prescribedBy(y,z) ∧ ( PlanSpecification(z) ∨ ∃p ( PlanSpecification(p) ∧ continuantPartOfAtAllTimes(z,p) ) ) ) )" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "role held by a material artifact or an engineered system when it is planned to be involved in or is involved in carrying out some part of a planned process and that is not consumed in that planned process"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to define necessary and sufficient conditions. Namely, patterns for utilized in carrying out and not consumed need to be developed further." ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: if x is an ‘equipment role’ then whenever x ‘has realization’ y, y is a ‘planned process’ that ‘realizes’ some ‘function’ that is ‘function of’ some ‘engineered system’ or ‘material artifact’",
        "LA2: if x is an ‘equipment role’ then whenever x ‘role of’ y, y must be an ‘engineered system’ or a ‘material artifact’",
        "LA3: if x is an ‘equipment role’ then x is ‘role of’ some y such that y is an ‘engineered system’ or a ‘material artifact’, and y is ‘prescribed by’ some entity that is either a ‘plan specification’ or something that is ‘continuant part of at all times’ some ‘plan specification’" .

iof-constr:MaintainableMaterialItemRole a owl:Class ;
    rdfs:label "maintainable material item role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000023 ;
    skos:example "a CNC machine has the maintainable material item role when it is undergoing repair after a failure"@en-US ;
    iof-av:adaptedFrom "https://ceur-ws.org/Vol-2900/WS5Paper2.pdf" ;
    iof-av:firstOrderLogicAxiom "MaintainableMaterialItemRole(x) → Role(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "role played by an asset (engineered system or material artifact) when there is a maintenance strategy prescribing its maintenance process"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for 'maintenance strategy' and 'maintenance process' need to be formalized." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'maintainable material item' then x is a 'role'" .

iof-constr:ManufacturerRole a owl:Class ;
    rdfs:label "manufacturer role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( iof-constr:Organization [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000056 ;
                                owl:someValuesFrom iof-constr:ProductProductionProcess ] ) ] ],
        iof-constr:AgentRole ;
    skos:example "MiliporeSigma has a manufacturer role when it produces single-use bioreactors; Boeing has a manufacturer role when it produces airplanes; Dell has a manufacturer role when it produces lap-tops"@en-US ;
    iof-av:adaptedFrom "bizfluent.com" ;
    iof-av:firstOrderLogicAxiom "ManufacturerRole(x) → Role(x) ∧ ∃y∃p(Organization(y) ∧ ProductProductionProcess(p) ∧ participatesInAtSomeTime(y,p) ∧ roleOf(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "agent role held by an organization when it produces material products"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for linking the manufacturer to a product it produces are still lacking." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'manufacturer role' x then x is an 'agent role' that is the 'role of' some 'organization' when it 'participates in at some time' some 'product production process'" .

iof-constr:MaterialComponentRole a owl:Class ;
    rdfs:label "material component role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom bfo:BFO_0000040 ],
        bfo:BFO_0000023 ;
    skos:example "an engine has the component role when it is a part of a car; a tool when it is planned to be mounted on a CNC machine"@en-US ;
    iof-av:adaptedFrom "APICS" ;
    iof-av:firstOrderLogicAxiom "MaterialComponentRole(x) → Role(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "role held by a material entity when it is a proper part of another material entity or is planned to be a proper part of another material entity"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for 'planned to be a part' need to be formalized. Also, the realization of the material component role needs to be analyzed further." ;
    iof-av:semiFormalNaturalLanguageAxiom "If x is a 'material component role' then x is a 'role'" .

iof-constr:MaterialProductRole a owl:Class ;
    rdfs:label "material product role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000056 ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:unionOf ( iof-constr:BuyingBusinessProcess iof-constr:SellingBusinessProcess iof-constr:SupplyingBusinessProcess ) ] ] ) ] ],
        bfo:BFO_0000023 ;
    skos:example "a manufactured good has a material product role when a manufacturer offers it for sale; a drug product has a material product role when it is bought by a customer in a pharmacy; sea shells have a material product role when they are collected, packaged and offered for sale;"@en-US ;
    iof-av:adaptedFrom "Oxford Languages, term by the name ‘product’; also Wikipedia, term by the name ‘goods’ (as used in economics) and in particular, tangible goods" ;
    iof-av:firstOrderLogicAxiom "MaterialProductRole(x) → Role(x) ∧ ∃y∃z((BuyingBusinessProcess(y) ∨ OfferingForSaleBusinessProcess(y) ∨ SupplyingBusinessProcess(y)) ∧ MaterialEntity(z) ∧ participatesInAtSomeTime(z,y) ∧ roleOf(x,z))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "role held by a material entity that is intended to be sold, or has been bought, or has been supplied"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for economic transactions and ownership are lacking" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'material product role' x then x is a 'role' that is the 'role of' some 'material entity' when it 'participates in at some time' some 'buying business process' or 'offering for sale business process' or 'supplying business process'" .

iof-constr:MaterialResourceRole a owl:Class ;
    rdfs:label "material resource role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                                owl:onProperty iof-constr:isAvailableToAtSomeTime ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:unionOf ( iof-constr:EngineeredSystem iof-constr:GroupOfAgents iof-constr:Person ) ] ] ) ] ],
        bfo:BFO_0000023 ;
    skos:example "factory has a material resource role when it is available to be used for producing a product; a body of water has a material resource role when it is available to cool a reactor; money has a material resource role when it is available to a person to buy an item; a portion of raw material has a material resource role when it is available to produce a good or service"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/ArtifactOntology"@en-US ;
    iof-av:firstOrderLogicAxiom "MaterialResourceRole(x) → Role(x) ∧ ∃a∃y((Person(a) ∨ GroupOfAgents(a) ∨ EngineeredSystem(y)) ∧ MaterialEntity(y) ∧ isAvailableToAtSomeTime(y,a) ∧ roleOf(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "role played by a material entity that consists in it being available to a person or group of agents or engineered system"@en-US ;
    iof-av:primitiveRationale "This term is expected to remain primitive. While 'is available to at some time' captures the essence of being a material resource, the realization of the material resource role is expected to have too generic of a scope to define a sufficient condition that would not cause conflict (overlap) with the realization of other roles." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'material resource role' x then x is a 'role' that is the 'role of' some 'material entity' when it 'is available to at some time' some 'person' or 'group of agents' or 'engineered system'" .

iof-constr:MeasuredValueExpression a owl:Class ;
    rdfs:label "measured value expression"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:ValueExpression ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:ValueExpression [ a owl:Restriction ;
                        owl:onProperty iof-constr:isMeasuredValueOfAtSomeTime ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:unionOf ( bfo:BFO_0000008 bfo:BFO_0000020 iof-constr:ProcessCharacteristic ) ] ] ) ] ;
    skos:example "the value of '20g' that represents the measured weight of a mouse and that is determined on the quantitative scale of mass"@en-US ;
    iof-av:adaptedFrom "International Vocabulary of Metrology Fourth edition,2.11" ;
    iof-av:explanatoryNote """1. The values of the measured value expression are generated during the measurement process that produces the measurement information content entity the measured value expression is a part of. The corresponding parthood axiom is captured in the measurement information content entity class and is not reintroduced in the formal definition here to avoid redundancy.

2. Since this class is a subclassOf: value expression, the values contained in the measured value expression are always according to a classification scheme or a quantitative scale.""" ;
    iof-av:firstOrderLogicDefinition """MeasuredValueSpecification(x) ↔ ValueExpression(x) ∧ ∃e((TemporalRegion(e) ∨ ProcessCharacteristic(e) ∨ SpecificallyDependentContinuant(e))
∧ isMeasuredValueOfAtSomeTime(x,e))""" ;
    iof-av:naturalLanguageDefinition "value expression that contains the measured value of an attribute (specifically dependent continuant or process characteristic or temporal region)"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'measured value expression' is defined exactly as an instance of 'information content entity' that 'is measured value of at some time' some 'process characteristic' or 'temporal region' or 'specifically dependent continuant'" .

iof-constr:MeasurementCapability a owl:Class ;
    rdfs:label "measurement capability"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:capabilityOf ;
            owl:someValuesFrom bfo:BFO_0000040 ],
        [ a owl:Restriction ;
            owl:allValuesFrom iof-constr:MeasurementProcess ;
            owl:onProperty bfo:BFO_0000054 ],
        iof-constr:Capability ;
    skos:example "the capability of a pH sensor to measure the pH; capability of a scale to measure the weight of an object"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/OBI_0000453" ;
    iof-av:explanatoryNote "To measure the value means to determine the entities value relative to some classification scheme or on a quantitative scale." ;
    iof-av:firstOrderLogicAxiom "MeasurementCapability(x) → Capability(x) ∧ ∃z(MaterialEntity(z) ∧ capabilityOf(x,z)) ∧ ∀y(hasRealization(x,y) → MeasurementProcess(y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "capability of a material entity to measure the value of some entity"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs in the ontology to create necessary and sufficient conditions. Namely, 'to measure the value' needs a better formalization in its connection to the capability" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'measurement capability' then x is a 'capability' that is the 'capability of' some 'material entity' and whenever some y 'realizes' x that y must be a 'measurement process'" .

iof-constr:MeasurementInformationContentEntity a owl:Class ;
    rdfs:label "measurement information content entity"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000110 ;
                        owl:someValuesFrom iof-constr:MeasuredValueExpression ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:describes ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:unionOf ( bfo:BFO_0000008 bfo:BFO_0000020 iof-constr:ProcessCharacteristic ) ] ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:isAbout ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000035 [ a owl:Class ;
                                            owl:intersectionOf ( bfo:BFO_0000004 [ a owl:Class ;
                                                        owl:complementOf bfo:BFO_0000006 ] ) ] ) ] ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:isOutputOf ;
                        owl:someValuesFrom iof-constr:MeasurementProcess ] ) ] ;
    skos:example "a two fold increase in expression of a gene in a cancer patient and the associated metadata; results of measuring the thickness of a piece of steel; results of measuring the change in pH in a bioreactor over the interval of two days"@en-US ;
    iof-av:abbreviation "measurement ICE"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology and the International Vocabulary of Metrology" ;
    iof-av:counterExample "similarity measurement of information" ;
    iof-av:explanatoryNote """1. Attribute here comprehends qualities in case the entity the measurement content entity 'is about' is an independent continuant and process characteristics if the entity is a process or temporal region if the entity is a process or process boundary.
2. Measurement ICE describes attributes of physical entities. As such, it is not intended to be used for capturing metrics related to strictly digital objects (information content entities in the IOF framework).
3. Measurement ICE can contain qualitative, semi-quantitative, or quantitative measurements of the attribute. These values are stored within the measured value expression that is a part of the measurement ICE.
4. Measurement ICE can be utilized for both raw and processed measurement data.
5. The International Vocabulary of Metrology defines measurement ICE as a "set of values being attributed to a measurand together with any other available relevant information." This implies that, in addition to the actual measurement value, the measurement ICE contains other information(e.g., the entity of interest of which the measurand is the 'attribute of').""" ;
    iof-av:firstOrderLogicDefinition "MeasurementInformationContentEntity(x) ↔ InformationContentEntity(x) ∧ ∃y∃z∃m∃p(((IndependentContinuant(y) ∧ ¬(SpatialRegion(y)) ∧ SpecificallyDependentContinuant(z) ∧ bearerOf(y,z)) ∨ (Process(y) ∨ ProcessBoundary(y) ∧ TemporalRegion(z) ∧ occupiesTemporalRegion(y,z)) ∨ (Process(y) ∧ ProcessCharacteristic(z) ∧ processCharacteristicOf(z,y))) ∧ MeasuredValueExpression(m) ∧ MeasurementProcess(p) ∧ isAbout(x,y) ∧ describes(x,z) ∧ hasContinuantPartAtAllTimes(x,m) ∧ isMeasuredValueOf(m,y) ∧ isOutputOf(x,p))" ;
    iof-av:naturalLanguageDefinition "informational content that is the result of measuring a set of attributes (specifically dependent continuant or process characteristic or temporal region) belonging to the entity (independent continuant or process or process boundary) the informational content is about"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'measurement information content entity is defined as exactly an instance of 'information content entity' that is 'output of' some 'measurement process' that 'describes' some 'specifically dependent continuant' or 'temporal region' or 'process characteristic' y that are an attribute of ('inhere in' or 'process characteristic of' or temporally occupied by) a 'process' or 'process boundary' or 'independent continuant'(that is not a 'spatial region') the 'measurement information content entity' 'is about' and that 'has continuant part at all times' some 'measured value expression' that 'is measured value of' y" .

iof-constr:OrganizationIdentifier a owl:Class ;
    rdfs:label "organization identifier"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Identifier ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:Identifier [ a owl:Restriction ;
                        owl:onProperty iof-constr:designates ;
                        owl:someValuesFrom iof-constr:Organization ] ) ] ;
    skos:example "DUNS Number, CAGE Code, EIN, FIIN, BICID, DODAACID, SCACID"@en-US ;
    iof-av:explanatoryNote """1. Organization identifier used here is intended to uniquely identify a particular organization within a region, country, or globally. A government body usually issues one such identifier in the region or country where the business operates (a.k.a. legal entity identifier). Other such identifiers may be assigned by well-known business organizations operating in a locale, a region, or a country -- an example being Dun and Bradstreet for businesses operating in the United States. Moreover, others may still be assigned by international trade organizations for multi-national organizations. In all cases, these unique identifiers facilitate regional or international trade and commerce between such "legal entities."

2. As introduced here, the term serves to identify other organizational types, including government entities, who are often parties in trade or commerce or have a vested interest in controlling it. In the future, the IOF will introduce and adopt a mid-level ontology for legal entities and relations.

3. The identifier of an organization may be the name of an organization or an alias and may only be unique in a particular jurisdiction (locale, region) and may not be unique on a wider scale - namely at the country level or globally.""" ;
    iof-av:firstOrderLogicDefinition "OrganizationIdentifier(x) ↔ Identifier(x) ∧ ∃b(Organization(b) ∧ designates(x,b))" ;
    iof-av:naturalLanguageDefinition "identifier that identifies an organization"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of ‘organization identifier’ is defined as exactly an instance of ‘identifier' that 'designates' an 'organization'" .

iof-constr:RawMaterialRole a owl:Class ;
    rdfs:label "raw material role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:allValuesFrom [ a owl:Class ;
                    owl:unionOf ( iof-constr:ProductProductionProcess [ a owl:Class ;
                                owl:intersectionOf ( iof-constr:ManufacturingProcess [ a owl:Restriction ;
                                            owl:onProperty bfo:BFO_0000132 ;
                                            owl:someValuesFrom iof-constr:ProductProductionProcess ] ) ] ) ] ;
            owl:onProperty bfo:BFO_0000054 ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000056 ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:intersectionOf ( iof-constr:BuyingBusinessProcess [ a owl:Restriction ;
                                                    owl:onProperty bfo:BFO_0000057 ;
                                                    owl:someValuesFrom [ a owl:Class ;
                                                            owl:intersectionOf ( iof-constr:Organization [ a owl:Restriction ;
                                                                        owl:onProperty iof-constr:hasRole ;
                                                                        owl:someValuesFrom iof-constr:BuyerRole ] ) ] ] ) ] ] ) ] ],
        bfo:BFO_0000023 ;
    skos:example "rolls of aluminum a manufacturer purchases to be consumed to produce aluminum cans"@en-US ;
    iof-av:adaptedFrom "ISO 17889-1:2021(en) and https://www.merriam-webster.com/dictionary/raw%20material" ;
    iof-av:counterExample "production intermediary going from one production cell to another; reagent that is used in a quality testing process of the product or any intermediary" ;
    iof-av:explanatoryNote """1. IOF considers raw materials only material entities that are acquired from a different organizational unit. However, that organizational unit can be within the same manufacturing enterprise (e.g., exchange of goods between divisions).
2. Raw materials are incorporated during the product production process into the final product. In other words, 'raw materials' exclude consumables from non-manufacturing processes that are a part of product production (e.g., maintenance or quality control) or consumables that are not incorporated into the product (e.g., single-use equipment).""" ;
    iof-av:firstOrderLogicAxiom "RawMaterialRole(x) → Role(x) ∧ ∃y∃m∃z∃b(BuyingBusinessProcess(y) ∧ Organization(m) ∧ MaterialEntity(z) ∧ BuyerRole(b) ∧ roleOf(b,m) ∧ roleOf(x,z) ∧ hasParticipantAtSomeTime(y,m) ∧ hasParticipantAtSomeTime(y,z)) ∧ ∀y1(hasRealization(x,y1) → (ProductProductionProcess(y1) ∨ ManufacturingProcess(y1)))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "role held by a material entity when it is acquired by an organizational entity with some plan to transform or modify it into intermediate-level components or substances or into a product"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for transforming or modifying are lacking." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'raw material role' then x is a 'role' that is the 'role of' some 'material entity' when it 'participates in at some time' a 'buying business process' in which some 'organization' that 'has role' 'buyer role' participates in at some time' and whenever x 'has realization' y that y must be a 'product production process' or a 'manufacturing process'" .

iof-constr:ServiceProvider a owl:Class ;
    rdfs:label "service provider"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Supplier ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( [ a owl:Class ;
                        owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:ServiceProviderRole ] ) ] ;
    skos:example "FedEx; Home-cleaning service; aircraft maintenance service; internet service provider"@en-US ;
    iof-av:explanatoryNote "See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience." ;
    iof-av:firstOrderLogicDefinition "ServiceProvider(x) ↔ (Person(x) ∨ Organization(x)) ∧ ∃r(ServiceProviderRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "person or organization which has a service provider role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'service provider' is defined as exactly an instance of 'person' or 'organization' that 'has role' some 'service provider role'" .

iof-constr:achievesAtSomeTime a owl:ObjectProperty ;
    rdfs:label "achieves at some time"@en-US ;
    rdfs:domain bfo:BFO_0000015 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:InformationContentEntity ;
    rdfs:subPropertyOf bfo:BFO_0000059 ;
    owl:inverseOf iof-constr:isAchievedByAtSomeTime ;
    skos:example "The staffing and ramping up of production to 2 shifts per work day acheives the company plan of satisfying a surge in demand for its products."@en-US ;
    iof-av:firstOrderLogicAxiom "achievesAtSomeTime(x,y) → Process(x) ∧ InformationContentEntity(y) ∧ (concretizesAtSomeTime(x,y) ∨ ∃z(continuantPartOfAtAllTimes(z,y) ∧ InformationContentEntity(z) ∧ concretizesAtSomeTime(x,z)))" ;
    iof-av:naturalLanguageDefinition "relation from a process to an information content entity wherein the process partially or fully concretizes the information content entity"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x achieves at some time y holds when x is a 'process' and y is an 'information content entity' and x 'concretizes at some time' y or a 'continuant part of at all times' y" .

iof-constr:before a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "before"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000063 ;
    skos:example "The surface of the metal is cleaned to make it free from dust or grease before polishing; a product is designed before it can be manufactured; January comes before March."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "LA1: before(i,j) → (TemporalInterval(i) ∧ TemporalInterval(j)) ∨ (Process(i) ∧ Process(j))",
        "LA2: TemporalInterval(i) ∧ TemporalInterval(j) ∧ before(i,j) → ∃i1∃j1(TemporalInstant(i1) ∧ TemporalInstant(j1) ∧ hasLastInstant(i,i1) ∧ hasFirstInstant(j,j1) ∧ precedes(i1,j1))",
        "LA3: Process(i) ∧ Process(j) ∧ ∃i1∃j1(TemporalInterval(i1) ∧ before(i,j) → TemporalInterval(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ before(i1,j1))" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the last instant of the temporal extent of i is earlier than the first instant of the temporal extent of j"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: If i is 'before' j then either both are 'temporal intervals' or both are 'process'",
        "LA2: If both i and j are 'temporal intervals' and i is 'before' j then the 'last instant of' i 'precedes' the 'first instant of' j",
        "LA3: If both i and j are 'process' and i is 'before' j then the 'temporal interval' that i occupies is 'before' the 'temporal interval' that j occupies" .

iof-constr:capabilityOf a owl:ObjectProperty ;
    rdfs:label "capability of"@en-US ;
    rdfs:domain iof-constr:Capability ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000004 ;
    rdfs:subPropertyOf bfo:BFO_0000197 ;
    owl:inverseOf iof-constr:hasCapability ;
    skos:example "turning at the maximal speed of 4000RPM is the capability of a lathe; temperature sensor has the capability to measuring temperature with a 0.01C precision is the capability of a temperature sensor; measuring pH in the range of 0-14 is the capability of a pH meter"@en-US ;
    iof-av:firstOrderLogicAxiom "capabilityOf(x,y) → Capability(x) ∧ IndependentContinuant(y) ∧ inheresIn(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a capability to an independent continuant (the bearer), in which the capability specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x capability of y holds when x is a 'capability' and y is a 'independent continuant' and x is 'inheres in' y" .

iof-constr:componentPartOfAtAllTimes a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "component part of at all times"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000137,
        iof-constr:componentPartOfAtSomeTime ;
    skos:example "transmission assembly is a component part of a car; engine control ;sparger is a component part of a bioreactor"@en-US ;
    iof-av:firstOrderLogicAxiom "componentPartOfAtAllTimes(x,y) → (MaterialEntity(x) ∧ ¬(FiatObjectPart(x))) ∧ (MaterialEntity(y) ∧ ¬(FiatObjectPart(y))) ∧ properContinuantPartOfAtAllTimes(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a material entity to another material entity that it is a proper part of at all times it exists"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x component part of at all times y holds when x is a 'material entity' that is not a 'fiat object part' and y is a 'material entity' that is not a 'fiat object part' and x is 'proper continuant part of at all times' y" .

iof-constr:componentPartOfAtSomeTime a owl:ObjectProperty ;
    rdfs:label "component part of at some time"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000175 ;
    owl:inverseOf iof-constr:hasComponentPartAtSomeTime ;
    skos:example "a particular chromatography column is a component part of a chromatography system during several purification cycles; a particular tool is a component part of a CNC machine while it is being used for manufacturing a particular part"@en-US ;
    iof-av:explanatoryNote "The IOF does not consider as component part of material entities that are delineated by a non-physical (fiat) boundary from the material entity they are a part of." ;
    iof-av:firstOrderLogicAxiom "componentPartOfAtSomeTime(x,y) → (MaterialEntity(x) ∧ ¬(FiatObjectPart(x))) ∧ (MaterialEntity(y) ∧ ¬(FiatObjectPart(y))) ∧ properContinuantPartOfAtSomeTime(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a material entity to another material entity that it is a proper part of at some time"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x component part of at some time y holds when x is a 'material entity' that is not a 'fiat object part' and y is a 'material entity' that is not a 'fiat object part' and x is 'proper continuant part of at some time' y" .

iof-constr:denotedBy a owl:ObjectProperty ;
    rdfs:label "denoted by"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:InformationContentEntity ;
    rdfs:subPropertyOf iof-constr:isSubjectOf ;
    owl:inverseOf iof-constr:denotes ;
    skos:example "one or more individuals are denoted by the name 'John'; vehicle is denoted by a 'vehicle identification number'; molecules with the structure CH3-CH2-OH is denoted by 'ethanol'"@en-US ;
    iof-av:naturalLanguageDefinition "relation from an entity to an information content entity that distinguishes the entity"@en-US .

iof-constr:describedBy a owl:ObjectProperty ;
    rdfs:label "described by"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:InformationContentEntity ;
    rdfs:subPropertyOf iof-constr:isSubjectOf ;
    owl:inverseOf iof-constr:describes ;
    skos:example "some current event is described by the content of a newspaper article; some facility visit is described by the content of a visitor's log; some accident is described by the content of an accident report"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relation from an entity to an information content entity that characterizes the entity"@en-US .

iof-constr:designatedBy a owl:InverseFunctionalProperty,
        owl:ObjectProperty ;
    rdfs:label "designated by"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:InformationContentEntity ;
    rdfs:subPropertyOf iof-constr:denotedBy ;
    owl:inverseOf iof-constr:designates ;
    skos:example "a Web Page's location on the internet is designated by an URL; an individual in USA is designated by SSN ; a particular lot of product is designated by a 'lot number'"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relation from an entity to an information content entity that uniquely distinguishes the entity from other entities"@en-US .

iof-constr:hasComponentPartAtAllTimes a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "has component part at all times"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000111,
        iof-constr:hasComponentPartAtSomeTime ;
    skos:example "car has component part a chasy; a bioractor has component part a stainless steel vessel"@en-US ;
    iof-av:firstOrderLogicAxiom "hasComponentPartAtAllTimes(x,y) → (MaterialEntity(x) ∧ ¬(FiatObjectPart(x))) ∧ (MaterialEntity(y) ∧ ¬(FiatObjectPart(y))) ∧ hasProperContinuantPartAtAllTimes(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a material entity to another material entity that it has as a proper part at all times it exists"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x has component part at all times y holds when x is a 'material entity' that is not a 'fiat object part' and y is a 'material entity' that is not a 'fiat object part' and x 'has proper continuant part at all times' y" .

iof-constr:hasDisposition a owl:ObjectProperty ;
    rdfs:label "has disposition"@en-US ;
    rdfs:domain bfo:BFO_0000004 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000016 ;
    rdfs:subPropertyOf bfo:BFO_0000196 ;
    skos:example "An atom of element X has the disposition to decay to an atom of element Y; a poorly assembled item has the disposition to break apart"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000091" ;
    iof-av:firstOrderLogicAxiom "hasDisposition(x,y) → IndependentContinuant(x) ∧ Disposition(y) ∧ bearerOf(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from an independent continuant (the bearer) to a disposition, in which the disposition specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x has disposition y holds when x is a 'independent continuant' and y is a 'disposition' and x is 'bearer of' y" .

iof-constr:hasFunction a owl:ObjectProperty ;
    rdfs:label "has function"@en-US ;
    rdfs:domain bfo:BFO_0000004 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000034 ;
    rdfs:subPropertyOf bfo:BFO_0000196 ;
    skos:example "this enzyme has function this catalysis function (more colloquially: this enzyme has this catalysis function)"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000085" ;
    iof-av:explanatoryNote "A bearer can have many functions, and its functions can exist for different periods of time, but none of its functions can exist when the bearer does not exist. A function need not be realized at all the times that the function exists."@en-US ;
    iof-av:firstOrderLogicAxiom "hasFunction(x,y) → IndependentContinuant(x) ∧ Function(y) ∧ bearerOf(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from an independent continuant (the bearer) to a function, in which the function specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x has function y holds when x is a 'independent continuant' and y is a 'function' and x is 'bearer of' y" .

iof-constr:hasSimpleExpressionValue a owl:DatatypeProperty ;
    rdfs:label "has simple expression value"@en-US ;
    rdfs:domain iof-constr:ValueExpression ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subPropertyOf owl:topDataProperty ;
    skos:example "value expression with the unit 'C' that is the value expression of temperature has simple expression value \"37\""@en-US ;
    iof-av:explanatoryNote """1. the literal represents the magnitude or a
category within a classification scheme of an entity that the value expression is the value expression of
2. The label 'simple expression' was chosen due to the possiblity of introduction of a 'complex expression' object property in the future release that would be utilized for representation of things such as mathematical formulas""" ;
    iof-av:naturalLanguageDefinition "data property that relates a value expression to a literal"@en-US .

iof-constr:isAvailableToAtSomeTime a owl:ObjectProperty ;
    rdfs:label "is available to at some time"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000029 bfo:BFO_0000040 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:Agent ;
    skos:example "a roll of aluminum (resource) is avaiable to an agent to use in a forming process, a milling workstation (resource) is available to a manufacturer to produce some parts"@en-US ;
    iof-av:explanatoryNote "this definition of 'is available to' is not the same as the state of availability e.g a machine is idle hence it is in the available state" ;
    iof-av:firstOrderLogicAxiom "isAvailableToAtSomeTime(x,y) → (MaterialEntity(x) ∨ Site(x)) ∧ Agent(y) ∧ ∃p∃o∃c(Process(p) ∧ ObjectiveSpecification(o) ∧ Capability(c) ∧ hasCapability(x,c) ∧ genericallyDependsOnAtSomeTime(o,y) ∧ (realizes(p,c) ∧ participatesInAtSomeTime(y,p)→ AchievesAtSomeTime(p,o)))" ;
    iof-av:naturalLanguageDefinition "relation from a material entity or physical location to an agent that holds when the material entity or physical location have a capability that is needed by the agent to fulfil some objective carried by the agent"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x is available at some time y holds when x is a 'material entity' or 'site' and y is an 'agent' and x 'has capability' some 'capability' which when 'realized in' some 'process' p that y 'participates in at some time' implies that p 'achieves at some time' some 'objective specification' that 'generically depends on at some time' y" .

iof-constr:isTemporallyOverlappedBy a owl:ObjectProperty ;
    rdfs:label "is temporally overlapped by"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:temporallyOverlaps ;
    skos:example "When two plates are being welded at a joint, the heating of current point being welded is temporally overlapped by the cooling of a previously welded point; the receiving process is temporally overlapped by the sending process in a transaction process; Sumerian civilization (c. 3500 BCE - c. 2000 BCE) in Mesopotamia was temporally overlapped by Ancient Egyptian civilization (c. 3000 BCE - 30 BCE)."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "isTemporallyOverlappedBy(x,y) ↔ temporallyOverlaps(y,x)" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals and processes i and j when the first instant of the temporal extent of j is earlier than and the last instant of the temporal extent of j is later than the first instant of the temporal extent of i, and the last instance of the temporal extent of j is earlier than the last instant of the temporal extent of i"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "'is temporally overlapped by' and 'temporally overlaps' are inverse relations" .

iof-constr:meets a owl:ObjectProperty ;
    rdfs:label "meets"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000063 ;
    owl:inverseOf iof-constr:metBy ;
    skos:example "When an item is placed on a moving conveyor by a robotic arm, the process of placing the item meets the process of moving the item; summer meets fall; January meets February; the Christmas holiday period meets New Year’s holiday period."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "LA1: meets(i,j) → (TemporalInterval(i) ∧ TemporalInterval(j)) ∨ (Process(i) ∧ Process(j))",
        "LA2: TemporalInterval(i) ∧ TemporalInterval(j) ∧ meets(i,j) → ∃i1∃j1(TemporalInstant(i1) ∧ TemporalInstant(j1) ∧ hasLastInstant(i,i1) ∧ hasFirstInstant(j,j1) ∧ occursSimultaneouslyWith(i1,j1))",
        "LA3: Process(i) ∧ Process(j) ∧ meets(i,j) → ∃i1∃j1(TemporalInterval(i1) ∧ TemporalInterval(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ meets(i1,j1))" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the last instant of the temporal extent of i is the same as the first instant of the temporal extent of j"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: If i 'meets' j then either both are 'temporal intervals' or both are 'process'",
        "LA2: If both i and j are 'temporal intervals' and i 'meets' j then the 'last instant of' i 'occurs simultaneously with' the 'first instant of' j",
        "LA3: If both i and j are 'process' and i 'meets' j then the 'temporal interval' that i occupies 'meets' the 'temporal interval' that j occupies" .

iof-constr:observesAtSomeTime a owl:ObjectProperty ;
    rdfs:label "observes at some time"@en-US ;
    rdfs:domain iof-constr:Agent ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    skos:example "a scientist observing a chemical reaction in an experiment, an operator observes a machining process, a doctor observes a group of COVID patients"@en-US ;
    iof-av:explanatoryNote "this property was not put under participates in at some time because the target of observation can be continuant or an occurent and in the case of an occurent an agent that observes the occurent might not participate in that occurent" ;
    iof-av:firstOrderLogicAxiom "observesAtSomeTime (x, y) → Agent(x) ∧ Entity(y) ∧ ∃p∃i(Process(p) ∧ InformationContentEntity(i) ∧ participatesInAtSomeTime(x,p) ∧ hasOutput(p,i) ∧ isAbout(i,y))" ;
    iof-av:naturalLanguageDefinition "relation from an agent to an entity indicating that the agent participates in some process that outputs information about the entity, at some time"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "b observes p at some time t when b is an 'agent' and p is an 'entity and there is a 'process' in which b 'participates in at some time' and that 'has output' some 'information content entity' that 'is about' p" .

iof-constr:occursDuring a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "occurs during"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    skos:example "The final inspection and removal of defective products occur during the product is being moved to the packaging station by a conveyor belt; a sensor measures the thickness of the wall during the sand-grinding process; turkey is traditionally served during dinners on Thanksgiving In the United States."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "LA1: occursDuring(i,j) → (TemporalInterval(i) ∧ TemporalInterval(j)) ∨ (Process(i) ∧ Process(j))",
        "LA2: TemporalInterval(i) ∧ TemporalInterval(j) ∧ occursDuring(i,j) → ∃i1∃i2∃j1∃j2(TemporalInstant(i1) ∧ TemporalInstant(i2) ∧ TemporalInstant(j1) ∧ TemporalInstant(j2) ∧ hasFirstInstant(i,i1) ∧ hasLastInstant(i,i2) ∧ hasFirstInstant(j,j1) ∧ hasLastInstant(j,j2) ∧ precedes(j1,i1) ∧ precedes(i2,j2))",
        "LA3: Process(i) ∧ Process(j) ∧ occursDuring(i,j) → ∃i1∃j1(TemporalInterval(i1) ∧ TemporalInterval(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ occursDuring(i1,j1))",
        "LA4: occursDuring(i,j) ↔ ∃k(temporallyFinishes(i,k) ∧ temporallyStarts(k,j))" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the first instant of the temporal extent of i is later than the first instant of the temporal extent of j and the last instant of the temporal extent of i is earlier than the last instant of the temporal extent of j"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: If i 'occurs during' j then either both are 'temporal intervals' or both are 'process'",
        "LA2: If both i and j are 'temporal intervals' and i 'occurs during' j' then first instant of' j ‘precedes’ the 'first instant of' i and the 'last instant of' i ‘precedes’ the 'last instant of' j",
        "LA3: If both i and j are 'process' and i 'occurs during' j then the 'temporal interval' that i occupies 'occurs during' the 'temporal interval' that j occupies",
        "LA4: i 'occurs during' j if and only if there exists k such that i temporally finishes k and k temporally starts j" .

iof-constr:processCharacteristicOf a owl:ObjectProperty ;
    rdfs:label "process characteristic of"@en-US ;
    rdfs:domain iof-constr:ProcessCharacteristic ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000015 ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    skos:example "constant production rate is the process characteristic of a product production process; temperature change of 1C/min is the process characteristic of a heating process"@en-US ;
    iof-av:naturalLanguageDefinition "relation between a characteristic and the process it is a characteristic of"@en-US .

iof-constr:qualityOf a owl:ObjectProperty ;
    rdfs:label "quality of"@en-US ;
    rdfs:domain bfo:BFO_0000019 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000004 ;
    rdfs:subPropertyOf bfo:BFO_0000197 ;
    skos:example "this red color is a quality of this apple"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000080" ;
    iof-av:firstOrderLogicAxiom "qualityOf(x,y) → Quality(x) ∧ IndependentContinuant(y) ∧ inheresIn(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a quality to an independent continuant (the bearer), in which the quality specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x disposition of y holds when x is a 'quality' and y is a 'independent continuant' and x is 'inheres in' y" .

iof-constr:recognizedByAtSomeTime a owl:ObjectProperty ;
    rdfs:label "recognized by at some time"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:Agent ;
    owl:inverseOf iof-constr:recognizesAtSomeTime ;
    skos:example "a failure event is recognized by an operator that results in information about the event such as the time of occurrence and the description about the failure; a defect on a part is recognized by a quality control engineer that results in information about the defect such as the nature of the defect and the cause of the defect"@en-US ;
    iof-av:naturalLanguageDefinition "relation from an entity to an agent that is able to describe the entity or is able to associate an information content entity that describes the entity, at some time"@en-US .

iof-constr:recognizesAtSomeTime a owl:ObjectProperty ;
    rdfs:label "recognizes at some time"@en-US ;
    rdfs:domain iof-constr:Agent ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    skos:example "operator recognizes a failure event that results in information about the event such as the time of occurrence and the description about the failure, a quality control engineer recognizes a defect on a part that results in information about the defect such as the nature of the defect and the cause of the defect"@en-US ;
    iof-av:explanatoryNote "Recognition is preceded by an observation of an entity that is related to the entity being recognized or the entity being recognized is an entity that is an attribute of the entity being observed",
        "this property was not put under participates in at some time because the target of recognition can be continuant or an occurent and in the case of an occurent an agent that recognizes the occurent might not participate in that occurent" ;
    iof-av:naturalLanguageDefinition "relation from an agent to an entity that the agent is able to describe the entity or is able to associate an information content entity that describes the entity, at some time"@en-US .

iof-constr:requirementSatisfiedBy a owl:ObjectProperty ;
    rdfs:label "requirement satisfied by"@en-US ;
    rdfs:domain iof-constr:RequirementSpecification ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    owl:inverseOf iof-constr:satisfiesRequirement ;
    skos:example "a UML requirement specification is satisfied by a a piece of software; functional requirement specification of a car is satisfied by its desgn specification"@en-US ;
    iof-av:naturalLanguageDefinition "relation from a requirement specification to an entity that conforms to the requirement specification"@en-US .

bfo:BFO_0000063 iof-av:explanatoryNote "while the scope of BFO: precedes is occurrent, for the purposes of formalization of Allen interval algebra we have added the FOL elaborations for 'time instant' 'time interval', 'process boundary' and 'process'. For the case of other occurrents the formalization already provided by BFO (https://github.com/BFO-ontology/BFO-2020/tree/master/21838-2/pdf) should be followed."@en-US ;
    iof-av:firstOrderLogicAxiom "LA1: precedes(i,j) ∧ process(i) ∧ process(j) → ∃i1∃j1 (TemporalInterval(i1)∧TemporalInterval(j1)∧occupiesTemporalRegion(i,i1)∧occupiesTemporalRegion(j,j1) ∧ precedes(i1,j1))",
        "LA2: precedes(i,j) ∧ ProcessBoundary(i) ∧ ProcessBoundary(j) → ∃i1∃j1 (TemporalInstant(i1)∧TemporalInstant(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ precedes(i1,j1))",
        "LA3: precedes(i,j) ∧TemporalInstant(i) ∧TemporalInterval(j) → ∃j1(hasFirstInstant(j,j1)∧ precedes(i,j1))",
        "LA4: precedes(i,j) ∧ TemporalInterval(i) ∧ TemporalInstant(j) → ∃i1(hasLastInstant(i,i1) ∧ precedes(i1,j))",
        "LA5: precedes (i,j) ∧TemporalInstant (i) ∧ TemporalInstant(j) → ∃k∃l(hasValueExpressionAtAllTimes(i,k) ∧ hasValueExpressionAtAllTimes(j,l) ∧ ∃v1∃v2(hasDateTimeInstantValue(k,v1) ∧ hasDateTimeInstantValue(l,v2) ∧ (v1 < v2)))",
        "LA6: precedes(i,j) ∧ TemporalInterval(i) ∧ TemporalInterval(j) → ∃i1∃j1(TemporalInstant(i1) ∧ TemporalInstant(j1) ∧ hasLastInstant(i,i1) ∧ hasFirstInstant(j,j1) ∧ (precedes(i1,j1) ∨ occursSimultaneouslyWith(i1,j1)))" ;
    iof-av:naturalLanguageDefinition "comes before (something) in time"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: If i and j are both ‘process’ and i 'precedes' j then the ‘temporal instant’ that i occupies 'precedes' ‘temporal instant’ that j occupies",
        "LA2: If i and j are both ‘process boundary’ and i 'precedes' j then the ‘temporal instant’ that i occupies 'precedes' ‘temporal instant’ that j occupies",
        "LA3: if i is ‘temporal instant’ and j is ‘temporal interval’ and i 'precedes' j then i 'precedes' the 'first instant of' j",
        "LA4: if i is ‘temporal interval’ and j is ‘temporal instant’ and i 'precedes' j then the 'last instant of' i 'precedes' j",
        "LA5: If i and j are both ‘temporal instant’ and i 'precedes' j then the 'temporal instant value expression' of i is less than the 'temporal instant value expression' of j",
        "LA6: If both i and j are 'temporal intervals' and i is 'precedes' j then the 'last instant of' i 'precedes' the 'first instant of' j or the 'last instant of' i 'occurs simultaneously with' the 'first instant of' j" .

iof-constr:Agreement a owl:Class ;
    rdfs:label "agreement"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000110 ;
            owl:someValuesFrom iof-constr:ObjectiveSpecification ],
        iof-constr:InformationContentEntity ;
    skos:example "prenuptial agreement; memorandum of understanding; non-disclosure agreement; employment agreement; purchase order that has been confirmed by the seller by e-mail; handshake agreement to buy something in the State of Florida, which happens to be legally-binding in that juristiction provided certain evidence can be produced"@en-US ;
    iof-av:adaptedFrom "FIBO https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Agreements, term by the same name" ;
    iof-av:firstOrderLogicAxiom "Agreement(x) → InformationContentEntity(x) ∧ ∃o(ObjectiveSpecification(o) ∧ hasContinuantPartAtAllTimes(x,o))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "understanding between two or more parties that contains a set of commitments on the part of the parties"@en-US ;
    iof-av:primitiveRationale "In addition to the general discussion provided for information content enty,there are insufficient constructs to create necessary and sufficient conditions. Namely, patterns surrounding commitment and party need to be established" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'agreement' then x is an 'information content entity' that 'has continuant part at all times' some 'objective specification'" .

iof-constr:Assembly a owl:Class ;
    rdfs:label "assembly"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty [ owl:inverseOf iof-constr:componentPartOfAtAllTimes ] ;
            owl:someValuesFrom iof-constr:MaterialComponent ],
        iof-constr:MaterialArtifact ;
    skos:example "powertrain assembly; partially-assembled powertrain + transmission assembly lying nearby; driveshaft assembly temporarily disassembled for repair or routine maintenance; separator assembly consisting of variously-shaped separator parts that safeguard wine bottles in a case of wine during transport; a material artifact produced entirely through additive manufacturing (provided it is a component somewhere, and can it can be disassembled without damage/destruction)."@en-US ;
    iof-av:adaptedFrom "APICS 14 ed., 2013, term by the same name; DoD Standard Practice, Identification Marking of US Military Property (MIL-STD-130N Nov. 2012) https://dodprocurementtoolbox.com/cms/sites/default/files/resources/2016-03/MIL-Std130N_Ch1_4.pdf, term by the same name" ;
    iof-av:counterExample "a portion of material; a piece of glass; a rod of aluminum; a roll of aluminum; an engine block" ;
    iof-av:explanatoryNote "Although the term is polysemous and used in a number of other domains beyond manufacturing, it is introduced here as a covering term for any man-made artifact that satisfies the conditions provided, and independent of modality. We expect various subclasses of assembly to be introduced in future along with more precise heuristics for the various modalities in which they exist." ;
    iof-av:firstOrderLogicAxiom "LA1: Assembly(x) → MaterialArtifact(x) ∧ ∃c∃c1(MaterialComponent(c) ∧ MaterialComponent(c1) ∧ componentPartOfAtAllTimes(c,x) ∧ componentPartOfAtAllTimes(c1,x) ∧ ¬(c=c1 ∨ (componentPartOfAtAllTimes(c,c1) ∨ componentPartOfAtAllTimes(c1,c))))",
        "LA2: MaterialArtifact(x) ∧ ∃p(AssemblyProcess(p) ∧ isSpecifiedOutputOf(x,p)) → Assembly(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "material artifact that is composed of material components that are physically connected and that is capable of disassembly"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs in the ontology to provide necessary and sufficient conditions. Namely, 'disassembly capability' is missing." ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: if x is an 'assembly' then x is a 'material artifact' and there are at least two distinct 'material component' that are 'component part of at all times' x",
        "LA2: Material Artifact x that 'is specified output of' some Assembly Process p implies x is an Assembly" ;
    iof-av:usageNote "Every assembly has a plurality of material components. While this is captured in the FOL, due to reasoning limitations with cardinality restrictions and complex properties, the OWL axiom uses 'some' instead of min 2. Hence, this class should be modeled as having at least two material components on the instance level." .

iof-constr:BusinessFunction a owl:Class ;
    rdfs:label "business function"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:allValuesFrom iof-constr:BusinessProcess ;
            owl:onProperty bfo:BFO_0000054 ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:functionOf ;
            owl:someValuesFrom iof-constr:Organization ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:prescribedBy ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( iof-constr:ObjectiveSpecification [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000084 ;
                                owl:someValuesFrom iof-constr:Organization ] ) ] ],
        bfo:BFO_0000034 ;
    skos:example "Pfizer has the business function to produce medicines; Airbus has the business function of manufacturing planes"@en-US ;
    iof-av:adaptedFrom "https://en.wikipedia.org/wiki/Business_purpose" ;
    iof-av:counterExample "any function of a non-profit organization" ;
    iof-av:firstOrderLogicAxiom "LA1: BusinessFunction(x) → Function(x) ∧ ∃o∃i(Organization(o) ∧ ObjectiveSpecification(i) ∧ functionOf(x,o) ∧ genericallyDependsOnAtSomeTime(i,o) ∧ prescribedBy(x,i)) ∧ ∀y(hasRealization(x,y) → BusinessProcess(y))",
        "LA2: Function(x) ∧ ∃o∃i∃p(Organization(o) ∧ ObjectiveSpecification(i) ∧ BusinessProcess(p) ∧ functionOf(x,o) ∧ genericallyDependsOnAtSomeTime(i,o) ∧ prescribedBy(x,i) ∧ hasRealization(x,p)) → BusinessFunction(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "function of an organization to partake in for profit activities as prescribed by the objectives specified by that organization"@en-US ;
    iof-av:primitiveRationale "As a function will come into its existance prior to its realization in given business processes necessary and sufficient conditions can not be created at this point due to a lack of patterns to express process types regardless of the time of their existence" ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: if x is a 'business function' then x is a 'function' that is 'function of' some 'organization' and that is 'prescribed by' some 'objective specification' and whenever x 'has realization' y that y must be a 'business process'",
        "LA2: if x is a 'function' that is 'function of' some 'organization' and that is 'prescribed by' some 'objective specification' and that 'has realization' some 'business process' then x is a 'business function'" .

iof-constr:BusinessOrganization a owl:Class ;
    rdfs:label "business organization"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Organization ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:Organization [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000196 ;
                        owl:someValuesFrom iof-constr:BusinessFunction ] ) ] ;
    skos:example "Mercedes-Benz, Deloitte, Pfizer, Airbus"@en-US ;
    iof-av:adaptedFrom "https://en.wikipedia.org/wiki/Business" ;
    iof-av:explanatoryNote "Business entities are formally organized according to the laws prevailing in the locales and countries in which it operates or conducts business, and include companies, corporations, partnerships, or sole proprietorships." ;
    iof-av:firstOrderLogicDefinition "BusinessOrganization(x) ↔ Organization(x) ∧ ∃f(BusinessFunction(f) ∧ hasFunction(x,f))" ;
    iof-av:naturalLanguageDefinition "organization engaging in or planning to engage in any activity of buying and selling goods or services for a profit"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of a business organization' is defined as exactly an instance of 'organization' that 'has function' some 'business function'" .

iof-constr:BuyerRole a owl:Class ;
    rdfs:label "buyer role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( [ a owl:Class ;
                                owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000056 ;
                                owl:someValuesFrom iof-constr:BuyingBusinessProcess ] ) ] ],
        iof-constr:AgentRole ;
    skos:example "Pfizer has a buyer role when it buys a bulk of chemicals from MiliporeSigma; a person has a buyer role when they buy groceries at the supermarket; a manufacturing enterprise has a buyer role when they hire an external organization to do some manufacturing process (manufacturing as a service); a person has a buyer role when they hire someone to repair a broken pipe"@en-US ;
    iof-av:adaptedFrom "OAGIS" ;
    iof-av:firstOrderLogicAxiom "BuyerRole(x) → Role(x) ∧ ∃y∃p ((Organization(y) ∨ Person(y)) ∧ BuyingBusinessProcess(p) ∧ participatesInAtSomeTime(y,p) ∧ roleOf(x, y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "agent role held by a person or organization when it buys a product or a service"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for economic transactions and ownership are lacking" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'buyer role' x then x is an 'agent role' that is the 'role of' some 'person' or 'organization' when it 'participates in at some time' some 'buying business process'" .

iof-constr:CommercialServiceSpecification a owl:Class ;
    rdfs:label "commercial service specification"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:PlanSpecification ;
    skos:example "protocol on how maintenance will be conducted on airplanes that is a part of the agreement between Frankfurt Airport and various airlines"@en-US ;
    iof-av:adaptedFrom "https://schema.org/, http://www.heppnetz.de/projects/goodrelations/ and http://dini-ag-kim.github.io/service-ontology/service.html" ;
    iof-av:firstOrderLogicAxiom "PlanSpecification(x) ∧ ∃c(CommercialService(c) ∧ prescribes(x,c)) → CommercialServiceSpecification(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "plan specification that prescribes a commercial service"@en-US ;
    iof-av:primitiveRationale "See the general discussion and rationale provided for informational entities under 'information content entity'." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'plan specification' that 'prescribes' some 'commercial service' then x is a 'commercial service specification'" .

iof-constr:CustomerRole a owl:Class ;
    rdfs:label "customer role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] ],
        iof-constr:AgentRole ;
    skos:example "GE aviation subsidiary and GE Transportation subsidiary have the customer role when they utilize the steel bought for them by the GE Conglomerate; a person has a customer role when they utilize a lap top that they bought from Target; a person has a customer role when they subscribe for a phone plan"@en-US ;
    iof-av:adaptedFrom "OAGIS" ;
    iof-av:firstOrderLogicAxiom "CustomerRole(x) → AgentRole(x) ∧ ∃y((Person(y) ∨ Organization(y)) ∧ roleOf(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "agent role held by a person or organization when it utilizes the product or receives the service or subscribes to the commercial service agreement"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for 'utilizing the product' and 'subscribing to an agreement' need to be formalized." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'customer role' then x is an 'agent role' that is the 'role of' a 'person' or 'organization'" .

iof-constr:DesignedFunction a owl:Class ;
    rdfs:label "designed function"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000034 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000034 [ a owl:Restriction ;
                        owl:onProperty iof-constr:prescribedBy ;
                        owl:someValuesFrom iof-constr:DesignSpecification ] ) ] ;
    skos:example "the function of a oil pump to pump oil, the function of a knife to cut things" ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/ArtifactOntology"@en-US ;
    iof-av:firstOrderLogicDefinition "ArtifactFunction(x) ↔ Function(x) ∧ ∃d(DesignSpecification(m)∧ prescribedBy(x,d))" ;
    iof-av:naturalLanguageDefinition "function that is intentionally designed"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'designed function' is exactly an instance of 'function' that is 'prescribed by' some 'design specification'" .

iof-constr:MeasurementProcess a owl:Class ;
    rdfs:label "measurement process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( [ a owl:Class ;
                                owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                                            owl:onProperty iof-constr:hasCapability ;
                                            owl:someValuesFrom iof-constr:MeasurementCapability ] ) ] [ a owl:Restriction ;
                                owl:onProperty iof-constr:measuresAtSomeTime ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:unionOf ( bfo:BFO_0000008 bfo:BFO_0000020 iof-constr:ProcessCharacteristic ) ] ] ) ] ],
        [ a owl:Restriction ;
            owl:allValuesFrom iof-constr:MeasurementInformationContentEntity ;
            owl:onProperty iof-constr:hasSpecifiedOutput ],
        iof-constr:PlannedProcess ;
    skos:example "measuring the pH of a buffer by a pH probe; measuring of a weight of a bulk of a substance by an industrial scale; measuring the rate of an enzymatic reaction by a spectrophotometer; measuring the time it takes to produce a unit of a product"@en-US ;
    iof-av:adaptedFrom "ISO 9000:2015(en), 3.11.5" ;
    iof-av:explanatoryNote """1. Determining the value here is to be interpreted in the context of qualitative, semi-quantitative, and quantitative measurements. As such, it comprehends both categorical and numerical measurements.
2. Typically, the results of measurements are recorded and stored as a measurement information content entity.
3. Measurement processes can have as temporal or occurrent parts other measurement processes as well data transformation processes which transform the raw measurement data.
4. The entity whose attribute is measured might either participate in the process if it is a continuant or occupy a temporal interval that precedes or partially coincides with the measurement process if it is an occurrent.
5. The material entity measuring the attribute must be capable of measuring that attribute. This is axiomatically captured by mandating that the material entity that is measuring the attribute must have a measurement capability.""" ;
    iof-av:firstOrderLogicAxiom "MeasurementProcess ↔ PlannedProcess(x) ∧ ∃m∃y∃z∃c(MaterialEntity(m) ∧ MeasurementCapability(c) ∧ hasCapability(m,c) ∧ (((IndependentContinuant(y) ∧ ¬(SpatialRegion(y))) ∧ SpecificallyDependentContinuant(z) ∧ bearerOf(y,z) ∧ participatesInAtSomeTime(y,x)) ∨ (Process(y) ∨ ProcessBoundary(y) ∧ TemporalRegion(z) ∧ occupiesTemporalRegion(y,z) ∧ ∃t(temporalRegion(t) ∧ occupiesTemporalRegion(x,t) ∧ (occurrentPartOf(t,z) ∨ hasOccurrentPart(t,z)))) ∨ (Process(y) ∧ ProcessCharacteristic(z) ∧ processCharacteristicOf(z,y) ∧ (preceedes(y,x) ∨ ∃t1∃t2(temporalRegion(t1) ∧ temporalRegion(t2) ∧ occupiesTemporalRegion(x,t1) ∧ occupiesTemporalRegion(y,t2) ∧ (occurrentPartOf(t1,t2) ∨ hasOccurrentPart(t1,t2)))))) ∧ measuresAtSomeTime(m,z)) ∧ ∀b(hasSpecifiedOutput(x,b) → MeasurementInformationContentEntity(b))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "planned process to determine the value of an attribute (specifically dependent continuant or temporal region or process characteristic) of an entity of interest"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, n-ary constructs that are able to adequately capture the relation between the process, attribute and the entity of interest are still lacking. Also formalization of being an entity of interest is lacking." ;
    iof-av:semiFormalNaturalLanguageAxiom """if x is a 'measurement process' then x is a 'planned process' that 'has participant at some time' some 'material entity' y that 'has measurement capability' and y 'measures at some time' either
1) 'process characteristic' that is 'process characteristic of' a 'process' that 'preceedes' or (partially or fully) temporally coincides with x) or
2)'specifically dependent continuant' that 'inheres in' an 'independent continuant' (that is not a 'spatial region') which 'participates in at some time' x or
3) 'temporal region' that is temporally occupied by some 'process' or 'process boundary' and that 'has occurrent part' or 'occurent part of' a 'temporal region' temporally occupied by x
and whenever x 'has specified output' b that b must be a 'measurement information content entity'""" .

iof-constr:OrganizedGroupOfAgents a owl:Class ;
    rdfs:label "organized group of agents"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:GroupOfAgents ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:GroupOfAgents [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000196 ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:intersectionOf ( bfo:BFO_0000034 [ a owl:Restriction ;
                                            owl:onProperty iof-constr:prescribedBy ;
                                            owl:someValuesFrom iof-constr:DirectiveInformationContentEntity ] ) ] ] ) ] ;
    skos:example "goverment, division, an automated manufacturing cell"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/AgentOntology" ;
    iof-av:firstOrderLogicDefinition "OrganizedGroupOfAgents(x) ↔ ObjectAggregate(x) ∧ ∃i∃f(DirectiveInformationContentEntity(i) ∧ Function(f) ∧ bearerOf(x, f) ∧ prescribes(i, f))" ;
    iof-av:naturalLanguageDefinition "group of agents that is pursuing a common set of plans and objectives"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'organized group of agents' is defined as exactly an instance of 'group of agents' that is the 'bearer of' some 'function' which is 'prescribed by' some 'directive information content entity'" .

iof-constr:ServiceProviderRole a owl:Class ;
    rdfs:label "service provider role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( [ a owl:Class ;
                                owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000056 ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:unionOf ( iof-constr:CommercialService [ a owl:Class ;
                                                    owl:intersectionOf ( iof-constr:SellingBusinessProcess [ a owl:Restriction ;
                                                                owl:onProperty bfo:BFO_0000057 ;
                                                                owl:someValuesFrom iof-constr:CommercialServiceAgreement ] ) ] ) ] ] ) ] ],
        iof-constr:SupplierRole ;
    skos:example "FedEx; Home-cleaning service; aircraft maintenance service; internet service provider"@en-US ;
    iof-av:adaptedFrom "https://en.wikipedia.org/wiki/Service_provider" ;
    iof-av:firstOrderLogicAxiom "ServiceProviderRole(x) → AgentRole(x) ∧ ∃y∃p((Organization(y) ∨ Person(y)) ∧ (CommercialService(p) ∨ (OfferingForSaleBusinessProcess(p) ∧ ∃c(CommercialServiceAgreement(c) ∧ hasParticipantAtSomeTime(p,c)))) ∧ participatesInAtSomeTime(y,p) ∧ roleOf(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "supplier role held by a person or organization when it offers to sell or provide a commercial service"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for economic transactions and ownership are lacking" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'service provider role' then x is an 'agent role' that is the 'role of' some 'person' or 'organization' that 'participates in at some time' some 'commercial service' or some 'offering for sale business process' which 'has participant at some time' some 'commercial service agreement'" .

iof-constr:SupplierRole a owl:Class ;
    rdfs:label "supplier role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( [ a owl:Class ;
                                owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000056 ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:unionOf ( iof-constr:SellingBusinessProcess iof-constr:SupplyingBusinessProcess ) ] ] ) ] ],
        iof-constr:AgentRole ;
    skos:example "logistics service provider; vending machine; the material handling department (which manages the raw material and finished goods in company warehouses, and provides material handling services to manufacturing and other departments within its factories)"@en-US ;
    iof-av:adaptedFrom "APICS, term by the same name and Oxford Languages, term by the name ‘vendor’" ;
    iof-av:firstOrderLogicAxiom "SupplierRole(x) → Role(x) ∧ ∃y∃p((Organization(y) ∨ Person(y)) ∧ (SupplyingBusinessProcess(p) ∨ OfferingForSaleBusinessProcess(p)) ∧ participatesInAtSomeTime(y,p) ∧ roleOf(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "agent role held by a person or organization when it offers to sell or provide products or services"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for economic transactions and ownership are lacking." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'supplier role' x then x is an 'agent role' that is the 'role of' some 'person' or 'organization' when it 'participates in at some time' some 'supplying business process' or 'offering for sale business process'" .

iof-constr:System a owl:Class ;
    rdfs:label "system"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000027 ;
    skos:example "solar system, digestive system, forest ecosystem, hydraulic system, subway system, social system, technical system, natural system"@en-US ;
    iof-av:adaptedFrom "Merriam-Webster Dictionary for term under the same name." ;
    iof-av:explanatoryNote """1. As introduced here, the term is limited to natural, social and technical systems that are tangible and whose "elements" are also tangible.

2. Frequently, the elements comprising a system are instances of BFO: object. However, the system elements may also include object aggregates (e.g., a system of systems; a system that includes a production line consisting of humans, machines, and other equipment)

3. Although the system is asserted under BFO: object aggregate, which is constrained to have only material entities (tangible things) as elements, the approach to modeling systems comprised of both software and hardware (also known as a cyber-physical system) can still be modeled indirectly: by introducing a 'generically depends on' relationship between the software or other intangible elements (information content entity types) and its physical bearer (hardware or hardware system), which are in turn members of the system.""" ;
    iof-av:firstOrderLogicAxiom "System(x) → ObjectAggregate(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "collection of elements (object aggregate) that form a unified whole and interact"@en-US ;
    iof-av:primitiveRationale "The term is introduced here as a general class to allow the introduction of specialized kinds of systems that appear in particular modalities. Furthermore, an effort remains to formalize what it means for two things to interact, or what it means to regularly interact." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'system' then x is an 'object aggregate'" .

iof-constr:TemporalInstantValueExpression a owl:Class ;
    rdfs:label "temporal instant value expression"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:ValueExpression ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:ValueExpression [ a owl:Restriction ;
                        owl:onProperty iof-constr:isValueExpressionOfAtAllTimes ;
                        owl:someValuesFrom bfo:BFO_0000203 ] ) ] ;
    skos:example "The time instant at which a train arrives at a station has its clock time expressed by a temporal instant value expression."@en-US ;
    iof-av:explanatoryNote "1. This class was introduced as a helper class to map OWL time to IOF Core. For detailed expression of date and time in a specific calendar system, use a suitable subclass of TemporalPosition class from Time ontology (https://www.w3.org/TR/owl-time/) instead of ‘temporal instant value expression’ (see mapping file https://spec.industrialontologies.org/ontology/core/commonstocoremapping/MappingOWLTimeToIOF/)"@en-US ;
    iof-av:firstOrderLogicDefinition "TemporalInstantValueExpression(x) ↔ ValueExpression(x) ∧ ∃y(TemporalInstant(y) ∧ isValueExpressionOfAtAllTimes(x,y))" ;
    iof-av:naturalLanguageDefinition "value expression that describes the position of a time instant in the time line"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'temporal instant value expression' is defined exactly as an instance of 'value expression' that 'is value expression of at all times' some 'temporal instant'" .

iof-constr:actsOnBehalfOfAtSomeTime a owl:ObjectProperty ;
    rdfs:label "acts on behalf of at some time"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( iof-constr:EngineeredSystem iof-constr:GroupOfAgents iof-constr:Person ) ] ;
    skos:example "An agent acts on behalf of a business organization. A laywer acts on behalf of a person."@en-US ;
    iof-av:firstOrderLogicAxiom "actsOnBehalfOfAtSomeTime(x,y) → (MaterialEntity(x) ∧ ¬(FiatObjectPart(x))) ∧ (Person(y) ∨ GroupOfAgents(y) ∨ EngineeredSystem(y)) ∧ ∃p∃d(PlannedProcess(p) ∧ ObjectiveSpecification(d) ∧ participatesInAtSomeTime(x,p) ∧achievesAtSomeTime(p,d) ∧ genericallyDependsOnAtSomeTime(d,y))" ;
    iof-av:naturalLanguageDefinition "relation from a material entity to a person or a group of agents or engineered system that holds when the material entity participates in some planned process in order to fulfill an objective for the person or group of agents or engineered system"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x acts on behalf of at some time y holds when x is a 'material entity' (that is not a 'fiat object part') and y is some 'person' or 'group of agents' or 'engineered system' and at some time t, there exists a 'planned process' p such that x 'participates in' p and p 'achieves at some time' some 'objective specification' d that 'generically depends on at some time' y" .

iof-constr:denotes a owl:ObjectProperty ;
    rdfs:label "denotes"@en-US ;
    rdfs:domain iof-constr:InformationContentEntity ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf iof-constr:isAbout ;
    skos:example "the name 'John' denotes one or more individuals that have that name; 'vehicle identification number' denotes a vehicle; 'ethanol' is a name given by IUPAC which denotes molecules with the structure CH3-CH2-OH"@en-US ;
    iof-av:explanatoryNote "The distinguishment implied by denotes is not necessarily unique, which is why this property is not made functional. For example, a name can, at one point, 'denote' multiple individuals." ;
    iof-av:naturalLanguageDefinition "relation from an information content entity to an entity that the information content entity distinguishes"@en-US .

iof-constr:hasCapability a owl:ObjectProperty ;
    rdfs:label "has capability"@en-US ;
    rdfs:domain bfo:BFO_0000004 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:Capability ;
    rdfs:subPropertyOf bfo:BFO_0000196 ;
    skos:example "a lathe has a capability to turn at the maximal speed of 4000RPM; temperature sensor has the capability to measure temperature with a 0.01C precision; pH meter has the capability to measure pH in the range of 0-14"@en-US ;
    iof-av:firstOrderLogicAxiom "hasCapability(x,y) → IndependentContinuant(x) ∧ Capability(y) ∧ bearerOf(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from an independent continuant (the bearer) to a capability, in which the capability specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x has capability y holds when x is a 'independent continuant' and y is a 'capability' and x is 'bearer of' y" .

iof-constr:hasComponentPartAtSomeTime a owl:ObjectProperty ;
    rdfs:label "has component part at some time"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                        owl:complementOf bfo:BFO_0000024 ] ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000174 ;
    skos:example "a particular chromatography column is a component part of a chromatography system has a component part a particular chromatography column during several purification cycles; a CNC machine has component part a particular tool while it is being used for manufacturing a particular part"@en-US ;
    iof-av:firstOrderLogicAxiom "hasComponentPartAtSomeTime(y,x) → (MaterialEntity(x) ∧ ¬(FiatObjectPart(x))) ∧ (MaterialEntity(y) ∧ ¬(FiatObjectPart(y))) ∧ properContinuantPartOfAtSomeTime(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a material entity to another material entity that it has as a proper part at some time"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "y has component part at some time x holds when x is a 'material entity' that is not a 'fiat object part' and y is a 'material entity' that is not a 'fiat object part' and x is 'proper continuant part of at some time' y" .

iof-constr:hasOutput a owl:ObjectProperty ;
    rdfs:label "has output"@en-US ;
    rdfs:domain bfo:BFO_0000015 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000002 ;
    rdfs:subPropertyOf bfo:BFO_0000057 ;
    owl:inverseOf iof-constr:isOutputOf ;
    skos:example "chemical manufacturing process has output a wastestream; toluene manufacturing process has output a certain quantity of toluene; car manufacturing process has output a car"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/ExtendedRelationOntology"^^xsd:anyURI ;
    iof-av:explanatoryNote "By introducing the condition that it must exist at the end of the process materials that only transitively exist during the process (e.g., reaction intermediary) are excluded from being considered the output." ;
    iof-av:naturalLanguageDefinition "relation from a process to someone or something physical or digital (continuant) that participates in the process such that it is generated or modified during the process, and that it exists at the end of the process"@en-US .

iof-constr:hasValueExpressionAtSomeTime a owl:ObjectProperty ;
    rdfs:label "has value expression at some time"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:ValueExpression ;
    rdfs:subPropertyOf iof-constr:describedBy ;
    owl:inverseOf iof-constr:isValueExpressionOfAtSomeTime ;
    skos:example "the diameter of a screw head has value expression 1cm that is specified in its design; a bioreactor has value expression 37C that was measured during the production process; \"low risk\" is the value expression of a process parameter \"low risk\" that is based on the risk analysis classification scheme; an antibody has value expression 3 g/l that was generated by a process simulation"@en-US ;
    iof-av:explanatoryNote "determined in this context can be interpreted as either being simulated or being measured" ;
    iof-av:naturalLanguageDefinition "relation from an entity to a value expression that contains the value of the entity determined or set at some time t"@en-US .

iof-constr:isAchievedByAtSomeTime a owl:ObjectProperty ;
    rdfs:label "is achieved by at some time"@en-US ;
    rdfs:domain iof-constr:InformationContentEntity ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000015 ;
    rdfs:subPropertyOf bfo:BFO_0000058 ;
    skos:example "The company plan of satisfying a surge in demand for its products is achieved by the staffing and ramping up of production to 2 shifts per work day."@en-US ;
    iof-av:firstOrderLogicAxiom "isAchievedByAtSomeTime(y,x) → Process(x) ∧ InformationContentEntity(y) ∧ (concretizesAtSomeTime(x,y) ∨ ∃z(continuantPartOf(z,y) ∧ InformationContentEntity(z) ∧ concretizesAtSomeTime(x,z)))" ;
    iof-av:naturalLanguageDefinition "relation from an information content entity to a process that partially or fully concretizes the information content entity"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "y is achieved by at some time x holds when x is a 'process' and y is an 'information content entity' and x 'concretizes' y or a 'continuant part of' y, at some time t" .

iof-constr:isInputOf a owl:ObjectProperty ;
    rdfs:label "is input of"@en-US ;
    rdfs:domain bfo:BFO_0000002 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000015 ;
    rdfs:subPropertyOf bfo:BFO_0000056 ;
    skos:example "a dataset is an input of a machine learning execution process; growth medium is an input of a fermentation process; metal powder is an input of an additive manufacturing process;"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/ExtendedRelationOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relates someone or something physical or digital (continuant) to a process that it is a necessary precondition for the process to start"@en-US .

iof-constr:isMeasuredValueOfAtSomeTime a owl:ObjectProperty ;
    rdfs:label "is measured value of at some time"@en-US ;
    rdfs:domain iof-constr:ValueExpression ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf iof-constr:isValueExpressionOfAtSomeTime ;
    skos:example "'80kg' is the measured weight of a particular male human"@en-US ;
    iof-av:naturalLanguageDefinition "relation from a value expression to the entity indicating that the value expression contains the value of the entity measured at some time t"@en-US .

iof-constr:isSpecifiedOutputOf a owl:ObjectProperty ;
    rdfs:label "is specified output of"@en-US ;
    rdfs:domain bfo:BFO_0000002 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:PlannedProcess ;
    rdfs:subPropertyOf iof-constr:isOutputOf ;
    skos:example "antibody solution of 99.999% purity is the specified output of a biopharmaceutical production process; prediction of part porosity is a specified output of a simulation execution; temperature measurement result is the specified output of a temperature measurement process; a car is the specified output of a car manufacturing process"@en-US ;
    iof-av:firstOrderLogicAxiom "isSpecifiedOutputOf(y,x) → PlannedProcess(x) ∧ Continuant(y) ∧ ∃o(ObjectiveSpecification(o) ∧ prescribes(o,y) ∧ achievesAtSomeTime(x,o) ∧ hasOutput(x,y))" ;
    iof-av:naturalLanguageDefinition "relation from someone or something physical or digital (continuant) to a planned process in which it is produced or modified as prescribed by some objective"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "y 'has specified output' x holds when x is a 'planned process' and y is a 'continuant' and x 'has output' y and y is 'prescribed by' some 'objective specification' which x 'achieves at some time'" ;
    iof-av:synonym "is intended output of"@en-US .

iof-constr:measuresAtSomeTime a owl:ObjectProperty ;
    rdfs:label "measures at some time"@en-US ;
    rdfs:domain bfo:BFO_0000040 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    skos:example "a tempearture sensor measures the temperature within a production vessel at certain points in time during the chemical production process; a scale measures the weight of a material bulk"@en-US ;
    iof-av:explanatoryNote "In this context, value is always determined relative to some classification scheme or on a quantitative scale" ;
    iof-av:naturalLanguageDefinition "relation from a material entity to an entity indicating that the measurement capability of the material entity got realized to determine the value of the entity, at some time"@en-US .

iof-constr:metBy a owl:ObjectProperty ;
    rdfs:label "met by"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf bfo:BFO_0000062 ;
    skos:example "When an item is placed on a moving conveyor by a robotic arm, the process of moving of the item is met by the process of placing the item; fall is met by summer; February is met by January; the New Year’s holiday period is met by the Christmas holiday period."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "metBy(x,y) ↔ meets(y,x)" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the last instant of the temporal extent of j is the same as the first instant of the temporal extent of i"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "'met by' and 'meets' are inverse relations" .

iof-constr:satisfiesRequirement a owl:ObjectProperty ;
    rdfs:label "satisfies requirement"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:RequirementSpecification ;
    skos:example "a piece of software satisfies a UML requirement specification, a design specification of a car satisfies its functional requirement specification"@en-US ;
    iof-av:naturalLanguageDefinition "relation from an entity to a requirement specification that the entity conforms to"@en-US .

iof-constr:temporallyFinishes a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "temporally finishes"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    skos:example "The generation of “proof of delivery” temporally finishes the delivery process; Referee’s final whistle temporally finishes the football match; Sunday temporally finishes the week."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "LA1: temporallyFinishes(i,j) → (TemporalInterval(i) ∧ TemporalInterval(j)) ∨ (Process(i) ∧ Process(j))",
        "LA2: TemporalInterval(i) ∧ TemporalInterval(j) ∧ temporallyFinishes(i,j) → ∃i1∃i2∃j1∃j2(TemporalInstant(i1) ∧ TemporalInstant(i2) ∧ TemporalInstant(j1) ∧ TemporalInstant(j2) ∧ hasFirstInstant(i,i1) ∧ hasLastInstant(i,i2) ∧ hasFirstInstant(j,j1) ∧ hasLastInstant(j,j2) ∧ occursSimultaneouslyWith(i2,j2) ∧ precedes(j1,i1))",
        "LA3: Process(i) ∧ Process(j) ∧ temporallyFinishes(i,j) → ∃i1∃j1(TemporalInterval(i1) ∧ TemporalInterval(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ temporallyFinishes(i1,j1))",
        "LA4: temporallyFinishes(i,j) ↔ ∃k∃l(meets(i,k)∧meets(j,k) ∧ before(l,i) ∧ meets(l,j))" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the last instant of the temporal extent of i is the same as the last instant of the temporal extent of j and the first instant of j is precedes the first instant of i"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: If i 'temporally finishes' j then either both are 'temporal intervals' or both are 'process'",
        "LA2: If both i and j are 'temporal intervals' and i 'temporally finishes' j then the 'last instant’ of i ‘occurs simultaneously with’ the 'last instant of' j and the 'first instant of' j 'precedes' the 'first instant’ of i",
        "LA3: If both i and j are 'process' and i 'temporally finishes' j then the 'temporal interval' that i occupies 'temporally finishes' the 'temporal interval' that j occupies",
        "LA4: i 'temporally finishes' j if and only if there exists k such that i 'meets' k and j 'meets' k, and there exists l that is 'before' i and 'meets' j" .

iof-constr:temporallyStarts a owl:ObjectProperty,
        owl:TransitiveProperty ;
    rdfs:label "temporally starts"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    skos:example "the process of cranking temporally starts (the running of) an internal combustion engine; the pressing of a switch temporally starts (the running of) some machine; the New Year’s Day temporally starts a year."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "LA1: temporallyStarts(i,j) → (TemporalInterval(i) ∧ TemporalInterval(j)) ∨ (Process(i) ∧ Process(j))",
        "LA2: TemporalInterval(i) ∧ TemporalInterval(j) ∧ temporallyStarts(i,j) → ∃i1∃i2∃j1∃j2(TemporalInstant(i1) ∧ TemporalInstant(i2) ∧ TemporalInstant(j1) ∧ TemporalInstant(j2) ∧ hasFirstInstant(i,i1) ∧ hasLastInstant(i,i2) ∧ hasFirstInstant(j,j1) ∧ hasLastInstant(j,j2) ∧ occursSimultaneouslyWith(i1,j1) ∧ precedes(i2,j2))",
        "LA3: Process(i) ∧ Process(j) ∧ temporallyStarts(i,j) → ∃i1∃j1(TemporalInterval(i1) ∧ TemporalInterval(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ temporallyStarts(i1,j1))",
        "LA4: temporallyStarts(i,j) ↔ ∃k∃l(meets(k,i) ∧ meets(k,j) ∧ before(i,l) ∧ meets(j,l))" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals or processes i and j when the first instant of the temporal extent of i is the same as first the instant of the temporal extent of j and the last instant of i precedes the last instant of j"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: If i 'temporally starts' j then either both are 'temporal intervals' or both are 'process'",
        "LA2: If both i and j are 'temporal intervals' and i 'temporally starts' j then the 'first instant’ of i ‘occurs simultaneously with’ the 'first instant of' j and the 'last instant of' i 'precedes' the 'last instant of' j",
        "LA3: If both i and j are 'process' and i 'temporally starts' j then the 'temporal interval' that i occupies 'temporally starts' the 'temporal interval' that j occupies",
        "LA4: i 'temporally starts' j if and only if there exists k that 'meets' i and j and there exists l such that i is 'before' l and j 'meets' l" .

iof-constr:ActionSpecification a owl:Class ;
    rdfs:label "action specification"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    skos:example "pour the contents of flask 1 into flask 2; to loosen a screw with a screwdriver, grab the screw driver with your hand, insert the tip into the head of the screw, apply forward pressure into the screwdriver, and rotate the screwdriver counterclockwise."@en-US ;
    iof-av:adaptedFrom "Information Artifact Ontology, http://purl.obolibrary.org/obo/IAO_0000030 and also the Common Core Ontology, http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology (term Action Regulation)" ;
    iof-av:explanatoryNote """1. An action specification is typically a part of some plan specification.

2. All actions change the universe in some fashion. That is, they have outcomes, whether desired ones or not. Since desired outcomes are reasons for the existence of an action specification, we might argue that all action specifications are, in fact, plan specifications, with desired outcomes as objectives. However, our intent here is to capture instances of action specifications wherein objectives or desired outcomes are not explicitly stated and to delinate 'plan specifications' as cases where the objectives and the corresponding actions are explicitly stated. This is why the class is asserted directly under the information content entity.

3. Although not formalized at this stage, an action specification may prescribe a kind of process in more detail by prescribing the sequence of actions one or more participants are to do or by prescribing the actions persons bearing various roles are to do in bringing about the process. The latter would be relevant in situations where a particular participant bears two (or even more roles) in a process. An example of the latter would be a particular shop floor worker bearing and realizing both the role of the operator and that of the inspector as prescribed by some action specification and as realized in today's occurrences of some punch-press process.

4.  Action specification can be used together with plan specification to create a hierarchy of work instruction composition.""" ;
    iof-av:firstOrderLogicAxiom "InformationContentEntity(x) ∧ ∃p(Process(p) ∧ prescribes(x,p)) → ActionSpecification(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that prescribes what participants shall do in a process"@en-US ;
    iof-av:primitiveRationale "See the rationale provided under information content entity for informational entity types." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'information content entity' that 'prescribes' some 'process' then x is an 'action specification'" ;
    iof-av:synonym "actionable work instruction"@en-US .

iof-constr:Algorithm a owl:Class ;
    rdfs:label "algorithm"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    skos:example "pseudo code for sorting data, flowchart for automatic control of a process"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/IAO_0000064 and http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology" ;
    iof-av:counterExample "executable code, source code" ;
    iof-av:explanatoryNote """1. to translate in this context means to implement the algorithm such that it is readily executable
2. algorithms in this context should be interpreted as implementation-independent (language-neutral) representations and are typically represented as pseudo-code or a flowchart
3. declarative steps should be interpreted in the context of declarative programming""" ;
    iof-av:firstOrderLogicAxiom "InformationContentEntity(x) ∧ ∃y(EncodedAlgorithm(y) ∧ prescribes(x,y)) → Algorithm(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that prescribes procedural or declarative steps which can be translated to computer interpretable instructions"@en-US ;
    iof-av:primitiveRationale "See the general discussion and rationale provided under information content entity." ;
    iof-av:semiFormalNaturalLanguageAxiom "If x is an 'information content entity' that 'prescribes' some 'encoded algorithm' then x is an instance of 'algorithm'" .

iof-constr:DesignSpecification a owl:Class ;
    rdfs:label "design specification"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:allValuesFrom bfo:BFO_0000002 ;
            owl:onProperty iof-constr:prescribes ],
        iof-constr:InformationContentEntity ;
    skos:example "document specifying the characteristics of a pharmaceutical product; the design of a software program to schedule the work orders in a factory"@en-US ;
    iof-av:adaptedFrom "http://en.wikipedia.org/wiki/Design and from http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology, term under the name 'artifact design'" ;
    iof-av:counterExample "process design" ;
    iof-av:explanatoryNote """1. Design specification may be a model or a textual or graphical specification.

2. This class is not intended to be used to represent the design of planned processes. For this purpose, plan specification should be used.

3. Something 'man-made' comprehends those physical and non-physical things that are intentionally created by human beings. Hence the thing specified by a design specification may be either BFO:GDC or BFO:Material Entity.

4. A design specification specifies what the thing should be, such as its shape, size, tolerance, and performance but not necessarily how the thing should be made. If it contains information on how a thing should be made, this should be modeled separately through a 'plan specification' that is 'part of' the design specification

5. Typically, a design specification satisfies a set of requirements""" ;
    iof-av:firstOrderLogicAxiom "LA1: DesignSpecification(x) → InformationContentEntity(x) ∧ ∀c (prescribes(x,c) → Continuant(c))",
        "LA2: InformationContentEntity(x) ∧ ∃c∃r(Continuant(c) ∧ RequirementSpecification(r) ∧ satisfiesRequirement(x,r) ∧ prescribes(x,c)) ∧ ∀c1(prescribes(x,c1) → Continuant(c1)) → DesignSpecification(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that prescribes something man-made"@en-US ;
    iof-av:primitiveRationale "See the general discussion and rationale provided for informational entities under 'information content entity'." ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: if d is a 'design specification' then d is an 'information content entity' and whenever d 'prescribes' y that y must be a 'continuant'",
        "LA2: if d is an 'information content entity' that 'prescribes' some 'continuant' and that 'satisfies requirement' some 'requirement specification' and if all y that d 'presribes' are instance of 'continuant' then d is a 'design specification'" .

iof-constr:MaterialComponent a owl:Class ;
    rdfs:label "material component"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000040 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:MaterialComponentRole ] ) ] ;
    skos:example "portion of water; portion of crude oil; sea shells; bolt; transmission assembly;engine in an airplane"@en-US ;
    iof-av:counterExample "Braking subsystem -- systems and subsystems are object aggregates and often have fiat boundaries, in which case they may be incorrectly inferred as product components. Othertimes, they are systems with bonafide boundaries and should be inferred as a product component." ;
    iof-av:explanatoryNote """1. Assemblies that are components for one manufacturer may be final products for another (e.g., the selling of diesel engines is a primary product line of Cummins diesel engine yet a component assembly for its customers, Freightliner Trucks). In other words, the context in which a material entity is used must be considered to determine whether it bears the component role.

2. In most manufacturing use cases, material components will be a subclass of 'material artifact'.

3. See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience.""" ;
    iof-av:firstOrderLogicDefinition "MaterialComponent(x) ↔ MaterialEntity(x) ∧ ∃r(MaterialComponentRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "material entity which has the material component role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'material component' is defined as exactly an instance of 'material entity' that 'has role' some 'material component role'" ;
    iof-av:synonym "part"@en-US .

iof-constr:ProductProductionProcess a owl:Class ;
    rdfs:label "product production process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:BusinessProcess ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:BusinessProcess [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000117 ;
                        owl:someValuesFrom iof-constr:ManufacturingProcess ] [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000199 ;
                        owl:someValuesFrom [ a owl:Class ;
                                owl:intersectionOf ( bfo:BFO_0000008 [ a owl:Restriction ;
                                            owl:onProperty iof-constr:temporallyOverlaps ;
                                            owl:someValuesFrom [ a owl:Restriction ;
                                                    owl:onProperty [ owl:inverseOf bfo:BFO_0000108 ] ;
                                                    owl:someValuesFrom iof-constr:MaterialProduct ] ] ) ] ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasSpecifiedOutput ;
                        owl:someValuesFrom iof-constr:MaterialProduct ] ) ] ;
    skos:example "Making of an engine block as a product that consists of many processes such as manufacturing process, assembly process, inspection process etc."@en-US ;
    iof-av:adaptedFrom "https://en.wikipedia.org/wiki/Manufacturing and ISO 23952:2020(en)" ;
    iof-av:counterExample """1.Providing a service that does not deliver any tangible good
2.Acquiring unprocessed raw material (e.g., roll of aluminum) with intention to sell them or reselling. The Product existed before the initiation of the planned process.""" ;
    iof-av:explanatoryNote """1. A product production process is distinct from a maintenance process in that, in the latter case, the product exists both before and after the process occurs.

2. A product production process has several planned processes as parts (sub-processes), including at least one manufacturing or assembly process, and optionally, may include other planned process types such as inspection, packaging, rework, and material handling.

3. Note that the various parts of a product production process, for example, inspection, and testing, cannot be a product production process alone.

4. Some manufacturing processes will also be product production processes.""" ;
    iof-av:firstOrderLogicDefinition "ProductProductionProcess(x) ↔ BusinessProcess(x) ∧ ∃m(ManufacturingProcess(m) ∧ occurentPartOf(m,x)) ∧ ∃y∃t∃t1(MaterialProduct(y) ∧ TemporalRegion(t) ∧ TemporalRegion(t1) ∧ hasSpecifiedOutput(x, y) ∧ occupiesTemporalRegion(x, t) ∧ temporallyOverlaps(t, t1) ∧ existsAt(y, t1))" ;
    iof-av:naturalLanguageDefinition "business process that consists of at least one manufacturing process through which raw materials and components are transformed or modified to create a material product"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'product production process' is defined as exactly an instance of 'business process' that 'has occurrent part', some 'manufacturing process', and 'has specified output' some 'material product' which did not 'exist at' the beginning of the 'product production process'" .

iof-constr:Supplier a owl:Class ;
    rdfs:label "supplier"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Agent ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( [ a owl:Class ;
                        owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:SupplierRole ] ) ] ;
    skos:example "logistics service provider; vending machine; the material handling department (which manages the raw material and finished goods in company warehouses, and provides material handling services to manufacturing and other departments within its factories)"@en-US ;
    iof-av:explanatoryNote "See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience." ;
    iof-av:firstOrderLogicDefinition "Supplier(x) ↔ Person(x) ∨ Organization(x) ∧ ∃r(SupplierRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "person or organization which has a supplier role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'supplier' is defined as exactly an instance of 'person' or 'organization' that 'has role' some 'supplier role'" .

iof-constr:functionOf a owl:ObjectProperty ;
    rdfs:label "function of"@en-US ;
    rdfs:domain bfo:BFO_0000034 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000004 ;
    rdfs:subPropertyOf bfo:BFO_0000197 ;
    owl:inverseOf iof-constr:hasFunction ;
    skos:example "this catalysis function is a function of this enzyme"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000079" ;
    iof-av:firstOrderLogicAxiom "functionOf(x,y) → Function(x) ∧ IndependentContinuant(y) ∧ inheresIn(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a function to an independent continuant (the bearer), in which the function specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x function of y holds when x is a 'function' and y is a 'independent continuant' and x is 'inheres in' y" .

iof-constr:isValueExpressionOfAtAllTimes a owl:ObjectProperty ;
    rdfs:label "is value expression of at all times"@en-US ;
    rdfs:domain iof-constr:ValueExpression ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf iof-constr:isValueExpressionOfAtSomeTime ;
    skos:example "3×10^8 m/s is the value expression of the speed of light in a vacuum; 1.602176634×10−19 coulombs is the value expression of the electric charge carried by a single proton"@en-US ;
    iof-av:naturalLanguageDefinition "relation from a value expression to an entity indicating that the value expression contains the value of the entity which does not change during the entire existence of the entity"@en-US .

iof-constr:temporallyOverlaps a owl:ObjectProperty ;
    rdfs:label "temporally overlaps"@en-US ;
    rdfs:domain [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range [ a owl:Class ;
            owl:unionOf ( bfo:BFO_0000015 bfo:BFO_0000202 ) ] ;
    rdfs:subPropertyOf owl:topObjectProperty ;
    skos:example "When two plates are being welded at a joint, the cooling of a previously welded point temporally overlaps the heating of the point which is currently being welded; the sending process temporally overlaps the receiving process in a transaction process; Ancient Egyptian civilization (c. 3000 BCE - 30 BCE) temporally overlapped the Sumerian civilization (c. 3500 BCE - c. 2000 BCE) in Mesopotamia and the Indus Valley Civilization (c. 2600 BCE - c. 1900 BCE) in South Asia."@en-US ;
    iof-av:adaptedFrom "https://dl.acm.org/doi/10.1145/182.358434" ;
    iof-av:firstOrderLogicAxiom "LA1: temporallyOverlaps(i,j) → (TemporalInterval(i) ∧ TemporalInterval(j)) ∨ (Process(i) ∧ Process(j))",
        "LA2: TemporalInterval(i) ∧ TemporalInterval(j) ∧ temporallyOverlaps(i,j) → ∃i1∃i2∃j1∃j2(TemporalInstant(i1) ∧ TemporalInstant(i2) ∧ TemporalInstant(j1) ∧ TemporalInstant(j2) ∧ hasFirstInstant(i,i1) ∧ hasLastInstant(i,i2) ∧ hasFirstInstant(j,j1) ∧ hasLastInstant(j,j2) ∧ precedes(j1,i2) ∧ precedes(i1,j1) ∧ precedes(i2,j2))",
        "LA3: Process(i) ∧ Process(j) ∧ temporallyOverlaps(i,j) → ∃i1∃j1(TemporalInterval(i1) ∧ TemporalInterval(j1) ∧ occupiesTemporalRegion(i,i1) ∧ occupiesTemporalRegion(j,j1) ∧ temporallyOverlaps(i1,j1))",
        "LA4: temporallyOverlaps(i,j) ↔ ∃k(temporallyFinishes(k,i) ∧ starts(k,j))" ;
    iof-av:naturalLanguageDefinition "relation that holds between two intervals and processes i and j when the first instant of the temporal extent of i is earlier than and the last instant of the temporal extent of i is later than the first instant of the temporal extent of j, and the last instance of the temporal extent of i is earlier than the last instant of the temporal extent of j"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: If i 'temporally overlaps' j then either both are 'temporal intervals' or both are 'process'",
        "LA2: If both i and j are 'temporal intervals' and i 'temporally overlaps' j then the 'first instant’ of j ‘precedes’ the 'last instant of' i and the 'first instant of' i ‘precedes’ the 'first instant’ of j and the 'last instant of' i ‘precedes’ the 'last instant of' j",
        "LA3: If both i and j are 'process' and i 'temporally overlaps' j then the 'temporal interval' that i occupies 'temporally overlaps' the 'temporal interval' that j occupies",
        "LA4: i 'temporally overlaps' j if and only if there exists k that 'temporally finishes' i and 'temporally starts' j" .

bfo:BFO_0000029 skos:example "location of a container, floor area in a factory building, location of a machine (relative to the coordinate of a factory floor), location on a shelf in a warehouse"@en-US ;
    iof-av:explanatoryNote "Even though site (physical location) always refers to a 3D space it is fine to define it practically just through 2D or 1D or 0D spatial region. For example when we want to talk about 2x2m area within a factory floor even though the space specified is 2D it is still ok to assert it as site as there is always the third dimension above the area that is implicit." ;
    iof-av:synonym "physical location"@en-US .

iof-constr:BuyingBusinessProcess a owl:Class ;
    rdfs:label "buying business process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom iof-constr:Buyer ],
        [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:unionOf ( iof-constr:CommercialServiceAgreement iof-constr:MaterialProduct ) ] ],
        iof-constr:BusinessProcess ;
    skos:example "GM buys tires from Good Year to be assembled into its cars; GE Conglomerate (buyer) buys steels for uses in productions by its GE aviation subsidiary (customer) and GE Transportation subsidiary (customer)"@en-US ;
    iof-av:adaptedFrom """CCO:http://www.ontologyrepository.com/CommonCoreOntologies/ActOfBuying
NL definition: OAGIS and CCO""" ;
    iof-av:explanatoryNote """1.The agent who uses the finiancial instrument may not own the financial instrument and hence agent may not be the paying agent.
2. It should be noted that we consciously exclude the person-to-person transactions, but person-to-business is not excluded.""" ;
    iof-av:firstOrderLogicAxiom "BuyingBusinessProcess(x) → BusinessProcess(x) ∧ ∃y∃z((MaterialProduct(y) ∨ CommercialServiceAgreement(y)) ∧ Buyer(z) ∧ hasParticipantAtSomeTIme(x,y) ∧ hasParticipantAtSomeTime(x,z))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "business process wherein a financial instrument is used by an agent (buyer) to acquire ownership of a product or commercial service from another agent (seller) for the buyer itself or for another agent (customer)"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, ownership and economic transactions require formalization." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'buying business process' then x is a 'business process' that 'has participant at some time' some 'buyer' and x 'has participant at some time' some 'material product' or 'commercial service agreement'" .

iof-constr:CommercialService a owl:Class ;
    rdfs:label "commercial service"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000117 ;
            owl:someValuesFrom iof-constr:SupplyingBusinessProcess ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:isSubjectOf ;
            owl:someValuesFrom iof-constr:CommercialServiceAgreement ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:prescribedBy ;
            owl:someValuesFrom iof-constr:CommercialServiceSpecification ],
        [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom iof-constr:ServiceProvider ],
        iof-constr:BusinessProcess ;
    skos:example "Lufthansa Aviation Services maintains airplanes for United Airlines when the plane stops at Frankfurt International Airport."@en-US ;
    iof-av:explanatoryNote """1. A consumption process means using or benefiting.

2.Typically, the service provisioning process and consumption process coincide temporally which is different from a material product that is consumed (used) only after supplied.""" ;
    iof-av:firstOrderLogicAxiom "Commercialervice(x) → BusinessProcess(x) ∧ ∃p∃y∃a∃s(CommercialServiceSpecification(p) ∧ ServiceProvider(y) ∧ CommercialServiceAgreement(s) ∧ SupplyingBusinessProcess(a) ∧ hasParticipantAtSomeTime(x,y) ∧ hasOccurentPart(x,a) ∧ prescribedBy(x,p) ∧ isSubjectOf(x,s))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "business process that consists of a service provisioning process and a consumption process"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, service consumption needs to be formalized." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'commercial service' then x is a 'business process' that is 'prescribed by' some 'commercial service specification' and that 'has participant at some time' some 'service provider' 'and x 'has occurent part' some 'supplying business process' and x 'is subject of' some 'commercial service agreement'" .

iof-constr:EncodedAlgorithm a owl:Class ;
    rdfs:label "encoded algorithm"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:PlanSpecification ;
    skos:example "source code encoded in Java that implements a sorting algorithm; Python script that implements a decision tree and that has the objective to classify melt pool images"@en-US ;
    iof-av:adaptedFrom "http://www.ebi.ac.uk/swo/SWO_0000001" ;
    iof-av:counterExample "flowchart, pseudocode" ;
    iof-av:explanatoryNote "Readily executable means that it can be 1) concretized by a computing process which is prescribed by the encoded algorithm or 2) in case of source code concretized by a compiling process" ;
    iof-av:firstOrderLogicAxiom "PlanSpecification(x) ∧ ∃y(ComputingProcess(y) ∧ prescribes(x,y)) → EncodedAlgorithm(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "plan specification that is the implementation of an algorithm encoded in a specific programming language or framework and that is readily executable"@en-US ;
    iof-av:primitiveRationale "In addition to the general discussion provided for information content enty,there are insufficient constructs to create necessary and sufficient conditions. Namely constructs for 'encoded in', 'implementation of' and 'programming language' or 'framework' as well as 'compiling process' are still missing." ;
    iof-av:semiFormalNaturalLanguageAxiom "If x is a 'plan specification' that 'prescribes' some 'computing process' then x is an instance of 'encoded algorithm'" .

iof-constr:Identifier a owl:Class ;
    rdfs:label "identifier"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:designates ;
            owl:someValuesFrom bfo:BFO_0000001 ],
        iof-constr:InformationContentEntity ;
    skos:example "URI of a website; social security number of a person (living in the United States), a global location number assigned to the Amazon regional distribution center at 12300 Bermuda Rd in Henderson, NV; the lot identifier assigned to a batch of rivets just received from China by the Airbus final assembly plant in Toulouse, FR; the VIN number assigned to the Tesla in my garage; a credit card number, the value of a field in a company's internal IT systems system used to uniquely identify a particular product and product revision."@en-US ;
    iof-av:adaptedFrom "https://www.omg.org/spec/Commons/Identifiers/Identifier" ;
    iof-av:explanatoryNote """1. Identifier can be just one designative ICE or consist of a combination of them. It can also be a combination of other types of information; for example, in a particular domain of discourse, a combination of first name and last name can provide sufficient uniqueness for entities in that domain.
2. The designative property enforces uniqueness as it is a functional property. In other words, on the instance level, each instance of identifier designates exactly one instance of an entity.""" ;
    iof-av:firstOrderLogicAxiom "Identifier(x) → InformationContentEntity(x) ∧ ∃e(Entity(e) ∧ designates(x,e))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that is used to uniquely identify an entity within a particular context"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely patterns to connect context to the identifier are still missing" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'identifier' then x is an 'information content entity' that 'designates' some 'entity'" .

iof-constr:ManufacturingProcess a owl:Class ;
    rdfs:label "manufacturing process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( iof-constr:Agent [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000101 ;
                                owl:someValuesFrom iof-constr:PlanSpecification ] ) ] ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:hasSpecifiedOutput ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:unionOf ( iof-constr:MaterialArtifact [ a owl:Class ;
                                owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                                            owl:onProperty iof-constr:prescribedBy ;
                                            owl:someValuesFrom iof-constr:DesignSpecification ] ) ] ) ] ],
        [ a owl:Restriction ;
            owl:onProperty iof-constr:hasInput ;
            owl:someValuesFrom bfo:BFO_0000040 ],
        iof-constr:PlannedProcess ;
    skos:example "Drilling a hole on an engine block; manufacturing operation for making a shaft consisting of milling, turning, and drilling manufacturing processes; assembly process, and quality control process; a manufacturing process that uses 3D printing to create the output material entity."@en-US ;
    iof-av:adaptedFrom "ISO 15531-1 and ISO 15531-43:2006(en)" ;
    iof-av:counterExample "statistical process control and preventative maintenance management processes that maximize machine availability and the product quality of manufactured products." ;
    iof-av:explanatoryNote """1. This definition presupposes that the outputs of a manufacturing process are in every case material artifacts or man-made substances.

2. Processes that have as their primary output, something immaterial or informational in nature (digital outputs), such as found in the production of software, will be considered speparately at a later stage.

3.. There are other processes that while they may come into direct contact with a manufactured component or substance and are often considered part of the overall set of activities planned and executed to manufacture something, they are not "transformative" in nature relative to that which is manufactured, and are specifically excluded the definition. Examples include setup, tear down, transporting components or materials between locations, inspection, and so forth.
This is addressed by output in the axiom. Setup => does not have output. Tear down like disassembly should still be considered transformative.

4. This definition places no additional restrictions on the output of a manufacturing process in terms of being in a state of completion (completed component or finished good).""" ;
    iof-av:firstOrderLogicAxiom "ManufacturingProcess(x) → PlannedProcess(x) ∧ ∃m∃y∃p∃z(MaterialEntity(m) ∧ (MaterialArtifact(y) ∨ ∃d(MaterialEntity(y) ∧ DesignSpecification(d) ∧ prescribes(d,y))) ∧ PlanSpecification(p) ∧ prescribes(p,x) ∧ Agent(z) ∧ isCarrierOfAtSomeTime(z,p) ∧ participatesInAtSomeTime(z,x) ∧ isInputOf(m,x) ∧ hasSpecifiedOutput(x,y))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "planned process that consists of a structured set of operations through which input material is transformed or modified"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for 'being transformed or modified' need to be formalized" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'manufacturing process' x then x is a 'planned process' that 'has input' some 'material entity' and 'has specified output' some 'material artifact' or a 'material entity' that is 'prescribes by' some 'design specification' and x 'has participant at some time' some 'agent' that is the 'carrier of at some time' a 'plan specification' that 'prescribes' x" .

iof-constr:RequirementSpecification a owl:Class ;
    rdfs:label "requirement specification"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:isAbout ;
            owl:someValuesFrom iof-constr:ObjectiveSpecification ],
        iof-constr:InformationContentEntity ;
    skos:example "UML use case document, competency questions, high level activity diagram"@en-US ;
    iof-av:adaptedFrom "https://demo-irm-dnvgl.northeurope.cloudapp.azure.com/ontology/requirement-ontology/core/A01A" ;
    iof-av:explanatoryNote "Being a requirement specification can be context specific. For example, a UML class diagram may be a requirement specification for a data exchange specification or a design specification for software code." ;
    iof-av:firstOrderLogicAxiom "LA1: RequirementSpecification(x) → InformationContentEntity(x) ∧ ∃y(ObjectiveSpecification(y) ∧ isAbout(x,y))",
        "LA2: InformationContentEntity(x) ∧ ∃y(Entity(y) ∧ satisfiesRequirement(y,x)) → RequirementSpecification(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that prescribes a set of requirements"@en-US ;
    iof-av:primitiveRationale "See the general discussion and rationale provided for informational entities under 'information content entity'." ;
    iof-av:semiFormalNaturalLanguageAxiom "LA1: if x is a 'requirement specification' then x is an 'information content entity' that 'is about' some 'objective specification'",
        "LA2: if x is an 'information content entity' and exists an entity that 'satisfies requirement' x then x is a 'requirement specification'" .

iof-constr:SellingBusinessProcess a owl:Class ;
    rdfs:label "offering for sale business process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom iof-constr:Supplier ],
        [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:unionOf ( iof-constr:CommercialServiceAgreement iof-constr:MaterialProduct ) ] ],
        iof-constr:BusinessProcess ;
    skos:example "Good Year offers tires for sale, Boeing offers 737 planes for along with service agreements for the maintenance of the planes"@en-US ;
    iof-av:adaptedFrom """CCO:http://www.ontologyrepository.com/CommonCoreOntologies/ActOfBuying
NL definition: OAGIS and CCO""" ;
    iof-av:explanatoryNote "It should be noted that we consciously exclude the person-to-person transactions, but person-to-business is not excluded." ;
    iof-av:firstOrderLogicAxiom "OfferingForSaleBusinessProcess(x) → BusinessProcess(x) ∧ ∃y∃z((MaterialProduct(y) ∨ CommercialServiceAgreement(y)) ∧ Supplier(z) ∧ hasParticipantAtSomeTIme(x,y) ∧ hasParticipantAtSomeTime(x,z))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "business process wherein a product or commercial service is offered by an agent (seller) for another agent (buyer) to acquire ownership via a financial instrument"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, ownership and economic transactions require formalization." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'offering for sale business process' then x is a 'business proces' that 'has participant at some time' some 'supplier' and x 'has participant at some time' some 'material product' or 'commercial service agreement'" .

iof-constr:SupplyingBusinessProcess a owl:Class ;
    rdfs:label "supplying business process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom iof-constr:Supplier ],
        [ a owl:Class ;
            owl:unionOf ( [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000057 ;
                        owl:someValuesFrom iof-constr:MaterialProduct ] [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000132 ;
                        owl:someValuesFrom iof-constr:CommercialService ] ) ],
        iof-constr:BusinessProcess ;
    skos:example "BMW dealer supplies a car to the Customer; US importer of steel from China supplies the steel to a US manufacturer; company (supplier) supplied (ship directly) a product to a buyer who bought the product on Amazon (seller)"@en-US ;
    iof-av:adaptedFrom "https://www.oberlo.com/ecommerce-wiki/supply" ;
    iof-av:counterExample "A BMW dealer supplies a car to a Customer in the US, but the BMW Manufacturer in Germany does not supply the car to the Customer. The BMW Manufacturer supplies the car to the BMW dealer." ;
    iof-av:explanatoryNote """1. To supply a product means to deliver the product to another agent.
2.To supply a service means to perform a process (e.g. commercial service) for another agent, typically involving a service agreement.
3.It should be noted that we consciously exclude the person-to-person transactions, but person-to-business is not excluded.""" ;
    iof-av:firstOrderLogicAxiom "SupplyingBusinessProcess(x) → BusinessProcess(x) ∧ ∃y(Supplier(y) ∧ hasParticipantAtSomeTime(x,y)) ∧ (∃p(MaterialProduct(p) ∧ hasParticipantAtSomeTime(x,p)) ∨ ∃c(CommercialService(c) ∧ occurrentPartOf(x,c)))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "business process wherein a product or service is supplied"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely, constructs for economic transactions, service or product provision and ownership are lacking" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'supplying business process' then x is a 'business process' that 'has participant at some time' some 'supplier' and x 'has participant at some time' some 'material product' or is 'occurent part of' some 'commercial service'" .

iof-constr:describes a owl:ObjectProperty ;
    rdfs:label "describes"@en-US ;
    rdfs:domain iof-constr:InformationContentEntity ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf iof-constr:isAbout ;
    skos:example "the content of a newspaper article describes some current event; the content of a visitor's log describes some facility visit; the content of an accident report describes some accident"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relation from an information content entity to an entity that the information content entity characterizes"@en-US .

iof-constr:hasInput a owl:ObjectProperty ;
    rdfs:label "has input"@en-US ;
    rdfs:domain bfo:BFO_0000015 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000002 ;
    rdfs:subPropertyOf bfo:BFO_0000057 ;
    owl:inverseOf iof-constr:isInputOf ;
    skos:example "machine learning execution process has input a dataset;fermentation process has input growth medium; additive manufacturing process has input metal powder;"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/ExtendedRelationOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relation from a process to someone or something physical or digital (continuant) that is a necessary precondition for the process to start"@en-US .

iof-constr:isOutputOf a owl:ObjectProperty ;
    rdfs:label "is output of"@en-US ;
    rdfs:domain bfo:BFO_0000002 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000015 ;
    rdfs:subPropertyOf bfo:BFO_0000056 ;
    skos:example "wastestream is an output of a chemical manufacturing process; a certain quantity of toluene is an output of a toluene manufacturing process; a car is an output of a car manufacturing process"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/ExtendedRelationOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relation from someone or something physical or digital (continuant) to a process that it participates in such that it is generated or modified during the process, and it exists at the end of the process"@en-US .

iof-constr:isValueExpressionOfAtSomeTime a owl:ObjectProperty ;
    rdfs:label "is value expression of at some time"@en-US ;
    rdfs:domain iof-constr:ValueExpression ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf iof-constr:describes ;
    skos:example "1cm is the value expression of the diameter of a screw head that is specified in its design; 37C is the value expression of the temperature of a bioreactor measured during the production process; \"low risk\" is the value expression of a process parameter based on the risk analysis classification scheme; 3 g/l is the value expression of titer of an antibody generated by a process simulation"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/OBI_0001938" ;
    iof-av:naturalLanguageDefinition "relation from a value expression to the entity indicating that the value expression contains the value of the entity determined or set at some time t"@en-US .

bfo:BFO_0000054 iof-av:synonym "realized in"@en-US .

iof-constr:AgentRole a owl:Class ;
    rdfs:label "agent role"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:roleOf ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( [ a owl:Class ;
                                owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Class ;
                                            owl:complementOf bfo:BFO_0000024 ] ) ] [ a owl:Restriction ;
                                owl:onProperty iof-constr:actsOnBehalfOfAtSomeTime ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:unionOf ( iof-constr:EngineeredSystem iof-constr:GroupOfAgents iof-constr:Person ) ] ] ) ] ],
        bfo:BFO_0000023 ;
    skos:example "a person has an employee role when he/she acts on behalf of the business organization that employs them"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/AgentOntology" ;
    iof-av:counterExample """Other types of agents we are not including at this stage are:
1. Those that are physical and chemical in nature: Cleaning, vulcanizing, fluxing, indicator, sterilizing, emulisifying, refining.

2. Organisms: animals, cells, parts of organisms (organs, organelles, viruses).

3. In computing: intelligent, artificial, mobile, & autonomous""" ;
    iof-av:explanatoryNote """1.The IOF has elected to exclude material substances that may, at times, act like or are often referred to as agents, in that they realize some specific function that some person desires (e.g., platinum is a reducing agent in various reduction-type reactions -- as used in a catalytic converter to eliminate or reduce various pollutants in exhausts).

2. The IOF has at this time excluded other types of non-human agents, such as animals and other organisms (often referred to as biological agents).

3. in case the 'material entity' is an engineered system or group of agents or person acting on behalf of oneself is also allowed""" ;
    iof-av:firstOrderLogicAxiom "AgentRole(x) → Role(x) ∧ ∃n∃m((MaterialEntity(m) ∧ ¬FiatObjectPart(x)) ∧ roleOf(x,m) ∧ (Person(n) ∨ GroupOfAgents(n) ∨ EngineeredSystem(n)) ∧ actsOnBehalfOfAtSomeTime(m, n))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "role that someone or something has when they act on behalf of a person, engineered system or a group of agents"@en-US ;
    iof-av:primitiveRationale "This term is expected to remain primitive. While 'acting on behalf of at some time' captures the essence of being an agent, the realization of the agent role is expected to have too generic of a scope to define a sufficient condition that would not cause conflict (overlap) with the realization of other roles, which can in turn lead to reasoner errors when a specific entity bears multiple roles simoultaneously. Also, no further conditions specific to the role and not to the bearer of the role have been created thus far." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'agent role' x then x is a 'role' that is the 'role of' some 'material entity' (that is not a 'fiat object part') when it 'acts on behalf of at some time' some 'person' or 'group of agents' or 'engineered system'" .

iof-constr:Capability a owl:Class ;
    rdfs:label "capability"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000016 ;
    skos:example "Capability of a person to play chess at the \"master\" level; of a team to play football in the professional league; of a lathe to turn at maximal speed of 4,000 RPM; or of your digestive system to digest tiramisu."@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/AgentOntology" ;
    iof-av:explanatoryNote """1. Whereas the BFO term 'disposition refers to all tendencies, powers, habits, skills, potentials, and so forth, that a material entity may possess, a Capability narrows this down by requiring the existence of an Agent that has an interest in the realization of the capability

2. This definition does not attempt to capture "task-based" capabilities that an entity may bear -- e.g., a stone's capability to kill when used by some person. Rather, it captures "proper capabilities." See related discussion of "proper functions" in the literature.

3. All functions are capabilities and in a future release BFO:Function will be asserted directly under capability.

4. Not all capabilities are functions. Capabilities are often added to an artifact by the designer/engineer, or to a biological entity through evolution, as "additional benefits," and are differentiated from function (i.e., purpose). Examples: the air conditioner in your car is a capability but not the function of your car. Yet the function of the car air conditioner certainly forms some material basis of your car's ability to provide a comfortable experience. The ability of your heart to beat fast to support your need to run fast to escape a threat. The decaying stick on the forest lawn does not have the function to be used as a tool, but certainly a chimpanzee
 may have an interest in using a stick to extract food from a termite mound.""" ;
    iof-av:firstOrderLogicAxiom "Capability(x) → Disposition(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "disposition in whose realization some agent has an interest"@en-US ;
    iof-av:primitiveRationale "This concept will be further developed and formalized in a future release of BFO." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'capability' then x is a 'disposition'" ;
    iof-av:synonym "ability"@en-US .

iof-constr:CommercialServiceAgreement a owl:Class ;
    rdfs:label "commercial service agreement"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:Agreement ;
    skos:example "a cellphone plan, a maintenance service agreement, equipment lease agreement that includes a maintenance plan"@en-US ;
    iof-av:adaptedFrom "https://schema.org/, http://www.heppnetz.de/projects/goodrelations/ and http://dini-ag-kim.github.io/service-ontology/service.html" ;
    iof-av:counterExample "a blanket purchase order, commodity contract" ;
    iof-av:firstOrderLogicAxiom "Agreement(x) ∧ ∃c∃y∃z(CommercialService(c) ∧ ServiceProviderRole(y) ∧ CustomerRole(z) ∧ isAbout(x,c) ∧ prescribes(x,y) ∧ prescribes(x,z)) → CommercialServiceAgreement(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "agreement between a customer and service provider that is about some commercial service to be provided by the service provider in exchange for compensation from the customer"@en-US ;
    iof-av:primitiveRationale "See the general discussion and rationale provided for informational entities under 'information content entity'." ;
    iof-av:semiFormalNaturalLanguageAxiom "If x is an 'agreement' that 'is about' some 'commercial service' and that 'prescribes' some 'customer role' and some 'service provider role' then x is a 'commercial service agreement'" .

iof-constr:MaterialProduct a owl:Class ;
    rdfs:label "material product"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000040 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000040 [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:MaterialProductRole ] ) ] ;
    skos:example """1. Natural resources: the seashells lying on the beach that some person collects, packages and sells; the iron ore in a mountain the rights to which some mining company has just purchased which they intend to mine and sell to iron-making processors;

2. Any manufactured good when it is offered for sale, supplied or being bought"""@en-US ;
    iof-av:counterExample """certified pre-owned warranty plan; software as a service (SaaS); training course; consultancy services;
Office 365""" ;
    iof-av:explanatoryNote """1. The definition does exclude services sold as product which deviates from some standard definitions and economic theory.
Services as products as well as software products will be considered in the next version of the IOF Core

2. See expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience.""" ;
    iof-av:firstOrderLogicDefinition "MaterialProduct(x) ↔ MaterialEntity(x) ∧ ∃r(MaterialProductRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "material entity which has the material product role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'material product' is defined as exactly an instance of 'material entity' that is the 'has role' some 'material product role'" .

iof-constr:designates a owl:FunctionalProperty,
        owl:ObjectProperty ;
    rdfs:label "designates"@en-US ;
    rdfs:domain iof-constr:InformationContentEntity ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf iof-constr:denotes ;
    skos:example "a URL designates the location of a Web Page on the internet;SSN designates an individual; 'lot number' designates a particular lot of product"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:explanatoryNote """1. To ensure uniqueness, each information content entity can designate exactly one entity. As such, this property is made functional.
2. The uniqueness of the entity is typically within a particular context that is represented in the identification scheme that conveys the meaning of the assignment.""" ;
    iof-av:naturalLanguageDefinition "relation from an information content entity to an entity that the information content entity uniquely distinguishes from other entities"@en-US .

iof-constr:isSubjectOf a owl:ObjectProperty ;
    rdfs:label "is subject of"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:InformationContentEntity ;
    skos:example "temperature is subject of temperature recording; particular individual is subject of SSN; commercial service is subject of commercial service agreement"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "primitive, generic relationship between an entity and some information content entity"@en-US .

iof-constr:GroupOfAgents a owl:Class ;
    rdfs:label "group of agents"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000027 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000027 [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000115 ;
                        owl:someValuesFrom iof-constr:Agent ] [ a owl:Restriction ;
                        owl:allValuesFrom iof-constr:Agent ;
                        owl:onProperty bfo:BFO_0000115 ] ) ] ;
    skos:example "organization; an automated manufacturing cell; division; protesters"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/AgentOntology" ;
    iof-av:explanatoryNote """1. Group of agents being a BFO:Object Aggregate allows for a point in time where only one 'agent' is present.

2. As the name suggests, a group of agents is a grouping of agents based on some criteria. As such, it can only have agents as members.

3. The members of the group of agents can be any combination of persons, organizations, or engineered systems (classes that can be 'agent'). They are typically grouped based on the fact that they are working collectively in a particular type of process on behalf of someone.""" ;
    iof-av:firstOrderLogicDefinition "GroupOfAgents(x) ↔ ObjectAggregate(x) ∧ ∃y(Agent(y) ∧ hasMemberPartAtSomeTime(x, y)) ∧ ∀z (hasMemberPartAtSomeTime(x, z) → Agent(z))" ;
    iof-av:naturalLanguageDefinition "group (object aggregate) that has one or more agents as members"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'group of agents is defined as exactly an instance of 'object aggregate' that only has 'agent' as 'member parts' and that always has at least one 'agent as its 'member part'" .

iof-constr:ProcessCharacteristic a owl:Class ;
    rdfs:label "process characteristic"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000003 ;
    skos:example "the rate of production of a product production process, heart rate, the rate of temperature change resulting from a heating process"@en-US ;
    iof-av:explanatoryNote "Here ‘attribute’ is not a technical term." ;
    iof-av:firstOrderLogicAxiom "ProcessCharacteristic(x) → Occurrent(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "attribute of a process"@en-US ;
    iof-av:primitiveRationale "This term is expected to remain primitive as it is highly unlikely that a a set of conditions will be created such that no circularity is introduced." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'process characteristic' then x is an 'occurrent'" .

iof-constr:hasSpecifiedOutput a owl:ObjectProperty ;
    rdfs:label "has specified output"@en-US ;
    rdfs:domain iof-constr:PlannedProcess ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000002 ;
    rdfs:subPropertyOf iof-constr:hasOutput ;
    owl:inverseOf iof-constr:isSpecifiedOutputOf ;
    skos:example "biopharmaceutical production process has specified output an antibody solution of 99.999% purity; a simulation execution has specified output a prediction of part porosity; a temperature measurement process has specified output a temperature measurement result; a car manufacturing process has specified output a car"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/OBI_0000299" ;
    iof-av:explanatoryNote "this relation was added to specifically model the outputs that are not byproducts/wasteproducts" ;
    iof-av:firstOrderLogicAxiom "hasSpecifiedOutput(x,y) → PlannedProcess(x) ∧ Continuant(y) ∧ ∃o(ObjectiveSpecification(o) ∧ prescribes(o,y) ∧ achievesAtSomeTime(x,o) ∧ hasOutput(x,y))" ;
    iof-av:naturalLanguageDefinition "relation from a planned process to someone or something physical or digital (continuant) that is produced or modified in the planned process as prescribed by an objective"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x 'has specified output' y holds when x is a 'planned process' and y is a 'continuant' and x 'has output' y and y is 'prescribed by' some 'objective specification' which x 'achieves at some time'" ;
    iof-av:synonym "has intended output"@en-US .

iof-constr:isAbout a owl:ObjectProperty ;
    rdfs:label "is about"@en-US ;
    rdfs:domain iof-constr:InformationContentEntity ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    owl:inverseOf iof-constr:isSubjectOf ;
    skos:example "a temperature recording is about temperature; SSN is about a particular individual; commercial service agreement is about a commercial service"@en-US ;
    iof-av:adaptedFrom "IAO:http://purl.obolibrary.org/obo/IAO_0000136 and CCO:http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology" ;
    iof-av:naturalLanguageDefinition "primitive, generic relationship between an information content entity and some entity"@en-US .

bfo:BFO_0000034 rdfs:subClassOf iof-constr:Capability .

iof-constr:MaterialArtifact a owl:Class ;
    rdfs:label "material artifact"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000030 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000030 [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000196 ;
                        owl:someValuesFrom iof-constr:DesignedFunction ] ) ] ;
    skos:example "a machine, a screwdriver, a screw, a sheet of paper"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/ArtifactOntology" ;
    iof-av:firstOrderLogicDefinition "MaterialArtifact(x) ↔ Object(x) ∧ ∃f(DesignedFunction(f) ∧ bearerOf(x,f))" ;
    iof-av:naturalLanguageDefinition "object that is deliberately created to have a certain function"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'material artifact' is defined as exactly an instance of 'object' that is the 'bearer of' some 'designed function'" .

iof-constr:ObjectiveSpecification a owl:Class ;
    rdfs:label "objective specification"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    skos:example "The objective specification in a manufacturer's six-sigma process improvement program will describe in some detail, the quality improvements to be achieved (as in e.g. the level of reduction in causes of defects, or in the level variability in either or both manufacturing and business processes)."@en-US ;
    iof-av:adaptedFrom "http://www.obofoundry.org/ontology/iao.html" ;
    iof-av:explanatoryNote """1.Typically is part of a plan specification.
		2.The NL definition states that the objective specification 'prescribes' the outcome of a 'process'. This does not necessarily imply that a given process exists as an instance during the entire 'objective specification' lifecycle. Instead, it should be interpreted as "if an instance of the  Process X (X here is intended to represent an OWL:Class that is SubClassOf: Process) exists, then its outcome should be as 'prescribed by' the 'objective specification'.""" ;
    iof-av:firstOrderLogicAxiom "InformationContentEntity(x) ∧ ∃y∃p(Process(p) ∧ isAchievedByAtSomeTime(x,p) ∧ ((ProcessCharacteristic(y) ∧ processCharacteristicOf(y,p))∨ (Capability(y) ∧ hasRealization(x,y)) ∨ (Continuant(c) ∧ isOutputOf(c,p))) ∧ prescribes(x,y)) → ObjectiveSpecification(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that prescribes what the outcome of some process should be"@en-US ;
    iof-av:primitiveRationale "See the general discussion and rationale provided for informational entities under 'information content entity'." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'information content entity' that 'is achieved by at some time' some 'process' p and that 'prescribes' some 'process characteristic' which is a 'process characteristic of' p or 'capability' that 'has realization' p or 'continuant' c that is 'output of' p then x is an 'objective specification'" .

iof-constr:prescribedBy a owl:ObjectProperty ;
    rdfs:label "prescribed by"@en-US ;
    rdfs:domain bfo:BFO_0000001 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range iof-constr:InformationContentEntity ;
    rdfs:subPropertyOf iof-constr:isSubjectOf ;
    owl:inverseOf iof-constr:prescribes ;
    skos:example "some Artifact or Facility is modeled by a blueprint; a set of rules to be followed while acting in a role within a profession are prescribed by a professional code of conduct; tasks that need to be performed to achieve the Objectives of the Operation are prescribed by the Operation Plan"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relation from an entity to an information content entity that the information content entity serves as a collection of rules or guide for if the entity is something that unfolds in time (occurrent), or as a model if the entity is someone or something physical or digital (continuant)"@en-US .

iof-constr:BusinessProcess a owl:Class ;
    rdfs:label "business process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:prescribedBy ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( iof-constr:PlanSpecification [ a owl:Restriction ;
                                owl:onProperty bfo:BFO_0000110 ;
                                owl:someValuesFrom [ a owl:Class ;
                                        owl:intersectionOf ( iof-constr:ObjectiveSpecification [ a owl:Restriction ;
                                                    owl:onProperty bfo:BFO_0000084 ;
                                                    owl:someValuesFrom iof-constr:BusinessOrganization ] ) ] ] ) ] ],
        [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000057 ;
            owl:someValuesFrom [ a owl:Class ;
                    owl:intersectionOf ( iof-constr:Agent [ a owl:Restriction ;
                                owl:onProperty iof-constr:actsOnBehalfOfAtSomeTime ;
                                owl:someValuesFrom iof-constr:BusinessOrganization ] ) ] ],
        iof-constr:PlannedProcess ;
    skos:example "product production process; manufacturing enterprise process; finance operation; logistics operation."@en-US ;
    iof-av:adaptedFrom "ISO 15704 and APICS" ;
    iof-av:explanatoryNote "This definition leaves open the possibility that the business entity that carries the plan that prescribes the process, has no direct participation in the process, which would imply that some 3rd-party agent is playing a causal role as the process unfolds, and is acting on behalf of the Business Entity's interests." ;
    iof-av:firstOrderLogicAxiom "BusinessProcess (p) → PlannedProcess(p) ∧ ∃o∃b∃s∃y (ObjectiveSpecification(o) ∧ BusinessOrganization(b) ∧ PlanSpecification(s) ∧ isCarrierOfAtSomeTime(b,o) ∧ continuantPartofAtAllTimes(o,s) ∧ Agent(y) ∧ actsOnBehalfOfAtSomeTime(y,b) ∧ participatesInAtSomeTime(y,x))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "planned process which is prescribed by a plan specification with one or more objectives specified by a business organization"@en-US ;
    iof-av:primitiveRationale "More conditions (differentia) need to be agreed upon by the domain experts." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'business process' then x is a 'planned process' that 'has participant at some time' some 'agent' that 'acts on behalf of at some time' a 'business organization' that 'is carrier of at some time' some 'objective specification' that is 'continuant part of at all times' a 'plan specification' that 'prescribes' x" .

iof-constr:EngineeredSystem a owl:Class ;
    rdfs:label "engineered system"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf iof-constr:System ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:System [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000196 ;
                        owl:someValuesFrom iof-constr:DesignedFunction ] ) ] ;
    skos:example "machine, laptop, traffic light system"@en-US ;
    iof-av:adaptedFrom "www.incose.com, term by the same name" ;
    iof-av:firstOrderLogicDefinition "EngineeredSystem(x) ↔ System(x) ∧ ∃f(DesignedFunction(f) ∧ bearerOf(x,f))" ;
    iof-av:naturalLanguageDefinition "system that is deliberately created to have a certain function"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'engineered system' is defined as exactly an instance of 'system' that is the 'bearer of' some 'designed function'" .

iof-constr:PlanSpecification a owl:Class ;
    rdfs:label "plan specification"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000110 ;
            owl:someValuesFrom iof-constr:ObjectiveSpecification ],
        [ a owl:Restriction ;
            owl:onProperty bfo:BFO_0000110 ;
            owl:someValuesFrom iof-constr:ActionSpecification ],
        iof-constr:InformationContentEntity ;
    skos:example "a manufacturer's sales plan; process plan for producing a part; a schedule for routine maintenance and inspection of a machine; a work order to build 100 of a particular kind component for today."@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/IAO_0000104" ;
    iof-av:explanatoryNote "When concretized, plan specification may be realized in a process where participants take the prescribed actions to achieve the prescribed process objectives. In other words, a plan specification is concretized in a 'planned process' that it 'prescribes'" ;
    iof-av:firstOrderLogicAxiom "InformationContentEntity(x) ∧ ∃a∃o∃p(ActionSpecification(a) ∧ ObjectiveSpecification(o) ∧ PlannedProcess(p) ∧ continuantPartOfAtAllTimes(a,x) ∧ continuantPartOfAtAllTimes(o,x) ∧ prescribes(x,p)) → PlanSpecification(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that has action specifications and objective specifications as parts"@en-US ;
    iof-av:primitiveRationale "See the general discussion and rationale provided for informational entities under 'information content entity'." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'information content entity' that 'prescribes' some 'planned process' and x 'has continuant part at all times' some 'action specification' and some 'objective specification' then x is a 'plan specification'" ;
    iof-av:synonym "process design"@en-US,
        "process specification"@en-US,
        "work instruction"@en-US .

iof-constr:PlannedProcess a owl:Class ;
    rdfs:label "planned process"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000015 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( bfo:BFO_0000015 [ a owl:Restriction ;
                        owl:onProperty iof-constr:prescribedBy ;
                        owl:someValuesFrom iof-constr:PlanSpecification ] ) ] ;
    skos:example "A tire manufacturing process occurs as prescribed by a manufacturing plan specification."@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/OBI_0000011" ;
    iof-av:counterExample "unexpected failure events; unexpected malfunctioning of a machine; safety occurrence (that lacks explicit plan specifications);" ;
    iof-av:explanatoryNote """1. 'Planned' is here functioning as a specifier, rather than as a modifier analogous to 'cancelled' or 'averted'. Therefore, to say that a process is planned is not to say that it has not yet taken place. Rather, it is to say that it is (was or will have been) protocol-driven, instruction-driven, command-driven, or software-driven, or in some combination thereof.

2. 'Planned' means 'protocol driven'. Protocols may be written, spoken, or simply thought – as when upon waking up, we plan, for instance, what to eat for breakfast.""" ;
    iof-av:firstOrderLogicDefinition "PlannedProcess(x) ↔ Process(x) ∧ ∃s(PlanSpecification(s) ∧ prescribes(s,x))" ;
    iof-av:naturalLanguageDefinition "process that is prescribed by a plan specification"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'planned process' is defined as exactly an instance of 'process' that is 'prescribed by' some 'plan specification'" .

iof-constr:ValueExpression a owl:Class ;
    rdfs:label "value expression"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:onProperty iof-constr:isValueExpressionOfAtSomeTime ;
            owl:someValuesFrom bfo:BFO_0000001 ],
        iof-constr:InformationContentEntity ;
    skos:example "1cm is the value expression of the diameter of a screw head that is specified in its design; 37C is the value expression of the temperature of a bioreactor measured during the production process; \"low risk\" is the value expression of a process parameter based on the risk analysis classification scheme; 3 g/l is the value expression of titer of an antibody generated by a process simulation"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/OBI_0001933" ;
    iof-av:explanatoryNote """1. Value expressions comprehend qualitative, semi-quantitative, or quantitative values.

2. All value expressions have a value associated with them through ‘has simple expression value’. This part is not formally captured as we do not want to impose a specific datatype constraint (e.g., xsd:int,rdfs:Literal) with the value expression. Nevertheless, any instance of ‘value expression’ MUST have a ‘has simple expression value’ or its subproperty pointing to a value.

3. This class is intended to provide a single framework for representing unit-value pairs and the connection between a value and a particular classification scheme in the case of qualitative values. While currently, IOF still needs to define classification schemes and quantitative scales, this class is compatible with and thus can be mapped to external ontologies such as the QUDT and the Units Ontology to get the necessary representation of units.""" ;
    iof-av:firstOrderLogicAxiom "ValueExpression(x) → InformationContentEntity(x) ∧ ∃e(Entity(e) ∧ isValueExpressionOfAtSomeTime(x,e))" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "information content entity that contains a value of an entity within a classification scheme or on a quantitative scale"@en-US ;
    iof-av:primitiveRationale "There are insufficient constructs to create necessary and sufficient conditions. Namely constructs for representing classification schemes and quantitative scales are still missing." ;
    iof-av:semiFormalNaturalLanguageAxiom "If x is a 'value expression' then x is an 'information content entity' that 'is value expression of at some time' some 'entity'" ;
    iof-av:synonym "value information content entity"@en-US .

iof-constr:hasRole a owl:ObjectProperty ;
    rdfs:label "has role"@en-US ;
    rdfs:domain bfo:BFO_0000004 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000023 ;
    rdfs:subPropertyOf bfo:BFO_0000196 ;
    owl:inverseOf iof-constr:roleOf ;
    skos:example "this person has role this investigator role (more colloquially: this person has this role of investigator)"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000087" ;
    iof-av:explanatoryNote "A bearer can have many roles, and its roles can exist for different periods of time, but none of its roles can exist when the bearer does not exist. A role need not be realized at all the times that the role exists."@en-US ;
    iof-av:firstOrderLogicAxiom "hasRole(x,y) → IndependentContinuant(x) ∧ Role(y) ∧ bearerOf(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from an independent continuant (the bearer) to a role, in which the role specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x has role y holds when x is a 'independent continuant' and y is a 'role' and x is 'bearer of' y" .

iof-constr:prescribes a owl:ObjectProperty ;
    rdfs:label "prescribes"@en-US ;
    rdfs:domain iof-constr:InformationContentEntity ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000001 ;
    rdfs:subPropertyOf iof-constr:isAbout ;
    skos:example "a blueprint serves as a model of some Artifact or Facility; a professional code of conduct serves as a set of rules to be followed while acting in a role within that profession; an Operations Plan serves as a guide for the tasks that need to be performed to achieve the Objectives of the Operation"@en-US ;
    iof-av:adaptedFrom "http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology"^^xsd:anyURI ;
    iof-av:naturalLanguageDefinition "relation from an information content entity to an entity such that the information content entity serves as a collection of rules or guide for the entity if the entity is something that unfolds in time (occurrent), or as a model if the entity is someone or something physical or digital (continuant)"@en-US .

iof-constr:roleOf a owl:ObjectProperty ;
    rdfs:label "role of"@en-US ;
    rdfs:domain bfo:BFO_0000023 ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:range bfo:BFO_0000004 ;
    rdfs:subPropertyOf bfo:BFO_0000197 ;
    skos:example "this investigator role is a role of this person"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/RO_0000081" ;
    iof-av:firstOrderLogicAxiom "roleOf(x,y) → Role(x) ∧ IndependentContinuant(y) ∧ inheresIn(x,y)" ;
    iof-av:naturalLanguageDefinition "relation from a role to an independent continuant (the bearer), in which the role specifically depends on the bearer for its existence"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "x disposition of y holds when x is a 'role' and y is a 'independent continuant' and x is 'inheres in' y" .

iof-constr:Agent a owl:Class ;
    rdfs:label "agent"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000040 ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( [ a owl:Class ;
                        owl:unionOf ( iof-constr:EngineeredSystem iof-constr:GroupOfAgents iof-constr:Person ) ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:hasRole ;
                        owl:someValuesFrom iof-constr:AgentRole ] ) ] ;
    skos:example "an employee; a transportation & logistics provider; a robot; a scheduling system"@en-US ;
    iof-av:counterExample """1. Of physical and chemical in nature: Cleaning, vulcanizing, fluxing, indicator, sterilizing, emulisifying, refining.

2. Organisms: animals, cells, parts of organisms (organs, organelles, viruses).""" ;
    iof-av:explanatoryNote """1. See the expanded definition under the corresponding role class. The term is formalized here as a defined class by referring to its corresponding role class and exists primarily for ontological modeling and implementation convenience.

2. The IOF has elected to exclude material substances often referred to as agents. That is, they realize some specific function that some person desires (e.g., platinum is a reducing agent in various reduction-type reactions -- as used in a catalytic converter to eliminate or reduce various pollutants in exhausts).

3. The IOF has, at this time, excluded non-human agents, such as animals and other organisms (often referred to as biological agents).""" ;
    iof-av:firstOrderLogicDefinition "Agent(x) ↔ (Person(x) ∨ GroupOfAgents(x) ∨ EngineeredSystem(x)) ∧ ∃r(AgentRole(r) ∧ hasRole(x,r))" ;
    iof-av:naturalLanguageDefinition "person, group of persons, or engineered system with an agent role"@en-US ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'agent' is defined as exactly an instance of 'person', 'group of agents', or 'engineered system' when it 'has role' some 'agent role'" .

iof-constr:Person a owl:Class ;
    rdfs:label "person"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000030 ;
    skos:example "any individual human being"@en-US ;
    iof-av:adaptedFrom "http://purl.obolibrary.org/obo/MF_0000016" ;
    iof-av:firstOrderLogicAxiom "Person(x) → Object(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "organism that is the member of the species of homo sapiens"@en-US ;
    iof-av:primitiveRationale "This term is expected to remain primitive. While the IOF might introduce a term for 'organism' in the future, speciation is out of the scope of IOF and should be utilized if needed from a biological ontology" ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'person' then x is an 'object'" ;
    iof-av:synonym "human being"@en-US .

bfo:BFO_0000057 owl:propertyChainAxiom ( bfo:BFO_0000117 bfo:BFO_0000057 ) ;
    iof-av:explanatoryNote "the IOF has decided to include transitive participation as an additional axiom of 'has participant at some time' which is reflected in the property chain associated with this property. That is, if A has an 'occurent part' B which 'has participant at some time' C then A 'has participant at some time' C." .

iof-constr:Organization a owl:Class ;
    rdfs:label "organization"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf [ a owl:Restriction ;
            owl:allValuesFrom [ a owl:Class ;
                    owl:unionOf ( iof-constr:Organization iof-constr:Person ) ] ;
            owl:onProperty bfo:BFO_0000115 ],
        [ a owl:Restriction ;
            owl:allValuesFrom iof-constr:Organization ;
            owl:onProperty bfo:BFO_0000174 ],
        iof-constr:OrganizedGroupOfAgents ;
    owl:equivalentClass [ a owl:Class ;
            owl:intersectionOf ( iof-constr:OrganizedGroupOfAgents [ a owl:Restriction ;
                        owl:onProperty bfo:BFO_0000172 ;
                        owl:someValuesFrom iof-constr:Person ] [ a owl:Restriction ;
                        owl:onProperty iof-constr:designatedBy ;
                        owl:someValuesFrom iof-constr:OrganizationIdentifier ] ) ] ;
    skos:example "goverment, a company, a political party, a city goverment, yakuza, department, division"@en-US ;
    iof-av:adaptedFrom "https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/Organization" ;
    iof-av:explanatoryNote """1. An organization may have a set of organizational rules that, among other things, prescribe a set of roles and responsibilities its members bear, how important decisions are made, and how members should behave when acting on behalf of the organization.
2. As introduced here, the mere gathering of a group of persons does not imply the existence of an organization, unless and until such members agree to form an organization and have agreed to a common set of objectives as mentioned in point 1."""@en-US ;
    iof-av:firstOrderLogicAxiom "Organization(x) → ∀y(hasMemberPartAtSomeTime(x,y) → (Person(y) ∨ Organization(y))) ∧ ∀z(hasProperContinuantPartAtSomeTime(x,z) → Organization(z))" ;
    iof-av:firstOrderLogicDefinition "Organization(x) ↔ OrganizedGroupOfAgents(x) ∧ ∃p∃i(Person(p) ∧OrganizationIdentifier(i) ∧ designatedBy(x,i) ∧ hasMemberPartAtAllTimes(x,p))" ;
    iof-av:naturalLanguageDefinition "group of persons that identifies itself by some name and pursues a common set of plans and objectives"@en-US ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is an 'organization' then whenever x 'has member part at some time' y that y must be a 'peson' or 'organization' and whenever x 'has proper continuant part at some time' z that z must be a 'organization'" ;
    iof-av:semiFormalNaturalLanguageDefinition "every instance of 'organization' is defined exactly as an instance of 'organized group of agents' that is 'designated by' some 'organization identifier' and that 'has member part at all times' one or more 'person'" ;
    iof-av:usageNote "Members of organizations are people or other organizations. However, an organization may be composed of several sub-organizations (e.g., departments). This composition should be modeled through 'proper continuant part' relations." .

bfo:BFO_0000202 iof-av:explanatoryNote """1. The ‘first instant of’ a ‘temporal interval’ should ‘precede’ the ‘last instant of’ that ‘temporal interval’. Therefore, the date-time asserted (i.e., ‘has date-time instant value’ of the ‘temporal instant value expression’ that ‘is value expression of at all times’ of the ‘temporal instant’) for the first instant should be before the last instant in terms their positions in the corresponding calendar and clock system. For example, the first instant and last instant of a ‘temporal interval’ are 2002-10-10T17:00:00Z and 2002-10-11T01:40:00Z.
2. If only one date-time is available for the interval due to lack of data or an interval being smaller than the tick time (the smallest duration by which the time progresses) then the date-time should be asserted either only for first instant or only for last instant of every interval uniformly for the entire knowledge base. For example, Barack Obama gained the role of presidency on 20 January 2009 should be modeled as the process p of type ‘gain of role’ ‘occupies temporal region’ r (a ‘temporal interval’) which ‘has last instant’ i (a ‘temporal instant’) which ‘has value expression at all times’ v (a ‘temporal instant value expression’) which ‘has data-time value’ 2009-01-20T00:00:00Z."""@en-US .

iof-constr:InformationContentEntity a owl:Class ;
    rdfs:label "information content entity"@en-US ;
    rdfs:isDefinedBy "https://spec.industrialontologies.org/ontology/core/Core/"^^xsd:anyURI ;
    rdfs:subClassOf bfo:BFO_0000031 ;
    skos:example "the content of an email; the content of a document; the content in a CAD file; an algorithm for solving the quadratic equation; a guide or standard for writing and formatting conference papers."@en-US ;
    iof-av:abbreviation "ICE" ;
    iof-av:adaptedFrom "Information Artifact Ontology, http://purl.obolibrary.org/obo/IAO_0000030 and also the Common Core Ontology, http://www.ontologyrepository.com/CommonCoreOntologies/Mid/InformationEntityOntology" ;
    iof-av:explanatoryNote """1. Information content entity is intended to be a class of entities whose instances represent some distinct content or pattern independent from the various ways of conveying it by physical, electronic, or other means. For example, three instances of information bearers -- a bar chart, a color-coded map, and a written report -- each conveying the GDP of Countries for the year 2010, are each different carriers of the same information content. It is this content that is generically dependent upon its carrier. This treatment of information content entity leads to a principle of subtyping based upon the relationship that ICE's have with the entity they are about rather than attributes such as format, language, measurement scale, or media. The latter are treated here as various qualities of the material entities that have them.

2. Information content entities are typically textual or schematic.""" ;
    iof-av:firstOrderLogicAxiom "GenericallyDependentContinuant(x) ∧ ∃e(Entity(e) ∧ isAbout(x,e)) → InformationContentEntity(x)" ;
    iof-av:isPrimitive true ;
    iof-av:naturalLanguageDefinition "content or a pattern (generically dependent continuant) that is about some entity"@en-US ;
    iof-av:primitiveRationale "Information content entities may well \"be about\" entity types for which no instances ever come into existence (e.g., a plan or requirement not implemented or satisfied, a command or directive never obeyed or followed, or an objective never achieved). IOF's current approach to modeling such informational entity types is to provide one or more sufficient conditions that can be readily expressed in OWL." ;
    iof-av:semiFormalNaturalLanguageAxiom "if x is a 'generically dependent continuant' that 'is about' some 'entity' then x is an 'information content entity'" ;
    iof-av:synonym "Information"@en-US .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:ObjectiveSpecification ;
    owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                owl:onProperty iof-constr:isAchievedByAtSomeTime ;
                owl:someValuesFrom bfo:BFO_0000015 ] [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom [ a owl:Class ;
                        owl:unionOf ( iof-constr:Capability iof-constr:ProcessCharacteristic [ a owl:Class ;
                                    owl:intersectionOf ( bfo:BFO_0000002 [ a owl:Restriction ;
                                                owl:onProperty iof-constr:isOutputOf ;
                                                owl:someValuesFrom bfo:BFO_0000015 ] ) ] ) ] ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:CommercialServiceSpecification ;
    owl:intersectionOf ( iof-constr:PlanSpecification [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom iof-constr:CommercialService ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:ActionSpecification ;
    owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom bfo:BFO_0000015 ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:Algorithm ;
    owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom iof-constr:EncodedAlgorithm ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:BusinessFunction ;
    owl:intersectionOf ( bfo:BFO_0000034 [ a owl:Restriction ;
                owl:onProperty bfo:BFO_0000054 ;
                owl:someValuesFrom iof-constr:BusinessProcess ] [ a owl:Restriction ;
                owl:onProperty iof-constr:functionOf ;
                owl:someValuesFrom iof-constr:Organization ] [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribedBy ;
                owl:someValuesFrom [ a owl:Class ;
                        owl:intersectionOf ( iof-constr:ObjectiveSpecification [ a owl:Restriction ;
                                    owl:onProperty bfo:BFO_0000084 ;
                                    owl:someValuesFrom iof-constr:Organization ] ) ] ] ) .

[] a owl:AllDisjointClasses ;
    owl:members ( iof-constr:EngineeredSystem iof-constr:MaterialArtifact iof-constr:Organization ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:DesignSpecification ;
    owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom bfo:BFO_0000002 ] [ a owl:Restriction ;
                owl:onProperty iof-constr:satisfiesRequirement ;
                owl:someValuesFrom iof-constr:RequirementSpecification ] [ a owl:Restriction ;
                owl:allValuesFrom bfo:BFO_0000002 ;
                owl:onProperty iof-constr:prescribes ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:InformationContentEntity ;
    owl:intersectionOf ( bfo:BFO_0000031 [ a owl:Restriction ;
                owl:onProperty iof-constr:isAbout ;
                owl:someValuesFrom bfo:BFO_0000001 ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:PlanSpecification ;
    owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                owl:onProperty bfo:BFO_0000110 ;
                owl:someValuesFrom iof-constr:ActionSpecification ] [ a owl:Restriction ;
                owl:onProperty bfo:BFO_0000110 ;
                owl:someValuesFrom iof-constr:ObjectiveSpecification ] [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom iof-constr:PlannedProcess ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:RequirementSpecification ;
    owl:intersectionOf ( iof-constr:InformationContentEntity [ a owl:Restriction ;
                owl:onProperty iof-constr:requirementSatisfiedBy ;
                owl:someValuesFrom bfo:BFO_0000001 ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:CommercialServiceAgreement ;
    owl:intersectionOf ( iof-constr:Agreement [ a owl:Restriction ;
                owl:onProperty iof-constr:isAbout ;
                owl:someValuesFrom iof-constr:CommercialService ] [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom iof-constr:CustomerRole ] [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom iof-constr:ServiceProviderRole ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:EncodedAlgorithm ;
    owl:intersectionOf ( iof-constr:PlanSpecification [ a owl:Restriction ;
                owl:onProperty iof-constr:prescribes ;
                owl:someValuesFrom iof-constr:ComputingProcess ] ) .

[] a owl:Class ;
    rdfs:subClassOf iof-constr:Assembly ;
    owl:intersectionOf ( iof-constr:MaterialArtifact [ a owl:Restriction ;
                owl:onProperty iof-constr:isSpecifiedOutputOf ;
                owl:someValuesFrom iof-constr:AssemblyProcess ] ) .


```


## Schema Dependency Hierarchy

- **bfo**: [http://purl.obolibrary.org/obo/bfo.owl](http://purl.obolibrary.org/obo/bfo.owl) (Local: `bfo/bfo.ttl`, `bfo/bfo.rdf`, `bfo/bfo.jsonld`, `bfo/bfo.compacted.jsonld`)
  - **brick**: [https://brickschema.org/schema/Brick#](https://brickschema.org/schema/Brick#) (Local: `brick/brick.ttl`)
  - **csvw**: [http://www.w3.org/ns/csvw#](http://www.w3.org/ns/csvw#) (Local: `csvw/csvw.ttl`)
  - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
  - **dcat**: [http://www.w3.org/ns/dcat#](http://www.w3.org/ns/dcat#) (Local: `dcat/dcat.ttl`)
  - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
  - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
  - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
  - **obo**: [http://purl.obolibrary.org/obo/](http://purl.obolibrary.org/obo/) (Local: `obo/obo.ttl`)
  - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
  - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
  - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
  - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
  - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
  - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
  - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
  - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
  - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
  - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
  - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
  - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
- **iof**: [https://spec.industrialontologies.org/ontology/core/Core/](https://spec.industrialontologies.org/ontology/core/Core/) (Local: `iof/iof.ttl`, `iof/iof.rdf`, `iof/iof.jsonld`, `iof/iof.compacted.jsonld`)
  - **bfo**: [http://purl.obolibrary.org/obo/](http://purl.obolibrary.org/obo/) (Local: `bfo/bfo.ttl`, `bfo/bfo.rdf`, `bfo/bfo.jsonld`, `bfo/bfo.compacted.jsonld`)
  - **brick**: [https://brickschema.org/schema/Brick#](https://brickschema.org/schema/Brick#) (Local: `brick/brick.ttl`, `brick/brick.rdf`, `brick/brick.jsonld`, `brick/brick.compacted.jsonld`)
    - **bacnet**: [http://data.ashrae.org/bacnet/2020#](http://data.ashrae.org/bacnet/2020#) (Local: `bacnet/bacnet.ttl`)
    - **csvw**: [http://www.w3.org/ns/csvw#](http://www.w3.org/ns/csvw#) (Local: `csvw/csvw.ttl`, `csvw/csvw.rdf`, `csvw/csvw.jsonld`, `csvw/csvw.compacted.jsonld`)
      - **as**: [https://www.w3.org/ns/activitystreams#](https://www.w3.org/ns/activitystreams#) (Local: `as/as.ttl`, `as/as.rdf`, `as/as.jsonld`, `as/as.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
      - **cc**: [http://creativecommons.org/ns#](http://creativecommons.org/ns#) (Local: `cc/cc.ttl`)
      - **ctag**: [http://commontag.org/ns#](http://commontag.org/ns#) (Local: `ctag/ctag.ttl`)
      - **dc11**: [http://purl.org/dc/elements/1.1/](http://purl.org/dc/elements/1.1/) (Local: `dc11/dc11.ttl`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
      - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
        - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
        - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
        - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
        - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
        - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
        - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
        - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **dcat**: [http://www.w3.org/ns/dcat#](http://www.w3.org/ns/dcat#) (Local: `dcat/dcat.ttl`, `dcat/dcat.rdf`, `dcat/dcat.jsonld`, `dcat/dcat.compacted.jsonld`)
        - **adms**: [http://www.w3.org/ns/adms#](http://www.w3.org/ns/adms#) (Local: `adms/adms.ttl`)
          - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
            - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
            - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
            - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
            - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
            - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
            - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
            - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
            - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
            - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
            - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
            - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
            - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
            - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
            - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
            - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
            - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
            - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
            - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
            - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
            - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
            - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
            - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
            - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
            - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
            - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
            - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
            - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
            - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
            - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
            - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
            - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
            - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
            - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
            - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
            - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
            - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
            - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
            - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
          - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
          - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
            - **cc**: [http://creativecommons.org/ns#](http://creativecommons.org/ns#) (Local: `cc/cc.ttl`)
            - **frbr**: [http://purl.org/vocab/frbr/core#](http://purl.org/vocab/frbr/core#) (Local: `frbr/frbr.ttl`)
            - **vs**: [http://www.w3.org/2003/06/sw-vocab-status/ns#](http://www.w3.org/2003/06/sw-vocab-status/ns#) (Local: `vs/vs.ttl`)
          - **wdrs**: [http://www.w3.org/2007/05/powder-s#](http://www.w3.org/2007/05/powder-s#) (Local: `wdrs/wdrs.ttl`)
          - **xhv**: [http://www.w3.org/1999/xhtml/vocab#](http://www.w3.org/1999/xhtml/vocab#) (Local: `xhv/xhv.ttl`)
        - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
          - **dc1**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dc1/dc1.ttl`)
          - **vs**: [http://www.w3.org/2003/06/sw-vocab-status/ns#](http://www.w3.org/2003/06/sw-vocab-status/ns#) (Local: `vs/vs.ttl`)
        - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
          - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
            - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
            - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
            - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
            - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
            - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
            - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
            - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
            - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
          - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
            - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
            - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
            - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
            - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
            - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
            - **sdo**: [https://schema.org/](https://schema.org/) (Local: `sdo/sdo.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **spec11**: [http://www.opengis.net/spec/geosparql/1.1/specification.html#](http://www.opengis.net/spec/geosparql/1.1/specification.html#) (Local: `spec11/spec11.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
            - **cc**: [http://creativecommons.org/ns#](http://creativecommons.org/ns#) (Local: `cc/cc.ttl`)
            - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
            - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
            - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
            - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
            - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
            - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
            - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
            - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
            - **gr**: [http://purl.org/goodrelations/v1#](http://purl.org/goodrelations/v1#) (Local: `gr/gr.ttl`)
            - **owlTime**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `owlTime/owlTime.ttl`)
            - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
            - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
            - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
            - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
            - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
            - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
            - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
            - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
            - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
            - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
            - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
            - **scovo**: [http://purl.org/NET/scovo#](http://purl.org/NET/scovo#) (Local: `scovo/scovo.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
            - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
            - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
            - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
            - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
            - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
            - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
            - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
            - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
            - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
            - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
            - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
            - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
            - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
            - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
            - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
            - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
            - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
            - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
            - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
            - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
            - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
            - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
            - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
            - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
            - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
            - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
            - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
            - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
            - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
            - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
            - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
            - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
            - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
            - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
            - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
            - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
            - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
            - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
            - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
            - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
            - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
            - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
            - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
            - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
            - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
          - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
          - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
        - **dctype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dctype/dctype.ttl`)
        - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
        - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
        - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
        - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
        - **pav**: [http://purl.org/pav/](http://purl.org/pav/) (Local: `pav/pav.ttl`)
          - **pav1**: [http://swan.mindinformatics.org/ontologies/1.2/pav/](http://swan.mindinformatics.org/ontologies/1.2/pav/) (Local: `pav1/pav1.ttl`)
        - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
        - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
        - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
        - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **sdo**: [http://schema.org/](http://schema.org/) (Local: `sdo/sdo.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
        - **xhv**: [http://www.w3.org/1999/xhtml/vocab#](http://www.w3.org/1999/xhtml/vocab#) (Local: `xhv/xhv.ttl`)
      - **dctypes**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dctypes/dctypes.ttl`)
      - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
      - **dqv**: [http://www.w3.org/ns/dqv#](http://www.w3.org/ns/dqv#) (Local: `dqv/dqv.ttl`, `dqv/dqv.rdf`, `dqv/dqv.jsonld`, `dqv/dqv.compacted.jsonld`)
        - **daq**: [http://purl.org/eis/vocab/daq#](http://purl.org/eis/vocab/daq#) (Local: `daq/daq.ttl`)
        - **duv**: [http://www.w3.org/ns/duv#](http://www.w3.org/ns/duv#) (Local: `duv/duv.ttl`)
          - **biro**: [http://purl.org/spar/biro/](http://purl.org/spar/biro/) (Local: `biro/biro.ttl`)
          - **disco**: [http://rdf-vocabulary.ddialliance.org/discovery#](http://rdf-vocabulary.ddialliance.org/discovery#) (Local: `disco/disco.ttl`)
            - **dcmitype1**: [http://purl.org/dc/terms/DCMIType](http://purl.org/dc/terms/DCMIType) (Local: `dcmitype1/dcmitype1.ttl`)
            - **xkos**: [http://purl.org/linked-data/xkos#](http://purl.org/linked-data/xkos#) (Local: `xkos/xkos.ttl`)
          - **frbr**: [http://purl.org/vocab/frbr/core#](http://purl.org/vocab/frbr/core#) (Local: `frbr/frbr.ttl`)
        - **oa**: [http://www.w3.org/ns/oa#](http://www.w3.org/ns/oa#) (Local: `oa/oa.ttl`)
          - **acl**: [http://www.w3.org/ns/auth/acl#](http://www.w3.org/ns/auth/acl#) (Local: `acl/acl.ttl`)
            - **gen**: [http://www.w3.org/2006/gen/ont#](http://www.w3.org/2006/gen/ont#) (Local: `gen/gen.ttl`)
          - **as**: [http://www.w3.org/ns/activitystreams#](http://www.w3.org/ns/activitystreams#) (Local: `as/as.ttl`)
          - **cnt**: [http://www.w3.org/2011/content#](http://www.w3.org/2011/content#) (Local: `cnt/cnt.ttl`)
          - **exif**: [http://www.w3.org/2003/12/exif/ns#](http://www.w3.org/2003/12/exif/ns#) (Local: `exif/exif.ttl`)
            - **ex**: [http://example.org/](http://example.org/) (Local: `ex/ex.ttl`)
          - **geo1**: [http://www.w3.org/2003/01/geo/wgs84_pos#](http://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `geo1/geo1.ttl`)
          - **gr**: [http://purl.org/goodrelations/v1#](http://purl.org/goodrelations/v1#) (Local: `gr/gr.ttl`)
          - **iana**: [http://www.iana.org/assignments/relation/](http://www.iana.org/assignments/relation/) (Local: `iana/iana.ttl`)
          - **iiif**: [http://iiif.io/api/image/2#](http://iiif.io/api/image/2#) (Local: `iiif/iiif.ttl`)
          - **ldp**: [http://www.w3.org/ns/ldp#](http://www.w3.org/ns/ldp#) (Local: `ldp/ldp.ttl`)
          - **ore**: [http://www.openarchives.org/ore/terms/](http://www.openarchives.org/ore/terms/) (Local: `ore/ore.ttl`)
            - **rdfg**: [http://www.w3.org/2004/03/trix/rdfg-1/](http://www.w3.org/2004/03/trix/rdfg-1/) (Local: `rdfg/rdfg.ttl`)
          - **pcdm**: [http://pcdm.org/models#](http://pcdm.org/models#) (Local: `pcdm/pcdm.ttl`)
          - **sc**: [http://iiif.io/api/presentation/2#](http://iiif.io/api/presentation/2#) (Local: `sc/sc.ttl`)
          - **sioc**: [http://rdfs.org/sioc/ns#](http://rdfs.org/sioc/ns#) (Local: `sioc/sioc.ttl`)
          - **svcs**: [http://rdfs.org/sioc/services#](http://rdfs.org/sioc/services#) (Local: `svcs/svcs.ttl`)
          - **trig**: [http://www.w3.org/2004/03/trix/rdfg-1/](http://www.w3.org/2004/03/trix/rdfg-1/) (Local: `trig/trig.ttl`)
        - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
      - **duv**: [https://www.w3.org/TR/vocab-duv#](https://www.w3.org/TR/vocab-duv#) (Local: `duv/duv.ttl`)
      - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`, `geo/geo.rdf`, `geo/geo.jsonld`, `geo/geo.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
        - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
        - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
        - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
        - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
        - **sdo**: [https://schema.org/](https://schema.org/) (Local: `sdo/sdo.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **spec11**: [http://www.opengis.net/spec/geosparql/1.1/specification.html#](http://www.opengis.net/spec/geosparql/1.1/specification.html#) (Local: `spec11/spec11.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **gr**: [http://purl.org/goodrelations/v1#](http://purl.org/goodrelations/v1#) (Local: `gr/gr.ttl`, `gr/gr.rdf`, `gr/gr.jsonld`, `gr/gr.compacted.jsonld`)
      - **grddl**: [http://www.w3.org/2003/g/data-view#](http://www.w3.org/2003/g/data-view#) (Local: `grddl/grddl.ttl`, `grddl/grddl.rdf`, `grddl/grddl.jsonld`, `grddl/grddl.compacted.jsonld`)
        - **admin**: [http://webns.net/mvcb/](http://webns.net/mvcb/) (Local: `admin/admin.ttl`)
      - **ical**: [http://www.w3.org/2002/12/cal/icaltzd#](http://www.w3.org/2002/12/cal/icaltzd#) (Local: `ical/ical.ttl`)
      - **ldp**: [http://www.w3.org/ns/ldp#](http://www.w3.org/ns/ldp#) (Local: `ldp/ldp.ttl`, `ldp/ldp.rdf`, `ldp/ldp.jsonld`, `ldp/ldp.compacted.jsonld`)
        - **vs**: [http://www.w3.org/2003/06/sw-vocab-status/ns#](http://www.w3.org/2003/06/sw-vocab-status/ns#) (Local: `vs/vs.ttl`)
      - **ma**: [http://www.w3.org/ns/ma-ont#](http://www.w3.org/ns/ma-ont#) (Local: `ma/ma.ttl`, `ma/ma.rdf`, `ma/ma.jsonld`, `ma/ma.compacted.jsonld`)
      - **oa**: [http://www.w3.org/ns/oa#](http://www.w3.org/ns/oa#) (Local: `oa/oa.ttl`, `oa/oa.rdf`, `oa/oa.jsonld`, `oa/oa.compacted.jsonld`)
        - **acl**: [http://www.w3.org/ns/auth/acl#](http://www.w3.org/ns/auth/acl#) (Local: `acl/acl.ttl`)
        - **as**: [http://www.w3.org/ns/activitystreams#](http://www.w3.org/ns/activitystreams#) (Local: `as/as.ttl`)
        - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
        - **cnt**: [http://www.w3.org/2011/content#](http://www.w3.org/2011/content#) (Local: `cnt/cnt.ttl`)
        - **exif**: [http://www.w3.org/2003/12/exif/ns#](http://www.w3.org/2003/12/exif/ns#) (Local: `exif/exif.ttl`)
        - **geo1**: [http://www.w3.org/2003/01/geo/wgs84_pos#](http://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `geo1/geo1.ttl`)
        - **iana**: [http://www.iana.org/assignments/relation/](http://www.iana.org/assignments/relation/) (Local: `iana/iana.ttl`)
        - **iiif**: [http://iiif.io/api/image/2#](http://iiif.io/api/image/2#) (Local: `iiif/iiif.ttl`)
        - **ore**: [http://www.openarchives.org/ore/terms/](http://www.openarchives.org/ore/terms/) (Local: `ore/ore.ttl`)
        - **pcdm**: [http://pcdm.org/models#](http://pcdm.org/models#) (Local: `pcdm/pcdm.ttl`)
        - **sc**: [http://iiif.io/api/presentation/2#](http://iiif.io/api/presentation/2#) (Local: `sc/sc.ttl`)
        - **sioc**: [http://rdfs.org/sioc/ns#](http://rdfs.org/sioc/ns#) (Local: `sioc/sioc.ttl`)
        - **svcs**: [http://rdfs.org/sioc/services#](http://rdfs.org/sioc/services#) (Local: `svcs/svcs.ttl`)
        - **trig**: [http://www.w3.org/2004/03/trix/rdfg-1/](http://www.w3.org/2004/03/trix/rdfg-1/) (Local: `trig/trig.ttl`)
      - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`, `odrl/odrl.rdf`, `odrl/odrl.jsonld`, `odrl/odrl.compacted.jsonld`)
        - **cc**: [http://creativecommons.org/ns#](http://creativecommons.org/ns#) (Local: `cc/cc.ttl`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
        - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
        - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
        - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
        - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
        - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **og**: [http://ogp.me/ns#](http://ogp.me/ns#) (Local: `og/og.ttl`)
      - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`, `org/org.rdf`, `org/org.jsonld`, `org/org.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
        - **gr**: [http://purl.org/goodrelations/v1#](http://purl.org/goodrelations/v1#) (Local: `gr/gr.ttl`)
        - **owlTime**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `owlTime/owlTime.ttl`)
        - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
        - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
        - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
        - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`, `prof/prof.rdf`, `prof/prof.jsonld`, `prof/prof.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
        - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
        - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
        - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`, `prov/prov.rdf`, `prov/prov.jsonld`, `prov/prov.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
        - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`, `qb/qb.rdf`, `qb/qb.jsonld`, `qb/qb.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **scovo**: [http://purl.org/NET/scovo#](http://purl.org/NET/scovo#) (Local: `scovo/scovo.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **rdfa**: [http://www.w3.org/ns/rdfa#](http://www.w3.org/ns/rdfa#) (Local: `rdfa/rdfa.ttl`, `rdfa/rdfa.rdf`, `rdfa/rdfa.jsonld`, `rdfa/rdfa.compacted.jsonld`)
      - **rev**: [http://purl.org/stuff/rev#](http://purl.org/stuff/rev#) (Local: `rev/rev.ttl`)
      - **rif**: [http://www.w3.org/2007/rif#](http://www.w3.org/2007/rif#) (Local: `rif/rif.ttl`, `rif/rif.rdf`, `rif/rif.jsonld`, `rif/rif.compacted.jsonld`)
        - **xs**: [http://www.w3.org/2001/XMLSchema](http://www.w3.org/2001/XMLSchema) (Local: `xs/xs.ttl`)
      - **rr**: [http://www.w3.org/ns/r2rml#](http://www.w3.org/ns/r2rml#) (Local: `rr/rr.ttl`, `rr/rr.rdf`, `rr/rr.jsonld`, `rr/rr.compacted.jsonld`)
        - **vaem**: [http://www.linkedmodel.org/schema/vaem#](http://www.linkedmodel.org/schema/vaem#) (Local: `vaem/vaem.ttl`)
          - **voag**: [http://voag.linkedmodel.org/voag/](http://voag.linkedmodel.org/voag/) (Local: `voag/voag.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
        - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
        - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
        - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
        - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
        - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
        - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
        - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
        - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
        - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
        - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
        - **dctype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dctype/dctype.ttl`)
        - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
        - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
        - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
        - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
        - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
        - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
        - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
        - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
        - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
        - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
        - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
        - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
        - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
        - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
        - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
        - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
        - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
        - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
        - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
        - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
        - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
        - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
        - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
        - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
        - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
        - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
        - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
        - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
        - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
        - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
        - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
        - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
        - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
        - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
        - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
        - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
        - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
        - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
        - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
        - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
        - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
        - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
        - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
        - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
        - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
        - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
        - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
        - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
        - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
        - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
        - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
        - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
        - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
        - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
        - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
        - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
        - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
        - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
        - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
        - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
        - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
        - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
        - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
        - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
        - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
        - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
        - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
        - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
      - **sd**: [http://www.w3.org/ns/sparql-service-description#](http://www.w3.org/ns/sparql-service-description#) (Local: `sd/sd.ttl`, `sd/sd.rdf`, `sd/sd.jsonld`, `sd/sd.compacted.jsonld`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`, `sh/sh.rdf`, `sh/sh.jsonld`, `sh/sh.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **sioc**: [http://rdfs.org/sioc/ns#](http://rdfs.org/sioc/ns#) (Local: `sioc/sioc.ttl`, `sioc/sioc.rdf`, `sioc/sioc.jsonld`, `sioc/sioc.compacted.jsonld`)
      - **skosxl**: [http://www.w3.org/2008/05/skos-xl#](http://www.w3.org/2008/05/skos-xl#) (Local: `skosxl/skosxl.ttl`, `skosxl/skosxl.rdf`, `skosxl/skosxl.jsonld`, `skosxl/skosxl.compacted.jsonld`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`, `sosa/sosa.rdf`, `sosa/sosa.jsonld`, `sosa/sosa.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
        - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`, `ssn/ssn.rdf`, `ssn/ssn.jsonld`, `ssn/ssn.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
        - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`, `time/time.rdf`, `time/time.jsonld`, `time/time.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
        - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
        - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
        - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **v**: [http://rdf.data-vocabulary.org/#](http://rdf.data-vocabulary.org/#) (Local: `v/v.ttl`)
      - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`, `vcard/vcard.rdf`, `vcard/vcard.jsonld`, `vcard/vcard.compacted.jsonld`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wdr**: [http://www.w3.org/2007/05/powder#](http://www.w3.org/2007/05/powder#) (Local: `wdr/wdr.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`, `wgs/wgs.rdf`, `wgs/wgs.jsonld`, `wgs/wgs.compacted.jsonld`)
        - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
      - **wrds**: [http://www.w3.org/2007/05/powder-s#](http://www.w3.org/2007/05/powder-s#) (Local: `wrds/wrds.ttl`, `wrds/wrds.rdf`, `wrds/wrds.jsonld`, `wrds/wrds.compacted.jsonld`)
        - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
      - **xhv**: [http://www.w3.org/1999/xhtml/vocab#](http://www.w3.org/1999/xhtml/vocab#) (Local: `xhv/xhv.ttl`)
    - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
      - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
      - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
      - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
      - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
      - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **dcat**: [http://www.w3.org/ns/dcat#](http://www.w3.org/ns/dcat#) (Local: `dcat/dcat.ttl`)
      - **adms**: [http://www.w3.org/ns/adms#](http://www.w3.org/ns/adms#) (Local: `adms/adms.ttl`)
      - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
      - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
      - **dctype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dctype/dctype.ttl`)
      - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
      - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
      - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
      - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
      - **pav**: [http://purl.org/pav/](http://purl.org/pav/) (Local: `pav/pav.ttl`)
      - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **sdo**: [http://schema.org/](http://schema.org/) (Local: `sdo/sdo.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
      - **xhv**: [http://www.w3.org/1999/xhtml/vocab#](http://www.w3.org/1999/xhtml/vocab#) (Local: `xhv/xhv.ttl`)
    - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
      - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
      - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
      - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
      - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
      - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
      - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
    - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
      - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
      - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
      - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **sdo**: [https://schema.org/](https://schema.org/) (Local: `sdo/sdo.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **spec11**: [http://www.opengis.net/spec/geosparql/1.1/specification.html#](http://www.opengis.net/spec/geosparql/1.1/specification.html#) (Local: `spec11/spec11.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
      - **cc**: [http://creativecommons.org/ns#](http://creativecommons.org/ns#) (Local: `cc/cc.ttl`)
      - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
      - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
      - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
      - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
      - **gr**: [http://purl.org/goodrelations/v1#](http://purl.org/goodrelations/v1#) (Local: `gr/gr.ttl`)
      - **owlTime**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `owlTime/owlTime.ttl`)
      - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
      - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
      - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
      - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
      - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **scovo**: [http://purl.org/NET/scovo#](http://purl.org/NET/scovo#) (Local: `scovo/scovo.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **qudt**: [http://qudt.org/schema/qudt/](http://qudt.org/schema/qudt/) (Local: `qudt/qudt.ttl`, `qudt/qudt.rdf`, `qudt/qudt.jsonld`, `qudt/qudt.compacted.jsonld`)
      - **dtype**: [http://www.linkedmodel.org/schema/dtype#](http://www.linkedmodel.org/schema/dtype#) (Local: `dtype/dtype.ttl`, `dtype/dtype.rdf`, `dtype/dtype.jsonld`, `dtype/dtype.compacted.jsonld`)
        - **vaem**: [http://www.linkedmodel.org/schema/vaem#](http://www.linkedmodel.org/schema/vaem#) (Local: `vaem/vaem.ttl`)
      - **vaem**: [http://www.linkedmodel.org/schema/vaem#](http://www.linkedmodel.org/schema/vaem#) (Local: `vaem/vaem.ttl`, `vaem/vaem.rdf`, `vaem/vaem.jsonld`, `vaem/vaem.compacted.jsonld`)
        - **voag**: [http://voag.linkedmodel.org/voag/](http://voag.linkedmodel.org/voag/) (Local: `voag/voag.ttl`)
      - **voag**: [http://voag.linkedmodel.org/schema/voag#](http://voag.linkedmodel.org/schema/voag#) (Local: `voag/voag.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
      - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
      - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
      - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
      - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
      - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
      - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
      - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
      - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
      - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
      - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
      - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
      - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
      - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
      - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
      - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
      - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
      - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
      - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
      - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
      - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
      - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
      - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
      - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
      - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
      - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
      - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
      - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
      - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
      - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
      - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
      - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
      - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
      - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
      - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
      - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
      - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
      - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
      - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **sdo**: [http://schema.org/](http://schema.org/) (Local: `sdo/sdo.ttl`)
      - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
      - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
      - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
      - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
      - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
      - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
      - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
      - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
      - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
      - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
      - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
      - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
      - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
      - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
      - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
      - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
      - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
      - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
      - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
      - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
      - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
      - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
      - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
      - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
      - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
      - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
      - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
      - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
      - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
      - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
      - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
      - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
      - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
      - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
      - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
      - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
      - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
      - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
      - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
      - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
      - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
      - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
      - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
      - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
      - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
      - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **csvw**: [http://www.w3.org/ns/csvw#](http://www.w3.org/ns/csvw#) (Local: `csvw/csvw.ttl`)
    - **as**: [https://www.w3.org/ns/activitystreams#](https://www.w3.org/ns/activitystreams#) (Local: `as/as.ttl`)
    - **cc**: [http://creativecommons.org/ns#](http://creativecommons.org/ns#) (Local: `cc/cc.ttl`)
    - **ctag**: [http://commontag.org/ns#](http://commontag.org/ns#) (Local: `ctag/ctag.ttl`)
    - **dc11**: [http://purl.org/dc/elements/1.1/](http://purl.org/dc/elements/1.1/) (Local: `dc11/dc11.ttl`)
    - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
    - **dcat**: [http://www.w3.org/ns/dcat#](http://www.w3.org/ns/dcat#) (Local: `dcat/dcat.ttl`)
    - **dctypes**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dctypes/dctypes.ttl`)
    - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
    - **dqv**: [http://www.w3.org/ns/dqv#](http://www.w3.org/ns/dqv#) (Local: `dqv/dqv.ttl`)
    - **duv**: [https://www.w3.org/TR/vocab-duv#](https://www.w3.org/TR/vocab-duv#) (Local: `duv/duv.ttl`)
    - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
    - **gr**: [http://purl.org/goodrelations/v1#](http://purl.org/goodrelations/v1#) (Local: `gr/gr.ttl`)
    - **grddl**: [http://www.w3.org/2003/g/data-view#](http://www.w3.org/2003/g/data-view#) (Local: `grddl/grddl.ttl`)
    - **ical**: [http://www.w3.org/2002/12/cal/icaltzd#](http://www.w3.org/2002/12/cal/icaltzd#) (Local: `ical/ical.ttl`)
    - **ldp**: [http://www.w3.org/ns/ldp#](http://www.w3.org/ns/ldp#) (Local: `ldp/ldp.ttl`)
    - **ma**: [http://www.w3.org/ns/ma-ont#](http://www.w3.org/ns/ma-ont#) (Local: `ma/ma.ttl`)
    - **oa**: [http://www.w3.org/ns/oa#](http://www.w3.org/ns/oa#) (Local: `oa/oa.ttl`)
    - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
    - **og**: [http://ogp.me/ns#](http://ogp.me/ns#) (Local: `og/og.ttl`)
    - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **rdfa**: [http://www.w3.org/ns/rdfa#](http://www.w3.org/ns/rdfa#) (Local: `rdfa/rdfa.ttl`)
    - **rev**: [http://purl.org/stuff/rev#](http://purl.org/stuff/rev#) (Local: `rev/rev.ttl`)
    - **rif**: [http://www.w3.org/2007/rif#](http://www.w3.org/2007/rif#) (Local: `rif/rif.ttl`)
    - **rr**: [http://www.w3.org/ns/r2rml#](http://www.w3.org/ns/r2rml#) (Local: `rr/rr.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
    - **sd**: [http://www.w3.org/ns/sparql-service-description#](http://www.w3.org/ns/sparql-service-description#) (Local: `sd/sd.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sioc**: [http://rdfs.org/sioc/ns#](http://rdfs.org/sioc/ns#) (Local: `sioc/sioc.ttl`)
    - **skosxl**: [http://www.w3.org/2008/05/skos-xl#](http://www.w3.org/2008/05/skos-xl#) (Local: `skosxl/skosxl.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **v**: [http://rdf.data-vocabulary.org/#](http://rdf.data-vocabulary.org/#) (Local: `v/v.ttl`)
    - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wdr**: [http://www.w3.org/2007/05/powder#](http://www.w3.org/2007/05/powder#) (Local: `wdr/wdr.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **wrds**: [http://www.w3.org/2007/05/powder-s#](http://www.w3.org/2007/05/powder-s#) (Local: `wrds/wrds.ttl`)
    - **xhv**: [http://www.w3.org/1999/xhtml/vocab#](http://www.w3.org/1999/xhtml/vocab#) (Local: `xhv/xhv.ttl`)
  - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
    - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
    - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
    - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
    - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **dcat**: [http://www.w3.org/ns/dcat#](http://www.w3.org/ns/dcat#) (Local: `dcat/dcat.ttl`)
    - **adms**: [http://www.w3.org/ns/adms#](http://www.w3.org/ns/adms#) (Local: `adms/adms.ttl`)
    - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
    - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
    - **dctype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dctype/dctype.ttl`)
    - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
    - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
    - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
    - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
    - **pav**: [http://purl.org/pav/](http://purl.org/pav/) (Local: `pav/pav.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **sdo**: [http://schema.org/](http://schema.org/) (Local: `sdo/sdo.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
    - **xhv**: [http://www.w3.org/1999/xhtml/vocab#](http://www.w3.org/1999/xhtml/vocab#) (Local: `xhv/xhv.ttl`)
  - **dcmitype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dcmitype/dcmitype.ttl`)
    - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
    - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
    - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
    - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
    - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
  - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
    - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
    - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **sdo**: [https://schema.org/](https://schema.org/) (Local: `sdo/sdo.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **spec11**: [http://www.opengis.net/spec/geosparql/1.1/specification.html#](http://www.opengis.net/spec/geosparql/1.1/specification.html#) (Local: `spec11/spec11.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **iof-av**: [https://spec.industrialontologies.org/ontology/annotation/](https://spec.industrialontologies.org/ontology/annotation/) (Local: `iof-av/iof-av.ttl`, `iof-av/iof-av.rdf`, `iof-av/iof-av.jsonld`, `iof-av/iof-av.compacted.jsonld`)
    - **iof-ind**: [https://spec.industrialontologies.org/ontology/individual/](https://spec.industrialontologies.org/ontology/individual/) (Local: `iof-ind/iof-ind.ttl`)
  - **iof-constr**: [https://spec.industrialontologies.org/ontology/construct/](https://spec.industrialontologies.org/ontology/construct/) (Local: `iof-constr/iof-constr.ttl`)
  - **iof-ind**: [https://spec.industrialontologies.org/ontology/individual/](https://spec.industrialontologies.org/ontology/individual/) (Local: `iof-ind/iof-ind.ttl`)
  - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
    - **cc**: [http://creativecommons.org/ns#](http://creativecommons.org/ns#) (Local: `cc/cc.ttl`)
    - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
    - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
    - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
    - **gr**: [http://purl.org/goodrelations/v1#](http://purl.org/goodrelations/v1#) (Local: `gr/gr.ttl`)
    - **owlTime**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `owlTime/owlTime.ttl`)
    - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
    - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
    - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
    - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
    - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **scovo**: [http://purl.org/NET/scovo#](http://purl.org/NET/scovo#) (Local: `scovo/scovo.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`)
    - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
    - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
    - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
    - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
    - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
    - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
    - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
    - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
    - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
    - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
    - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
    - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
    - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
    - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
    - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
    - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
    - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
    - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
    - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
    - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
    - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
    - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
    - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
    - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
    - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
    - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
    - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
    - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
    - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
    - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
    - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
    - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
    - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
    - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
    - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
    - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
    - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
    - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
    - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
    - **schema1**: [http://schema.org/](http://schema.org/) (Local: `schema1/schema1.ttl`)
    - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
    - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **voaf**: [http://purl.org/vocommons/voaf#](http://purl.org/vocommons/voaf#) (Local: `voaf/voaf.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
    - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
    - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
    - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
  - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
  - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)
- **iof-av**: [https://spec.industrialontologies.org/ontology/core/meta/AnnotationVocabulary/](https://spec.industrialontologies.org/ontology/core/meta/AnnotationVocabulary/) (Local: `iof-av/iof-av.ttl`, `iof-av/iof-av.rdf`, `iof-av/iof-av.jsonld`, `iof-av/iof-av.compacted.jsonld`)
- **iof-cert**: [https://spec.industrialontologies.org/ontology/certification/Certification/](https://spec.industrialontologies.org/ontology/certification/Certification/) (Local: `iof-cert/iof-cert.ttl`, `iof-cert/iof-cert.rdf`, `iof-cert/iof-cert.jsonld`, `iof-cert/iof-cert.compacted.jsonld`)
- **iof-maint**: [https://spec.industrialontologies.org/ontology/maintenance/Maintenance/](https://spec.industrialontologies.org/ontology/maintenance/Maintenance/) (Local: `iof-maint/iof-maint.ttl`, `iof-maint/iof-maint.rdf`, `iof-maint/iof-maint.jsonld`, `iof-maint/iof-maint.compacted.jsonld`)
- **iof-mapping**: [https://spec.industrialontologies.org/ontology/core/commonstocoremapping/MappingCommonsToIOF/](https://spec.industrialontologies.org/ontology/core/commonstocoremapping/MappingCommonsToIOF/) (Local: `iof-mapping/iof-mapping.ttl`, `iof-mapping/iof-mapping.rdf`, `iof-mapping/iof-mapping.jsonld`, `iof-mapping/iof-mapping.compacted.jsonld`)
  - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`, `cmns-col/cmns-col.rdf`, `cmns-col/cmns-col.jsonld`, `cmns-col/cmns-col.compacted.jsonld`)
    - **cmns-av**: [https://www.omg.org/spec/Commons/AnnotationVocabulary/](https://www.omg.org/spec/Commons/AnnotationVocabulary/) (Local: `cmns-av/cmns-av.ttl`, `cmns-av/cmns-av.rdf`, `cmns-av/cmns-av.jsonld`, `cmns-av/cmns-av.compacted.jsonld`)
    - **cmns-txt**: [https://www.omg.org/spec/Commons/TextDatatype/](https://www.omg.org/spec/Commons/TextDatatype/) (Local: `cmns-txt/cmns-txt.ttl`, `cmns-txt/cmns-txt.rdf`, `cmns-txt/cmns-txt.jsonld`, `cmns-txt/cmns-txt.compacted.jsonld`)
  - **cmns-dsg**: [https://www.omg.org/spec/Commons/Designators/](https://www.omg.org/spec/Commons/Designators/) (Local: `cmns-dsg/cmns-dsg.ttl`, `cmns-dsg/cmns-dsg.rdf`, `cmns-dsg/cmns-dsg.jsonld`, `cmns-dsg/cmns-dsg.compacted.jsonld`)
    - **cmns-av**: [https://www.omg.org/spec/Commons/AnnotationVocabulary/](https://www.omg.org/spec/Commons/AnnotationVocabulary/) (Local: `cmns-av/cmns-av.ttl`)
    - **cmns-txt**: [https://www.omg.org/spec/Commons/TextDatatype/](https://www.omg.org/spec/Commons/TextDatatype/) (Local: `cmns-txt/cmns-txt.ttl`)
  - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`, `cmns-id/cmns-id.rdf`, `cmns-id/cmns-id.jsonld`, `cmns-id/cmns-id.compacted.jsonld`)
    - **cmns-av**: [https://www.omg.org/spec/Commons/AnnotationVocabulary/](https://www.omg.org/spec/Commons/AnnotationVocabulary/) (Local: `cmns-av/cmns-av.ttl`)
- **iof-metadata**: [https://spec.industrialontologies.org/ontology/core/Metadatacore/](https://spec.industrialontologies.org/ontology/core/Metadatacore/) (Local: `iof-metadata/iof-metadata.ttl`, `iof-metadata/iof-metadata.rdf`, `iof-metadata/iof-metadata.jsonld`, `iof-metadata/iof-metadata.compacted.jsonld`)
  - **sm**: [http://www.omg.org/techprocess/ab/SpecificationMetadata/](http://www.omg.org/techprocess/ab/SpecificationMetadata/) (Local: `sm/sm.ttl`, `sm/sm.rdf`, `sm/sm.jsonld`, `sm/sm.compacted.jsonld`)
- **iof-planning**: [https://spec.industrialontologies.org/ontology/productionplanning/ProductionPlanning/](https://spec.industrialontologies.org/ontology/productionplanning/ProductionPlanning/) (Local: `iof-planning/iof-planning.ttl`, `iof-planning/iof-planning.rdf`, `iof-planning/iof-planning.jsonld`, `iof-planning/iof-planning.compacted.jsonld`)
- **iof-pss**: [https://spec.industrialontologies.org/ontology/productservicesystem/ProductServiceSystem/](https://spec.industrialontologies.org/ontology/productservicesystem/ProductServiceSystem/) (Local: `iof-pss/iof-pss.ttl`, `iof-pss/iof-pss.rdf`, `iof-pss/iof-pss.jsonld`, `iof-pss/iof-pss.compacted.jsonld`)
- **iof-supply**: [https://spec.industrialontologies.org/ontology/supplychain/SupplyChain/](https://spec.industrialontologies.org/ontology/supplychain/SupplyChain/) (Local: `iof-supply/iof-supply.ttl`, `iof-supply/iof-supply.rdf`, `iof-supply/iof-supply.jsonld`, `iof-supply/iof-supply.compacted.jsonld`)
- **schema**: [https://schema.org/](https://schema.org/) (Local: `schema/schema.ttl`, `schema/schema.rdf`, `schema/schema.jsonld`)
  - **bibo**: [http://purl.org/ontology/bibo/](http://purl.org/ontology/bibo/) (Local: `bibo/bibo.ttl`)
  - **brick**: [https://brickschema.org/schema/Brick#](https://brickschema.org/schema/Brick#) (Local: `brick/brick.ttl`)
  - **cmns-cls**: [https://www.omg.org/spec/Commons/Classifiers/](https://www.omg.org/spec/Commons/Classifiers/) (Local: `cmns-cls/cmns-cls.ttl`)
  - **cmns-col**: [https://www.omg.org/spec/Commons/Collections/](https://www.omg.org/spec/Commons/Collections/) (Local: `cmns-col/cmns-col.ttl`)
  - **cmns-dt**: [https://www.omg.org/spec/Commons/DatesAndTimes/](https://www.omg.org/spec/Commons/DatesAndTimes/) (Local: `cmns-dt/cmns-dt.ttl`)
  - **cmns-ge**: [https://www.omg.org/spec/Commons/GeopoliticalEntities/](https://www.omg.org/spec/Commons/GeopoliticalEntities/) (Local: `cmns-ge/cmns-ge.ttl`)
  - **cmns-id**: [https://www.omg.org/spec/Commons/Identifiers/](https://www.omg.org/spec/Commons/Identifiers/) (Local: `cmns-id/cmns-id.ttl`)
  - **cmns-loc**: [https://www.omg.org/spec/Commons/Locations/](https://www.omg.org/spec/Commons/Locations/) (Local: `cmns-loc/cmns-loc.ttl`)
  - **cmns-q**: [https://www.omg.org/spec/Commons/Quantities/](https://www.omg.org/spec/Commons/Quantities/) (Local: `cmns-q/cmns-q.ttl`)
  - **cmns-txt**: [https://www.omg.org/spec/Commons/Text/](https://www.omg.org/spec/Commons/Text/) (Local: `cmns-txt/cmns-txt.ttl`)
  - **csvw**: [http://www.w3.org/ns/csvw#](http://www.w3.org/ns/csvw#) (Local: `csvw/csvw.ttl`)
  - **dcam**: [http://purl.org/dc/dcam/](http://purl.org/dc/dcam/) (Local: `dcam/dcam.ttl`)
  - **dcat**: [http://www.w3.org/ns/dcat#](http://www.w3.org/ns/dcat#) (Local: `dcat/dcat.ttl`)
  - **dct**: [http://purl.org/dc/terms/](http://purl.org/dc/terms/) (Local: `dct/dct.ttl`)
  - **dctype**: [http://purl.org/dc/dcmitype/](http://purl.org/dc/dcmitype/) (Local: `dctype/dctype.ttl`)
  - **doap**: [http://usefulinc.com/ns/doap#](http://usefulinc.com/ns/doap#) (Local: `doap/doap.ttl`)
  - **eli**: [http://data.europa.eu/eli/ontology#](http://data.europa.eu/eli/ontology#) (Local: `eli/eli.ttl`)
  - **fibo-be-corp-corp**: [https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/](https://spec.edmcouncil.org/fibo/ontology/BE/Corporations/Corporations/) (Local: `fibo-be-corp-corp/fibo-be-corp-corp.ttl`)
  - **fibo-be-le-cb**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/CorporateBodies/) (Local: `fibo-be-le-cb/fibo-be-le-cb.ttl`)
  - **fibo-be-le-lp**: [https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/](https://spec.edmcouncil.org/fibo/ontology/BE/LegalEntities/LegalPersons/) (Local: `fibo-be-le-lp/fibo-be-le-lp.ttl`)
  - **fibo-be-nfp-nfp**: [https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/](https://spec.edmcouncil.org/fibo/ontology/BE/NotForProfitOrganizations/NotForProfitOrganizations/) (Local: `fibo-be-nfp-nfp/fibo-be-nfp-nfp.ttl`)
  - **fibo-be-oac-cctl**: [https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/](https://spec.edmcouncil.org/fibo/ontology/BE/OwnershipAndControl/CorporateControl/) (Local: `fibo-be-oac-cctl/fibo-be-oac-cctl.ttl`)
  - **fibo-fbc-dae-dbt**: [https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/](https://spec.edmcouncil.org/fibo/ontology/FBC/DebtAndEquities/Debt/) (Local: `fibo-fbc-dae-dbt/fibo-fbc-dae-dbt.ttl`)
  - **fibo-fbc-pas-fpas**: [https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FBC/ProductsAndServices/FinancialProductsAndServices/) (Local: `fibo-fbc-pas-fpas/fibo-fbc-pas-fpas.ttl`)
  - **fibo-fnd-acc-cur**: [https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/](https://spec.edmcouncil.org/fibo/ontology/FND/Accounting/CurrencyAmount/) (Local: `fibo-fnd-acc-cur/fibo-fnd-acc-cur.ttl`)
  - **fibo-fnd-agr-ctr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/](https://spec.edmcouncil.org/fibo/ontology/FND/Agreements/Contracts/) (Local: `fibo-fnd-agr-ctr/fibo-fnd-agr-ctr.ttl`)
  - **fibo-fnd-arr-doc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/](https://spec.edmcouncil.org/fibo/ontology/FND/Arrangements/Documents/) (Local: `fibo-fnd-arr-doc/fibo-fnd-arr-doc.ttl`)
  - **fibo-fnd-dt-oc**: [https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/](https://spec.edmcouncil.org/fibo/ontology/FND/DatesAndTimes/Occurrences/) (Local: `fibo-fnd-dt-oc/fibo-fnd-dt-oc.ttl`)
  - **fibo-fnd-org-org**: [https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/](https://spec.edmcouncil.org/fibo/ontology/FND/Organizations/Organizations/) (Local: `fibo-fnd-org-org/fibo-fnd-org-org.ttl`)
  - **fibo-fnd-pas-pas**: [https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/](https://spec.edmcouncil.org/fibo/ontology/FND/ProductsAndServices/ProductsAndServices/) (Local: `fibo-fnd-pas-pas/fibo-fnd-pas-pas.ttl`)
  - **fibo-fnd-plc-adr**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Addresses/) (Local: `fibo-fnd-plc-adr/fibo-fnd-plc-adr.ttl`)
  - **fibo-fnd-plc-loc**: [https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/](https://spec.edmcouncil.org/fibo/ontology/FND/Places/Locations/) (Local: `fibo-fnd-plc-loc/fibo-fnd-plc-loc.ttl`)
  - **fibo-fnd-pty-pty**: [https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/](https://spec.edmcouncil.org/fibo/ontology/FND/Parties/Parties/) (Local: `fibo-fnd-pty-pty/fibo-fnd-pty-pty.ttl`)
  - **fibo-fnd-rel-rel**: [https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/](https://spec.edmcouncil.org/fibo/ontology/FND/Relations/Relations/) (Local: `fibo-fnd-rel-rel/fibo-fnd-rel-rel.ttl`)
  - **fibo-pay-ps-ps**: [https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/](https://spec.edmcouncil.org/fibo/ontology/PAY/PaymentServices/PaymentServices/) (Local: `fibo-pay-ps-ps/fibo-pay-ps-ps.ttl`)
  - **geo**: [http://www.opengis.net/ont/geosparql#](http://www.opengis.net/ont/geosparql#) (Local: `geo/geo.ttl`)
  - **gleif-L1**: [https://www.gleif.org/ontology/L1/](https://www.gleif.org/ontology/L1/) (Local: `gleif-L1/gleif-L1.ttl`)
  - **gs1**: [https://ref.gs1.org/voc/](https://ref.gs1.org/voc/) (Local: `gs1/gs1.ttl`)
  - **hydra**: [http://www.w3.org/ns/hydra/core#](http://www.w3.org/ns/hydra/core#) (Local: `hydra/hydra.ttl`)
  - **lcc-cr**: [https://www.omg.org/spec/LCC/Countries/CountryRepresentation/](https://www.omg.org/spec/LCC/Countries/CountryRepresentation/) (Local: `lcc-cr/lcc-cr.ttl`)
  - **lrmoo**: [http://iflastandards.info/ns/lrm/lrmoo/](http://iflastandards.info/ns/lrm/lrmoo/) (Local: `lrmoo/lrmoo.ttl`)
  - **mo**: [http://purl.org/ontology/mo/](http://purl.org/ontology/mo/) (Local: `mo/mo.ttl`)
  - **odrl**: [http://www.w3.org/ns/odrl/2/](http://www.w3.org/ns/odrl/2/) (Local: `odrl/odrl.ttl`)
  - **org**: [http://www.w3.org/ns/org#](http://www.w3.org/ns/org#) (Local: `org/org.ttl`)
  - **prof**: [http://www.w3.org/ns/dx/prof/](http://www.w3.org/ns/dx/prof/) (Local: `prof/prof.ttl`)
  - **prov**: [http://www.w3.org/ns/prov#](http://www.w3.org/ns/prov#) (Local: `prov/prov.ttl`)
  - **qb**: [http://purl.org/linked-data/cube#](http://purl.org/linked-data/cube#) (Local: `qb/qb.ttl`)
  - **sarif**: [http://sarif.info/](http://sarif.info/) (Local: `sarif/sarif.ttl`)
  - **sh**: [http://www.w3.org/ns/shacl#](http://www.w3.org/ns/shacl#) (Local: `sh/sh.ttl`)
  - **snomed**: [http://purl.bioontology.org/ontology/SNOMEDCT/](http://purl.bioontology.org/ontology/SNOMEDCT/) (Local: `snomed/snomed.ttl`)
  - **sosa**: [http://www.w3.org/ns/sosa/](http://www.w3.org/ns/sosa/) (Local: `sosa/sosa.ttl`)
  - **ssn**: [http://www.w3.org/ns/ssn/](http://www.w3.org/ns/ssn/) (Local: `ssn/ssn.ttl`)
  - **time**: [http://www.w3.org/2006/time#](http://www.w3.org/2006/time#) (Local: `time/time.ttl`)
  - **unece**: [http://unece.org/vocab#](http://unece.org/vocab#) (Local: `unece/unece.ttl`)
  - **vcard**: [http://www.w3.org/2006/vcard/ns#](http://www.w3.org/2006/vcard/ns#) (Local: `vcard/vcard.ttl`)
  - **void**: [http://rdfs.org/ns/void#](http://rdfs.org/ns/void#) (Local: `void/void.ttl`)
  - **wgs**: [https://www.w3.org/2003/01/geo/wgs84_pos#](https://www.w3.org/2003/01/geo/wgs84_pos#) (Local: `wgs/wgs.ttl`)

