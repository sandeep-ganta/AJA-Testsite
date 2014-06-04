using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Reflection;
using System.Web;

namespace DAL.Models
{
    public class Grid_old
    {

        #region Constructor

        public Grid_old(string gridid, GridResult data, int noofrows, int Activepage, string targetid, string ajaxactionmethod)
        {
            GridId = gridid;
            if (data.DataSource == null)
            {
                throw new ArgumentNullException("datasource");
            }

            this.type = data.DataSource.GetType().GetGenericArguments().Single();
            if (!type.IsClass)
            {
                throw new Exception("Invalid Type for Grid");
            }
            this.Data = data.DataSource;
            this.Count = data.Count;

            NoofRows = noofrows;
            TargetId = targetid;
            ActivePage = Activepage;
            Paging = true;
            ActionName = ajaxactionmethod;
            Sorting = true;
            Searching = true;
        }

        public Grid_old(string gridid, int Totalcount, int noofrows, int Activepage, string targetid, string ajaxactionmethod)
        {
            GridId = gridid;
            this.Count = Totalcount;
            NoofRows = noofrows;
            TargetId = targetid;
            ActivePage = Activepage;
            Paging = true;
            ActionName = ajaxactionmethod;
            Sorting = true;
            Searching = true;
        }


        #region with sorting
        public Grid_old(string gridid, GridResult data, int noofrows, int Activepage, string targetid, string ajaxactionmethod, bool sorting, bool _Searching)
        {
            GridId = gridid;
            if (data.DataSource == null)
            {
                throw new ArgumentNullException("datasource");
            }

            this.type = data.DataSource.GetType().GetGenericArguments().Single();
            if (!type.IsClass)
            {
                throw new Exception("Invalid Type for Grid");
            }
            this.Data = data.DataSource;
            this.Count = data.Count;

            NoofRows = noofrows;
            TargetId = targetid;
            ActivePage = Activepage;
            Paging = true;
            ActionName = ajaxactionmethod;
            Sorting = sorting;
            Searching = _Searching;

        }

        public Grid_old(string gridid, int TotalRows, int noofrows, int Activepage, string targetid, string ajaxactionmethod, bool sorting, bool _Searching)
        {
            GridId = gridid;
            this.Count = TotalRows;
            NoofRows = noofrows;
            TargetId = targetid;
            ActivePage = Activepage;
            Paging = true;
            ActionName = ajaxactionmethod;
            Sorting = sorting;
            Searching = _Searching;
        }
        #endregion

        #region with out paging
        public Grid_old(string gridid, GridResult data, string targetid, string ajaxactionmethod)
        {
            GridId = gridid;
            if (data.DataSource == null)
            {
                throw new ArgumentNullException("datasource");
            }

            this.type = data.DataSource.GetType().GetGenericArguments().Single();
            if (!type.IsClass)
            {
                throw new Exception("Invalid Type for Grid");
            }
            this.Data = data.DataSource;
            this.Count = data.Count;
            TargetId = targetid;
            Paging = false;
            ActionName = ajaxactionmethod;
        }

        public Grid_old(string gridid, int TotalRows, string targetid, string ajaxactionmethod)
        {
            GridId = gridid;

            this.Count = TotalRows;
            TargetId = targetid;
            Paging = false;
            ActionName = ajaxactionmethod;
        }

        #endregion

        #endregion

        public bool Searching { get; set; }

        public bool isDictionary { get; set; }

        public bool Sorting { get; set; }

        public bool Paging { get; set; }

        public string GridId { get; set; }

        public string Caption { get; set; }

        public string ActionName { get; set; }

        public int NoofRows { get; set; }

        public int PagerCount
        {
            get
            {
                if (Count > NoofRows)
                {
                    if (Count % NoofRows == 0)
                        return Count / NoofRows;
                    else
                        return Count / NoofRows + 1;
                }


                else
                    return 1;
            }
        }

        public int Count { get; set; }

        public IEnumerable Data { get; set; }

        public int[] RowCount
        {
            get
            {
                if (rowcount == null)
                    return new int[] { 3, 5, 10 };
                else
                    return rowcount;
            }
            set
            {
                rowcount = value;
            }
        }

        public int ActivePage { get; set; }

        public int SelectedRowCount { get; set; }

        public GridColumn[] Columns
        {
            get
            {
                if (Gridcols.Length <= 0 && this.type != null)
                    return GenerateColumns();
                else
                    return Gridcols;
            }
            set
            {
                Gridcols = value;
            }
        }

        public List<GridRow> Rows
        {
            get
            {
                if (GridRows.Count > 0)
                {
                    foreach (var row in GridRows)
                    {
                        if (!row.NoActionNButtons)
                        {
                            row.ActionButtons = ActionButtons;
                        }
                    }
                    return GridRows;
                }
                else
                    return GenerateRows();
            }
            set
            {
                GridRows = value;
            }
        }

        public int StartRecord
        {
            get
            {
                if (Count == 0 || EndRecord == 0)
                    return 0;
                else
                    if (ActivePage == 1)
                        return 1;

                    else
                        return ((ActivePage - 1) * SelectedRowCount) + 1;
            }
        }

        public int EndRecord
        {
            get
            {
                if ((ActivePage * SelectedRowCount) > Count || !Paging)
                    return Count;
                else
                    return ActivePage * SelectedRowCount;
            }
        }

        public string PagerDrowpdownId
        {
            get
            {
                return GridId + "_Pager";
            }
        }

