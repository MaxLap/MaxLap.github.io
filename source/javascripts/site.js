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
