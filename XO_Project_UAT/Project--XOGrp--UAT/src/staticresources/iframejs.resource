
var setupEventListener = function() {
	// Create IE + others compatible event handler
	var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
	var eventer = window[eventMethod];
	var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";

	console.log(messageEvent);

	// Listen to message from child window
	eventer(messageEvent,function(e) {
	  console.log('parent received message!:  ' + e.data);
	  var messageObject = JSON.parse(e.data);

	  console.log(messageObject);

	  /*var iframeContainer = document.querySelector('.xo-iframe');
	  console.log(iframeContainer);
	  iframeContainer.height = '400px';*/
	},false);
}

/**
 *   Function used to close(remove) the current iframe living in the record detail page.
 *   Needs to be extended to accept a class name instead of statically supplied.
 *   
 *   @author Justin
 *   @param  {Element} element The clicked/supplied element which initiated the close
 *                             iframe function and will be used to find the iframe
 *                             container
 */
var closeIframe = function(element, animated) {
	var iframeContainer = findAncestorByClassName(element, 'iframe-container');

	if(animated) {
		var animated = iframeContainer.querySelector('.animated');
		animated.className = animated.className.replace('fadeInDown', 'fadeOutUp');
		setTimeout(function() {
			iframeContainer.parentElement.removeChild(iframeContainer);
		}, 1000);
		return;
	}

	iframeContainer.parentElement.removeChild(iframeContainer);
}

/**
 *   Function used to retrieve an parent/ancestor with a supplied className
 *   
 *   @author Justin
 *   @param  {Element} element  Starting element to begin ancestor traversal
 *   @param  {String}  strClass Class name that is being searched for
 *   @return {Element}          Ancestor with the matching class name that was supplied
 */
var findAncestorByClassName = function(element, strClass) {
	while((element = element.parentElement) && element.className.indexOf(strClass) < 0);
		return element;
}

/**
 *   Function used to loop through an array of JS library URLs and append them to the header element
 *   for the current page. If no head element is supplied or supplied incorrectly then the actual head
 *   element is retrieved from the current page.
 *   
 *   @author Justin
 *   @param  {Element}  headElement HTML <head> Element
 *   @param  {String[]} libraryArr  Array of JS Library URLs(String)
 */
var addJSLibraries = function(headElement, libraryArr) {
	if(headElement == null || typeof headElement === 'undefined') {
		headElement = document.querySelector('head');
	}

	for(var i = 0; i < libraryArr.length; i++) {
    var scriptElement = document.createElement('script');
    scriptElement.src = libraryArr[i];
    headElement.appendChild(scriptElement);
  }
}

/**
 *   Function used to loop through an array of CSS Resource URLs and append them to the header element
 *   for the current page. If no head element is supplied or supplied incorrectly then the actual head
 *   element is retrieved from the current page.
 *   
 *   @author Justin
 *   @param  {Element}  headElement HTML <head> Element
 *   @param  {String[]} resourceArr Array of CSS Resource URLs(String)
 */
var addCSSResources = function(headElement, resourceArr) {
	if(headElement == null || typeof headElement === 'undefined') {
		headElement = document.querySelector('head');
	}

	for(var i = 0; i < resourceArr.length; i++) {
    var styleLink = document.createElement('link');
    styleLink.rel = 'stylesheet';
    styleLink.href = resourceArr[i];
    headElement.appendChild(styleLink);
  }
}
