(function(window) {
  // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode
  'use strict';
  function define_xojs() {
    var XOjs = {};

    XOjs.findAncestorByClassName = function(element, strClass) {
      while((element = element.parentElement) && element.className.indexOf(strClass) < 0);
      return element;
    };

    XOjs.findAncestorByType = function(element, strType) {
      while((element = element.parentElement) && element.tagName.toLowerCase().indexOf(strType) < 0);
      return element;
    };

    XOjs.removeChildNodes = function(parentNode) {
      while(parentNode.firstChild) {
        parentNode.removeChild(parentNode.firstChild);
      }
    };

    return XOjs;
  }

  if(typeof(window.XOjs) === 'undefined') {
    window.XOjs = define_xojs();
  } else {
    console.log('XOjs already defined.');
  }
})(window);