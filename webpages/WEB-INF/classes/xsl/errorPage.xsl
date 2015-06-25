<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="i18n xlink">
  <xsl:variable name="Type" select="'document'" />

  <xsl:variable name="PageTitle" select="i18n:translate('titles.pageTitle.error',concat(' ',/mcr_error/@HttpError))" />

  <xsl:template match="/mcr_error">
    <div class="row">
      <div class="col-md-12" lang="de">
        <xsl:choose>
          <xsl:when test="/mcr_error/@HttpError = '500'">
              <h2>Interner Serverfehler</h2>
              <p>Es ist leider ein Serverfehler aufgetreten. Wir arbeiten an dessen Beseitigung!
              Gern können Sie uns eine Mail an <span class="madress">dms-list [at] gbv.de</span>
              schicken und kurz schildern wie es zu diesem Fehler kam.
              <br/><br/>
              Vielen Dank!</p>
          </xsl:when>
          <xsl:when test="/mcr_error/@HttpError = '404'">
              <h2><xsl:value-of select="." /></h2>
              <p>Die von Ihnen angefordete Seite konnte leider nicht gefunden werden. Eventuell
              haben Sie ein altes Lesezeichen oder einen veralteten Link benutzt. Bitte versuchen
              Sie mithilfe der <a href="/index.html">Suche</a> die gewünschte Seite zu finden oder
              schreiben Sie eine Mail an <span class="madress">dms-list [at] gbv.de</span> und
              schildern kurz wie es zu diesem Fehler kam.
              <br/><br/>
              Vielen Dank!</p>
          </xsl:when>
          <xsl:when test="/mcr_error/@HttpError = '403'">
              <h2>Zugriff verweigert</h2>
              <p>Sie haben keine Berechtigung diese Seite zu sehen. Melden Sie sich bitte am System an.
              Sollten Sie trotz Anmeldung nicht die nötigen Rechte haben um diese Seite zu sehen, wenden
              Sie sich ggf. an Ihren Administrator oder
              schreiben Sie eine Mail an <span class="madress">dms-list [at] gbv.de</span>.
              <br/><br/>
              Vielen Dank!</p>
          </xsl:when>
          <xsl:otherwise>
              <h2><xsl:value-of select="."></xsl:value-of></h2>
              <p>Es ist leider ein Fehler aufgetreten. Sollte dies wiederholt der Fall sein,
              schreiben Sie bitte eine Mail an <span class="madress">dms-list [at] gbv.de</span> und
              schildern kurz wie es dazu kam.
              <br/><br/>
              Vielen Dank!</p>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>
  <xsl:include href="MyCoReLayout.xsl" />
</xsl:stylesheet>
