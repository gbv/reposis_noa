# noa

## Installation instructions

* run `mvn clean install`
* copy jar to `~/.mycore/(dev-)mir/lib/`
* configure `mycore.properties` if necessary

## Development

You can add these to your `~/.mycore/(dev-)mir/.mycore.properties`:

```
MCR.Developer.Resource.Override=/path/to/reposis_noa/src/main/resources
MCR.LayoutService.LastModifiedCheckPeriod=0
MCR.UseXSLTemplateCache=false
MCR.SASS.DeveloperMode=true
```

## Project-specific adaptations

* Additional fields in the user editor for notes and address
* Extra page `new-author.xed` with a note advising users to contact the GWLB
* Additional field for **Art der Ablieferung** with a corresponding search facet
* Additional keyword browser (`response-filter.xsl`)
* Customized editors
