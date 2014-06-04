function GetFormDataAsJson() {

    var Valuechange = false;
    var FieldValues = [];

    var uid = $("#txt_UserId").val();
    var uname = $("#txt_UserName").val();
    var EId = $("#txt_EmailId").val();
    var Fname = $("#txt_FirstName").val();
    var Lname = $("#txt_LastName").val();
    var Pwd = $("#txt_Password").val();
    var CPassword = $("#txt_ConfirmPassword").val();
    var Title = $("#ddl_title").val();
    var zip = $("#txt_Postalcode").val();
    var profsn = $("#ddl_Profession").val();
    var userspeciality = $("#ddl_speciality").val();
    var GradYear = $("#GraduationYr").val();
    var Practice = $("#ddl_PracticeID").val();
    var Country = $("#ddl_countryID").val();
    var EditorsQuery = $("#chk_sendemail").is(":checked");
    var SavedQuery = $("#chk_AutoQueryEmail").is(":checked");
    var IsAdmin = $('#chk_IsAdmin').is(":checked");
    var IsAjaUser = $('#chk_IsAjaUser').is(":checked");

    var Roles = [];

    $('input[name="chkRole"]:checked').each(function (i) {
        Roles.push({ 'RoleID': $(this).val(), 'RoleName': $(this).next('label').text(), 'IsSelected': true });
    });
    var todaysdate = new Date();
    var chkChange = $('#div_dynamicFelids :checkbox');

    //---------------- checking checkbox value change---------------


    var i;
    for (i = 0; i < chkChange.length; i++) {
        var checkchange = false;
        if (chkChange[i].name != 'chkRole' && chkChange[i].checked != chkChange[i].defaultChecked) {
            Valuechange = true;
            checkchange = true;
        }

        if (checkchange) {
            if (chkChange[i].checked)
                FieldValues.push({ 'UserID': uid, 'OptionID': chkChange[i].accessKey, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel': 0 });
            else {
                FieldValues.push({ 'UserID': uid, 'OptionID': chkChange[i].accessKey, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel': 1 });
            }
        }
    }
    //---------------- checking radiobutton value change---------------


    var rbtnChange = $('#div_dynamicFelids :radio');

    var i;
    for (i = 0; i < rbtnChange.length; i++) {

        var radiochange = false;
        if (rbtnChange[i].checked != rbtnChange[i].defaultChecked) {
            Valuechange = true;
            radiochange = true;
        }
        if (radiochange) {
            if (rbtnChange[i].checked)
                FieldValues.push({ 'UserID': uid, 'OptionID': rbtnChange[i].accessKey, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel': 0 });
            else
                FieldValues.push({ 'UserID': uid, 'OptionID': rbtnChange[i].accessKey, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel': 1 });
        }
    }

    //---------------- checking textbox or tetarea value change---------------



    //var txtChange = $('#div_dynamicFelids :text');
    //var i;
    //for (i = 0; i < txtChange.length; i++) {
    //    var textchange = false;
    //    if (txtChange[i].value != txtChange[i].defaultValue) {
    //        if (txtChange[i].id != 'txt_UserId' && txtChange[i].id != 'txt_EmailId' && txtChange[i].id != 'txt_Password' && txtChange[i].id != 'txt_ConfirmPassword')
    //            FieldValues.push({ 'UserID': uid, 'OptionID': txtChange[i].accessKey, 'Value': txtChange[i].value, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel':0 });
    //        Valuechange = true;
    //    }
    //}


    var txt = $('#div_dynamicFelids input[type=text], textarea');
    var i = 0;
    for (i = 0; i < txt.length; i++) {
        if (txt[i].value != txt[i].defaultValue) {
            FieldValues.push({ 'UserID': uid, 'OptionID': txt[i].accessKey, 'Value': txt[i].value, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel': 0 });
            Valuechange = true;
        }
    }
    //---------------- checking dropdown list (single checked allowed) value change---------------            

    var ddlChange = $('#div_dynamicFelids select');
    var i;

    for (i = 0; i < ddlChange.length; i++) {

        if (!ddlChange[i].options[ddlChange[i].selectedIndex].defaultSelected) {
            FieldValues.push({ 'UserID': uid, 'OptionID': +ddlChange[i].options[ddlChange[i].options.selectedIndex].accessKey, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel': 0 });


            var defaultindex;
            $.each(ddlChange[i].options, function (j) {

                if (ddlChange[i].options[j].defaultSelected) {
                    if (ddlChange[i].options[j].value != "") {
                        defaultindex = ddlChange[i].options[j].index;
                        FieldValues.push({ 'UserID': uid, 'OptionID': +ddlChange[i].options[defaultindex].accessKey, 'UpdatedDate': todaysdate, 'UpdatedBy': 0, 'NeedToDel': 1 });

                    }

                }

            });
            Valuechange = true;

        }
    }

    var formObject = {
        UserId: uid,
        EmailID: EId,
        UserName: uname,
        FirstName: Fname,
        LastName: Lname,
        Roles: Roles,
        Password: Pwd,
        ConfirmPassword: CPassword,
        Title: Title,
        PracticeID: Practice,
        postalcode: zip,
        Profession: profsn,
        SpecialityID: userspeciality,
        GraduationYr: GradYear,
        CountryID: Country,
        NotNulIsendmail: EditorsQuery,
        NotNullIsSavedQueryemail: SavedQuery,
        IsAJAUser: IsAjaUser,
        IsAdmin: IsAdmin,
    }
    
    return formObject;
}