        public string NoofRowsDropdownId
        {
            get
            {
                return GridId + "_Noofrows";
            }
        }

        public string AjaxPagerformId
        {
            get
            {
                return GridId + "_ajax_pager_form";
            }
        }

        public string Sort_Expression
        {
            get;
            set;
        }

        public string Sort_Type { get; set; }

        public string SearchText
        {
            get
            {
                return searchcreteria;
            }
            set
            {
                searchcreteria = value;
            }

        }

        public string SearchBoxId
        {
            get
            {
                return GridId + "_Search_Box";
            }
        }

        public string TargetId
        {
            get;
            set;
        }

        public ActionButton[] ActionButtons
        {
            get;
            set;
        }

        public bool IsAnyActionButtons
        {
            get
            {
                var rowactionbuttons = Rows.Any(i => i.NoActionNButtons == false);
                if (rowactionbuttons)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public bool IsTableActions
        {
            get
            {

                if (TableActions == null)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
        }

        public ActionButton[] TableActions
        {
            get;
            set;
        }

        public string ActionUrl
        {
            get
            {
                return ActionName + "?pageid=dummy&rowcount=dummy2&sortexpression=dummy3&SortType=dummy4&SearchText=dummy5";
            }
        }

        #region Private Props

        private int[] rowcount;

        private string searchcreteria = string.Empty;

        private Type type { get; set; }

        private IEnumerable<PropertyInfo> Props
        {
            get
            {
                return this.type.GetProperties().AsEnumerable();
            }
        }

        private GridColumn[] Gridcols = { };

        private List<GridRow> GridRows = new List<GridRow>();

        private string[] Keys
        {
            get
            {

                return (Data as List<Dictionary<string, object>>).FirstOrDefault().Keys.ToArray();
            }

        }

        #endregion

        #region SUB-Classes


        public class ActionButton
        {
            public string DisplayName { get; set; }


            public string OnClick { get; set; }
        }

        public class GridColumn
        {
            public GridColumn()
            {
                Sortable = true;
            }

            public bool idColumn { get; set; }

            public string Property { get; set; }

            public string DisplayName { get; set; }

            public string width { get; set; }

            public bool Sortable { get; set; }

            public string GetSortType(string Sort_Expression, string Sort_Type)
            {
                if (Sort_Expression == Property)
                {
                    if (Sort_Type == "ASC")
                        return "DSC";
                    else
                        return "ASC";
                }
                return "ASC";
            }

            public string GetSortCssClass(string Sort_Expression, string Sort_Type)
            {
                if (Sort_Expression == Property)
                {
                    if (Sort_Type == "ASC")
                    {
                        return "sort-asc";
                    }
                    else
                    {
                        return "sort-dsc";
                    }
                }
                else
                {
                    return "sort";
                }
            }
        }

        public class GridRow
        {
            public GridRow()
            {
                Cells = new List<GridCell>();

                NoActionNButtons = false;
            }
            public List<GridCell> Cells { get; set; }

            public Grid_old.ActionButton[] ActionButtons { get; set; }

            public bool NoActionNButtons
            {
                get;
                set;
            }

            public class GridCell
            {
                public GridCell()
                {

                }
                public GridCell(string Value, bool isIdColumn)
                {
                    this.Value = Value;
                    this.isIdColumn = isIdColumn;
                }
                public string Value { get; set; }

                public bool isIdColumn { get; set; }
            }
        }

        public class GridResult
        {
            public GridResult(IEnumerable data, int count)
            {
                DataSource = data;
                Count = count;
            }
            public GridResult()
            {

            }
            public IEnumerable DataSource { get; set; }

            public int Count { get; set; }


        }

        #endregion

        #region Methods

        private GridColumn[] GenerateColumns()
        {

            List<GridColumn> cols = new List<GridColumn>();
            if (!isDictionary)
            {
                foreach (var prop in Props)
                {
                    var width = (100 / Props.Count()).ToString();
                    cols.Add(new GridColumn { Property = prop.Name, DisplayName = prop.Name, width = width, Sortable = Sorting });
                }
            }
            else
            {
                foreach (var key in Keys)
                {
                    var width = (100 / Keys.Count()).ToString();
                    cols.Add(new GridColumn { Property = key, DisplayName = key, width = width, Sortable = Sorting });
                }

            }
            return cols.ToArray();
        }

        private List<GridRow> GenerateRows()
        {
            List<GridRow> rows = new List<GridRow>();

            if (Data != null)
            {
                foreach (var item in Data)
                {
                    GridRow row = new GridRow();

                    foreach (var col in Columns)
                    {
                        if (!isDictionary)
                        {
                            if (item.GetType().GetProperty(col.Property) != null)
                            {
                                var colvalue = (item.GetType().GetProperty(col.Property).GetValue(item, null) ?? "").ToString();
                                var cell = new GridRow.GridCell(colvalue, col.idColumn);

                                row.Cells.Add(cell);
                            }
                            else
                            {
                                throw new ArgumentNullException("Invalid Property Name;");
                            }
                        }
                        else
                        {
                            var colvalue = (item as Dictionary<string, object>)[col.Property].ToString();
                            var cell = new GridRow.GridCell(colvalue, col.idColumn);

                            row.Cells.Add(cell);
                        }
                    }
                    if (ActionButtons.Count() > 0)
                        row.ActionButtons = ActionButtons;

                    rows.Add(row);
                }
            }
            return rows;
        }

        #endregion

    }
}