
//from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
var urlParams;
(window.onpopstate = function () {
    var match,
        pl     = /\+/g,  // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
        query  = window.location.search.substring(1);

    urlParams = {};
    while (match = search.exec(query))
       urlParams[decode(match[1])] = decode(match[2]);
})();


function handle_query(){
    if (window.location.search){
	var year = urlParams["year"];
	var month = urlParams["month"];
	var day = urlParams["day"];
	var form = document.forms[0];
	//alert("hey hey " + year + "-" + month + "-" + day + " = " + document.forms.length);
	form.year.value = year;
	form.month.value = month;
	form.day.value = day;
	process_form(form);
    }
}


function process_form(form){
    var year = parseInt(this.year.value);
    var month = parseInt(this.month.value);
    var day = parseInt(this.day.value);
    //alert("hey hey " + year + "-" + month + "-" + day);
    var julian = convert_date(year, month, day);
    var factors = factor(julian);
    var searches = factor_searches(factors);
    //alert("hey hey " + year + "-" + month + "-" + day + " = " + julian + ": " + factors + " searches " + searches);
    var results = [];
    for (var i = 0; i < searches.length; i++){
	get_results(results, searches[i], searches, factors);
    }
   

}

function convert_date(year, month, day){
    //from xslt cookbook:
    //alert("hey hey hey " + year + "-" + month + "-" + day);
    var a = Math.floor((14 - month)/12);
    var y = year + 4800 - a;
    var m = month + 12 * a - 3;
    //alert("hey hey hey " + a + " " + y + " " + m);
    var jd = day;
    //alert (jd);
    jd += Math.floor((153 * m + 2)/5);
    //alert (jd);
    jd += (y * 365);
    //alert (jd);
    jd += Math.floor(y/4);
    //alert (jd);
    jd -= Math.floor(y/100);
    //alert (jd);
    jd += Math.floor(y/400);
    //alert (jd);
    jd -= 32046; //subtracted one more day to match naval obs 
    return jd;
}

function factor(number){
    var factors = [];
    var current = 2;
    while (number > Math.pow(current,2)){
	if (number % current == 0){
	    factors.push(current);
	    number /= current;
	} else {
	    current++; //inefficient, whatever
	}
    } 
    factors.push(number);
    return factors;
}

function factor_searches(factors){
    var searches = [];
    //use binary numbers to get all combinations
    for (var n = Math.pow(2,factors.length) -1; n > 0; n--){ //all combinations except 0;
	//alert(n);
	var tempfactor = 1;
	var factorsleft = factors.length;
	for (var i = 0; i < factors.length; i++){
	    //alert(i + "::" + n);
	    if ((Math.pow(2,i) & n) > 0){
		tempfactor *= factors[i];
		factorsleft--;
	    }
	}
	if (tempfactor < 100000){
	    var sfactor = ("0000" + tempfactor).slice(-5);
	    var sfactorsleft = ("0"  + factorsleft).slice(-2);
	    var dir = sfactor.substring(0,2);
	    var search = dir + "/" + sfactor + "-" + sfactorsleft;
	    if (searches.indexOf(search) == -1) {
		searches.push(search);
	    }
	}
    }
    if (1 == factors.length){
	//alert("prime");
	searches.push("PRIME");
    }
    //alert(searches);
    return searches;
    
}

function get_results(results, search, searches, factors){
    var url = "data/./" + search + ".json";
    var req = new XMLHttpRequest(); // a new request
    req.onreadystatechange = function() {
	if (req.readyState == 4){
	    if (req.status == 200 || req.status == 0) {
		var text = req.responseText;
		text = text.replace(/\'/g, '"');
		//alert(text);
		var obj;
		if (text){
		    obj = JSON.parse(text);
		} else {
		    obj = {"error":"error"};
		}
		obj.search = search;
		results.push(obj);
		if (results.length == searches.length){
		    update_page(results, factors);
		
		}
	    } else {
		//alert(url + ": " + req.status);
	    }
	} else {
	    //alert(url + ": " + req.readyState);
	}
    };    
    req.open("GET",url,true);
    req.send();
    
}

function update_page(results, factors){
    var searches = [];
    for (var i = 0; i < results.length; i++){
	var obj = results[i];
	searches.push(obj.search);
    }
    searches.sort();
    searches.reverse();
    var html = "<h2>Your Factors:</h2><h3>" + factors.toString().replace(/,/g, ", ") + "</h3>";
    html += "<h2>Your Matches</h2>";
    for (var i = 0; i < searches.length; i++){
	for (var j = 0; j < results.length; j++){
	    if (results[j].search == searches[i]){
		var obj = results[j];
		var births = obj.births;
		if (births){
		    //alert(JSON.stringify(births));
		    if (obj.search == "PRIME"){
			html += "<h3>Prime</h3>";
		    } else {
			factor = parseInt(obj.search.substring(3,8));
			left = parseInt(obj.search.substring(9));
			html += "<h3>" + factor + " and " + left + " other factor";
			if (left != 1){
			    html += "s";
			}
			html += "</h3>";
		    }
		    html += "<ul>";
		    for (var k = 0; k < births.length; k++){
			if (births[k]){
			    var birth = births[k];
			    html += "<li>";
			    html += "<a href='http://en.wikipedia.org/wiki/" + birth.name.replace("\u0027","%27") + "' target='_blank'>" + birth.name.replace(/_/g, " ") + "</a>: ";
			    html += birth.date;
			    html += "</li>";
			}
		    }
		    html += "</ul>";
		}
	    }
	}
    }
    //alert(document.getElementById('results'));
    document.getElementById('results').innerHTML = html;
    //alert(html);
}