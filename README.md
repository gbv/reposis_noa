
# noa

## Installation Instructions

* run `mvn clean install`
* copy jar to ~/.mycore/(dev-)mir/lib/

## Development

You can add these to your ~/.mycore/(dev-)mir/.mycore.properties
```
MCR.Developer.Resource.Override=/path/to/reposis_noa/src/main/resources
MCR.LayoutService.LastModifiedCheckPeriod=0
MCR.UseXSLTemplateCache=false
MCR.SASS.DeveloperMode=true
```

## besondere Anpassungen

* zusätzliche Felder in Nutzereditor für Notizen und die Adresse
* extra seite `new-author.xed` mit Notiz das man sich an die GWLB wenden soll
* zusätzliches Feld für `Art der Ablieferung` mit Facette in der Suche
* zusätzlicher Schlagwort-Browser (response-filter.xsl)
* angepasste editoren