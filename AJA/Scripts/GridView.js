


///Global Variables
var PendingRequests = 0;
var NestedGridImageURL = "../Content/images/list_metro.png";
var NestedGridOpenerTRCssClass = "Chaild-Grid-Opener-tr";



//End

function LoadAllJqueryStyles() {

    LoadSpinners();


    //$(".ChaildGridButton").button({
    //    icons: {
    //        primary: "ui-icon-circle-plus"
    //    },
    //    text: false
    //});
    $('.Gridtable').find('.ui-spinner-button').siblings('input').keydown(function (e) {
        if (e.shiftKey || e.ctrlKey || e.altKey) {
            e.preventDefault();
        } else {
            var key = e.keyCode;
            if (key == 13 || key == 9) {
                RowCountChanged($(this));
                e.preventDefault();

            }
            if (!((key == 8) || (key == 46) || (key >= 35 && key <= 40) || (key >= 48 && key <= 57) || (key >= 96 && key <= 105))) {
                e.preventDefault();
            }




        }
    });


    $('.Gridtable').find('.ui-spinner-button').click(function () {
        //alert("changed");
        var elem = $(this).siblings('input');
        RowCountChanged(elem);

    });

    $(".bt_grid_refresh").button({
        icons: {
            primary: "ui-icon-refresh"
        },
        text: false
    });
    LoadTableActions();



    $(".btn_show_hide_grid").button({
        icons: {
            primary: "ui-icon-circle-triangle-n"
        },
        text: false
    });


    $(".btn-close-chaildGrid").button({

        icons: {
            primary: "ui-icon-closethick"
        },
        text: false
    });
};

$(function () {
    //$("#tbl_AllUsers tr:first:child").addClass('first');
    scrolldata();

    jQuery.expr[':'].contains = function (a, i, m) {

        return jQuery(a).text().toUpperCase()
            .indexOf(m[3].toUpperCase()) >= 0;
    };

    LoadAllJqueryStyles();
    AutoOpen_OnLoad();
    HelightSearch_OnLoad();


});

function HelightSearch_OnLoad() {

    var Grids = $(".Gridtable");
    for (var g = 0 ; g < Grids.length; g++) {
        var Grid = Grids[g];
        var SearchText = $(Grid).children("caption:first").find(".Grid_SearchBox").val();
        Helight_Search(Grid, SearchText);
    }
}
function OpenchaildGrid(elem) {

    var Grid = $(elem).parents("table.Gridtable:first");
    $(elem).parents('tr').toggleClass(NestedGridOpenerTRCssClass);
    var tr = $(elem).parents('tr').next('tr.SubGrid');
    if (tr.length != 0) {

        $(elem).parents('tr').next('tr.SubGrid').toggle();
    }
    else {
        var keyId = $(elem).attr("data-val-keyId");
        var Actions = $(elem).attr("data-val-chaildAction").split(",");
        var isOpen = $(elem).attr("data-val-isOpen");
        var addinfo = "";
        var addinfoFn = $(elem).attr("data-val-Fn");
        var data = { keyId: keyId };
        if (addinfoFn != undefined || addinfoFn != "") {
            if (typeof (window[addinfoFn]) === 'function') {
                var fnval = window[addinfoFn](Grid);
                addinfo = fnval;
                data = { keyId: keyId, addinfo: Stringify(addinfo) };
            }
        }



        if (Actions != null && data != null) {
            LoadNestedGrids(Grid, elem, data, Actions, 0);
        }

    }

};

