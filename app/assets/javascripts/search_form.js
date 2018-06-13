document.addEventListener("DOMContentLoaded", function(event) {
  var searchForm = document.getElementsByClassName("search_form");
  var i;
  for (i = 0; i < searchForm.length; i++) {
    searchForm[i].addEventListener('submit', function() {
      document.getElementById("loading").style.display="inherit";
    });
  }
});
