// This is where it all goes :)

document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll('.spoiler-toggler').forEach(function(toggler) {
    var target = bubblingNextElementSibling(toggler);

    toggler.addEventListener('click', function() {
      toggler.classList.toggle('spoiler-toggler--hidden');
      target.classList.toggle('spoiler-target--displayed');
    });

    target.addEventListener('click', function(e) {
      if (e.target.classList.contains('with-tooltip')) {
        return;
      }

      toggler.classList.toggle('spoiler-toggler--hidden');
      target.classList.toggle('spoiler-target--displayed');
    });
  });

  document.querySelectorAll('.code-book').forEach(function(code_book) {
    code_book.addEventListener("mousedown", function(e) {
      var current = e.target;
      var prev;

      while(current && current !== code_book) {
        prev = current;
        current = current.parentElement;
      }

      var column_number = Array.prototype.indexOf.call(code_book.children, prev) % 2 + 1;

      if (column_number > 0) {
        code_book.classList.remove('selecting-column-1');
        code_book.classList.remove('selecting-column-2');
        code_book.classList.add('selecting-column-' + column_number);
      }
    });
  });

  tippy('[data-tippy-content]',
        {allowHTML: true,
         hideOnClick: false,
         interactive: true,
         interactiveBorder: 5,
         interactiveDebounce: 75});
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