function LoadNestedGrids(Grid, elem, data, Actions, index) {




    //var Grid = $(elem).parents("table.Gridtable:first");

    if (index < Actions.length) {


        var action = Actions[index];
        PendingRequests += 1;
        ShowBusy(Grid, true);
        $.post(action, data)
             .done(function (resdata) {
                 // ShowBusy(false);
                 CreateNestedGrid(resdata, elem);


                 //alert("success");
                 //LoadGrid(data, Grid);
                 //  $('#' + TargetId).html(data);
                 // scrolldata();
             })
             .fail(function (jqXHR, textStatus, errorThrown) {

                 switch (jqXHR.status) {
                     case 404:
                         alert("Page Not Found");
                         ShowBusy(Grid, false);
                         break;
                     case 403:
                         onSessionTimeout();
                         // alert("Forbidden : You are not authorized to access it ! Please login !");
                         ShowBusy(Grid, false);
                         break;
                     default:
                         alert(errorThrown);
                         ShowBusy(Grid, false);
                         break;
                 }
             })
         .always(function () {
             // ShowBusy(Grid, false);
             if (PendingRequests != 0)
                 PendingRequests -= 1;
             LoadNestedGrids(Grid, elem, data, Actions, index + 1);

         });
    }


};



function GenerateNewGrid(Model, keyId, isChaild) {

    var div_Chaild_Grid = "";
    if (isChaild)
        div_Chaild_Grid += '<div class="gridcontner Chaild-Grid-div">';
    else
        div_Chaild_Grid += '<div class="gridcontner">';


    //loader image
    div_Chaild_Grid += '<div class="loader-img" id="ajax_loader">';
    div_Chaild_Grid += ' <table>';
    div_Chaild_Grid += ' <tr>';
    div_Chaild_Grid += ' <td valign="middle">';
    div_Chaild_Grid += ' <div class="imgcntnr"></div></td>';
    div_Chaild_Grid += ' </tr>';
    div_Chaild_Grid += ' </table>';
    div_Chaild_Grid += '</div>';

    var Thtml = GenerateGrid(Model, keyId, true);
    div_Chaild_Grid += Thtml;

    div_Chaild_Grid += '</div>';

    return div_Chaild_Grid;

};
function CreateNestedGrid(Model, elem) {
    var keyId = $(elem).attr("data-val-keyId");

    var div_Chaild_Grid = GenerateNewGrid(Model, keyId, true);
    //



    var ParenthaveActions = $(elem).parents('table.Gridtable:first').find("tbody tr td.Grid-Row-Actions").length > 1 ? true : false;

    var colspan = ($(elem).parents('tr:first').children('td').length) - 1;


    var subGrid = $(elem).parents('tr:first').next('tr.SubGrid');
    if (subGrid.length > 0) {
        $(subGrid).children("td:nth-child(2)").append("<div style='margin-bottom:20px;'></div>");
        $(subGrid).children("td:nth-child(2)").append(div_Chaild_Grid);
    }
    else {

        if (ParenthaveActions)
            colspan -= 1;

        var res = '<tr class="SubGrid"><td></td><td colspan=' + colspan + '>' + div_Chaild_Grid + '</td>';

        if (ParenthaveActions)
            res += '<td></td>';

        res += '</tr>';
        //$(elem).parents('tr:first').next('tr.SubGrid').remove();
        $(elem).parents('tr:first').after(res);
    }

    LoadAllJqueryStyles();
    if (subGrid.length == 0) {
        var newGrid = $(elem).parents('tr:first').next("tr.SubGrid").find("table.Gridtable:first");
    }
    CheckautoOpenGrids(newGrid);

}

function CheckautoOpenGrids(Grid) {

    var list = $(Grid).children("tbody.Grid_rows").find("div[data-val-isopen='true']");
    if (list.length == 0)
        list = $(Grid).children("tbody.Grid_rows").find("div[data-val-isopen='True']");

    $(list).trigger("click");
    setTimeout(function () {
        if (PendingRequests < 1)

            ShowBusy(Grid, false);
    }, 1);
    //alert(list.length);
};

function AutoOpen_OnLoad() {

    var Grids = $(".Gridtable");
    for (var g = 0 ; g < Grids.length; g++) {
        var Grid = Grids[g];
        CheckautoOpenGrids(Grid);
    }
};

