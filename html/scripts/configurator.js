var fontSize = 7;
var shadowa = 1;
var shadowb = 2;
var shadowc = 3;
var shadowd = 4;
var shadowe = 5;
var margin = 1;
var lineHeight = 0.66;
var modifier = 1.1;
var sOffAdjust = 0.8;
var eOffAdjust = 0.6;

function embiggen() {
	if (fontSize > 18) { 
		document.getElementById("embiggen").disabled = true;
		document.getElementById("embiggen").style.backgroundColor = 'grey';
		return; 
	}
	document.getElementById("emsmallen").disabled = false;
	document.getElementById("emsmallen").style.backgroundColor = '#1bdd1d';
	
	fontSize = fontSize * modifier;
	shadowa = shadowa * modifier;
	shadowb = shadowb * modifier;
	shadowc = shadowc * modifier;
	shadowd = shadowd * modifier;
	shadowe = shadowe * modifier;
	
	updateLogoShow();
	updateLogoCode();
}
function emsmallen() {
	if (fontSize < 1.7) { 
		document.getElementById("emsmallen").disabled = true;
		document.getElementById("emsmallen").style.backgroundColor = 'grey';
		return; 
	}
	document.getElementById("embiggen").disabled = false;
	document.getElementById("embiggen").style.backgroundColor = '#1bdd1d';
	
	fontSize = fontSize / modifier;
	shadowa = shadowa / modifier;
	shadowb = shadowb / modifier;
	shadowc = shadowc / modifier;
	shadowd = shadowd / modifier;
	shadowe = shadowe / modifier;
	
	updateLogoShow();
	updateLogoCode();
}

function updateLogoShow() {
	document.getElementById("eg").style.fontSize = fontSize+'em';
	document.getElementById("eg").style.textShadow = 	"-" + shadowa + "px -" + shadowa + "px 0 #13c115, " + 
														"-" + shadowb + "px -" + shadowb + "px 0 #13c115, " + 
														"-" + shadowc + "px -" + shadowc + "px 0 #13c115, " + 
														"-" + shadowd + "px -" + shadowd + "px 0 #13c115, " +
														"-" + shadowe + "px -" + shadowe + "px 0 #13c115";
}

var stylestart = "<style type='text/css'>";
var ldflogostatic = ".ldflogo{text-transform: uppercase;font-family: '04b19Regular',Impact,sans-serif;font-weight: normal;color: #1BDD1D;font-weight:normal;";
var ldflink = ".ldflink,.ldflink:hover,.ldflink:active{text-decoration: none;}";
var styleend = "</style>";
var html = '<a href="http://www.leedsdigitalfestival.com" class="ldflink"><h2 class="ldflogo" id="eg">Leeds Digital Festival</h2></a>';
var fontPath;

function updateFontPath() {
	fontPath = document.logocustomiser.elements["fontpath"].value;
	updateLogoCode();
}

function updateLogoCode() {
	var rshadowa = sOffAdjust * shadowa;
	var rshadowb = sOffAdjust * shadowb;
	var rshadowc = sOffAdjust * shadowc;
	var rshadowd = sOffAdjust * shadowd;
	var rshadowe = sOffAdjust * shadowe;
	var rfontSize = eOffAdjust * fontSize;
	
	rshadowa = rshadowa.toFixed(1);
	rshadowb = rshadowb.toFixed(1);
	rshadowc = rshadowc.toFixed(1);
	rshadowd = rshadowd.toFixed(1);
	rshadowe = rshadowe.toFixed(1);
	rfontSize = rfontSize.toFixed(1);
	
	if (fontPath == undefined) {
		fontPath = '';
	}
	
	document.logocustomiser.elements["logocode"].value = 
		stylestart + "\n" + 
		ldflink + "\n" +
		ldflogostatic + "\n" + 
		"text-shadow:" + 
			"-" + rshadowa + "px -" + rshadowa + "px 0 #13c115," + "\n" +
			"-" + rshadowb + "px -" + rshadowb + "px 0 #13c115," + "\n" +
			"-" + rshadowc + "px -" + rshadowc + "px 0 #13c115," + "\n" +
			"-" + rshadowd + "px -" + rshadowd + "px 0 #13c115," + "\n" +
			"-" + rshadowe + "px -" + rshadowe + "px 0 #13c115;" + "\n" +
		"font-size: " + rfontSize + "em;" + "\n" +
		"margin-bottom: " + margin + "rem;" + "\n" +
		"line-height: " + lineHeight + ";}" + "\n" +
		"@font-face {font-family:'04b19Regular';" +
		"src:url('" + fontPath + "04b_19__-webfont.eot');" +
		"src:local('?'), " + 
		"url('" + fontPath + "04b_19__-webfont.woff') format('woff'), " +
		"url('" + fontPath + "04b_19__-webfont.ttf') format('truetype'), " +
		"url('" + fontPath + "04b_19__-webfont.svg#04b19Regular') format('svg');" + "\n" +
		"font-weight:normal;" + "\n" +
		"font-style:normal;}" + "\n" +
		styleend + "\n" + html;
}
