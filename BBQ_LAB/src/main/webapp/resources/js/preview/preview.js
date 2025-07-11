function fn_openPreview1(docType) {
    var url = "";
    
    switch (docType) {
        case "PROD":
            url = "/preview/productPopup";
            break;
        case "MENU":
            url = "/preview/menuPopup";
            break;
        default:
            alert("미리보기 유형이 올바르지 않습니다.");
            return;
    }

    // 새 창 오픈 후 데이터 전달
    var popup = window.open(url, "preview", "width=842,height=1191,scrollbars=yes,resizable=yes");
	
}