//function Grid_onLoad() {
//    var Grids = $(".Gridtable");
//    for (var g = 0 ; g < Grids.length; g++) {
//        var Grid = Grids[g];
//       // CheckautoOpenGrids(Grid);
//    }
//};

function GenerateGrid(Model, keyId, isChaildGrid) {

    if (keyId == undefined)
        keyId = 0;
    if (isChaildGrid == undefined)
        isChaildGrid = true;
    var TableCssClass = "Gridtable"

    var res = "";
    //if(isChaildGrid)
    //    res += '<div class="gridcontner Chaild-Grid-div">';
    //else
    //    res += '<div class="gridcontner">';

    ////loader image
    //res += '<div class="loader-img" id="ajax_loader">';
    //res += ' <table>';
    //res += ' <tr>';
    //res += ' <td valign="middle">';
    //res += '<img src="/Content/images/ajax-loader.gif" alt="Loading Records..." /></td>';
    //res += ' </tr>';
    //res += ' </table>';
    //res += '</div>';
    //

    //table

    if (isChaildGrid) {
        TableCssClass += " Chaild-Grid-table";
        res += '<table id= "' + Model.GridId + '" Filter-AddinfoFN="' + Model.AddinfoFilterFN + '" data-val-keyId="' + keyId + '" class="' + TableCssClass + '" Action-Url="' + Model.ActionUrl + '" Paging="' + Model.Paging + '" Sorting="' + Model.Sorting + '" Sort-Exp ="' + Model.Sort_Expression + '" Sort-Type="' + Model.Sort_Type + '">';
    }
    else {
        res += '<table id= "' + Model.GridId + '" Filter-AddinfoFN= "' + Model.AddinfoFilterFN + '" class="' + TableCssClass + '" Action-Url="' + Model.ActionUrl + '" Paging="' + Model.Paging + '" Sorting="' + Model.Sorting + '" Sort-Exp ="' + Model.Sort_Expression + '" Sort-Type="' + Model.Sort_Type + '">';
    }

    //Caption
    res += '<caption class="ui-widget-header ui-corner-top ui-helper-clearfix">';

    res += '<div class="Grid-Caption-Refresh">';

    res += '<button class="bt_grid_refresh ac_btns_icons" onclick="Refresh(this);"></button>';
    var Caption = "";
    if (Model.Caption != null)
        Caption = Model.Caption;
    res += '<Label class="ui-dialog-title Grid-Tittle">' + Caption + '</Label>';
    res += '</div>';



    res += '<div class="Grid-Caption-Search">';
    if (Model.Searching) {
        res += '<ul class="form-search">';
        res += '<li>';
        res += '<input type="text" value="' + Model.SearchData + '" class="Grid_SearchBox header_tbSearch" onkeydown="Search(event,this);" />';
        res += '</li>';
        res += '<li>';
        res += '<span class="form-header-search-submit-btn" onclick="Refresh(this);">.</span>';
        res += '</li>';
        res += '</ul>';

    }
    if (isChaildGrid)
        res += '<button class="btn-close-chaildGrid ac_btns_icons" onclick="CllopseChaildGrid(this);" ></button>';
    else

        res += '<button class="btn_show_hide_grid ac_btns_icons" onclick="ShowHideGrid(this);" ></button>';


    res += '</div>';
    res += '</caption>';
    //

    //Thead

    res += '<thead>';
    res += '<tr class="ui-accordion-header ui-state-default">';
    if (Model.IsAnyChaildActions) {
        res += '<td class="Chaild-Grid-Opener-td"></td>';
    }
    for (c in Model.Columns) {
        var col = Model.Columns[c];

        if (col.Visible) {

            res += '<td>';
            if (col.Sortable || col.Searchable) {
                // res += "<span Sort-Exp='" + col.Property + "' Sort-Type='" + col.SortType + "' class= 'sortable " + col.CssClass + "' onclick='Sorting(this);'>" + col.DisplayName + "</span>";
                res += "<span Prop-Name ='" + col.Property + "' class='" + col.CssClass + "' Sort-Type='" + col.SortType + "' onclick='Sorting(this);'>" + col.DisplayName + "</span>";

            }
            else {
                res += col.DisplayName;
            }
            res += ' </td>';
        }
    }
    if (Model.IsAnyRowActions) {
        res += ' <td class="Grid-RowAction-td">Action </td>';
    }

    res += '</tr>';
    res += '</thead>';
    //


    //Tbody
    res += '<tbody class="Grid_rows">';

    if (Model.Rows.length > 0) {
        for (r in Model.Rows) {
            var row = Model.Rows[r];
            res += '<tr data-val-keyId =' + row.KeyId + '>';
            if (row.AnyChaildGrids) {
                res += '<td>';
                res += '<div class="Chaild-Grid-Opener ChaildGridButton" onclick="OpenchaildGrid(this);" data-val-keyId =' + row.Cells[0].Value + ' data-val-isOpen =' + row.ChildGrid.isOpen + ' data-val-Fn=' + row.ChildGrid.addinfoFN + ' data-val-chaildAction=' + row.ChildGrid.actionURls + '></div>';
                //res += '<button class="ChaildGridButton" onclick="OpenchaildGrid(this);" keyid =' + row.Cells[0].Value + ' data-val-isOpen =' + row.ChildGrid.isOpen + ' data-val-Fn=' + row.ChildGrid.addinfoFN + ' data-val-chaildAction=' + row.ChildGrid.actionURls + '></button>';
                res += '</td>';
            }
            for (c in row.Cells) {
                var cell = row.Cells[c];
                if (cell.Visible) {

                    res += '<td><span>' + cell.Value + '</span></td> ';
                }

            }
            if (Model.IsAnyRowActions) {
                res += '<td class="Grid-RowAction-td Grid-Row-Actions">';
                if (!row.NoActionNButtons || row.ActionButtons != null) {
                    res += '<div>';

                    res += '<div class="menubar" onmouseover="ViewActionButtons(this);">';
                    res += '<ul>';

                    res += ' <li>';
                    res += '<div class="list-icon-bgcss">';
                    res += '</div>';
                    res += ' <ul>';
                    for (b in row.ActionButtons) {
                        var button = row.ActionButtons[b];
                        res += '<li>';

                        res += '<span keyid =' + row.KeyId + ' onclick="' + button.OnClick + '">' + button.DisplayName + '</span>';

                        res += '</li>';
                    }

                    res += '</ul>';

                    res += '</li>';
                    res += '</ul>';
                    res += '</div>';
                    res += '</div>';
                }
                res += '</td>';
            }
            res += '</tr>';
        }
    }
    else {
        res += ' <tr>';
        res += '<td class="Grid-NoRsults-Td"  colspan=' + Model.Columns.length + '>No Results Found </td>';
        res += '</tr>';
    }

    res += '</tbody>';
    //


    //tfoot

    res += '<tfoot>';
    var colspan = Model.Columns.length;
    if (Model.IsAnyRowActions) {
        colspan += 1;
    }
    res += '<tr class="ui-dialog-titlebar ui-widget-header">';
    res += '<td colspan=' + colspan + '>';
    res += '<table class="Grid-Tfoot-Subtable">';
    res += '<tr>';


    res += '<td class="Grid-T-ACButtons">';
    for (tb in Model.TableActions) {
        var tbaction = Model.TableActions[tb];
        var onclickFN = tbaction.OnClick;//ConvertToHTmlString(tbaction.OnClick);
        res += '<button class="btn_grid_create ac_btns_icons_text" onclick="' + onclickFN + '">' + tbaction.DisplayName + '</button>';

    }
    res += '</td>';



    res += '<td class="Grid-Pager-Td">';
    if (Model.Paging) {
        res += '<label style="font-weight: normal;">Page </label>';

        res += '<input class="Grid_Pager Grid_Number_Spinner" Max=' + Model.NoofPages + ' value=' + Model.ActivePage + ' />';

        res += '<label style="font-weight: normal;"><span> of&nbsp</span><span class="Grid_PagesCount">' + Model.NoofPages + '</span> </label>';

        res += '<label style="font-weight: normal;">&nbsp&nbspShow </label>';


        res += '<input class="Grid_Noofrows Grid_Number_Spinner" Max=' + 2147483647 + ' value=' + Model.SelectedRowCount + ' />';



        res += '<label style="font-weight: normal;"> Rows per page</label>';
    }

    res += '</td>';
    res += '<td class="Grid-info-Td">';
    res += '<label class="Grid-info-Label">Showing <span class="Grid_Start_Record">' + Model.IntialRecord + '</span>-<span class="Grid_End_Record">' + Model.FinalRecord + '</span> of <span class="Grid_Total_Count">' + Model.Count + '</span>  </label>';
    res += '</td>';
    res += '</tr>';
    res += '</table>';
    res += '</td>';
    res += '</tr>';

    res += '</tfoot>';
    //


    res += '</table>';
    //
    //res += '</div>';
    //
    return res;
};

