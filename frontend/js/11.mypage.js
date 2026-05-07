// 페이지 로드 시 모든 초기화 작업 수행
window.onload = function() {
    const isLoggedIn = localStorage.getItem('isLoggedIn');
    const userName = localStorage.getItem('userName');

    // 1. 보안 체크: 로그인 데이터가 없으면 메인으로 리다이렉트
    if (!isLoggedIn || !userName) {
        alert("로그인이 필요한 페이지입니다.");
        location.href = '1.main.html';
        return; // 이후 코드 실행 방지
    }

    // 2. 로그인 상태에 따라 헤더 UI 변경
    checkLoginStatus(userName);

    // 3. 마이페이지 본문에 사용자 이름 반영
    displayUserName(userName);
};

// 헤더의 로그인/로그아웃 버튼 관리 함수
function checkLoginStatus(name) {
    const authMenu = document.getElementById('auth-menu');
    if (authMenu) {
        authMenu.innerHTML = `
            <a href="11.mypage.html" style="margin-right:15px; color:#333; text-decoration:none;">마이페이지</a>
            <span style="margin-right:15px; color:#333; font-weight:bold;">${name}님</span>
            <a href="javascript:void(0)" class="login-btn" onclick="handleLogout()">로그아웃</a>
        `;
    }
}

// 본문 내 사용자 이름 표시 함수
function displayUserName(name) {
    const nameDisplay = document.getElementById('user-name-display');
    if (nameDisplay) {
        nameDisplay.innerText = name;
    }
}

// 로그아웃 처리 함수
function handleLogout() {
    if(confirm("로그아웃 하시겠습니까?")) {
        localStorage.removeItem('isLoggedIn');
        localStorage.removeItem('userName');
        alert("로그아웃 되었습니다.");
        location.href = '1.main.html';
    }
}

// 로그인 팝업 함수 (혹시 비로그인 상태에서 버튼이 노출될 경우 대비)
function openLoginWindow() {
    const width = 450; 
    const height = 620;
    const left = (window.screen.width / 2) - (width / 2);
    const top = (window.screen.height / 2) - (height / 2);
    
    window.open('4.login.html', 'ESS_Login', 
        `width=${width}, height=${height}, left=${left}, top=${top}, resizable=no, scrollbars=no`);
}
