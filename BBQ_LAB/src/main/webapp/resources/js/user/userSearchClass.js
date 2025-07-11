
// ✅ fn2: userSearch 전용 헬퍼 함수
var fn2 = new Object();
fn2.isEmpty = function(value) {
    return (value === '' || value === null || value === undefined);
};
fn2.ajax = function(url, postData, successFn, errorFn, type) {
    $.ajax({
        type: type || "POST",
        url: url,
        dataType: "json",
        data: postData,
        async: false,
        success: successFn,
        error: errorFn || function() { alert("오류 발생"); },
        traditional: true
    });
};
fn2.autoComplete = function(objKeyWord) {
    var config = new Object();
    config.minLength = 1;
    config.delay = 300;

    config.source = function(request, response) {
        if ((objKeyWord.val() || '').indexOf("/") > 0) return;
        fn2.ajax("/approval/searchUserAjax", { keyword: objKeyWord.val() }, function(data) {
            response($.map(data, function(item) {
                return {
                    label: item.USER_NAME + " / " + item.USER_ID + " / " + item.OBJTTX + " / " + (item.RESP_TXT || ''),
                    value: item.USER_NAME + " / " + item.USER_ID + " / " + item.OBJTTX + " / " + (item.RESP_TXT || ''),
                    userId: item.USER_ID,
                    deptName: item.OBJTTX,
                    teamName: item.RESP_TXT || '',
                    userName: item.USER_NAME
                };
            }));
        });
    };

    config.select = function(event, ui) {
        $('#sharedUserKeyword').val(ui.item.userName);
        $('#sharedUserId').val(ui.item.userId);
        $('#sharedUserName').val(ui.item.userName);
        $('#sharedUserDept').val(ui.item.deptName);
        $('#sharedUserTeam').val(ui.item.teamName);
    };

    config.focus = function(event, ui) {
        return false;
    };

    objKeyWord.autocomplete(config);
};

// ✅ sharedUserClass - 사용자 팝업 로직 모듈
var sharedUserClass = (function () {
    var _callback = null;
    var _userList = [];

    function open(callback, initUserList = []) {
        _callback = callback;
        _userList = [...initUserList];
        $('#sharedUserKeyword').val('');
        $('#sharedUserList').empty();
        renderList();
        $('#sharedUserDialog').show();
    }

    function close() {
        $('#sharedUserDialog').hide();
        _callback = null;
        _userList = [];
    }

    function add() {
        const userId = $.trim($('#sharedUserId').val());
        const userName = $.trim($('#sharedUserName').val());
        const deptName = $.trim($('#sharedUserDept').val());
        const teamName = $.trim($('#sharedUserTeam').val());

        if (fn2.isEmpty(userId)) {
            alert("사용자를 선택해주세요.");
            return;
        }

        const exists = _userList.some(u => u.userId === userId);
        if (exists) {
            alert("이미 추가된 사용자입니다.");
            clearFields();
            return;
        }

        _userList.push({ userId, userName, deptName, teamName });
        renderList();
        clearFields();
    }

    function renderList() {
        const $ul = $('#sharedUserList');
        $ul.empty();
        _userList.forEach((u, idx) => {
            var html = 
                '<li style="display: flex; justify-content: space-between; align-items: center;">' +
                    '<div>' + u.userName + ' / ' + u.userId + ' / ' + u.deptName + ' / ' + u.teamName + '</div>' +
                    '<button class="btn_small02 ml5" onclick="sharedUserClass.remove(' + idx + ')">삭제</button>' +
                '</li>';
            $ul.append(html);
        });
    }

    function remove(index) {
        _userList.splice(index, 1);
        renderList();
    }

    function clearFields() {
        $('#sharedUserKeyword').val('');
        $('#sharedUserId').val('');
        $('#sharedUserName').val('');
        $('#sharedUserDept').val('');
        $('#sharedUserTeam').val('');
    }

    function submit() {
	    if (_userList.length === 0) {
	        alert("공동 참여자를 한 명 이상 선택해주세요.");
	        return;
	    }
	    if (_callback) {
	        const userIds = _userList.map(u => u.userId);
	        const userNames = _userList.map(u => u.userName);
	        const userDepts = _userList.map(u => u.deptName);
	        const userTeams = _userList.map(u => u.teamName);
	        _callback({ userIds, userNames, userDepts, userTeams }); // ✅ 확장
	    }
	    close();
	}
	
	function setList(list) {
	    _userList = list || [];
	    renderList();
	}

    return {
        open,
        add,
        remove,
        submit,
        close,
        setList
    };
})();

