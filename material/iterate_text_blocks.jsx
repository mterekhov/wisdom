main();
function main(){
	//Make certain that user interaction (display of dialogs, etc.) is turned on.
	app.scriptPreferences.userInteractionLevel = UserInteractionLevels.interactWithAll;
	if(app.documents.length != 0){
		if (app.activeDocument.stories.length != 0){
			myDisplayDialog();
		}
		else{
			alert("The document does not contain any text. Please open a document containing text and try again.");
		}
	}
	else{
		alert("No documents are open. Please open a document and try again.");
	}
}
function myDisplayDialog(){
	myFolder = Folder.selectDialog ("Choose a Folder");
	if((myFolder != null)&&(app.activeDocument.stories.length !=0)){
		exportAllStoriesByTextFrames(myFolder);
	}
}

function exportAllStoriesByTextFrames(myFolder) {
	var str = "[";

	var sanskritLayer = app.activeDocument.layers.itemByName("Sanskrit")
	var iastLayer = app.activeDocument.layers.itemByName("IAST")
	var englishLayer = app.activeDocument.layers.itemByName("English")

	for(k = 0; k < sanskritLayer.pageItems.length; k++){
		str += "{\"sanskrit\":\"" + sanskritLayer.pageItems[k].contents + "\",";
		if (k < iastLayer.pageItems.length) {
			str += "\"iast\":\"" + iastLayer.pageItems[k].contents + "\",";
		}
		if (k < englishLayer.pageItems.length) {
			str += "\"english\":\"" + englishLayer.pageItems[k].contents + "\"},";
		}
	}
	str += "]"

	var outfile = File(myFolder + "/" + "export.json")
	outfile.encoding = 'UTF-8';
	outfile.open("w");
	outfile.write(str);
	outfile.close();
}

function exportAllStories(myFolder) {
	var str = "";
	for(myCounter = 0; myCounter < app.activeDocument.stories.length; myCounter++){
		str += app.activeDocument.stories[myCounter].contents + "\n\n";
	}

	var outfile = File(myFolder + "/" + "export.json")
	outfile.encoding = 'UTF-8';
	outfile.open("w");
	outfile.write(str);
	outfile.close();
}

function exportAllTextFrames(myFolder) {
	var str = "";
	for(i = 0; i < app.activeDocument.textFrames.length; i++) {
		str += app.activeDocument.textFrames[i].contents + "\n";
	}

	var outfile = File(myFolder + "/" + "export.json")
	outfile.encoding = 'UTF-8';
	outfile.open("w");
	outfile.write(str);
	outfile.close();
}