function LoadSpinners() {
    $(".Grid_Number_Spinner").spinner(
        {
            min: 1,
            max: $(this).attr('Max'),
            spin: function (event, ui) {
                if (ui.value > $(this).attr('Max')) {
                    $(this).spinner("value", $(this).attr('Max'));
                    return false;
                }
            }

        });

};

function LoadTableActions() {
    $(".btn_grid_create").button({
        icons: {
            primary: "ui-icon-plusthick"
        }
    });
};

function OnPaging(elem) {

    var btn_refresh = $(elem).parents("table.Gridtable:first").find("button.bt_grid_refresh");
    $(btn_refresh).trigger("click");
}

function RowCountChanged(elem) {

    var val = parseInt($(elem).val());

    if (!isNaN(val)) {

        var MIN = 1;
        var MAX = $(elem).attr('Max');

        if (val < MIN) {
            // alert("input value " + $(elem).val() + " is less than 1.");

            //$(elem).focus(function () {
            //    $(this).select();
            //});
            $(elem).spinner("value", MIN);
        }
        else if (val > MAX) {
            // alert("input value " + $(elem).val() + " is greater than total pages (" + MAX + ").");

            //$(elem).focus(function () {
            //    $(this).select();
            //});
            $(elem).spinner("value", MAX);
        } else {
            $(this).val(val);
            Refresh(elem);
            //var btn_refresh = $(elem).parents("table.Gridtable:first").find("button.bt_grid_refresh");
            //$(btn_refresh).trigger("click");
        }
    }
    else {
        alert($(elem).val() + " is not a valid Integer Value");
        $(elem).focus(function () {
            $(this).select();
        });

    }
};

