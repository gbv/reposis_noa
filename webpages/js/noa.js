
$﻿(document).ready(function() {

  // replace placeholder USERNAME with username
  var userID = $("#currentUser strong").html();
  var newHref = 'http://noa.gwlb.de/servlets/solr/select?q=createdby:' + userID + '&fq=objectType:mods';
  $("a[href='http://noa.gwlb.de/servlets/solr/select?q=createdby:USERNAME']").attr('href', newHref);

  // spam protection for mails
  $('span.madress').each(function(i) {
      var text = $(this).text();
      var address = text.replace(" [at] ", "@");
      $(this).after('<a href="mailto:'+address+'">'+ address +'</a>')
      $(this).remove();
  });

  $("a[href='http://noa.gwlb.de/servlets/solr/find?qry=%20%2Bmods.type:%22journal%22&amp;XSL.Style=selectIssue&amp;rows=1000']").attr('href', 'http://noa.gwlb.de/servlets/solr/find?qry=%20%2Bmods.type:%22journal%22&XSL.Style=selectIssue&rows=1000');

  // adjust editor from id
  setEditorID();

  // side nav toggle button
  $('#hide_side_button').click(function(){
    // adjust editor from id
    setEditorID();
  });

  /* --------------------------------------------
   *    adjust date input field
   * -------------------------------------------- */

  // settings
  genreSelector   = $("#genre select");     // triggered object
  genreValue      = "journal";              // triggered value
  defaultObject   = $(".date_issued");      // show by default
  triggeredObject = $(".daterange_issued"); // show on triggered value

  // adjust pub date imput on page load
  ajustInputBlock( genreSelector, genreValue, defaultObject, triggeredObject );

  // adjust pub date imput on select box changes
  genreSelector.change(function(){
    ajustInputBlock( genreSelector, genreValue, defaultObject, triggeredObject );
  });

  /* -------------------------------------------- */

});


/* ****************************************************************************
 * load side nav settings from "session" and adjust editor form
 *************************************************************************** */
function setEditorID() {
  if ( typeof(Storage) !== "undefined" ) {
      switch ( localStorage.getItem("sideNav") ) {
        case 'opened':
          $('#editor-admin-form-large').attr('id', 'editor-admin-form');
          $('#dynamic_editor-large').attr('id', 'dynamic_editor');
          break;
        case 'closed':
          $('#editor-admin-form').attr('id', 'editor-admin-form-large');
          $('#dynamic_editor').attr('id', 'dynamic_editor-large');
          break;
        case null:
          $('#editor-admin-form-large').attr('id', 'editor-admin-form');
          $('#dynamic_editor-large').attr('id', 'dynamic_editor');
          break;
      }
  }
}

/* ---------------------
 * ajustDateRangeInput()
 * ---------------------
 * show pub date range if journal is selected
 * on each other genre show simple date
 */
function ajustInputBlock ( genreSelector, genreValue, defaultObject, triggeredObject ) {
  // for journals
  if ( genreSelector.val() == genreValue )
  {
    // show range
    defaultObject.hide();
    triggeredObject.show();
  // for all other
  } else {
    // hide range
    triggeredObject.hide();
    defaultObject.show();
  }
}