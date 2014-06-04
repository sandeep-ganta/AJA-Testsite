/*This file is used for usermanagement create,delete ,update users */

//var CreateUser = function CreateUser() {
//    debugger;
//    var url = "../User/GetUserwithID?uid=0";
//    $.get(url, null, function (html) {
//        $('#Edit_User_Dialog').html(html);
//        $.validator.unobtrusive.parse($("#Edit_User_Dialog"));
//        $('#Edit_User_Dialog').dialog({
//            modal: true,
//            title: "Create User",
//            show: { effect: 'drop', direction: 'up' },
//            width: 600,
//            height: 630,
//            close: function (event, ui) {
//                $(this).html("");
//                $('#tbl_AllUsers_Noofrows').change();
//            }
//        });
//    });

//}

function EditUser(ctrl) {
   
    var url = '../Admin/GetUserwithEmailID?uid=' + $(ctrl).attr('keyid') + '&rand=' + randGenerator();
    $.get(url, null, function (html) {
        $('#Edit_User_Dialog').html(html);
        $.validator.unobtrusive.parse($("#Edit_User_Dialog"));
        $('#Edit_User_Dialog').dialog({
            modal: true,
            title: "Edit User",
            show: { effect: 'drop', direction: 'up' },
            width: 600,
            height: 630,
            close: function (event, ui) {
                $(this).html("");
                $('#tbl_AllUsers_Noofrows').change();
            }
        });
    });
}

//var DeleteUser = function DeleteUser(ctrl) {
//    debugger;
//    var uid = $(ctrl).attr('keyid');

//    var NewDialog = $('<div id="MenuDialog">\
//                            <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>&nbsp;&nbsp;Are you sure? </p>\
//                      </div>');
//    NewDialog.dialog({
//        modal: true,
//        title: "Delete User",
//        buttons: [
//            {
//                text: "OK", click: function () {
//                    $.ajax(
//                        {
//                            type: "POST",
//                            url: "../User/DeleteUserwithEmailID/?Userid=" + uid,
//                            // data: JSON.stringify({ userid: uid }),
//                            contentType: "application/json; charset=utf-8",
//                            dataType: "json",
//                            success: function (data) {
//                                if (data) {
//                                    alert("Deleted Successfully");
//                                    $('#tbl_AllUsers_Noofrows').change();
//                                }
//                            },
//                            error: function (msg) {
//                                alert("Error while deleting user..");
//                            }

//                        });
//                    $(this).dialog("close");
//                }
//            },
//            { text: "Cancel", click: function () { $(this).dialog("close") } }
//        ]
//    });
//}

var ResetPassword = function ResetPassword(ctrl) {
    var uid = $(ctrl).attr('keyid');

    $.ajax({
        type: "POST",
        url: "../Admin/ResetPasswordEmail",
        data: JSON.stringify({ Email: uid }),
        async: true,
        width: 350,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (msg) {
            var NewDialog = $('<div id="MenuDialog">\
                                              <p><span class="ui-icon ui-icon-circle-check" style="float: left; margin: 0 7px 50px 0;"></span> An Email has sent to User EmailId </br> with New Password. </p>\
                                                </div>');
            NewDialog.dialog({
                modal: true,
                width: 350,
                title: "Password Reset",
                buttons: [
                    {
                        text: "OK", click: function () {
                            $(this).dialog("close");
                        }
                    }
                ]
            });
        },
        error: function (msg) { alert(msg); }
    });
}

var SendDataToPartialView = function SendDataToPartialView(data, status) {
    alert(data);
}

var ErrorOnEdit = function ErrorOnEdit(msg) {
    alert(msg);
}




$(function () {


});
