//This file is used to write all the custom scripts related to the application

$(document).ready(function () {

   


    // hide #back-top first

    $("#back-top").hide();

    // fade in #back-top
    $(function () {
        $(window).scroll(function () {

            if ($(this).scrollTop() > 10) {
                $('#back-top').fadeIn();
            } else {
                $('#back-top').fadeOut();
            }
        });
        // scroll body to 0px on click
        $('#back-top a').click(function () {
            $('body,html').animate({
                scrollTop: 0
            }, 800);
            return false;
        });
    });
});

$(function () { 
    $("[id$='subhead']").accordion({
        collapsible: true,
        active: 1
    });
    $("[id$='subhead-panel-0']").css('height', 'auto');
    ServerURL= $("#hdn_ServerUrl").val();
});




/*Make a AJAX Request with call back functions */
function MakeARequest(url, data, RequestType, Successfn, Errorfn) {

    $.ajax(
               {
                   type: RequestType,
                   url: url,
                   data: data,
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   success: Successfn,
                   error: Errorfn

               });
}

function randGenerator() {
    var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZ";
    var string_length = 32;
    var myrnd = [], pos;

    // loop as long as string_length is > 0
    while (string_length--) {
        // get a random number between 0 and chars.length 
        pos = Math.floor(Math.random() * chars.length);
        // add the character from the base string to the array
        myrnd.push(chars.substr(pos, 1));
    }

    // join the array using '' as the separator, which gives us back a string
    var rnd = myrnd.join(''); // e.g "6DMIG9SP1KDEFB4JK5KWMNSI3UMQSSNT" 
    return rnd;
}

// Login Form

//$(function () {
 
//    var button = $('#loginButton');
//    var box = $('#loginBox');
//    var form = $('#loginForm');
//    button.removeAttr('href');
//    button.mouseup(function (login) {
//        box.toggle();
//        button.toggleClass('active');
//    });
//    form.mouseup(function () {
//        return false;
//    });
//    $(this).mouseup(function (login) {
//        if (!($(login.target).parent('#loginButton').length > 0)) {
//            button.removeClass('active');
//            box.hide();
//        }
//    });


   

//});


function EditDetails(emailid) { 
    var url = '../User/GetUserDetails?' + '&rand=' + randGenerator(); 
    $.get(url, null, function (html) {
        $('#div_User_details').html(html);
        $.validator.unobtrusive.parse($("#div_User_details"));
        $('#div_User_details').dialog({
            modal: true,
            title: "Modify Personal Details",
            width: 600,

            close: function (event, ui) {
                $(this).html("");
                if ($("#tbl_AllUsers_Noofrows").length != 0) {
                    $('#tbl_AllUsers_Noofrows').change();
                }

            }
        });
    });
};

 
//function ChangePassword() {
//    debugger;
//    var url = '../User/ChangePassword';
//    $.get(url, null, function (html) {
//        $('#div_User_details').html(html);
//        $.validator.unobtrusive.parse($("#div_User_details"));
//        $('#div_User_details').dialog({
//            modal: true,
//            title: "Change Password",
//            width: 470,
//            close: function (event, ui) {
//                $(this).html("");

//            }
//        });
//    });
//}

function SaveChangePassword() { 
    if ($("#form_Change_Password").valid()) {
        var $form = $("#form_Change_Password");
        var url = $form.attr('action');
        //var data = $("#form_Change_Password").serialize();

        var fieldValuePairs = $("#form_Change_Password").serializeArray();

        var data = ArraytoJsonObject(fieldValuePairs);
        var val = JSON.stringify({ "cp": data });
        var RequestType = $form.attr('method');

        $.ajax({
            type: RequestType,
            url: url,
            data: val,
            contentType: "application/json; charset=utf-8",
            dataType: "json"

        }).done(function () {

            var dail = $form.parents('div[class^="ui-dialog ui-widget ui-widget-content ui-corner-all ui-front ui-draggable ui-resizable"]')[0];
            var dailogid = $(dail).attr('aria-describedby');
            //$(dail).dialog('close');
            $('#' + dailogid).dialog('close');
            alert('Password Changed Successfully');
        })
        .fail(function (E) { alert("error"); }).
        always(function () { });
    }
}


function ArraytoJsonObject(fieldValuePairs) {

    var cp = new Object();
    $.each(fieldValuePairs, function (index, fieldValuePair) {

        cp[fieldValuePair.name] = fieldValuePair.value;
        // alert("Item " + index + " is [" + fieldValuePair.name + "," + fieldValuePair.value + "]");
    });

    return cp;

};


function alert(body, title) {   
    if (title == undefined)
        title = window.location.hostname + " says :";
    var NewDialog = $('<div><label>' + body + '</label> </div>');
    NewDialog.dialog({
        modal: true,
        maxWidth: 400,
        resize: false,
        title: title,
        height: 'auto',
        buttons: [
            {
                text: "OK", click: function () {
                    $(this).dialog("close");
                }
            },
        ]
    });
}

var Notify = function (text) {
    //var newdailog = '<div class="ui-widget"><div class="ui-state-error ui-corner-all" style="padding: 0 .7em;"> <p><span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span><strong>Alert:</strong>' + text + '</p></div></div>';
}


//Check string empty or not
function IsEmpty(StringToCheck) {
    //first remove all spaces using the following regex
    StrToCheck = StrToCheck.replace(/^\s+|\s+$/, '');

    //then we check for the length of the string if its 0 or not
    if (StrToCheck.length == 0)
        return false;
    else
        return true;
}



