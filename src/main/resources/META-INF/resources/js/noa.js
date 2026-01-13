function replaceMaskedEmails() {
  document.querySelectorAll("span.madress").forEach(span => {
    const address = span.textContent.replace(" [at] ", "@");
    const link = document.createElement("a");
    link.href = `mailto:${address}`;
    link.textContent = address;
    span.replaceWith(link);
  });
}

function removeGenreOptions(values) {
  const select = document.querySelector("select#genre");
  if (!select) {
    return;
  }
  Array.from(select.options).forEach(option => {
    if (values.includes(option.value)) {
      option.remove();
    }
  });
}

function setupGenreObserver(values) {
  const observer = new MutationObserver(() => {
    removeGenreOptions(values);
  });
  observer.observe(document.body, {childList: true, subtree: true});
  return observer;
}

function initPage() {
  const genresToRemove = ["series", "journal"];
  setupGenreObserver(genresToRemove);
  replaceMaskedEmails();
  removeGenreOptions(genresToRemove);
}

document.addEventListener("DOMContentLoaded", initPage);