function Search(event, elem) {
    // debugger;
    // console.log(event.keyCode + "----" + $(elem).val());
    if (event.keyCode == 13) {
        // debugger;
        //var searchbtn = $(elem).parents("ul.form-search").find("span.form-header-search-submit-btn");
        //// $("#id_of_button").click();          

        //$(searchbtn).click();
        // alert("hi");
        event.preventDefault();
        Refresh(elem);
        // $(elem).hover();
        //var btn_refresh = $(elem).parents("table.Gridtable").find("caption").find("button.bt_grid_refresh");
        //$(btn_refresh).trigger("click");

    }
};

function scrolldata() {
    //$(".Gridtable").tableScroll({ width: window });
    //$(".Gridtable").tableScroll({ height: 155 });
    //var captiondiv = '<div class="ui-widget-header ui-corner-top ui-helper-clearfix kgrid-caption">' + $(".Gridtable caption").html() + '</div>';
    // $('.tablescroll').prepend(captiondiv);
    //$('.tablescroll_head').prepend($(".Gridtable caption").clone());
    //  $(".Gridtable caption").hide();
    //$(".Gridtable tr td:first-child").css('width', $('.Gridtable tr td:first-child').width() + 1);
    //$(".Gridtable thead tr td").css('width', $('.Gridtable tbody tr td').width());
    // $('.tablescroll_head thead tr td').width() == $('.tablescroll_body tbody tr td').width();

    //var tdwidth = $('.tablescroll_body tbody tr td:first').css('width');
    //alert(tdwidth);
    //$('.tablescroll_head thead tr td:first').css('width', tdwidth + 10);

    var searchbox = $(".header_tbSearch");
    //if (searchbox.length != -1 ) {

    //    if (IsEmpty($(searchbox).val())) {

    //        var searchtext = $(searchbox).val();

    //        alert(searchtext);
    //    }

    //}
};

