// Light / Dark / System theme switcher.
// "System" removes data-theme so tokens.css follows the OS setting.
(function () {
  var KEY = 'tcv-theme';
  var root = document.documentElement;

  function read() {
    try { return localStorage.getItem(KEY) || 'system'; } catch (e) { return 'system'; }
  }

  function write(choice) {
    try {
      if (choice === 'system') localStorage.removeItem(KEY);
      else localStorage.setItem(KEY, choice);
    } catch (e) { /* storage blocked: the choice lasts for this page only */ }
  }

  function apply(choice) {
    if (choice === 'light' || choice === 'dark') root.setAttribute('data-theme', choice);
    else root.removeAttribute('data-theme');
  }

  // Apply before first paint so there is no flash of the wrong theme.
  apply(read());

  document.addEventListener('DOMContentLoaded', function () {
    var group = document.querySelector('.aw-theme');
    if (!group) return;
    var buttons = group.querySelectorAll('button[data-theme-choice]');

    function mark(choice) {
      buttons.forEach(function (b) {
        b.setAttribute('aria-pressed', String(b.getAttribute('data-theme-choice') === choice));
      });
    }

    buttons.forEach(function (b) {
      b.addEventListener('click', function () {
        var choice = b.getAttribute('data-theme-choice');
        write(choice);
        apply(choice);
        mark(choice);
      });
    });

    mark(read());
    group.hidden = false;
  });
})();
