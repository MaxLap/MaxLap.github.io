// This is where it all goes :)

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll('.spoiler-toggler').forEach(function(toggler) {
    var target = bubblingNextElementSibling(toggler);

    toggler.addEventListener('click', function() {
      toggler.classList.toggle('spoiler-toggler--hidden');
      target.classList.toggle('spoiler-target--displayed');
    });

    target.addEventListener('click', function() {
      toggler.classList.toggle('spoiler-toggler--hidden');
      target.classList.toggle('spoiler-target--displayed');
    });
  });

  document.querySelectorAll('.table-for-code').forEach(function(table) {
    table.addEventListener("mousedown", function(e) {
      var current = e.target;
      var column_number = 0;
      while(current !== table) {
        if (current.tagName.toUpperCase() == 'TD') {
          column_number = Array.prototype.indexOf.call(current.parentElement.children, current) + 1;
        }
        current = current.parentElement;
      }

      if (column_number > 0) {
        table.classList.remove('selecting-column-1');
        table.classList.remove('selecting-column-2');
        table.classList.add('selecting-column-' + column_number);
      }
    });
  });
});

function bubblingNextElementSibling(elem) {
  while (!elem.nextElementSibling) {
    elem = elem.parentElement;
    if (!elem) {
      return elem;
    }
  }
  return elem.nextElementSibling;
}
