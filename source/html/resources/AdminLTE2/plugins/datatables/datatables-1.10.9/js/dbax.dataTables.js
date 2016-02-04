/**
 * DBAX dataTables checkbox row selction
 * @param   tableId   the tableID
 * @param   dataTable   the datatable object
 * @param   selectAllName   the name of the input checkbox in the table header
 * @param   selectedArr   the array of selected checboxes
 */
function checkboxRowSelection(tableId, dataTable, selectAllName, selectedArr) {

    // Handle click on checkbox
    $('#' + tableId + ' tbody').on('change', 'input[type="checkbox"]', function(e) {
        var $row = $(this).closest('tr');
        // Get row ID
        var id = $row[0].id;
        var index = $.inArray(id, selectedArr);

        if (index === -1) {
            selectedArr.push(id);
        } else {
            selectedArr.splice(index, 1);
        }

        // Update state of "Select all" control
        updateDataTableSelectAllCtrl(dataTable);

        // Prevent click event from propagating to parent
        e.stopPropagation();
    });

    // Handle click on "Select all" control
    $('#' + tableId + ' thead input[name="' + selectAllName + '"]').on('click', function(e) {
        if (this.checked) {
            $('#' + tableId + ' tbody input[type="checkbox"]:not(:checked)').trigger('click');
        } else {
            $('#' + tableId + ' tbody input[type="checkbox"]:checked').trigger('click');
        }

        // Prevent click event from propagating to parent
        e.stopPropagation();
    });

    // Handle table draw event
    dataTable.on('draw', function() {
        // Update state of "Select all" control
        updateDataTableSelectAllCtrl(dataTable);
    });

    //
    // Updates "Select all" control in a data table
    //
    function updateDataTableSelectAllCtrl(table) {
        var $table = table.table().node();
        var $chkbox_all = $('tbody input[type="checkbox"]', $table);
        var $chkbox_checked = $('tbody input[type="checkbox"]:checked', $table);
        var chkbox_select_all = $('thead input[name="' + selectAllName + '"]', $table).get(0);

        // If none of the checkboxes are checked
        if ($chkbox_checked.length === 0) {
            chkbox_select_all.checked = false;
            if ('indeterminate' in chkbox_select_all) {
                chkbox_select_all.indeterminate = false;
            }

            // If all of the checkboxes are checked
        } else if ($chkbox_checked.length === $chkbox_all.length) {
            chkbox_select_all.checked = true;
            if ('indeterminate' in chkbox_select_all) {
                chkbox_select_all.indeterminate = false;
            }

            // If some of the checkboxes are checked
        } else {
            chkbox_select_all.checked = true;
            if ('indeterminate' in chkbox_select_all) {
                chkbox_select_all.indeterminate = true;
            }
        }
    }
}

/**
 * DBAX dataTable navigate HTML text input fields with arrow keys 
 * @param   tableId   the tableID 
 */
function inputTextKeyMap(tableId) {
    // Handle arrow kyes
    $('#' + tableId + ' tbody').on('keyup', 'input[type="text"]', function(e) {
        // un-comment to display key code
        //console.log(e.which);
        if (e.which == 39) { // right arrow
            nextBox = $(this).closest('td').next().find('input[type="text"]');
            nextBox.focus();
            nextBox.select();
        } else if (e.which == 37) { // left arrow              
            prevBox = $(this).closest('td').prev().find('input[type="text"]');
            prevBox.focus();
            prevBox.select();
        } else if (e.which == 40) { // down arrow              
            downBox = $(this).closest('tr').next().find('td:eq(' + $(this).closest('td').index() + ')').find('input[type="text"]');
            downBox.focus();
            downBox.select();
        } else if (e.which == 38) { // up arrow              
            upBox = $(this).closest('tr').prev().find('td:eq(' + $(this).closest('td').index() + ')').find('input[type="text"]');
            upBox.focus();
            upBox.select();
        } else if (e.which == 13) { // enter key            
            enterBox = $(this).closest('tr').next().find('input[type="text"]').first();
            enterBox.focus();
            enterBox.select();
        }
        // Prevent click event from propagating to parent
        e.stopPropagation();
    });
}