function ViewActionButtons(elem) {
    //var pelem = $(elem).find("li:first").find("ul:first");
    //var offset = $(elem).offset();
    ////alert(elem.top);
    //$(pelem).css('top', offset.top);
    //$(pelem).css('left', offset.left - 130);
    $('.menubar ul li:hover > ul').show();
};

function Sorting(elem) {

    var Grid = $(elem).parents("table.Gridtable:first");
    var sorttype = $(elem).attr("Sort-Type");
    var SortExp = $(elem).attr("prop-name");
    var action = $(Grid).attr("Action-Url");
    var obj = GetFilterObject(Grid, sorttype, SortExp);
    if (obj != null) {
        ReloadData(action, Grid, obj);
    }
    else {
        alert("InValid Input Value");
    }

};

function LoadGrid(obj, Grid) {

    if (obj != null) {

        var isChaildGrid = $(Grid).hasClass("Chaild-Grid-table");
        var keyid = $(Grid).attr("data-val-keyid") == undefined ? 0 : $(Grid).attr("data-val-keyid");

        var ParentDivContainer = $(Grid).parents("div.gridcontner:first");

        var NewGridHTML = GenerateGrid(obj, keyid, isChaildGrid);
        $(Grid).replaceWith(NewGridHTML);

        var NewGrid = $(ParentDivContainer).children("table.Gridtable:first");
        LoadAllJqueryStyles();
        //ShowBusy(Grid, false);

        var afterLoadFN = $.trim(obj.AfterLoad);

        if (typeof (window[afterLoadFN]) === 'function') {
            window[afterLoadFN](NewGrid);

        }
        Helight_Search(NewGrid, obj.SearchData);

        CheckautoOpenGrids(NewGrid);

    }
    //else {
    //   // alert("Obje");
    //}
}

///Grid Reload function 
var Grid_Reload = function (elem) {
    if (elem == undefined) {

        elem = $("table.Gridtable:first").find(".bt_grid_refresh:first");
    }

    Refresh(elem);
};



function ReloadData(action, Grid, obj) {
    PendingRequests += 1;
    ShowBusy(Grid, true);
    $.post(action, obj)
        .done(function (data) {
            ShowBusy(false);
            // debugger;
            LoadGrid(data, Grid);
            //ActionSetting();
            //  $('#' + TargetId).html(data);
            // scrolldata();
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            switch (jqXHR.status) {
                case 404:
                    alert("Page Not Found");
                    ShowBusy(Grid, false);
                    break;
                case 403:
                    onSessionTimeout();
                    // alert("Forbidden : You are not authorized to access it ! Please login !");
                    ShowBusy(Grid, false);
                    breakk;
                default:
                    alert(errorThrown);
                    ShowBusy(Grid, false);
                    break;
            }


        })
    .always(function () {
        //ShowBusy(Grid, false);
        PendingRequests -= 1;
    });


}

