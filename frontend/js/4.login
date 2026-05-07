
        // 1. 탭 전환 기능
        function selectType(type) {
            const tabs = document.querySelectorAll('.tab-btn');
            tabs.forEach(tab => tab.classList.remove('active'));
            
            if(type === 'user') {
                tabs[0].classList.add('active');
                console.log("개인용 로그인 모드");
            } else {
                tabs[1].classList.add('active');
                console.log("기업용 로그인 모드");
            }
        }

        // 2. 로그인 처리 기능 (selectType 밖으로 분리)
        function handleLoginSubmit(event) {
            // 폼 제출 시 페이지가 새로고침되는 것을 방지
            event.preventDefault(); 
            
            // 실제 서비스에서는 입력값을 검증하지만, 여기서는 가상 성공 처리
            localStorage.setItem('isLoggedIn', 'true');
            localStorage.setItem('userName', '홍길동'); // 테스트용 이름 저장
            
            alert("로그인 되었습니다!");
            
            // 부모 창(1.main.html 등)이 존재하면 새로고침하여 로그인 상태 반영
            if (window.opener && !window.opener.closed) {
                window.opener.location.reload();
            }
            
            // 현재 로그인 팝업 창 닫기
            window.close();
        }
