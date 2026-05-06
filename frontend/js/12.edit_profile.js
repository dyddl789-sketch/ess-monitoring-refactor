window.onload = function() {
    // 1. 기존 데이터 불러오기
    const currentName = localStorage.getItem('userName');
    const currentEmail = localStorage.getItem('userEmail') || ''; // 저장된 게 없다면 빈칸
    const currentPhone = localStorage.getItem('userPhone') || '';

    // 2. 입력란에 미리 채워넣기
    document.getElementById('editName').value = currentName;
    document.getElementById('editEmail').value = currentEmail;
    document.getElementById('editPhone').value = currentPhone;
};

// 3. 수정 완료 처리
// 폼 제출 이벤트가 발생했을 때 실행
document.getElementById('editForm').onsubmit = function(e) {
    e.preventDefault(); // 1. 폼 제출 시 페이지가 바로 새로고침되는 것을 방지

    // 입력값 가져오기
    const newName = document.getElementById('editName').value;
    const newEmail = document.getElementById('editEmail').value;
    const newPhone = document.getElementById('editPhone').value;

    if (confirm("정보를 수정하시겠습니까?")) {
        // 2. localStorage에 데이터 저장
        localStorage.setItem('userName', newName);
        localStorage.setItem('userEmail', newEmail);
        localStorage.setItem('userPhone', newPhone);

        alert("회원 정보가 성공적으로 수정되었습니다.");

        // 3. 11.mypage.html로 페이지 이동 (이 코드가 핵심입니다!)
        location.href = '11.mypage.html'; 
    }
};
