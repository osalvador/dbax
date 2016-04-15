//Check all/none visible CheckBoxes
function checkAll(checkboxId, tableId){        
  //Standar checkboxes
  $('#' + tableId).find('td input:checkbox:visible').prop( "checked" , $('#'+ checkboxId).prop( "checked" ));

}
/**********/

// Enable links to tab in Bootstrap
var url = document.location.toString();
if (url.match('#')) {
    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
} 
// Change hash for page-reload
$('.nav-tabs a').on('shown.bs.tab', function (e) {
    window.location.hash = e.target.hash;
})
/**********/

//Delete checked Items, Post Ajax and reload page.
function Delete(tableId, postURL){
   //Get selected Data
   var postData = [];
    $('#' + tableId).find('td input:checkbox').each(function() {
        if ($(this).is(":checked")){
            postData.push(encodeURIComponent($(this).val())); //Data is encoded
        }
        
    });    
    
    if (postData.length === 0)
    {
        swal({  title: "No items are selected"
              , text: "You must select at least one item"
              , type: "warning"});
    }else{

        //User confirmation
        swal({   title: 'Are you sure?',
                 text: 'Are you sure you want to delete '+ postData.length +' items?',
                 type: 'warning',
                 showCancelButton: true,
                 confirmButtonColor: '#3085d6',
                 cancelButtonColor: '#d33',
                 confirmButtonText: 'Yes',
                 closeOnConfirm: false }
                 , function() {
                        //Ajax Request to delete items
                        $.ajax(
                        {
                            url : postURL,
                            type: "POST",
                            data : {data: encodeURIComponent(postData)}, //Data is encoded
                            success:function(data, textStatus, jqXHR) 
                            {
                                //Parse JSON
                                //var obj = $.parseJSON(data);
                                //Sweet Alert
                                swal({  title: "Successfully deleted", text: data.text, type: "success"}
                                        , function(){
                                            location.reload();
                                        });
                               location.reload();                    
                            },
                            error: function(jqXHR, textStatus, errorThrown) 
                            {   
                                swal({  title: "Error deleting items" 
                                       ,html: "There is a problem deleting your data, please try again later or contact with the Adminstrator." + '<br/><br/><pre><code class="prettyprint">' + jqXHR.responseText + '</code></pre>' 
                                       ,type: "error"
                                     });                                    
                            }
                        });                            
            });            
     } //end if
    
}

/****************/
//Export checked Items, Post Ajax and reload page.
function Export(tableId, postURL){
   //Get selected Data
   var postData = [];
    $('#' + tableId).find('td input:checkbox').each(function() {
        if ($(this).is(":checked")){
            postData.push(encodeURIComponent($(this).val())); //Data is encoded
        }
        
    });    
    
    if (postData.length === 0)
    {
        swal({  title: "No items are selected"
              , text: "You must select at least one item"
              , type: "warning"});
    }else{
        //User confirmation
        swal({   title: 'Are you sure?',
                 text: 'Are you sure you want to export '+ postData.length +' items?',
                 type: 'warning',
                 showCancelButton: true,
                 confirmButtonColor: '#3085d6',
                 cancelButtonColor: '#d33',
                 confirmButtonText: 'Yes',
                 closeOnConfirm: true }
                 , function() {
                       //Non-Ajax post form to download file
                        $('<form action="'+postURL+'" method="POST">' + 
    						'<input type="hidden" name="data" value="' + encodeURIComponent(postData) + '">' +
    						'</form>').submit();
                        return;
                       /* $.ajax(
                        {
                            url : postURL,
                            type: "POST",
                            data : {data: encodeURIComponent(postData)}, //Data is encoded
                            success:function(data, textStatus, jqXHR) 
                            {
                                //Parse JSON
                                //var obj = $.parseJSON(data);
                                //Sweet Alert
                                swal({  title: "Successfully deleted", text: data.text, type: "success"}
                                        , function(){
                                            location.reload();
                                        });
                               location.reload();
                            },
                            error: function(jqXHR, textStatus, errorThrown) 
                            {   
                                swal({  title: "Error deleting items" 
                                       ,html: "There is a problem deleting your data, please try again later or contact with the Adminstrator." + '<br/><br/><pre><code class="prettyprint">' + jqXHR.responseText + '</code></pre>' 
                                       ,type: "error"
                                     });                                    
                            }
                        });*/
            });            
     } //end if
    
}