function ShowBusy(Grid, res) {
    if (res) {
        //$('#' + TargetId).width();
        $('#ajax_loader').show();
        $('.gridcontner').css('position', 'relative');
        $('.div_busy_panel_background').css('width', $(Grid).width());
        $('.div_busy_panel_background').css('height', $(Grid).height());
        $('.div_busy_panel_background').show();
    }
    else {
        $('#ajax_loader').hide();
        $('.div_busy_panel_background').hide();
        $('.gridcontner').css('position', 'inherit');
    }
};

function Refresh(elem) {

    var Grid = $(elem).parents("table.Gridtable:first");
    var sorttype = $(Grid).attr("Sort-Type");
    var SortExp = $(Grid).attr("Sort-Exp");
    //alert(SortExp);
    var action = $(Grid).attr("Action-Url");

    var obj = GetFilterObject(Grid, sorttype, SortExp);

    if (obj != null) {
        ReloadData(action, Grid, obj);
    }
    else {
        alert("InValid Input Value");
    }
}


function GetFilterObject(Grid, sorttype, sortexp) {
    var obj = new Object();

    var pvalue = 1;
    var rvalue = 2147483647;

    var hitserver = true;

    var Sorting = parseBool($(Grid).attr("Sorting"));
    var paging = parseBool($(Grid).attr("Paging"));

    if (paging) {
        var Pager = $(Grid).find(".Grid_Pager:last");
        var RowsChanger = $(Grid).find(".Grid_Noofrows:last");
        var tcount = parseInt($(Grid).find(".Grid_Total_Count").text());
        if ($(Pager).val() != "") {
            pvalue = parseInt($(Pager).val());
        }
        if ($(RowsChanger).val() != "") {
            rvalue = parseInt($(RowsChanger).val());
        }

        if (isNaN(pvalue) || isNaN(rvalue)) {
            hitserver = false;
        }
        else {

            if (pvalue > $(Pager).attr("MAX")) {

                // alert("InValid Input Value");
                $(Pager).spinner("value", $(Pager).attr("MAX"));
                // hitserver = false;
            }
            else if (rvalue > $(RowsChanger).attr("MAX")) {

                //alert("InValid Input Value");
                $(RowsChanger).spinner("value", $(RowsChanger).attr("MAX"));
                // hitserver = false;
            }
            if ((pvalue * rvalue) > tcount && pvalue != 1) {

                //console.log("Change URl - " + pvalue + " " + rvalue + " " + tcount );
                pvalue = CheckPageId(pvalue, rvalue, tcount);
            }

            $(Grid).find(".Grid_Pager").val(pvalue);
        }
    }
    // alert(hitserver);

    if (hitserver) {

        var SearchText = $(Grid).find(".Grid_SearchBox").val();
        if (SearchText == undefined) {
            SearchText = "";
        }
        else {
            SearchText = $.trim(SearchText);
        }


        obj["isPaging"] = paging;
        obj["PageNo"] = pvalue;
        obj["NoofRows"] = rvalue;


        if (Sorting) {

            var SortProps = new Array();
            $(Grid).find("thead:first > tr>td>span.Sortable").each(function (index, elem) { SortProps.push($(elem).attr("Prop-Name").toString()); });
            obj["SortPropJson"] = JSON.stringify(SortProps);
            obj["isSorting"] = true;
            obj["SortProp"] = ManageSpaces(sortexp);
            obj["isAscending"] = sorttype == "ASC" ? true : false;
        }
        else {
            obj["isSorting"] = false;
        }


        var SearchProps = new Array();
        $(Grid).find("thead:first > tr>td>span.Searchable").each(function (index, elem) { SearchProps.push($(elem).attr("Prop-Name").toString()); });
        if (SearchProps.length > 0) {

            obj["isSearching"] = true;
            obj["SearchPropJson"] = JSON.stringify(SearchProps);
            obj["SearchText"] = ManageSpaces(SearchText);
        }
        else {
            obj["isSearching"] = false;
        }

        if ($(Grid).attr("data-val-keyid") != undefined)
            obj["ParentId"] = $(Grid).attr("data-val-keyid");
        else
            obj["ParentId"] = 0;


        // var addinfo = new Object();
        var fnname = $(Grid).attr("Filter-AddinfoFN");
        if (typeof (window[fnname]) === 'function') {
            var fnval = window[fnname](Grid);
            // addinfo = fnval;

            obj["AddinfoJson"] = Stringify(fnval);
        }

    }
    return obj;
}
function IsJson(str) {
    try {
        JSON.parse(str);
    } catch (e) {
        return false;
    }
    return true;
}

