//Global editor variable
var editor;
var changes = false;
var changeFirst = false;

//
function dbaxCodeMirror(textareaId,formId){
        //load CodeMirror
    editor = CodeMirror.fromTextArea(document.getElementById(textareaId), {                  
          lineNumbers: true,
          mode: "htmlmixed",//"text/html",
          matchBrackets: true,
          theme: "monokai",
          extraKeys: {
            "F11": function(cm) {
              cm.setOption("fullScreen", !cm.getOption("fullScreen"));
            },
            "Esc": function(cm) {
              //if (cm.getOption("fullScreen")) cm.setOption("fullScreen", false);
              cm.setOption("fullScreen", !cm.getOption("fullScreen"));
            },
            "Ctrl-S": function(cm) {
              //Save editor
              editor.save();
              //Save Source Code
              SubmitClobForm(formId);
              changes = false;
            }
          }
        });
      	
      editor.on("change", function(cm, change) { 
        //Prevent onload change
        if (changeFirst){
          changes=true;
        }
        changeFirst = true;          
      })   

}


/**********/
//Update Hash location/CodeMirror and refresh editor on click tab
$('.nav-tabs a').on('shown.bs.tab', function (e) {
    window.location.hash = e.target.hash;
        editor.refresh();
})


/**********/
//Export Edtitor 
 function exportEditor(textareaId, inputFileNameId)
{
    //Save editor to textarea
    editor.save();
  
    var textToWrite = $('#' + textareaId)[0].value;//??
    var textFileAsBlob = new Blob([textToWrite], {type:'text/html'});
    var fileNameToSaveAs = $('#' + inputFileNameId)[0].value;

    var downloadLink = document.createElement("a");
    downloadLink.download = fileNameToSaveAs;
    downloadLink.innerHTML = "Download File";
    if (window.webkitURL != null)
    {
        // Chrome allows the link to be clicked
        // without actually adding it to the DOM.
        downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob);
    }
    else
    {
        // Firefox requires the link to be added to the DOM
        // before it can be clicked.
        downloadLink.href = window.URL.createObjectURL(textFileAsBlob);
        downloadLink.onclick = destroyClickedElement;
        downloadLink.style.display = "none";
        document.body.appendChild(downloadLink);
    }

    downloadLink.click();
}

function destroyClickedElement(event)
{
    document.body.removeChild(event.target);
}

//Import Edtitor 
function importEditor(textareaId,inputFileId, modalId)
{
  //If input file is in Boostrap modal
  if (modalId === undefined){
    var inputFile = $('#'+inputFileId)[0];//?
      fileToLoad = inputFile.files[0];
  }else{
    var modal = $('#' + modalId);
    var inputFile = modal.find('.modal-body input#'+inputFileId);
      fileToLoad = inputFile[0].files[0];
  }        
  
    var fileReader = new FileReader();
    fileReader.onload = function(fileLoadedEvent) 
    {
        var textFromFileLoaded = fileLoadedEvent.target.result;
        $('#' + textareaId).value = textFromFileLoaded;
        editor.setValue(textFromFileLoaded);
    };
    fileReader.readAsText(fileToLoad, "UTF-8");
}