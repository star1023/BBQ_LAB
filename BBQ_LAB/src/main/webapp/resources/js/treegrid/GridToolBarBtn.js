var GridToolBar = new Object();
GridToolBar.showColumns = function(gridNm){
    Grids[gridNm].ActionShowColumns();
    return;
}
function showColumns(gridNm){
    Grids[gridNm].ActionShowColumns();
    return;
}

function reloadGrid(name){
    var grid;
    var gridRows=-1;

    if(name.length<1){
        grid = Grids[0];
    }else{
        grid = Grids[name];
    }

    gridRows = grid.RowCount;
    grid.ReloadBody();
}

function printGrid(gridNm){
    Grids[gridNm].ActionPrint();

    return;
}

function exportGrid(gridNm, type){
    grid = Grids[gridNm];
    col = grid.GetCols();

    for(var i =0; i < col.length; i ++){
        if(grid.Cols[col[i]].Visible == 1 && col[i] != "Panel"){
            if(grid.Cols[col[i]].CanExport == 0 && grid.Cols[col[i]].Type != "Icon"){
                grid.SetAttribute(null, col[i], "CanExport", 1, 1);
            }
        }else if(grid.Cols[col[i]].Visible == 0 && col[i] != "Panel"){
            grid.SetAttribute(null, col[i], "CanExport", 0, 1);
        }
    }

    if(type.toUpperCase() == 'PDF'){
        Grids[gridNm].ActionExportPDF();
    }else{
        //Grids[gridNm].Source.Export.Type=type;
        Grids[gridNm].ActionExport();
    }

    return;
}