function Stringify(obj) {

    if (IsJson(obj))
        return obj;
    else
        return JSON.stringify(obj);

}

function ManageSpaces(data) {
    if (data != undefined) {
        var data = data.replace(/ /g, '%20');
        return data;
    }
}

function CheckPageId(pno, rno, tc) {

    try {

        //console.log("CheckPageId before --- " + pno + " " + rno + " " + tc);
        var min = (pno - 1) * rno;
        var max = (pno) * rno;

        if (!(min < tc && tc <= max)) {
            pno = CheckPageId(pno - 1, rno, tc);
        }
        //console.log("CheckPageId after --- " + pno + " " + rno + " " + tc);
        return pno;
    }
    catch (x) {
        //  debugger;
        alert(x.message);

    }


};

var ShowHideGrid = function (elem) {

    $(elem).parents(".Gridtable").children(".Gridtable thead, .Gridtable tbody, .Gridtable tfoot").slideToggle("600", function () {

        $(elem).children("span.ui-icon-circle-triangle-s").switchClass("ui-icon-circle-triangle-s", "ui-icon-circle-triangle-n", 'fast');
        $(elem).children("span.ui-icon-circle-triangle-n").switchClass("ui-icon-circle-triangle-n", "ui-icon-circle-triangle-s", 'fast');

    });
    $(elem).parents('div:first').children("ul:first").toggle('600');

    //$(elem).parents("table.tablescroll_head").children("thead").slideToggle();

};

function highlight_words(keywords, element) {
    if (keywords) {
        var textNodes;
        keywords = keywords.replace(/\W/g, '');
        var str = keywords.split(" ");
        $(str).each(function () {
            var term = this;
            var textNodes = $(element).contents().filter(function () { return this.nodeType === 3 });
            textNodes.each(function () {
                var content = $(this).text();
                var regex = new RegExp(term, "gi");
                content = content.replace(regex, '<span style="background-color:yellow" class="highlight">' + term + '</span>');
                $(this).replaceWith(content);
            });
        });
    }
};

function Helight_Search(Grid, SearchText) {


    if ($.trim(SearchText)) {
        $(Grid).find('tbody.Grid_rows span:contains(' + SearchText + ')').not('div.menubar li span').each(function (index, elem) {
            var html = $(elem).text();

            var reg = new RegExp(SearchText, 'gi');
            var newhtml = html.replace(reg, function (str) { return "<span style='background:yellow;'>" + str + "</span>" });


            $(elem).html(newhtml);
            //$(elem).css('background', 'yellow');
        });
    }

};

function CllopseChaildGrid(elem) {
    $(elem).parents("tr.SubGrid:first").prev("tr").removeClass(NestedGridOpenerTRCssClass);
    $(elem).parents("tr.SubGrid:first").remove();
};

function ConvertToHTmlString(str) {
    var re = '\"';
    var newre = '"';
    return str.replace(re, newre);

};

function parseBool(value) {
    if (typeof value === "string") {
        value = value.replace(/^\s+|\s+$/g, "").toLowerCase();
        if (value === "true" || value === "false")
            return value === "true";
    }
    return; // returns undefined
}
