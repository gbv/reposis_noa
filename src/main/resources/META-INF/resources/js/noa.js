document.addEventListener('DOMContentLoaded', () => {

  // spam protection for mails
  document.querySelectorAll("span.madress").forEach((element) => {
    const text = element.textContent;
    const address = text.replace(" [at] ", "@");
    const mailtoLink = document.createElement("a");
    mailtoLink.setAttribute("href", "mailto:" + address);
    mailtoLink.textContent = address;
    element.parentNode.insertBefore(mailtoLink, element.nextSibling);
    element.remove();
  });

  // replace placeholder USERNAME with username
  const userID = $("#currentUser strong").html();
  const linksWithPlaceholder = document.querySelectorAll(
      "a[href*='createdby:USERNAME']");
  linksWithPlaceholder.forEach((link) => {
    const href = link.getAttribute("href");
    const newHref = href.replace("USERNAME", encodeURIComponent(userID));
    link.setAttribute("href", newHref);
  });
});

/* TODO: required?
$( document ).ajaxComplete(function() {
  // remove series and journal as option from publish/index.xml
  $("select#genre option[value='series']").remove();
  $("select#genre option[value='journal']").remove();
});
*/