/**********/
//Submit Ajax Form with validation
 function dbaxSubmitForm(formId){
            
            var form =  $('#' + formId);
          
            //Validate Form inputs
            var validator = $(form).validate();
           
            //If form is valid 
            if (validator.form()){
               return $.ajax(
                    {
                        url: $(form).attr('action'),
                        type: $(form).attr('method'),
                        data: $(form).serialize(),
                        dataType: "json"
                     })
                     .done(function(data) {                                                    
                          //Functional errors                          
                          if (data.cod_error !== undefined){
	                          	swal({  title: "Error saving data"
	                               ,html: "There is a problem saving your data" + '<br/><br/><pre><code class="prettyprint">' + data.msg_error + '</code></pre>'
	                               ,type: "error"});                                
                    		}else{                          		
                          		 swal({  title: "Successfully saved", text: data.text,   type: "success"});                          		
                          	}
                     })
                     .then(function(data) {
                          	return $.Deferred().resolve(data);
                     })
                     .fail(function(jqXHR, textStatus, errorThrown) 
                        {   
                            //HTTP errors
                            swal({  title: "Error saving data" 
                                   ,html: "There is a problem saving your data, please try again later or contact with the Adminstrator." + '<br/><br/><pre><code class="prettyprint">' + jqXHR.responseText + '</code></pre>' 
                                   ,type: "error"
                                 });                                    
                        }
                    );
            }else{
                return $.Deferred().reject(false)
            } 
        }


/**********/
//Alert user If leave the page befora saving data
function confirmExit()
{
  if (changes){
    var confirmationMessage = 'It looks like you have been editing something.';
    confirmationMessage += ' If you leave before saving, your changes will be lost.';

    //(e || window.event).returnValue = confirmationMessage; //Gecko + IE
    return confirmationMessage; //Gecko + Webkit, Safari, Chrome etc.
  }
}

/**********/
//Drag-Drop Table Rows with update Index Column
var fixHelperModified = function(e, tr) {
        var $originals = tr.children();
        var $helper = tr.clone();
        $helper.children().each(function(index) {
            $(this).width($originals.eq(index).width())
        });
        return $helper;
    }, updateIndex = function(e, ui) {
        $('td.index', ui.item.parent()).each(function (i) {
            $(this).html(i + 1);
        });
        changes = true;
    };        


/**********/
//Split big string into array
function chunkString(str, length) {
  return str.match(new RegExp('(.|[\r\n]){1,' + length + '}', 'g'));
}

//Oracle accepts a maximum of 32000 characters parameters.
//This function creates a form with hidden textarea as groups of 31000 characters.
function formTextareaToClob(formId, textareaId) {
	 //Clone original Form
	var form = $('#' + formId).clone(true).appendTo("body");
	//Rename form Id
	var newFormId = formId + Math.random().toString(36).substring(12);
	$(form).attr('id',newFormId);
	
    //get Big String textarea
	var bigString = $('#'+formId+' > textarea#'+textareaId).val();    
	
	//Remove original textarea
	$('#'+newFormId+' > textarea#'+textareaId).remove()	
	//split text area into array of 31000 char
	var arrChunkedString = chunkString(bigString,31000);
	//append chunks as form hidden inputs
	$.each(arrChunkedString, function(index, value) {	
		var input = $("<input>")
		     .attr("type", "hidden")
		     .attr("name", textareaId + index).val(value);
		  
		$('#'+newFormId).append($(input));
	});

	return newFormId;
}

/**********/
//Submit jQuery Ajax Form with Textarea Clob
function SubmitClobForm(formId){
  //Saving CLOB data greater than 32K 
  //Split textarea into hidden parameters
  var newFormId = formTextareaToClob(formId, "code");
  
  dbaxSubmitForm(newFormId).done(function(data) {
        if (data.cod_error === undefined){
            //Update Values
            $('#hash').val(data.hash)
            $('#modified_by').val(data.modified_by)
            $('#modified_date').val(data.modified_date)
        }
    });
    
    //Remove new form  
    $('#'+newFormId).remove();
}   