// ✅ 사용자 토큰 관리 및 팝업 통합 클래스
var userSearchClass = new Object();

userSearchClass.open = function(callback) {
    const userIds = $('#sharedUserIds').val().split(',').filter(id => id);
    const userNames = $('#sharedUserNames').val().split(',');
    const userDepts = $('#sharedUserDepts').val().split(',');
    const userTeams = $('#sharedUserTeams').val().split(',');

    const userList = userIds.map((id, i) => ({
        userId: id,
        userName: userNames[i],
        deptName: userDepts[i] || '',
        teamName: userTeams[i] || ''
    }));

    sharedUserClass.open(callback, userList);
};

userSearchClass.close = function() {
    sharedUserClass.close();
};
userSearchClass.submit = function() {
    sharedUserClass.submit();
};

userSearchClass.openSharedUserPopup = function() {
    userSearchClass.open(userSearchClass.handlePopupResult);
};

userSearchClass.handlePopupResult = function(result) {
    const userList = result.userIds.map((id, i) => ({
        userId: id,
        userName: result.userNames[i],
        deptName: result.userDepts ? result.userDepts[i] : '',     // ← 부서명
        teamName: result.userTeams ? result.userTeams[i] : ''      // ← 팀명
    }));

    userSearchClass.renderTokenList(userList);

    // 리스트에도 초기값 반영
    sharedUserClass.setList(userList); // ✅ 이 함수 추가 필요
};

userSearchClass.addToken = function(userId, userName) {
    const token = document.createElement('span');
    token.className = 'user-token';
    token.innerHTML = userName + ' <span class="token-close" data-user-id="' + userId + '">&times;</span>';
    token.style = "display: flex; align-items: center; background: #e0e0e0; border-radius: 12px; padding: 4px 8px; margin-right: 5px; font-size: 13px;";

    token.querySelector('.token-close').addEventListener('click', function () {
        token.remove();
        userSearchClass.removeSharedUser(userId);
    });

    document.getElementById('sharedUserTokens').appendChild(token);
};

userSearchClass.renderTokenList = function(userList) {
    $('#sharedUserTokens').empty();

    const ids = userList.map(u => u.userId);
    const names = userList.map(u => u.userName);
	const depts = userList.map(u => u.deptName);
	const teams = userList.map(u => u.teamName);
	
	$('#sharedUserDepts').val(depts.join(','));
	$('#sharedUserTeams').val(teams.join(','));
    $('#sharedUserIds').val(ids.join(','));
    $('#sharedUserNames').val(names.join(','));

    userList.forEach(u => userSearchClass.addToken(u.userId, u.userName));
};

userSearchClass.removeSharedUser = function(userId) {
    const ids = $('#sharedUserIds').val().split(',').filter(id => id !== userId);
    const names = $('#sharedUserNames').val().split(',');
    const idx = $('#sharedUserIds').val().split(',').indexOf(userId);
    if (idx !== -1) names.splice(idx, 1);

    $('#sharedUserIds').val(ids.join(','));
    $('#sharedUserNames').val(names.join(','));
};

userSearchClass.clearTokens = function () {
    $('#sharedUserTokens').empty();
    $('#sharedUserIds').val('');
    $('#sharedUserNames').val('');
};
